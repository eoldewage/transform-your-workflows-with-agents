function tailRisk = analyzeTailRisk(modelData, options)
%analyzeTailRisk - Simulate and summarize market-tail events
%   tailRisk = analyzeTailRisk(modelData) simulates one-day returns from
%   MODELDATA and summarizes events below the default -3% threshold.
%
%   [...] = analyzeTailRisk(...,Threshold=VALUE) specifies the threshold.
%
%   [...] = analyzeTailRisk(...,TrialSize=VALUE,Horizon=VALUE, ...
%   NumTrials=VALUE) specifies the simulation workload.
%
%   See also simulateMarketReturns, copularnd

arguments
    modelData (1,1) struct
    options.Threshold (1,1) {mustBeNumeric, mustBeReal, mustBeFinite, ...
        mustBeNegative} = -0.03
    options.TrialSize (1,1) {mustBeNumeric, mustBeReal, mustBeFinite, ...
        mustBeInteger, mustBePositive} = 500
    options.Horizon (1,1) {mustBeNumeric, mustBeReal, mustBeFinite, ...
        mustBeInteger, mustBePositive} = 1
    options.NumTrials (1,1) {mustBeNumeric, mustBeReal, mustBeFinite, ...
        mustBeInteger, mustBePositive} = 5
end

validateModelData(modelData)
numIndices = size(modelData.returns, 2);
tailReturnsByTrial = cell(options.NumTrials, 1);
plotReturns = [];
plotSamples = [];

startTime = tic;
for trialNumber = 1:options.NumTrials
    nextDayReturns = simulateMarketReturns(options.TrialSize, options.Horizon, ...
        modelData.copulaCorrelation, modelData.copulaDegreesOfFreedom, ...
        modelData.distributions, modelData.fittedModels, modelData.returns, ...
        modelData.residuals, modelData.variances);
    nextDayReturns = reshape(nextDayReturns, ...
        [options.Horizon * options.TrialSize, numIndices]);

    tailSamples = nextDayReturns < options.Threshold;
    if trialNumber == 1
        plotReturns = nextDayReturns;
        plotSamples = any(tailSamples, 2);
    end
    tailReturnsByTrial{trialNumber} = nextDayReturns(any(tailSamples, 2), :);
end

tailReturns = vertcat(tailReturnsByTrial{:});
tailRisk = struct( ...
    threshold=options.Threshold, ...
    plotReturns=plotReturns, ...
    plotSamples=plotSamples, ...
    meanLoss=mean(tailReturns), ...
    eventCount=size(tailReturns, 1), ...
    elapsedSeconds=toc(startTime));
end

function validateModelData(modelData)
requiredFields = {'copulaCorrelation', 'copulaDegreesOfFreedom', ...
    'distributions', 'fittedModels', 'returns', 'residuals', 'variances'};
missingFields = requiredFields(~isfield(modelData, requiredFields));
if ~isempty(missingFields)
    error("analyzeTailRisk:MissingModelData", ...
        "modelData is missing: %s.", strjoin(missingFields, ", "))
end

if ~isnumeric(modelData.returns) || ~ismatrix(modelData.returns)
    error("analyzeTailRisk:InvalidReturns", ...
        "modelData.returns must be a numeric matrix.")
end

numIndices = size(modelData.returns, 2);
hasMatchingInputs = numIndices > 0 && ...
    isequal(size(modelData.residuals), size(modelData.returns)) && ...
    isequal(size(modelData.variances), size(modelData.returns)) && ...
    numel(modelData.distributions) == numIndices && ...
    numel(modelData.fittedModels) == numIndices && ...
    isequal(size(modelData.copulaCorrelation), [numIndices, numIndices]);
if ~hasMatchingInputs
    error("analyzeTailRisk:InconsistentModelData", ...
        "Model inputs must have a consistent number of series.")
end
end
