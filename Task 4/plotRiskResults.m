function figures = plotRiskResults(dates, series, data, returns, residuals, ...
    variances, simulatedReturns, tailRisk, options)
%PLOTRISKRESULTS Plot fitted residuals, simulations, and tail events.

arguments
    dates (:, 1) double
    series
    data (:, :) double
    returns (:, :) double
    residuals (:, :) double
    variances (:, :) double
    simulatedReturns (:, :, :) double
    tailRisk (1, 1) struct
    options.NumSimulationsToPlot (1, 1) double {mustBeInteger, mustBePositive} = 10
end

figures = gobjects(4, 1);

figures(1) = figure;
plot(dates, ret2price(price2ret(data)))
datetick("x")
xlabel("Date")
ylabel("Index Value")
title("Relative Daily Index Closings")
legend(series, Location="northwest")

figures(2) = figure;
tiledlayout(2, 1)

nexttile
plot(dates(2:end), residuals(:, 1))
datetick("x")
xlabel("Date")
ylabel("Residual")
title("Filtered Residuals")

nexttile
plot(dates(2:end), sqrt(variances(:, 1)))
datetick("x")
xlabel("Date")
ylabel("Volatility")
title("Filtered Conditional Standard Deviations")

figures(3) = figure;
plot(dates(end-20:end), returns(end-20:end, 1), "LineWidth", 1)
datetick("x")
hold on
for simulationNumber = 1:min(options.NumSimulationsToPlot, size(simulatedReturns, 2))
    futureDateNumbers = dates(end) + (0:size(simulatedReturns, 1))';
    plot(futureDateNumbers, [returns(end, 1); simulatedReturns(:, simulationNumber, 1)])
end
title("Simulated returns for " + series(1))
ylabel("Returns")
hold off

figures(4) = figure;
scatter(tailRisk.PlotReturns(~tailRisk.PlotSamples, 1), ...
    tailRisk.PlotReturns(~tailRisk.PlotSamples, 2), "b.")
hold on
scatter(tailRisk.PlotReturns(tailRisk.PlotSamples, 1), ...
    tailRisk.PlotReturns(tailRisk.PlotSamples, 2), "r.")
xline(tailRisk.Threshold, "k--")
yline(tailRisk.Threshold, "k--")
xlabel(series(1) + " returns")
ylabel(series(2) + " returns")
title("Tail Event Sample")
hold off
end
