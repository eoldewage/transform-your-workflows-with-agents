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
            testCase.verifySize(actual.tailPlotReturns, [500, 2]);
            testCase.verifySize(actual.tailPlotSamples, [500, 1]);
            testCase.verifyClass(actual.tailPlotSamples, "logical");
            testCase.verifyTrue(any(actual.tailPlotSamples));
            testCase.verifyTrue(all(any( ...
                actual.tailPlotReturns(actual.tailPlotSamples, :) < ...
                actual.threshold, 2)));
            testCase.verifyFalse(any(any( ...
                actual.tailPlotReturns(~actual.tailPlotSamples, :) < ...
                actual.threshold, 2)));
            testCase.verifyGreaterThan(actual.tailEventCount, 0);
            testCase.verifyTrue(all(isfinite(actual.tailMeanLoss)));
            testCase.verifyGreaterThanOrEqual(actual.tailElapsedSeconds, 0);
        end

        function testNoTailEvents(testCase)
            actual = analyzeTailRiskTest.runNoTailCase();

            testCase.verifyEqual(actual.threshold, -0.03);
            testCase.verifySize(actual.tailPlotReturns, [500, 2]);
            testCase.verifySize(actual.tailPlotSamples, [500, 1]);
            testCase.verifyFalse(any(actual.tailPlotSamples));
            testCase.verifyEqual(actual.tailEventCount, 0);
            testCase.verifyTrue(all(isnan(actual.tailMeanLoss)));
            testCase.verifyGreaterThanOrEqual(actual.tailElapsedSeconds, 0);
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

        function actual = runAnalysis(model, distributions, variances)
            fit = {model; model};
            returns = zeros(10, 2);
            residuals = zeros(10, 2);

            [threshold, tailPlotReturns, tailPlotSamples, tailMeanLoss, ...
                tailEventCount, tailElapsedSeconds] = analyzeTailRisk( ...
                eye(2), 8, distributions, fit, returns, residuals, variances);

            actual = struct( ...
                threshold=threshold, ...
                tailPlotReturns=tailPlotReturns, ...
                tailPlotSamples=tailPlotSamples, ...
                tailMeanLoss=tailMeanLoss, ...
                tailEventCount=tailEventCount, ...
                tailElapsedSeconds=tailElapsedSeconds);
        end

        function outputs = baselineOutputs(actual)
            outputs = rmfield(actual, "tailElapsedSeconds");
        end
    end
end
