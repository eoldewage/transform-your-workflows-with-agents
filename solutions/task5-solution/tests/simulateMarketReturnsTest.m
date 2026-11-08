classdef simulateMarketReturnsTest < matlab.unittest.TestCase

    properties (TestParameter)
        simulatedReturns = matlabtest.parameters.matfileBaseline( ...
            fullfile(fileparts(mfilename("fullpath")), "baselines", ...
            "simulateMarketReturnsBaseline.mat"), ...
            VariableName="simulatedReturns")
    end

    methods (TestMethodSetup)
        function setRandomSeed(testCase)
            originalRng = rng;
            testCase.addTeardown(@() rng(originalRng));
            rng(42, "twister")
        end
    end

    methods (Test)
        function testSharedModelDataMatchesBaseline(testCase, simulatedReturns)
            modelData = simulateMarketReturnsTest.createModelData();
            actual = simulateMarketReturns(modelData, 4, 3);

            testCase.verifyEqualsBaseline(actual, simulatedReturns, ...
                AbsTol=1e-12);
            testCase.verifySize(actual, [3, 4, 2]);
            testCase.verifyTrue(all(isfinite(actual), "all"));
        end
    end

    methods (Static, Access=private)
        function modelData = createModelData()
            model = arima(Constant=0, AR=0, Variance=1e-4);
            distributions = { ...
                makedist("tLocationScale", mu=0, sigma=1, nu=8); ...
                makedist("tLocationScale", mu=0, sigma=1, nu=8)};
            fittedModels = {model; model};

            modelData = struct( ...
                copulaCorrelation=eye(2), ...
                copulaDegreesOfFreedom=8, ...
                distributions={distributions}, ...
                fittedModels={fittedModels}, ...
                returns=zeros(10, 2), ...
                residuals=zeros(10, 2), ...
                variances=1e-4 * ones(10, 2));
        end
    end
end
