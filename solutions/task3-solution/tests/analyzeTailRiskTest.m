classdef analyzeTailRiskTest < matlab.unittest.TestCase

    properties (TestParameter)
        happyPath = matlabtest.parameters.matfileBaseline( ...
            fullfile(fileparts(mfilename("fullpath")), "baselines", ...
            "analyzeTailRiskBaseline.mat"), VariableName="happyPath")
    end

    methods (TestClassSetup)
        function addSourceFolder(testCase)
            sourceFolder = fileparts(fileparts(mfilename("fullpath")));
            testCase.applyFixture( ...
                matlab.unittest.fixtures.PathFixture(sourceFolder));
        end
    end

    methods (TestMethodSetup)
        function setRandomSeed(testCase)
            originalRng = rng;
            testCase.addTeardown(@() rng(originalRng));
            rng(42, "twister")
        end
    end

    methods (Test)
        function testHappyPathMatchesBaseline(testCase, happyPath)
            actual = analyzeTailRiskTest.runHappyPath();

            testCase.verifyEqualsBaseline( ...
                analyzeTailRiskTest.baselineOutputs(actual), happyPath, ...
                AbsTol=1e-12);
            testCase.verifyEqual(actual.threshold, -0.03);
            testCase.verifySize(actual.plotReturns, [500, 2]);
            testCase.verifySize(actual.plotSamples, [500, 1]);
            testCase.verifyClass(actual.plotSamples, "logical");
            testCase.verifyTrue(any(actual.plotSamples));
            testCase.verifyTrue(all(any( ...
                actual.plotReturns(actual.plotSamples, :) < ...
                actual.threshold, 2)));
            testCase.verifyFalse(any(any( ...
                actual.plotReturns(~actual.plotSamples, :) < ...
                actual.threshold, 2)));
            testCase.verifyGreaterThan(actual.eventCount, 0);
            testCase.verifyTrue(all(isfinite(actual.meanLoss)));
            testCase.verifyGreaterThanOrEqual(actual.elapsedSeconds, 0);
        end

        function testNoTailEvents(testCase)
            actual = analyzeTailRiskTest.runNoTailCase();

            testCase.verifyEqual(actual.threshold, -0.03);
            testCase.verifySize(actual.plotReturns, [500, 2]);
            testCase.verifySize(actual.plotSamples, [500, 1]);
            testCase.verifyFalse(any(actual.plotSamples));
            testCase.verifyEqual(actual.eventCount, 0);
            testCase.verifyTrue(all(isnan(actual.meanLoss)));
            testCase.verifyGreaterThanOrEqual(actual.elapsedSeconds, 0);
        end

        function testAnySeriesCanTriggerTailEvent(testCase)
            actual = analyzeTailRiskTest.runThreeSeriesCase();
            expectedSamples = any(actual.plotReturns < actual.threshold, 2);
            thirdSeriesOnly = actual.plotReturns(:, 3) < actual.threshold & ...
                all(actual.plotReturns(:, 1:2) >= actual.threshold, 2);

            testCase.verifySize(actual.plotReturns, [500, 3]);
            testCase.verifyEqual(actual.plotSamples, expectedSamples);
            testCase.verifyTrue(any(thirdSeriesOnly));
            testCase.verifyTrue(all(actual.plotSamples(thirdSeriesOnly)));
        end

        function testCustomSimulationOptions(testCase)
            actual = analyzeTailRiskTest.runCustomOptions();

            testCase.verifyEqual(actual.threshold, -0.01);
            testCase.verifySize(actual.plotReturns, [24, 2]);
            testCase.verifySize(actual.plotSamples, [24, 1]);
        end
    end

    methods (Static, Access=private)
        function actual = runHappyPath()
            model = arima(Constant=0, AR=0, Variance=1e-4);
            distributions = { ...
                makedist("tLocationScale", mu=0, sigma=1, nu=8); ...
                makedist("tLocationScale", mu=0, sigma=1, nu=8)};

            actual = analyzeTailRiskTest.runAnalysis( ...
                model, distributions, 1e-4 * ones(10, 2));
        end

        function actual = runNoTailCase()
            model = arima(Constant=0, AR=0, Variance=1e-12);
            distributions = { ...
                makedist("Normal", mu=0, sigma=1e-6); ...
                makedist("Normal", mu=0, sigma=1e-6)};

            actual = analyzeTailRiskTest.runAnalysis( ...
                model, distributions, 1e-12 * ones(10, 2));
        end

        function actual = runThreeSeriesCase()
            lowRiskModel = arima(Constant=0, AR=0, Variance=1e-12);
            highRiskModel = arima(Constant=0, AR=0, Variance=1);
            distributions = { ...
                makedist("Normal", mu=0, sigma=1e-6); ...
                makedist("Normal", mu=0, sigma=1e-6); ...
                makedist("tLocationScale", mu=0, sigma=1, nu=8)};
            fittedModels = {lowRiskModel; lowRiskModel; highRiskModel};
            returns = zeros(10, 3);
            residuals = zeros(10, 3);
            variances = [1e-12 * ones(10, 2), ones(10, 1)];
            modelData = analyzeTailRiskTest.createModelData( ...
                fittedModels, distributions, returns, residuals, variances);

            actual = analyzeTailRisk(modelData);
        end

        function actual = runCustomOptions()
            model = arima(Constant=0, AR=0, Variance=1e-4);
            distributions = { ...
                makedist("tLocationScale", mu=0, sigma=1, nu=8); ...
                makedist("tLocationScale", mu=0, sigma=1, nu=8)};
            modelData = analyzeTailRiskTest.createModelData( ...
                {model; model}, distributions, zeros(10, 2), zeros(10, 2), ...
                1e-4 * ones(10, 2));

            actual = analyzeTailRisk(modelData, Threshold=-0.01, ...
                TrialSize=12, Horizon=2, NumTrials=2);
        end

        function actual = runAnalysis(model, distributions, variances)
            fit = {model; model};
            returns = zeros(10, 2);
            residuals = zeros(10, 2);

            modelData = analyzeTailRiskTest.createModelData( ...
                fit, distributions, returns, residuals, variances);
            actual = analyzeTailRisk(modelData);
        end

        function modelData = createModelData( ...
                fittedModels, distributions, returns, residuals, variances)
            numIndices = size(returns, 2);
            modelData = struct( ...
                copulaCorrelation=eye(numIndices), ...
                copulaDegreesOfFreedom=8, ...
                distributions={distributions}, ...
                fittedModels={fittedModels}, ...
                returns=returns, ...
                residuals=residuals, ...
                variances=variances);
        end

        function outputs = baselineOutputs(actual)
            outputs = struct( ...
                threshold=actual.threshold, ...
                tailPlotReturns=actual.plotReturns, ...
                tailPlotSamples=actual.plotSamples, ...
                tailMeanLoss=actual.meanLoss, ...
                tailEventCount=actual.eventCount);
        end
    end
end
