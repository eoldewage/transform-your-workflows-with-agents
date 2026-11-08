%% Plot market risk results
% Plotting script expects variables from runMarketRiskAnalysis.

figure
tiledlayout(2, 1)

nexttile
plot(dates, residuals(:, 1))
datetick("x")
xlabel("Date")
ylabel("Residual")
title("Filtered Residuals")

nexttile
plot(dates, sqrt(variances(:, 1)))
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
% The workshop visualization displays the first two selected series.
scatter(tailRisk.plotReturns(~tailRisk.plotSamples, 1), ...
    tailRisk.plotReturns(~tailRisk.plotSamples, 2), "b.")
hold on
scatter(tailRisk.plotReturns(tailRisk.plotSamples, 1), ...
    tailRisk.plotReturns(tailRisk.plotSamples, 2), "r.")
xline(tailRisk.threshold, "k--")
yline(tailRisk.threshold, "k--")
xlabel(series(1) + " returns")
ylabel(series(2) + " returns")
title("Tail Event Sample")
hold off
