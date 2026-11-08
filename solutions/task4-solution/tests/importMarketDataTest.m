classdef importMarketDataTest < matlab.unittest.TestCase

    properties (TestParameter)
        importResult = matlabtest.parameters.matfileBaseline( ...
            fullfile(fileparts(mfilename("fullpath")), "baselines", ...
            "importMarketDataBaseline.mat"), VariableName="importResult")
    end

    properties (Access=private)
        sourceFiles
    end

    methods (TestMethodSetup)
        function createSimulatedSources(testCase)
            temporaryFolder = string(tempname);
            mkdir(temporaryFolder);
            testCase.addTeardown(@() rmdir(temporaryFolder, "s"));
            testCase.sourceFiles = importMarketDataTest.writeSources( ...
                temporaryFolder);
        end
    end

    methods (Test)
        function testSimulatedSourcesMatchBaseline(testCase, importResult)
            [returns, dates, series] = importMarketData( ...
                SourceFiles=testCase.sourceFiles, ...
                SeriesNames=["FTSE", "HK"]);
            actual = struct(returns=returns, dates=dates, series=series);

            testCase.verifyEqualsBaseline(actual, importResult, AbsTol=1e-12);
            testCase.verifySize(actual.returns, [3, 2]);
            testCase.verifyEqual(actual.series, ["FTSE", "HK"]);
        end
    end

    methods (Static, Access=private)
        function sourceFiles = writeSources(temporaryFolder)
            priceFile = fullfile(temporaryFolder, "prices.mat");
            returnFile = fullfile(temporaryFolder, "returns.xlsx");

            dates = datenum(datetime(2020, 1, 1) + caldays(0:3));
            Data = [100, 200; 102, 198; 101, 201; 104, 205];
            DataTable = array2table(Data, VariableNames=["FTSE", "CAC"]);
            save(priceFile, "Data", "DataTable", "dates");

            returnTable = table( ...
                datetime(2020, 1, 2) + caldays(0:2)', [1.5; -2; 0.5], ...
                VariableNames=["Time", "HK"]);
            writetable(returnTable, returnFile);

            sourceFiles = [priceFile, returnFile];
        end
    end
end
