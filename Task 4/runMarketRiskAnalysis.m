%% Run market risk analysis
% Fit ARIMA/GJR models, simulate market returns, and plot tail risk.

importMarketData;

returns = price2ret(data);    % Logarithmic returns

[modelResults, fitElapsedSeconds] = fitMarketRiskModels(returns);

[R, DoF] = copulafit("t", modelResults.UniformResiduals, ...
    Method="approximateml");

trialSize = 200;
horizon = 22;
simulatedReturns = simulateMarketReturns(trialSize, horizon, ...
    R, DoF, modelResults.ResidualDistributions, modelResults.Fit, returns, ...
    modelResults.Residuals, modelResults.Variances);

tailThreshold = -0.03;
tailTrialSize = 1000;
numTailTrials = 5;
tailRisk = analyzeTailRisk(R, DoF, modelResults.ResidualDistributions, ...
    modelResults.Fit, returns, modelResults.Residuals, ...
    modelResults.Variances, Threshold=tailThreshold, ...
    TrialSize=tailTrialSize, NumTrials=numTailTrials);

plotRiskResults(dates, series, data, returns, ...
    modelResults.Residuals, modelResults.Variances, simulatedReturns, ...
    tailRisk);


fprintf("fitElapsedSeconds = %.4f\n", fitElapsedSeconds);
disp("R =")
disp(R)
fprintf("DoF = %.4f\n", DoF);
fprintf("tailElapsedSeconds = %.4f\n", tailRisk.ElapsedSeconds);
disp("tailMeanLoss =")
disp(tailRisk.MeanLoss)
fprintf("tailEventCount = %d\n", tailRisk.EventCount);
