classdef importMarketDataTest < matlab.unittest.TestCase
    %importMarketDataTest Tests for importMarketData.

    methods (TestClassSetup)
        function addSourceToPath(testCase)
            sourceFolder = fileparts(fileparts(mfilename("fullpath")));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(sourceFolder));
        end
    end

    methods (Test)
        function testLoadsAlignedFtseAndAsianReturns(testCase)
            files = importMarketDataTest.createFixture(testCase, "aligned");

            data = importMarketData(files.Global, files.Asian);

            expectedFtseReturns = price2ret([100; 102; 101; 103; 104]);
            testCase.verifyEqual(data.Returns(:, 1), expectedFtseReturns, AbsTol=1e-12);
            testCase.verifyEqual(data.Returns(:, 2), [0.01; -0.02; 0.03; 0.04], AbsTol=1e-12);
            testCase.verifyEqual(data.Series, {'FTSE', 'HK'});
            testCase.verifyEqual(data.ReturnDates, datenum(2020, 1, (2:5)'), AbsTol=0);
            testCase.verifyEqual(data.Dates, datenum(2020, 1, (1:5)'), AbsTol=0);
            testCase.verifyEqual(data.BaselineDate, datenum(2020, 1, 1), AbsTol=0);
            testCase.verifyEqual(data.PriceDates, datenum(2020, 1, (1:5)'), AbsTol=0);
            testCase.verifySize(data.Prices, [5 2]);
        end

        function testLoadsConfiguredGlobalSymbolAndAsianColumn(testCase)
            files = importMarketDataTest.createFixture(testCase, "alternateColumns");

            data = importMarketData(files.Global, files.Asian, ...
                GlobalIndexSymbol="DAX", ...
                AsianReturnColumn=3, ...
                AsianDisplayLabel="SG");

            expectedGlobalReturns = price2ret([50; 51; 53; 52; 54]);
            testCase.verifyEqual(data.Returns(:, 1), expectedGlobalReturns, AbsTol=1e-12);
            testCase.verifyEqual(data.Returns(:, 2), [0.02; 0.04; -0.01; 0.03], AbsTol=1e-12);
            testCase.verifyEqual(data.Series, {'DAX', 'SG'});
            testCase.verifyEqual(data.ReturnDates, datenum(2020, 1, (2:5)'), AbsTol=0);
        end

        function testLoadsIsoDateText(testCase)
            files = importMarketDataTest.createFixture(testCase, "isoDates");

            data = importMarketData(files.Global, files.Asian);

            testCase.verifyEqual(data.Returns(:, 2), [0.01; -0.02; 0.03; 0.04], AbsTol=1e-12);
            testCase.verifyEqual(data.ReturnDates, datenum(2020, 1, (2:5)'), AbsTol=0);
        end

        function testKeepsOnlyOverlappingReturnDates(testCase)
            files = importMarketDataTest.createFixture(testCase, "partialOverlap");

            data = importMarketData(files.Global, files.Asian);

            expectedFtseReturns = price2ret([100; 102; 101; 103; 104]);
            testCase.verifyEqual(data.Returns(:, 1), expectedFtseReturns([2; 4]), AbsTol=1e-12);
            testCase.verifyEqual(data.Returns(:, 2), [0.03; 0.05], AbsTol=1e-12);
            testCase.verifyEqual(data.ReturnDates, datenum(2020, 1, [3; 5]), AbsTol=0);
            testCase.verifyEqual(data.Dates, datenum(2020, 1, [2; 3; 5]), AbsTol=0);
        end

        function testNoOverlappingDatesErrors(testCase)
            files = importMarketDataTest.createFixture(testCase, "noOverlap");

            testCase.verifyError(@() importMarketData(files.Global, files.Asian), ...
                "importMarketData:NoDateOverlap");
        end
    end

    methods (Static, Access=private)
        function files = createFixture(testCase, fixtureName)
            tmpDir = tempname;
            mkdir(tmpDir);
            testCase.addTeardown(@() rmdir(tmpDir, "s"));

            files.Global = fullfile(tmpDir, "global.mat");
            files.Asian = fullfile(tmpDir, "asian.xlsx");

            switch fixtureName
                case "alternateColumns"
                    Data = [[100; 102; 101; 103; 104], [50; 51; 53; 52; 54]];
                    DataTable = array2table(Data, VariableNames={'FTSE', 'DAX'});
                    series = {'FTSE', 'DAX'};
                otherwise
                    Data = [(10:14)', [100; 102; 101; 103; 104]];
                    DataTable = array2table(Data, VariableNames={'CAC', 'FTSE'});
                    series = {'CAC', 'FTSE'};
            end
            dates = datenum(2020, 1, (1:5)');
            save(files.Global, "Data", "DataTable", "dates", "series");

            importMarketDataTest.writeAsianFixture(files.Asian, fixtureName);
        end

        function writeAsianFixture(asianFile, fixtureName)
            switch fixtureName
                case "aligned"
                    asianRows = {
                        'Time',       'HK'
                        '02/01/2020',  1
                        '03/01/2020', -2
                        '04/01/2020',  3
                        '05/01/2020',  4};
                case "partialOverlap"
                    asianRows = {
                        'Time',       'HK'
                        '31/12/2019',  9
                        '03/01/2020',  3
                        '05/01/2020',  5
                        '07/01/2020',  7};
                case "noOverlap"
                    asianRows = {
                        'Time',       'HK'
                        '02/01/2021',  1
                        '03/01/2021',  2};
                case "alternateColumns"
                    asianRows = {
                        'Time',       'HK', 'SG'
                        '02/01/2020',  1,    2
                        '03/01/2020', -2,    4
                        '04/01/2020',  3,   -1
                        '05/01/2020',  4,    3};
                case "isoDates"
                    asianRows = {
                        'Time',       'HK'
                        '2020-01-02',  1
                        '2020-01-03', -2
                        '2020-01-04',  3
                        '2020-01-05',  4};
            end
            writecell(asianRows, asianFile);
        end
    end
end
