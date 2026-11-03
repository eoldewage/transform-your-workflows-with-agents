function simulatedReturns = simulateMarketReturns(nTrials, horizon, R, DoF, pds, fit, returns, residuals, variances)

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
