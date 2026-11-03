function tailRisk = analyzeTailRisk(model, options)
%ANALYZETAILRISK Estimate tail losses from repeated one-day simulations.

arguments
    model (1, 1) struct
    options.Threshold (1, 1) double = -0.03
    options.TrialSize (1, 1) double = 5000
    options.Horizon (1, 1) double = 1
    options.NumTrials (1, 1) double = 250
end

numIndices = size(model.Returns, 2);
tailReturnsByTrial = cell(options.NumTrials, 1);
tailPlotReturns = [];
tailPlotSamples = [];

tic
for trialNumber = 1:options.NumTrials
    nextDayReturns = simulateMarketReturns( ...
        options.TrialSize, options.Horizon, model);
    nextDayReturns = reshape(nextDayReturns, ...
        [options.Horizon * options.TrialSize, numIndices]);

    tailSamples = any(nextDayReturns < options.Threshold, 2);
    if trialNumber == 1
        tailPlotReturns = nextDayReturns;
        tailPlotSamples = tailSamples;
    end
    tailReturnsByTrial{trialNumber} = nextDayReturns(tailSamples, :);
end
tailElapsedSeconds = toc;
tailReturnsData = vertcat(tailReturnsByTrial{:});

tailRisk.Threshold = options.Threshold;
tailRisk.Returns = tailReturnsData;
tailRisk.PlotReturns = tailPlotReturns;
tailRisk.PlotSamples = tailPlotSamples;
tailRisk.MeanLoss = mean(tailReturnsData);
tailRisk.EventCount = size(tailReturnsData, 1);
tailRisk.ElapsedSeconds = tailElapsedSeconds;
end
