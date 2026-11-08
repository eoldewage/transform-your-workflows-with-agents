classdef plotRiskResultsTest < matlab.unittest.TestCase

    methods (TestMethodSetup)
        function hideFigures(testCase)
            originalVisibility = get(groot, "DefaultFigureVisible");
            testCase.addTeardown( ...
                @() set(groot, "DefaultFigureVisible", originalVisibility));
            set(groot, "DefaultFigureVisible", "off");
        end
    end

    methods (Test)
        function testSimulatedDataCreatesExpectedFigures(testCase)
            analysisData = plotRiskResultsTest.createAnalysisData();
            figureHandles = plotRiskResults(analysisData);
            testCase.addTeardown(@() close(figureHandles));

            testCase.verifySize(figureHandles, [3, 1]);
            testCase.verifyTrue(all(isgraphics(figureHandles)));
            testCase.verifyNumElements(findall(figureHandles(1), Type="axes"), 2);
            testCase.verifyNumElements(findall(figureHandles(2), Type="axes"), 1);
            testCase.verifyNumElements(findall(figureHandles(3), Type="axes"), 1);
        end
    end

    methods (Static, Access=private)
        function analysisData = createAnalysisData()
            dates = datenum(datetime(2020, 1, 1) + caldays(0:24));
            returns = repmat([-0.01, 0.01], 25, 1);
            tailRisk = struct( ...
                threshold=-0.03, ...
                plotReturns=[-0.04, 0.01; 0.02, -0.05; 0.01, 0.01], ...
                plotSamples=[true; true; false]);

            analysisData = struct( ...
                dates=dates, ...
                series=["FTSE", "HK"], ...
                returns=returns, ...
                residuals=returns / 2, ...
                variances=0.0001 * ones(25, 2), ...
                trialSize=3, ...
                horizon=2, ...
                simulatedReturns=zeros(2, 3, 2), ...
                tailRisk=tailRisk);
        end
    end
end
