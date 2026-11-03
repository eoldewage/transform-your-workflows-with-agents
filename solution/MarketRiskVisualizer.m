classdef MarketRiskVisualizer < handle
    %MARKETRISKVISUALIZER Compare a global index with HK market returns.

    properties (Access = private)
        Figure
        GlobalIndexDropDown
        ComparisonIndexDropDown
        HorizonField
        SimulationTrialsField
        TailThresholdField
        TailTrialSizeField
        TailTrialsField
        PathsToPlotField
        RunButton
        StatusLabel
        PriceAxes
        ResidualAxes
        VolatilityAxes
        SimulationAxes
        TailAxes
        GlobalData
        AsianDates
        AsianReturns
        Colors
    end

    methods
        function app = MarketRiskVisualizer
            %MARKETRISKVISUALIZER Create and show the market risk app.
            app.loadInputData();
            app.Colors = lines(2);
            app.createComponents();
        end
    end

    methods (Access = private)
        function loadInputData(app)
            globalSourceFile = app.resolveBundledSource("Data_GlobalIdx1.mat");
            asianSourceFile = app.resolveBundledSource("AsianIndexReturns.xlsx");
            app.GlobalData = load(globalSourceFile);
            asianData = readtable(asianSourceFile);

            if ~ismember("HK", string(asianData.Properties.VariableNames))
                error("MarketRiskVisualizer:MissingHKSeries", ...
                    "AsianIndexReturns.xlsx must contain an HK column.")
            end

            app.AsianDates = asianData.Time;
            app.AsianReturns = asianData.HK ./ 100;
        end

        function sourceFile = resolveBundledSource(~, sourceFile)
            if isdeployed
                sourceFile = fullfile(ctfroot, sourceFile);
            end
        end

        function createComponents(app)
            app.Figure = uifigure( ...
                Name="Market Risk Visualizer", ...
                Position=[100 100 1400 820], ...
                CloseRequestFcn=@(~, ~)app.closeApp());

            rootGrid = uigridlayout(app.Figure, [2 2]);
            rootGrid.RowHeight = {"1x", "fit"};
            rootGrid.ColumnWidth = {250, "1x"};
            rootGrid.Padding = [8 8 8 8];
            rootGrid.ColumnSpacing = 8;
            rootGrid.RowSpacing = 6;

            app.createControlPanel(rootGrid);
            app.createPlotPanels(rootGrid);

            app.StatusLabel = uilabel(rootGrid, ...
                Text="Choose a global index and click Run Analysis.", ...
                FontAngle="italic");
            app.StatusLabel.Layout.Row = 2;
            app.StatusLabel.Layout.Column = [1 2];
        end

        function createControlPanel(app, rootGrid)
            controlPanel = uipanel(rootGrid, Title="Analysis controls");
            controlPanel.Layout.Row = 1;
            controlPanel.Layout.Column = 1;

            controlGrid = uigridlayout(controlPanel, [18 1]);
            controlGrid.RowHeight = repmat({"fit"}, 1, 18);
            controlGrid.Padding = [10 10 10 10];
            controlGrid.RowSpacing = 5;

            uilabel(controlGrid, Text="First global index");
            series = string(app.GlobalData.series);
            app.GlobalIndexDropDown = uidropdown(controlGrid, ...
                Items=cellstr(series), Value=app.defaultSeries(series), ...
                ValueChangedFcn=@(~, ~)app.markSettingsChanged());

            uilabel(controlGrid, Text="Comparison series");
            app.ComparisonIndexDropDown = uidropdown(controlGrid, ...
                Items=[series, "HK (returns)"], ...
                Value="HK (returns)", ...
                ValueChangedFcn=@(~, ~)app.markSettingsChanged());

            parameterLabel = uilabel(controlGrid, Text="Simulation parameters");
            parameterLabel.FontWeight = "bold";

            app.HorizonField = app.addNumericField(controlGrid, ...
                "Forecast horizon (days)", 22);
            app.SimulationTrialsField = app.addNumericField(controlGrid, ...
                "Simulation trials", 200);
            app.TailThresholdField = app.addNumericField(controlGrid, ...
                "Tail threshold (decimal return)", -0.03);
            app.TailTrialSizeField = app.addNumericField(controlGrid, ...
                "Tail trial size", 1000);
            app.TailTrialsField = app.addNumericField(controlGrid, ...
                "Number of tail trials", 5);
            app.PathsToPlotField = app.addNumericField(controlGrid, ...
                "Simulation paths to show", 10);

            app.RunButton = uibutton(controlGrid, "push", ...
                Text="Analyze", ...
                BackgroundColor=[0.20 0.55 0.30], ...
                FontColor="white", ...
                ButtonPushedFcn=@(~, ~)app.runAnalysis());
        end

        function field = addNumericField(app, parent, labelText, value)
            uilabel(parent, Text=labelText);
            field = uieditfield(parent, "numeric", Value=value, ...
                ValueChangedFcn=@(~, ~)app.markSettingsChanged());
        end

        function createPlotPanels(app, rootGrid)
            dashboardGrid = uigridlayout(rootGrid, [2 2]);
            dashboardGrid.Layout.Row = 1;
            dashboardGrid.Layout.Column = 2;
            dashboardGrid.RowHeight = {"1x", "1x"};
            dashboardGrid.ColumnWidth = {"1x", "1x"};
            dashboardGrid.Padding = [0 0 0 0];
            dashboardGrid.RowSpacing = 8;
            dashboardGrid.ColumnSpacing = 8;

            pricePanel = uipanel(dashboardGrid, Title="Relative daily values");
            priceGrid = uigridlayout(pricePanel, [1 1]);
            priceGrid.Padding = [4 4 4 4];
            app.PriceAxes = uiaxes(priceGrid);

            residualPanel = uipanel(dashboardGrid, ...
                Title="Filtered residuals and volatility");
            residualGrid = uigridlayout(residualPanel, [2 1]);
            residualGrid.RowHeight = {"1x", "1x"};
            residualGrid.Padding = [4 4 4 4];
            residualGrid.RowSpacing = 5;
            app.ResidualAxes = uiaxes(residualGrid);
            app.VolatilityAxes = uiaxes(residualGrid);

            simulationPanel = uipanel(dashboardGrid, ...
                Title="Simulated returns");
            simulationGrid = uigridlayout(simulationPanel, [1 1]);
            simulationGrid.Padding = [4 4 4 4];
            app.SimulationAxes = uiaxes(simulationGrid);

            tailPanel = uipanel(dashboardGrid, Title="Tail event sample");
            tailGrid = uigridlayout(tailPanel, [1 1]);
            tailGrid.Padding = [4 4 4 4];
            app.TailAxes = uiaxes(tailGrid);
        end

        function selectedSeries = defaultSeries(~, series)
            selectedSeries = series(contains(series, "CAC", IgnoreCase=true));
            if isempty(selectedSeries)
                selectedSeries = series(1);
            else
                selectedSeries = selectedSeries(1);
            end
        end

        function markSettingsChanged(app)
            app.StatusLabel.Text = "Settings changed. Click Analyze to update plots.";
        end

        function runAnalysis(app)
            try
                settings = app.getSettings();
                app.setBusy(true);
                cleanup = onCleanup(@()app.setBusy(false));
                drawnow

                [dates, returns, seriesNames] = app.prepareReturns();
                [modelResults, fitElapsedSeconds] = fitMarketRiskModels(returns);
                [correlation, degreesOfFreedom] = copulafit("t", ...
                    modelResults.UniformResiduals, Method="approximateml");
                simulatedReturns = simulateMarketReturns( ...
                    settings.SimulationTrials, settings.Horizon, correlation, ...
                    degreesOfFreedom, modelResults.ResidualDistributions, ...
                    modelResults.Fit, returns, modelResults.Residuals, ...
                    modelResults.Variances);
                tailRisk = analyzeTailRisk(correlation, degreesOfFreedom, ...
                    modelResults.ResidualDistributions, modelResults.Fit, ...
                    returns, modelResults.Residuals, modelResults.Variances, ...
                    Threshold=settings.TailThreshold, ...
                    TrialSize=settings.TailTrialSize, ...
                    NumTrials=settings.TailTrials);

                app.plotResults(dates, returns, seriesNames, modelResults, ...
                    simulatedReturns, tailRisk, settings.PathsToPlot);
                app.StatusLabel.Text = sprintf( ...
                    "Completed: fit %.2f s; %d tail events.", ...
                    fitElapsedSeconds, tailRisk.EventCount);
            catch exception
                app.StatusLabel.Text = "Analysis failed: " + string(exception.message);
            end
        end

        function settings = getSettings(app)
            settings = struct( ...
                Horizon=app.requirePositiveInteger(app.HorizonField.Value, ...
                    "Forecast horizon"), ...
                SimulationTrials=app.requirePositiveInteger( ...
                    app.SimulationTrialsField.Value, "Simulation trials"), ...
                TailThreshold=app.requireFiniteScalar( ...
                    app.TailThresholdField.Value, "Tail threshold"), ...
                TailTrialSize=app.requirePositiveInteger( ...
                    app.TailTrialSizeField.Value, "Tail trial size"), ...
                TailTrials=app.requirePositiveInteger( ...
                    app.TailTrialsField.Value, "Number of tail trials"), ...
                PathsToPlot=app.requirePositiveInteger( ...
                    app.PathsToPlotField.Value, "Simulation paths to show"));
        end

        function value = requirePositiveInteger(~, value, name)
            if ~isscalar(value) || ~isfinite(value) || value <= 0 || ...
                    value ~= round(value)
                error("MarketRiskVisualizer:InvalidSetting", ...
                    "%s must be a positive integer.", name)
            end
        end

        function value = requireFiniteScalar(~, value, name)
            if ~isscalar(value) || ~isfinite(value)
                error("MarketRiskVisualizer:InvalidSetting", ...
                    "%s must be a finite scalar.", name)
            end
        end

        function [commonDates, returns, seriesNames] = prepareReturns(app)
            [firstDates, firstReturns] = app.getReturnSeries( ...
                string(app.GlobalIndexDropDown.Value));
            [secondDates, secondReturns] = app.getReturnSeries( ...
                string(app.ComparisonIndexDropDown.Value));
            [commonDates, firstRows, secondRows] = intersect( ...
                firstDates, secondDates);
            if numel(commonDates) < 2
                error("MarketRiskVisualizer:InsufficientOverlap", ...
                    "The selected series have fewer than two dates in common.")
            end

            returns = [firstReturns(firstRows), secondReturns(secondRows)];
            seriesNames = [string(app.GlobalIndexDropDown.Value), ...
                string(app.ComparisonIndexDropDown.Value)];
            if seriesNames(1) == seriesNames(2)
                error("MarketRiskVisualizer:DuplicateSeries", ...
                    "Choose two different indices to compare.")
            end
        end

        function [dates, returns] = getReturnSeries(app, selectedSeries)
            if selectedSeries == "HK (returns)"
                dates = app.AsianDates;
                returns = app.AsianReturns;
                return
            end

            series = string(app.GlobalData.series);
            selectedIndex = find(series == selectedSeries, 1);
            if isempty(selectedIndex)
                error("MarketRiskVisualizer:UnknownSeries", ...
                    "The selected index is not available.")
            end
            dates = datetime(app.GlobalData.dates(2:end), ...
                ConvertFrom="datenum");
            returns = price2ret(app.GlobalData.Data(:, selectedIndex));
        end

        function plotResults(app, dates, returns, seriesNames, modelResults, ...
                simulatedReturns, tailRisk, pathsToPlot)
            app.plotRelativeValues(dates, returns, seriesNames);
            app.plotModelResults(dates, modelResults, seriesNames);
            app.plotSimulations(dates, returns, simulatedReturns, ...
                seriesNames, pathsToPlot);
            app.plotTailRisk(tailRisk, seriesNames);
        end

        function plotRelativeValues(app, dates, returns, seriesNames)
            cla(app.PriceAxes);
            relativeValues = exp(cumsum(returns, 1));
            plot(app.PriceAxes, dates, relativeValues, LineWidth=1.2);
            title(app.PriceAxes, "Relative Daily Index Values");
            xlabel(app.PriceAxes, "Date");
            ylabel(app.PriceAxes, "Relative value");
            legend(app.PriceAxes, seriesNames, Location="northwest");
            grid(app.PriceAxes, "on");
        end

        function plotModelResults(app, dates, modelResults, seriesNames)
            cla(app.ResidualAxes);
            plot(app.ResidualAxes, dates, modelResults.Residuals, ...
                LineWidth=1);
            title(app.ResidualAxes, "Filtered Residuals");
            xlabel(app.ResidualAxes, "Date");
            ylabel(app.ResidualAxes, "Residual");
            legend(app.ResidualAxes, seriesNames, Location="best");
            grid(app.ResidualAxes, "on");

            cla(app.VolatilityAxes);
            plot(app.VolatilityAxes, dates, sqrt(modelResults.Variances), ...
                LineWidth=1);
            title(app.VolatilityAxes, "Filtered Conditional Standard Deviations");
            xlabel(app.VolatilityAxes, "Date");
            ylabel(app.VolatilityAxes, "Volatility");
            legend(app.VolatilityAxes, seriesNames, Location="best");
            grid(app.VolatilityAxes, "on");
        end

        function plotSimulations(app, dates, returns, simulatedReturns, ...
                seriesNames, pathsToPlot)
            cla(app.SimulationAxes);
            historyLength = min(21, size(returns, 1));
            historyRows = size(returns, 1) - historyLength + 1:size(returns, 1);
            historyHandles = plot(app.SimulationAxes, dates(historyRows), ...
                returns(historyRows, :), LineWidth=1.5);
            hold(app.SimulationAxes, "on");

            futureDates = dates(end) + caldays(0:size(simulatedReturns, 1));
            numPaths = min(pathsToPlot, size(simulatedReturns, 2));
            for assetNumber = 1:size(simulatedReturns, 3)
                pathColor = 0.55 * app.Colors(assetNumber, :) + 0.45;
                for pathNumber = 1:numPaths
                    pathReturns = [returns(end, assetNumber); ...
                        simulatedReturns(:, pathNumber, assetNumber)];
                    plot(app.SimulationAxes, futureDates, pathReturns, ...
                        Color=pathColor, HandleVisibility="off");
                end
            end
            hold(app.SimulationAxes, "off");
            title(app.SimulationAxes, "Historical and Simulated Returns");
            xlabel(app.SimulationAxes, "Date");
            ylabel(app.SimulationAxes, "Return");
            legend(app.SimulationAxes, historyHandles, seriesNames, ...
                Location="best");
            grid(app.SimulationAxes, "on");
        end

        function plotTailRisk(app, tailRisk, seriesNames)
            cla(app.TailAxes);
            nonsamples = ~tailRisk.PlotSamples;
            scatter(app.TailAxes, tailRisk.PlotReturns(nonsamples, 1), ...
                tailRisk.PlotReturns(nonsamples, 2), 12, "b", ".");
            hold(app.TailAxes, "on");
            scatter(app.TailAxes, tailRisk.PlotReturns(tailRisk.PlotSamples, 1), ...
                tailRisk.PlotReturns(tailRisk.PlotSamples, 2), 16, "r", ".");
            xline(app.TailAxes, tailRisk.Threshold, "k--");
            yline(app.TailAxes, tailRisk.Threshold, "k--");
            hold(app.TailAxes, "off");
            title(app.TailAxes, "Tail Event Sample");
            xlabel(app.TailAxes, seriesNames(1) + " returns");
            ylabel(app.TailAxes, seriesNames(2) + " returns");
            grid(app.TailAxes, "on");
        end

        function setBusy(app, isBusy)
            if isBusy
                app.RunButton.Enable = "off";
                app.StatusLabel.Text = "Running market risk analysis...";
            else
                app.RunButton.Enable = "on";
            end
        end

        function closeApp(app)
            delete(app.Figure);
        end
    end
end
