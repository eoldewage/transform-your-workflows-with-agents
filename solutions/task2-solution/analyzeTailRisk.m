function [threshold, tailPlotReturns, tailPlotSamples, tailMeanLoss, ...
    tailEventCount, tailElapsedSeconds] = analyzeTailRisk(R, DoF, pds, fit, ...
    returns, residuals, variances)
%ANALYZETAILRISK Simulate and summarize large single-day market losses.

threshold = -0.03;
tailTrialSize = 500;
tailHorizon = 1;
numTailTrials = 5;
numIndices = size(returns, 2);
tailReturnsData = [];
tailPlotReturns = [];
tailPlotSamples = [];

tic
for trialNumber = 1:numTailTrials
    nextDayReturns = simulateMarketReturns(tailTrialSize, tailHorizon, ...
        R, DoF, pds, fit, returns, residuals, variances);
    nextDayReturns = reshape(nextDayReturns, ...
        [tailHorizon * tailTrialSize, numIndices]);

    tailSamples = nextDayReturns(:, 1) < threshold | ...
        nextDayReturns(:, 2) < threshold;
    if trialNumber == 1
        tailPlotReturns = nextDayReturns;
        tailPlotSamples = tailSamples;
    end
    tailReturnsData = [tailReturnsData; nextDayReturns(tailSamples, :)];
end
tailElapsedSeconds = toc;

tailMeanLoss = mean(tailReturnsData);
tailEventCount = height(array2table(tailReturnsData));
end
