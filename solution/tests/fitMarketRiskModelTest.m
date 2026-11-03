classdef fitMarketRiskModelTest < matlab.unittest.TestCase
    %fitMarketRiskModelTest Tests for fitMarketRiskModel.

    properties
        Data
        Model
    end

    methods (TestClassSetup)
        function addSourceToPath(testCase)
            sourceFolder = fileparts(fileparts(mfilename("fullpath")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(sourceFolder));
        end

        function fitBaselineModel(testCase)
            testCase.Data = importMarketData;
            testCase.Model = fitMarketRiskModel(testCase.Data.Returns);
        end
    end

    methods (Test)
        function testFitsExpectedModelResultShape(testCase)
            testCase.verifySize(testCase.Model.Residuals, size(testCase.Data.Returns));
            testCase.verifySize(testCase.Model.Variances, size(testCase.Data.Returns));
            testCase.verifySize(testCase.Model.Correlation, [2 2]);
            testCase.verifyEqual(diag(testCase.Model.Correlation), ones(2, 1), AbsTol=1e-10);
            testCase.verifyTrue(all(testCase.Model.Variances > 0, "all"));
            testCase.verifyTrue(isfinite(testCase.Model.DegreesOfFreedom));
            testCase.verifyGreaterThan(testCase.Model.DegreesOfFreedom, 0);
            testCase.verifyNumElements(testCase.Model.Fits, 2);
            testCase.verifyNumElements(testCase.Model.MarginalDistributions, 2);
        end

        function testReportsFitDiagnostics(testCase)
            testCase.verifyTrue(isfield(testCase.Model, "FitDiagnostics"));
            testCase.verifySize(testCase.Model.FitDiagnostics, [2 1]);

            diagnostics = testCase.Model.FitDiagnostics;
            testCase.verifyEqual([diagnostics.AssetNumber]', [1; 2]);
            testCase.verifyTrue(all(isfield(diagnostics, [
                "EstimateWarningID"
                "EstimateWarningMessage"
                "MarginalWarningID"
                "MarginalWarningMessage"])));

            marginalMessages = string({diagnostics.MarginalWarningMessage}');
            testCase.verifyTrue(any(contains(marginalMessages, ...
                "Maximum likelihood estimation did not converge")));
        end

        function testAcceptsCallerProvidedModelOptions(testCase)
            modelSpec = arima(AR=NaN, Distribution="t", Variance=gjr(1, 1));
            optimizerOptions = optimoptions(@fmincon, ...
                Display="off", Diagnostics="off", Algorithm="sqp", TolCon=1e-7);

            model = fitMarketRiskModel(testCase.Data.Returns, ...
                Model=modelSpec, OptimizerOptions=optimizerOptions);

            testCase.verifyEqual(model.ModelSpecification, modelSpec);
            testCase.verifyEqual(model.OptimizerOptions.Algorithm, 'sqp');
            testCase.verifySize(model.Residuals, size(testCase.Data.Returns));
        end

        function testEmptyReturnsError(testCase)
            testCase.verifyError(@() fitMarketRiskModel([]), ...
                "stats:copulafit:InvalidDataDimensions");
        end

        function testSingleAssetReturnsError(testCase)
            testCase.verifyError(@() fitMarketRiskModel(testCase.Data.Returns(:, 1)), ...
                "stats:copulafit:InvalidDataDimensions");
        end
    end
end
