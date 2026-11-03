function simulatedReturns = simulateMarketReturns(nTrials, horizon, R, DoF, pds, fit, returns, residuals, variances)

arguments
    nTrials (1, 1) {mustBeNumeric, mustBeReal, mustBeFinite, ...
        mustBeInteger, mustBePositive}
    horizon (1, 1) {mustBeNumeric, mustBeReal, mustBeFinite, ...
        mustBeInteger, mustBePositive}
    R (:, :) {mustBeNumeric, mustBeReal, mustBeFinite, mustBeSquare}
    DoF (1, 1) {mustBeNumeric, mustBeReal, mustBeFinite, mustBePositive}
    pds {mustBeA(pds, "cell"), mustBeVector, mustBeNonempty}
    fit {mustBeA(fit, "cell"), mustBeVector, mustBeNonempty}
    returns (:, :) {mustBeNumeric, mustBeReal, mustBeFinite, ...
        mustBeConsistentSimulationInputs(R, pds, fit, returns)}
    residuals (:, :) {mustBeNumeric, mustBeReal, mustBeFinite, ...
        mustMatchSize(residuals, returns, "residuals", "returns")}
    variances (:, :) {mustBeNumeric, mustBeReal, mustBeFinite, ...
        mustBePositive, mustMatchSize(variances, returns, "variances", "returns")}
end

numIndices = size(returns, 2);

Z = zeros(horizon, nTrials, numIndices);
U = copularnd("t", R, DoF, horizon * nTrials);

for assetNumber = 1:numIndices
    Z(:, :, assetNumber) = reshape(icdf(pds{assetNumber}, U(:, assetNumber)), ...
        horizon, nTrials);
end

Y0 = returns(end, :);
Z0 = residuals(end, :);
V0 = variances(end, :);

simulatedReturns = zeros(horizon, nTrials, numIndices);
for assetNumber = 1:numIndices
    simulatedReturns(:, :, assetNumber) = filter(fit{assetNumber}, ...
        Z(:, :, assetNumber), Y0=Y0(assetNumber), Z0=Z0(assetNumber), ...
        V0=V0(assetNumber));
end
end

function mustBeSquare(value)
if size(value, 1) ~= size(value, 2)
    error("simulateMarketReturns:NonSquareCorrelation", ...
        "R must be a square correlation matrix.")
end
end

function mustBeConsistentSimulationInputs(R, pds, fit, returns)
numIndices = size(returns, 2);
if size(R, 1) ~= numIndices
    error("simulateMarketReturns:CorrelationSizeMismatch", ...
        "R must have one row and column for each return series.")
end
if numel(pds) ~= numIndices
    error("simulateMarketReturns:DistributionCountMismatch", ...
        "pds must contain one distribution for each return series.")
end
if numel(fit) ~= numIndices
    error("simulateMarketReturns:ModelCountMismatch", ...
        "fit must contain one model for each return series.")
end
if size(returns, 1) < 1
    error("simulateMarketReturns:EmptyReturns", ...
        "returns must contain at least one observation.")
end
end

function mustMatchSize(value, referenceValue, valueName, referenceName)
if ~isequal(size(value), size(referenceValue))
    error("simulateMarketReturns:SizeMismatch", ...
        "%s must have the same size as %s.", valueName, referenceName)
end
end
