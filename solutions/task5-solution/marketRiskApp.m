function app = marketRiskApp(options)
%marketRiskApp - Interactively compare simulated market-risk results.
%   app = marketRiskApp opens a dashboard for choosing two market series.
%   Changing either series updates the analysis. Edit simulation settings
%   and press Regenerate to apply them.

arguments
    options.AnalysisRunner (1,1) function_handle = @runSelectedAnalysis
end

catalog = createCatalog();
labels = string({catalog.Label});
activeSettings = defaultSettings();

app.Figure = uifigure(Name="Market Risk Dashboard", ...
    Position=[100, 100, 1280, 720]);
rootLayout = uigridlayout(app.Figure, [1, 2]);
rootLayout.ColumnWidth = {260, "1x"};
rootLayout.Padding = [10, 10, 10, 10];

controls = uigridlayout(rootLayout, [12, 1]);
controls.RowHeight = {22, 30, 22, 30, 22, 30, 22, 30, 22, 30, 30, "1x"};

uilabel(controls, Text="First market series");
app.FirstSeries = uidropdown(controls, Items=labels(labels ~= "Asia — HK"), ...
    Value="Global — FTSE", ValueChangedFcn=@seriesChanged);
uilabel(controls, Text="Second market series");
app.SecondSeries = uidropdown(controls, Items=labels(labels ~= "Global — FTSE"), ...
    Value="Asia — HK", ValueChangedFcn=@seriesChanged);
uilabel(controls, Text="Simulation paths");
app.PathCount = uieditfield(controls, "numeric", Value=activeSettings.TrialSize, ...
    Limits=[1, Inf], ValueChangedFcn=@settingsChanged);
uilabel(controls, Text="Horizon (days)");
app.Horizon = uieditfield(controls, "numeric", Value=activeSettings.Horizon, ...
    Limits=[1, Inf], ValueChangedFcn=@settingsChanged);
uilabel(controls, Text="Tail threshold");
app.Threshold = uieditfield(controls, "numeric", Value=activeSettings.Threshold, ...
    Limits=[-Inf, -eps], ValueChangedFcn=@settingsChanged);
app.RegenerateButton = uibutton(controls, Text="Regenerate", ...
    ButtonPushedFcn=@regenerate);
app.Status = uilabel(controls, Text="Starting analysis", ...
    HorizontalAlignment="center", WordWrap="on");

chartLayout = uigridlayout(rootLayout, [2, 2]);
app.Axes = [uiaxes(chartLayout), uiaxes(chartLayout), ...
    uiaxes(chartLayout), uiaxes(chartLayout)];
updateAnalysis()

    function seriesChanged(~, ~)
        updateSelectorItems()
        updateAnalysis()
    end

    function settingsChanged(~, ~)
        app.Status.Text = "Settings pending — press Regenerate";
    end

    function regenerate(~, ~)
        activeSettings = readSettings();
        updateAnalysis()
    end

    function updateSelectorItems()
        firstValue = string(app.FirstSeries.Value);
        secondValue = string(app.SecondSeries.Value);
        app.FirstSeries.Items = labels(labels ~= secondValue);
        app.SecondSeries.Items = labels(labels ~= firstValue);
    end

    function updateAnalysis()
        app.Status.Text = "Analysing selected markets...";
        drawnow

        try
            selections = selectedCatalogEntries();
            analysisData = options.AnalysisRunner(selections, activeSettings);
            plotRiskResults(analysisData, TargetAxes=app.Axes);
            app.Status.Text = "Analysis complete";
        catch exception
            app.Status.Text = "Analysis failed";
            uialert(app.Figure, exception.message, "Analysis failed");
        end
    end

    function selections = selectedCatalogEntries()
        selectedLabels = [string(app.FirstSeries.Value), ...
            string(app.SecondSeries.Value)];
        selectedIndices = arrayfun(@(label) find(labels == label, 1), ...
            selectedLabels);
        selections = catalog(selectedIndices);
    end

    function settings = readSettings()
        settings = struct( ...
            TrialSize=app.PathCount.Value, ...
            Horizon=app.Horizon.Value, ...
            Threshold=app.Threshold.Value);
    end
end

function catalog = createCatalog()
globalNames = ["TSX", "CAC", "DAX", "NIK", "FTSE", "SP"];
asianNames = ["HK", "AUS", "SGP", "JPN", "CHN", "KOR", "IND", "TWN", ...
    "MYS", "PHL", "THA", "IDN"];

catalog = repmat(struct( ...
    Label="", SourceFile="", SeriesName="", SheetName=""), ...
    1, numel(globalNames) + numel(asianNames));

for index = 1:numel(globalNames)
    catalog(index) = struct( ...
        Label="Global — " + globalNames(index), ...
        SourceFile="Data_GlobalIdx1.mat", ...
        SeriesName=globalNames(index), SheetName="");
end

for index = 1:numel(asianNames)
    catalog(numel(globalNames) + index) = struct( ...
        Label="Asia — " + asianNames(index), ...
        SourceFile="AsianIndexReturns.xlsx", ...
        SeriesName=asianNames(index), SheetName=asianNames(index));
end
end

function settings = defaultSettings()
settings = struct(TrialSize=200, Horizon=22, Threshold=-0.03);
end

function analysisData = runSelectedAnalysis(selections, settings)
sourceFiles = string({selections.SourceFile});
seriesNames = string({selections.SeriesName});
sheetNames = string({selections.SheetName});
[returns, dates, series] = importMarketData( ...
    SourceFiles=sourceFiles, SeriesNames=seriesNames, SheetNames=sheetNames);

model = arima(AR=NaN, Distribution="t", Variance=gjr(1, 1));
numIndices = size(returns, 2);
numObservations = size(returns, 1);
residuals = NaN(numObservations, numIndices);
variances = NaN(numObservations, numIndices);
fittedModels = cell(numIndices, 1);

fitOptions = optimoptions(@fmincon, Display="off", Diagnostics="off", ...
    Algorithm="sqp", TolCon=1e-7);
for assetNumber = 1:numIndices
    fittedModels{assetNumber} = estimate(model, returns(:, assetNumber), ...
        Display="off", Options=fitOptions);
    [residuals(:, assetNumber), variances(:, assetNumber)] = infer( ...
        fittedModels{assetNumber}, returns(:, assetNumber));
end

residuals = residuals ./ sqrt(variances);
distributions = cell(numIndices, 1);
uniformValues = zeros(size(residuals));
for assetNumber = 1:numIndices
    distributions{assetNumber} = fitdist( ...
        residuals(:, assetNumber), "tLocationScale");
    uniformValues(:, assetNumber) = cdf( ...
        distributions{assetNumber}, residuals(:, assetNumber));
end

[correlation, degreesOfFreedom] = copulafit("t", uniformValues, ...
    Method="approximateml");
modelData = struct( ...
    copulaCorrelation=correlation, ...
    copulaDegreesOfFreedom=degreesOfFreedom, ...
    distributions={distributions}, ...
    fittedModels={fittedModels}, ...
    returns=returns, ...
    residuals=residuals, ...
    variances=variances);

simulatedReturns = simulateMarketReturns( ...
    modelData, settings.TrialSize, settings.Horizon);
tailRisk = analyzeTailRisk(modelData, Threshold=settings.Threshold, ...
    TrialSize=settings.TrialSize, Horizon=settings.Horizon);
analysisData = struct( ...
    dates=dates, ...
    series=series, ...
    returns=returns, ...
    residuals=residuals, ...
    variances=variances, ...
    trialSize=settings.TrialSize, ...
    horizon=settings.Horizon, ...
    simulatedReturns=simulatedReturns, ...
    tailRisk=tailRisk);
end
