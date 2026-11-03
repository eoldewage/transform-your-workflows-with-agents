function [results, elapsedSeconds] = fitMarketRiskModels(returns)
%FITMARKETRISKMODELS Fit ARIMA/GJR models and residual distributions.

arguments
    returns (:, :) {mustBeNumeric, mustBeReal, mustBeFinite, ...
        mustHaveObservationsAndSeries}
end

numIndices = size(returns, 2);
numObservations = size(returns, 1);
residuals = NaN(numObservations, numIndices);
variances = NaN(numObservations, numIndices);
fit = cell(numIndices, 1);

model = arima(AR=NaN, Distribution="t", Variance=gjr(1, 1));
solverOptions = optimoptions(@fmincon, Display="off", Diagnostics="off", ...
    Algorithm="sqp", TolCon=1e-7);

tic
for assetNumber = 1:numIndices
    fit{assetNumber} = estimate(model, returns(:, assetNumber), ...
        Display="off", Options=solverOptions);
    [residuals(:, assetNumber), variances(:, assetNumber)] = infer( ...
        fit{assetNumber}, returns(:, assetNumber));
end
elapsedSeconds = toc;

standardizedResiduals = residuals ./ sqrt(variances);

residualDistributions = cell(numIndices, 1);
uniformResiduals = zeros(size(standardizedResiduals));
for assetNumber = 1:numIndices
    residualDistributions{assetNumber} = fitdist( ...
        standardizedResiduals(:, assetNumber), "tLocationScale");
    uniformResiduals(:, assetNumber) = cdf( ...
        residualDistributions{assetNumber}, standardizedResiduals(:, assetNumber));
end

results = struct( ...
    Fit={fit}, ...
    Residuals=standardizedResiduals, ...
    Variances=variances, ...
    ResidualDistributions={residualDistributions}, ...
    UniformResiduals=uniformResiduals);
end

function mustHaveObservationsAndSeries(returns)
if size(returns, 1) < 2 || size(returns, 2) < 1
    error("fitMarketRiskModels:InvalidReturns", ...
        "returns must contain at least two observations and one series.")
end
end
