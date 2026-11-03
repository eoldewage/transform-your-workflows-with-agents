function modelResults = fitMarketRiskModel(returns, options)
%FITMARKETRISKMODEL Fit marginal GJR models and a t copula.

arguments
    returns (:, :) double
    options.Model = []
    options.OptimizerOptions = []
end

if isempty(options.Model)
    options.Model = arima(AR=NaN, Distribution="t", Variance=gjr(1, 1));
end
if isempty(options.OptimizerOptions)
    options.OptimizerOptions = optimoptions(@fmincon, Display="off", ...
        Diagnostics="off", Algorithm="sqp", TolCon=1e-7);
end

numIndices = size(returns, 2);
numObservations = size(returns, 1);
residuals = NaN(numObservations, numIndices);
variances = NaN(numObservations, numIndices);
fit = cell(numIndices, 1);
fitDiagnostics = repmat(struct( ...
    AssetNumber=NaN, ...
    EstimateWarningID="", ...
    EstimateWarningMessage="", ...
    MarginalWarningID="", ...
    MarginalWarningMessage=""), numIndices, 1);

tic
for assetNumber = 1:numIndices
    fitDiagnostics(assetNumber).AssetNumber = assetNumber;
    lastwarn("");
    fit{assetNumber} = estimate(options.Model, returns(:, assetNumber), ...
        Display="off", Options=options.OptimizerOptions);
    [warningMessage, warningID] = lastwarn;
    fitDiagnostics(assetNumber).EstimateWarningID = string(warningID);
    fitDiagnostics(assetNumber).EstimateWarningMessage = string(warningMessage);

    [residuals(:, assetNumber), variances(:, assetNumber)] = infer( ...
        fit{assetNumber}, returns(:, assetNumber));
end
fitElapsedSeconds = toc;

residuals = residuals ./ sqrt(variances);

marginalDistributions = cell(numIndices, 1);
for assetNumber = 1:numIndices
    lastwarn("");
    marginalDistributions{assetNumber} = fitdist( ...
        residuals(:, assetNumber), "tLocationScale");
    [warningMessage, warningID] = lastwarn;
    fitDiagnostics(assetNumber).MarginalWarningID = string(warningID);
    fitDiagnostics(assetNumber).MarginalWarningMessage = string(warningMessage);
end

U = zeros(size(residuals));
for assetNumber = 1:numIndices
    U(:, assetNumber) = cdf(marginalDistributions{assetNumber}, ...
        residuals(:, assetNumber));
end

[correlation, degreesOfFreedom] = copulafit("t", U, Method="approximateml");

modelResults.Returns = returns;
modelResults.ModelSpecification = options.Model;
modelResults.OptimizerOptions = options.OptimizerOptions;
modelResults.Fits = fit;
modelResults.Residuals = residuals;
modelResults.Variances = variances;
modelResults.MarginalDistributions = marginalDistributions;
modelResults.FitDiagnostics = fitDiagnostics;
modelResults.Correlation = correlation;
modelResults.DegreesOfFreedom = degreesOfFreedom;
modelResults.FitElapsedSeconds = fitElapsedSeconds;
end
