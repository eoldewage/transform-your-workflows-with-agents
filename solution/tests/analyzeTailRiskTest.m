classdef analyzeTailRiskTest < matlab.unittest.TestCase
    %analyzeTailRiskTest Tests for analyzeTailRisk.

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
        function testReturnsExpectedTailRiskFields(testCase)
            tail = analyzeTailRisk(testCase.Model, ...
                TrialSize=20, Horizon=1, NumTrials=3);

            testCase.verifyEqual(tail.Threshold, -0.03);
            testCase.verifySize(tail.PlotReturns, [20 2]);
            testCase.verifySize(tail.PlotSamples, [20 1]);
            testCase.verifyEqual(tail.EventCount, size(tail.Returns, 1));
            testCase.verifyGreaterThanOrEqual(tail.EventCount, 0);
            testCase.verifyGreaterThan(tail.ElapsedSeconds, 0);
        end

        function testInfiniteThresholdSelectsEverySimulation(testCase)
            tail = analyzeTailRisk(testCase.Model, ...
                Threshold=Inf, TrialSize=20, Horizon=1, NumTrials=3);

            testCase.verifyEqual(tail.EventCount, 60);
            testCase.verifySize(tail.Returns, [60 2]);
            testCase.verifyTrue(all(tail.PlotSamples));
        end

        function testNegativeInfiniteThresholdSelectsNoSimulations(testCase)
            tail = analyzeTailRisk(testCase.Model, ...
                Threshold=-Inf, TrialSize=20, Horizon=1, NumTrials=3);

            testCase.verifyEqual(tail.EventCount, 0);
            testCase.verifySize(tail.Returns, [0 2]);
            testCase.verifyTrue(all(isnan(tail.MeanLoss)));
            testCase.verifyFalse(any(tail.PlotSamples));
        end
    end
end
