function simulatedReturns = simulateMarketReturns(nTrials, horizon, model)
%SIMULATEMARKETRETURNS Simulate correlated return paths from fitted models.

numIndices = size(model.Returns, 2);

Z = zeros(horizon, nTrials, numIndices);
U = copularnd("t", model.Correlation, ...
    model.DegreesOfFreedom, horizon * nTrials);

for assetNumber = 1:numIndices
    Z(:, :, assetNumber) = reshape(icdf( ...
        model.MarginalDistributions{assetNumber}, U(:, assetNumber)), ...
        horizon, nTrials);
end

Y0 = model.Returns(end, :);
Z0 = model.Residuals(end, :);
V0 = model.Variances(end, :);

simulatedReturns = zeros(horizon, nTrials, numIndices);
for assetNumber = 1:numIndices
    simulatedReturns(:, :, assetNumber) = filter( ...
        model.Fits{assetNumber}, Z(:, :, assetNumber), ...
        Y0=Y0(assetNumber), Z0=Z0(assetNumber), V0=V0(assetNumber));
end
end
