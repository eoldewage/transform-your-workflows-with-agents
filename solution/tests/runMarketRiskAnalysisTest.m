classdef runMarketRiskAnalysisTest < matlab.unittest.TestCase
    %runMarketRiskAnalysisTest Tests for runMarketRiskAnalysis.

    methods (TestClassSetup)
        function addSourceToPath(testCase)
            sourceFolder = fileparts(fileparts(mfilename("fullpath")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(sourceFolder));
        end
    end

    methods (TestMethodSetup)
        function seedRandomNumberGenerator(testCase)
            originalRng = rng;
            testCase.addTeardown(@() rng(originalRng));
            rng(42, "twister");
        end
    end

    methods (Test, TestTags = {'Integration'})
        function testRunsWorkflowWithoutPlots(testCase)
            results = runMarketRiskAnalysis(PlotResults=false);

            testCase.verifyEqual(sort(fieldnames(results)), ...
                sort({'MarketData'; 'Model'; 'Simulation'; 'TailRisk'}));
            testCase.verifySize(results.MarketData.Returns, [920 2]);
            testCase.verifySize(results.Simulation.Returns, [22 2000 2]);
            testCase.verifyEqual(results.TailRisk.EventCount, ...
                size(results.TailRisk.Returns, 1));
        end

        function testRunOptionsControlSimulationShape(testCase)
            results = runMarketRiskAnalysis(TrialSize=3, Horizon=2, PlotResults=false);

            testCase.verifyEqual(results.Simulation.TrialSize, 3);
            testCase.verifyEqual(results.Simulation.Horizon, 2);
            testCase.verifySize(results.Simulation.Returns, [2 3 2]);
        end
    end

    methods (Test)
        function testMissingGlobalFileErrors(testCase)
            testCase.verifyError(@() runMarketRiskAnalysis( ...
                GlobalIndexFile="does-not-exist.mat", PlotResults=false), ...
                "MATLAB:load:couldNotReadFile");
        end

        function testDoesNotCloseExistingFiguresByDefault(testCase)
            testCase.addTeardown(@() close(findall(groot, "Type", "figure")));
            figureHandle = figure(Visible="off");

            testCase.verifyError(@() runMarketRiskAnalysis( ...
                GlobalIndexFile="does-not-exist.mat", PlotResults=false), ...
                "MATLAB:load:couldNotReadFile");

            testCase.verifyTrue(isvalid(figureHandle));
        end

        function testCloseFiguresOptionClosesExistingFigures(testCase)
            testCase.addTeardown(@() close(findall(groot, "Type", "figure")));
            figureHandle = figure(Visible="off");

            testCase.verifyError(@() runMarketRiskAnalysis( ...
                GlobalIndexFile="does-not-exist.mat", ...
                PlotResults=false, ...
                CloseFigures=true), ...
                "MATLAB:load:couldNotReadFile");

            testCase.verifyFalse(isvalid(figureHandle));
        end
    end
end
