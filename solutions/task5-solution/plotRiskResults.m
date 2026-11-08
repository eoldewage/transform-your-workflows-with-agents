function figureHandles = plotRiskResults(analysisData, options)
%plotRiskResults - Create market risk result figures
%   figureHandles = plotRiskResults(analysisData) creates figures for
%   filtered residuals, simulated returns, and tail-event samples.
%
%   axesHandles = plotRiskResults(...,TargetAxes=AXES) draws the four
%   plots into AXES instead of creating standalone figures.
%
%   See also tiledlayout, scatter

arguments
    analysisData (1,1) struct
    options.TargetAxes = []
end

if ~isempty(options.TargetAxes)
    figureHandles = options.TargetAxes;
    plotDashboard(analysisData, figureHandles)
    return
end

figureHandles = gobjects(3, 1);
displayDates = datetime(analysisData.dates, ConvertFrom="datenum");

figureHandles(1) = figure;
layout = tiledlayout(figureHandles(1), 2, 1);

nexttile(layout)
plot(displayDates, analysisData.residuals(:, 1))
xtickformat("dd-MMM-yyyy")
xlabel("Date")
ylabel("Residual")
title("Filtered Residuals")

nexttile(layout)
plot(displayDates, sqrt(analysisData.variances(:, 1)))
xtickformat("dd-MMM-yyyy")
xlabel("Date")
ylabel("Volatility")
title("Filtered Conditional Standard Deviations")

figureHandles(2) = figure;
plot(displayDates(end-20:end), analysisData.returns(end-20:end, 1), ...
    "LineWidth", 1)
xtickformat("dd-MMM-yyyy")
hold on
numSimsToPlot = 10;
for simulationNumber = 1:min(numSimsToPlot, analysisData.trialSize)
    futureDates = displayDates(end) + caldays(0:analysisData.horizon)';
    plot(futureDates, [analysisData.returns(end, 1); ...
        analysisData.simulatedReturns(:, simulationNumber, 1)])
end
title("Simulated returns for " + analysisData.series(1))
ylabel("Returns")
hold off

figureHandles(3) = figure;
% The workshop visualization displays the first two selected series.
scatter(analysisData.tailRisk.plotReturns( ...
    ~analysisData.tailRisk.plotSamples, 1), ...
    analysisData.tailRisk.plotReturns( ...
    ~analysisData.tailRisk.plotSamples, 2), "b.")
hold on
scatter(analysisData.tailRisk.plotReturns( ...
    analysisData.tailRisk.plotSamples, 1), ...
    analysisData.tailRisk.plotReturns( ...
    analysisData.tailRisk.plotSamples, 2), "r.")
xline(analysisData.tailRisk.threshold, "k--")
yline(analysisData.tailRisk.threshold, "k--")
xlabel(analysisData.series(1) + " returns")
ylabel(analysisData.series(2) + " returns")
title("Tail Event Sample")
hold off
end

function plotDashboard(analysisData, axesHandles)
if numel(axesHandles) ~= 4 || ~all(isgraphics(axesHandles))
    error("plotRiskResults:InvalidTargetAxes", ...
        "TargetAxes must contain four valid axes.")
end

axesHandles = reshape(axesHandles, 1, []);
displayDates = datetime(analysisData.dates, ConvertFrom="datenum");
for axesHandle = axesHandles
    cla(axesHandle)
end

plot(axesHandles(1), displayDates, analysisData.residuals(:, 1))
formatDateAxis(axesHandles(1))
xlabel(axesHandles(1), "Date")
ylabel(axesHandles(1), "Residual")
title(axesHandles(1), "Filtered Residuals")

plot(axesHandles(2), displayDates, sqrt(analysisData.variances(:, 1)))
formatDateAxis(axesHandles(2))
xlabel(axesHandles(2), "Date")
ylabel(axesHandles(2), "Volatility")
title(axesHandles(2), "Filtered Conditional Standard Deviations")

plot(axesHandles(3), displayDates(end-20:end), ...
    analysisData.returns(end-20:end, 1), "LineWidth", 1)
hold(axesHandles(3), "on")
numSimsToPlot = 10;
for simulationNumber = 1:min(numSimsToPlot, analysisData.trialSize)
    futureDates = displayDates(end) + caldays(0:analysisData.horizon)';
    plot(axesHandles(3), futureDates, ...
        [analysisData.returns(end, 1); ...
        analysisData.simulatedReturns(:, simulationNumber, 1)])
end
title(axesHandles(3), "Simulated returns for " + analysisData.series(1))
xlabel(axesHandles(3), "Date")
ylabel(axesHandles(3), "Returns")
formatDateAxis(axesHandles(3))
hold(axesHandles(3), "off")

scatter(axesHandles(4), analysisData.tailRisk.plotReturns( ...
    ~analysisData.tailRisk.plotSamples, 1), ...
    analysisData.tailRisk.plotReturns( ...
    ~analysisData.tailRisk.plotSamples, 2), "b.")
hold(axesHandles(4), "on")
scatter(axesHandles(4), analysisData.tailRisk.plotReturns( ...
    analysisData.tailRisk.plotSamples, 1), ...
    analysisData.tailRisk.plotReturns( ...
    analysisData.tailRisk.plotSamples, 2), "r.")
xline(axesHandles(4), analysisData.tailRisk.threshold, "k--")
yline(axesHandles(4), analysisData.tailRisk.threshold, "k--")
xlabel(axesHandles(4), analysisData.series(1) + " returns")
ylabel(axesHandles(4), analysisData.series(2) + " returns")
title(axesHandles(4), "Tail Event Sample")
hold(axesHandles(4), "off")
end

function formatDateAxis(axesHandle)
xtickformat(axesHandle, "dd-MMM-yyyy")
end
