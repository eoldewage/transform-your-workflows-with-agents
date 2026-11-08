function simulatedReturns = simulateMarketReturns(modelData, numTrials, horizon)
%simulateMarketReturns - Generate conditional correlated return paths
%   simulatedReturns = simulateMarketReturns(modelData,numTrials,horizon)
%   generates NUMTRIALS correlated return paths over HORIZON periods.
%
%   See also copularnd, filter

arguments
    modelData (1,1) struct
    numTrials (1,1) {mustBeNumeric, mustBeReal, mustBeFinite, ...
        mustBeInteger, mustBePositive}
    horizon (1,1) {mustBeNumeric, mustBeReal, mustBeFinite, ...
        mustBeInteger, mustBePositive}
end

numIndices = size(modelData.returns, 2);

Z = zeros(horizon, numTrials, numIndices);
U = copularnd("t", modelData.copulaCorrelation, ...
    modelData.copulaDegreesOfFreedom, horizon * numTrials);

for assetNumber = 1:numIndices
    Z(:, :, assetNumber) = reshape( ...
        icdf(modelData.distributions{assetNumber}, U(:, assetNumber)), ...
        horizon, numTrials);
end

Y0 = modelData.returns(end, :);
Z0 = modelData.residuals(end, :);
V0 = modelData.variances(end, :);

simulatedReturns = zeros(horizon, numTrials, numIndices);
for assetNumber = 1:numIndices
    simulatedReturns(:, :, assetNumber) = filter( ...
        modelData.fittedModels{assetNumber}, ...
        Z(:, :, assetNumber), Y0=Y0(assetNumber), Z0=Z0(assetNumber), ...
        V0=V0(assetNumber));
end
end
