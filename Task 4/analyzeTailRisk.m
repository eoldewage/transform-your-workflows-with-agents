function tailRisk = analyzeTailRisk(R, DoF, pds, fit, returns, residuals, ...
    variances, options)
%ANALYZETAILRISK Simulate one-day returns and summarize tail events.

arguments
    R (:, :) double
    DoF (1, 1) double {mustBePositive}
    pds (:, 1) cell
    fit (:, 1) cell
    returns (:, :) double
    residuals (:, :) double
    variances (:, :) double
    options.Threshold (1, 1) double = -0.03
    options.TrialSize (1, 1) double {mustBeInteger, mustBePositive} = 1000
    options.Horizon (1, 1) double {mustBeInteger, mustBePositive} = 1
    options.NumTrials (1, 1) double {mustBeInteger, mustBePositive} = 5
end

numIndices = size(returns, 2);
tailReturnsData = zeros(0, numIndices);
tailPlotReturns = zeros(0, numIndices);
tailPlotSamples = false(0, 1);

tic
for trialNumber = 1:options.NumTrials
    nextDayReturns = simulateMarketReturns(options.TrialSize, options.Horizon, ...
        R, DoF, pds, fit, returns, residuals, variances);
    nextDayReturns = reshape(nextDayReturns, ...
        [options.Horizon * options.TrialSize, numIndices]);

    tailSamples = nextDayReturns(:, 1) < options.Threshold ...
        | nextDayReturns(:, 2) < options.Threshold;
    if trialNumber == 1
        tailPlotReturns = nextDayReturns;
        tailPlotSamples = tailSamples;
    end
    tailReturnsData = [tailReturnsData; nextDayReturns(tailSamples, :)]; %#ok<AGROW>
end
elapsedSeconds = toc;

tailRisk = struct( ...
    Threshold=options.Threshold, ...
    Returns=tailReturnsData, ...
    PlotReturns=tailPlotReturns, ...
    PlotSamples=tailPlotSamples, ...
    MeanLoss=mean(tailReturnsData), ...
    EventCount=size(tailReturnsData, 1), ...
    ElapsedSeconds=elapsedSeconds);
end
