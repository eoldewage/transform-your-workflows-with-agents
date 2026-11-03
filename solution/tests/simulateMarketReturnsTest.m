classdef simulateMarketReturnsTest < matlab.unittest.TestCase
    %simulateMarketReturnsTest Tests for simulateMarketReturns.

    properties
        Model
    end

    methods (TestClassSetup)
        function addSourceToPath(testCase)
            sourceFolder = fileparts(fileparts(mfilename("fullpath")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(sourceFolder));
        end

        function fitBaselineModel(testCase)
            data = importMarketData;
            testCase.Model = fitMarketRiskModel(data.Returns);
        end
    end

    methods (TestMethodSetup)
        function seedRandomNumberGenerator(testCase)
            originalRng = rng;
            testCase.addTeardown(@() rng(originalRng));
            rng(42, "twister");
        end
    end

    methods (Test)
        function testSimulatesExpectedShape(testCase)
            result = simulateMarketReturns(4, 3, testCase.Model);

            testCase.verifySize(result, [3 4 2]);
            testCase.verifyTrue(all(isfinite(result), "all"));
        end

        function testSimulatesSingleTrialSingleHorizon(testCase)
            result = simulateMarketReturns(1, 1, testCase.Model);

            testCase.verifySize(result, [1 1 2]);
            testCase.verifyTrue(all(isfinite(result), "all"));
        end

        function testZeroTrialsError(testCase)
            testCase.verifyError(@() simulateMarketReturns(0, 1, testCase.Model), ...
                "MATLAB:expectedNonempty");
        end
    end
end
