function plotRiskResults(data, model, sim, tail, options)
%PLOTRISKRESULTS Plot fitted residuals, simulations, and tail samples.

arguments
    data (1, 1) struct
    model (1, 1) struct
    sim (1, 1) struct
    tail (1, 1) struct
    options.DiagnosticAssetIndex (1, 1) double {mustBeInteger, mustBePositive} = 1
    options.NumSimulationPaths (1, 1) double {mustBeInteger, mustBeNonnegative} = 10
    options.TailAssetPair (1, 2) double {mustBeInteger, mustBePositive} = [1 2]
end

if numel(data.ReturnDates) < 21
    error("plotRiskResults:ShortHistory", ...
        "At least 21 return observations are required to plot recent returns.");
end

diagnosticAsset = options.DiagnosticAssetIndex;
tailAssetPair = options.TailAssetPair;
if diagnosticAsset > size(data.Returns, 2)
    error("plotRiskResults:InvalidDiagnosticAsset", ...
        "DiagnosticAssetIndex exceeds the number of return series.");
end
if any(tailAssetPair > size(tail.PlotReturns, 2))
    error("plotRiskResults:InvalidTailAssetPair", ...
        "TailAssetPair contains an asset index beyond the tail return data.");
end

figure
plot(data.PriceDates, data.Prices)
datetick("x")
xlabel("Date")
ylabel("Index Value")
title("Relative Daily Index Closings")
legend(data.Series, Location="northwest")

figure
tiledlayout(2, 1)

nexttile
plot(data.ReturnDates, model.Residuals(:, diagnosticAsset))
datetick("x")
xlabel("Date")
ylabel("Residual")
title("Filtered Residuals")

nexttile
plot(data.ReturnDates, sqrt(model.Variances(:, diagnosticAsset)))
datetick("x")
xlabel("Date")
ylabel("Volatility")
title("Filtered Conditional Standard Deviations")

figure
plot(data.ReturnDates(end-20:end), ...
    data.Returns(end-20:end, diagnosticAsset), "LineWidth", 1)
datetick("x")
hold on
numSimsToPlot = options.NumSimulationPaths;
for simulationNumber = 1:min(numSimsToPlot, sim.TrialSize)
    futureDateNumbers = data.ReturnDates(end) + (0:sim.Horizon)';
    plot(futureDateNumbers, ...
        [data.Returns(end, diagnosticAsset); ...
        sim.Returns(:, simulationNumber, diagnosticAsset)])
end
title("Simulated returns for " + data.Series(diagnosticAsset))
ylabel("Returns")
hold off

figure
scatter(tail.PlotReturns(~tail.PlotSamples, tailAssetPair(1)), ...
    tail.PlotReturns(~tail.PlotSamples, tailAssetPair(2)), "b.")
hold on
scatter(tail.PlotReturns(tail.PlotSamples, tailAssetPair(1)), ...
    tail.PlotReturns(tail.PlotSamples, tailAssetPair(2)), "r.")
xline(tail.Threshold, "k--")
yline(tail.Threshold, "k--")
xlabel(data.Series(tailAssetPair(1)) + " returns")
ylabel(data.Series(tailAssetPair(2)) + " returns")
title("Tail Event Sample")
hold off
end
