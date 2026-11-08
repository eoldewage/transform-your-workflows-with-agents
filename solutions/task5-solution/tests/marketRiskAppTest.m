classdef marketRiskAppTest < matlab.uitest.TestCase

    properties (Access=private)
        App
    end

    methods (TestMethodSetup)
        function launchApp(testCase)
            testCase.App = marketRiskApp( ...
                AnalysisRunner=@marketRiskAppTest.createAnalysisData);
            testCase.addTeardown(@() delete(testCase.App.Figure));
            drawnow
        end
    end

    methods (Test)
        function testStartsWithDefaultPairAndDashboard(testCase)
            testCase.verifyEqual(string(testCase.App.FirstSeries.Value), ...
                "Global — FTSE");
            testCase.verifyEqual(string(testCase.App.SecondSeries.Value), ...
                "Asia — HK");
            testCase.verifyNumElements(testCase.App.Axes, 4);
            testCase.verifyEqual(testCase.App.Status.Text, ...
                'Analysis complete');
        end

        function testChangingSeriesRefreshesAnalysis(testCase)
            testCase.choose(testCase.App.SecondSeries, "Global — CAC");

            testCase.verifyEqual(string(testCase.App.SecondSeries.Value), ...
                "Global — CAC");
            testCase.verifyEqual(testCase.App.Status.Text, ...
                'Analysis complete');
        end

        function testRegenerateAppliesEditedSettings(testCase)
            testCase.type(testCase.App.PathCount, 25);
            testCase.press(testCase.App.RegenerateButton);

            testCase.verifyEqual(testCase.App.Status.Text, ...
                'Analysis complete');
        end
    end

    methods (Static, Access=private)
        function analysisData = createAnalysisData(~, ~)
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
