%% Plot market risk results
% Plotting script expects variables from runMarketRiskAnalysis.

figure
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

figure
plot(dates(end-20:end), returns(end-20:end, 1), "LineWidth", 1)
datetick("x")
hold on
numSimsToPlot = 10;
for simulationNumber = 1:min(numSimsToPlot, trialSize)
    futureDateNumbers = dates(end) + (0:horizon)';
    plot(futureDateNumbers, [returns(end, 1); simulatedReturns(:, simulationNumber, 1)])
end
title("Simulated returns for " + series(1))
ylabel("Returns")
hold off

figure
scatter(tailPlotReturns(~tailPlotSamples, 1), tailPlotReturns(~tailPlotSamples, 2), "b.")
hold on
scatter(tailPlotReturns(tailPlotSamples, 1), tailPlotReturns(tailPlotSamples, 2), "r.")
xline(threshold, "k--")
yline(threshold, "k--")
xlabel(series(1) + " returns")
ylabel(series(2) + " returns")
title("Tail Event Sample")
hold off
