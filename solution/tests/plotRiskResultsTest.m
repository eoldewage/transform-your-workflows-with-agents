classdef plotRiskResultsTest < matlab.unittest.TestCase
    %plotRiskResultsTest Tests for plotRiskResults.

    methods (TestClassSetup)
        function addSourceToPath(testCase)
            sourceFolder = fileparts(fileparts(mfilename("fullpath")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(sourceFolder));
        end
    end

    methods (TestMethodSetup)
        function hideFigures(testCase)
            originalVisibility = get(groot, "DefaultFigureVisible");
            testCase.addTeardown(@() set(groot, "DefaultFigureVisible", originalVisibility));
            testCase.addTeardown(@() close(findall(groot, "Type", "figure")));
            set(groot, "DefaultFigureVisible", "off");
        end
    end

    methods (Test)
        function testPlotsExpectedFigures(testCase)
            [data, model, sim, tail] = plotRiskResultsTest.createPlotInputs;

            plotRiskResults(data, model, sim, tail);

            testCase.verifyNumElements(findall(groot, "Type", "figure"), 4);
        end

        function testPlotsWhenNoTailSamples(testCase)
            [data, model, sim, tail] = plotRiskResultsTest.createPlotInputs;
            tail.PlotSamples = false(size(tail.PlotSamples));

            plotRiskResults(data, model, sim, tail);

            testCase.verifyNumElements(findall(groot, "Type", "figure"), 4);
        end

        function testPlotsConfiguredAssets(testCase)
            [data, model, sim, tail] = plotRiskResultsTest.createPlotInputs;
            data.Returns(:, 3) = data.Returns(:, 1) / 2;
            data.Prices(:, 3) = ret2price(data.Returns(:, 3));
            data.Series = {'FTSE', 'HK', 'SG'};
            model.Residuals(:, 3) = model.Residuals(:, 1) / 2;
            model.Variances(:, 3) = model.Variances(:, 1) * 2;
            sim.Returns(:, :, 3) = sim.Returns(:, :, 1);
            tail.PlotReturns(:, 3) = tail.PlotReturns(:, 1) / 2;

            plotRiskResults(data, model, sim, tail, ...
                DiagnosticAssetIndex=2, ...
                NumSimulationPaths=1, ...
                TailAssetPair=[2 3]);

            testCase.verifyNumElements(findall(groot, "Type", "figure"), 4);
        end

        function testShortHistoryErrors(testCase)
            [data, model, sim, tail] = plotRiskResultsTest.createPlotInputs;
            data.Dates = data.Dates(1:6);
            data.BaselineDate = data.Dates(1);
            data.PriceDates = data.Dates;
            data.ReturnDates = data.Dates(2:end);
            data.Returns = data.Returns(1:5, :);
            data.Prices = data.Prices(1:6, :);
            model.Residuals = model.Residuals(1:5, :);
            model.Variances = model.Variances(1:5, :);

            testCase.verifyError(@() plotRiskResults(data, model, sim, tail), ...
                "plotRiskResults:ShortHistory");
        end
    end

    methods (Static, Access=private)
        function [data, model, sim, tail] = createPlotInputs
            data.Dates = datenum(2020, 1, (1:25)');
            data.BaselineDate = data.Dates(1);
            data.PriceDates = data.Dates;
            data.ReturnDates = data.Dates(2:end);
            data.Returns = [linspace(-0.01, 0.01, 24)', linspace(0.01, -0.01, 24)'];
            data.Prices = ret2price(data.Returns);
            data.Series = {'FTSE', 'HK'};

            model.Residuals = [linspace(-1, 1, 24)', linspace(1, -1, 24)'];
            model.Variances = 0.01 * ones(24, 2);

            sim.TrialSize = 2;
            sim.Horizon = 3;
            sim.Returns = zeros(3, 2, 2);

            tail.Threshold = -0.03;
            tail.PlotReturns = [-0.01 0.01; -0.04 0.02; 0.01 -0.05; 0.02 0.03; -0.02 -0.01];
            tail.PlotSamples = [false; true; true; false; false];
        end
    end
end
