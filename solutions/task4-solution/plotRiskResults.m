function figureHandles = plotRiskResults(analysisData)
%plotRiskResults - Create market risk result figures
%   figureHandles = plotRiskResults(analysisData) creates figures for
%   filtered residuals, simulated returns, and tail-event samples.
%
%   See also tiledlayout, scatter

arguments
    analysisData (1,1) struct
end

figureHandles = gobjects(3, 1);

figureHandles(1) = figure;
layout = tiledlayout(figureHandles(1), 2, 1);

nexttile(layout)
plot(analysisData.dates, analysisData.residuals(:, 1))
datetick("x")
xlabel("Date")
ylabel("Residual")
title("Filtered Residuals")

nexttile(layout)
plot(analysisData.dates, sqrt(analysisData.variances(:, 1)))
datetick("x")
xlabel("Date")
ylabel("Volatility")
title("Filtered Conditional Standard Deviations")

figureHandles(2) = figure;
plot(analysisData.dates(end-20:end), analysisData.returns(end-20:end, 1), ...
    "LineWidth", 1)
datetick("x")
hold on
numSimsToPlot = 10;
for simulationNumber = 1:min(numSimsToPlot, analysisData.trialSize)
    futureDateNumbers = analysisData.dates(end) + ...
        (0:analysisData.horizon)';
    plot(futureDateNumbers, [analysisData.returns(end, 1); ...
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
