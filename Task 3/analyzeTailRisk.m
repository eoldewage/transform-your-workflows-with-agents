%% Analyze tail risk
% Uses the fitted model variables created by runMarketRiskAnalysis.

threshold = -0.03;
tailTrialSize = 500;
tailHorizon = 1;
numTailTrials = 5;
tailReturnsData = [];
tailPlotReturns = [];
tailPlotSamples = [];

tic
for trialNumber = 1:numTailTrials
    nextDayReturns = simulateMarketReturns(tailTrialSize, tailHorizon, ...
        R, DoF, pds, fit, returns, residuals, variances);
    nextDayReturns = reshape(nextDayReturns, [tailHorizon * tailTrialSize, numIndices]);

    tailSamples = nextDayReturns(:, 1) < threshold | nextDayReturns(:, 2) < threshold;
    if trialNumber == 1
        tailPlotReturns = nextDayReturns;
        tailPlotSamples = tailSamples;
    end
    tailReturnsData = [tailReturnsData; nextDayReturns(tailSamples, :)];
end
tailElapsedSeconds = toc

tailMeanLoss = mean(tailReturnsData)
tailEventCount = height(array2table(tailReturnsData))
