%% Market Risk Analysis
% Inherited workflow script used for the agent workshop starter.

clear
clc
close all

importMarketData

returns = price2ret(data);    % Logarithmic returns

figure
plot(dates, ret2price(price2ret(data)))
datetick("x")
xlabel("Date")
ylabel("Index Value")
title("Relative Daily Index Closings")
legend(series, Location="northwest")

model = arima(AR=NaN, Distribution="t", Variance=gjr(1,1));
numIndices = size(returns, 2);
numObservations = size(returns, 1);
residuals = NaN(numObservations, numIndices);
variances = NaN(numObservations, numIndices);
fit = cell(numIndices, 1);

options = optimoptions(@fmincon, Display="off", Diagnostics="off", ...
    Algorithm="sqp", TolCon=1e-7);

tic
for assetNumber = 1:numIndices
    fit{assetNumber} = estimate(model, returns(:, assetNumber), ...
        Display="off", Options=options);
    [residuals(:, assetNumber), variances(:, assetNumber)] = infer( ...
        fit{assetNumber}, returns(:, assetNumber));
end
fitElapsedSeconds = toc

residuals = residuals ./ sqrt(variances);

pds = cell(numIndices, 1);
for assetNumber = 1:numIndices
    pds{assetNumber} = fitdist(residuals(:, assetNumber), "tLocationScale");
end

U = zeros(size(residuals));
for assetNumber = 1:numIndices
    U(:, assetNumber) = cdf(pds{assetNumber}, residuals(:, assetNumber));
end

[R, DoF] = copulafit("t", U, Method="approximateml")

trialSize = 200;
horizon = 22;
simulatedReturns = simulateMarketReturns(trialSize, horizon, R, DoF, ...
    pds, fit, returns, residuals, variances);

[threshold, tailPlotReturns, tailPlotSamples, tailMeanLoss, ...
    tailEventCount, tailElapsedSeconds] = analyzeTailRisk(R, DoF, pds, fit, ...
    returns, residuals, variances);
plotRiskResults
