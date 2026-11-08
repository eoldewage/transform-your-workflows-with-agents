function [returns, dates, series] = importMarketData(options)
%importMarketData - Load and align daily returns for two market series
%   [RETURNS,DATES,SERIES] = importMarketData loads the default FTSE and
%   Hong Kong series, converts prices or percentage returns to decimal
%   daily returns, and aligns both series by date.
%
%   [...] = importMarketData(SourceFiles=FILES,SeriesNames=NAMES) loads
%   the two named series from FILES. FILES and NAMES are two-element
%   string arrays. A source file may be specified for both series.
%
%   See also load, readtable, price2ret, intersect

arguments
    options.SourceFiles (1,2) string = ...
        ["Data_GlobalIdx1.mat", "AsianIndexReturns.xlsx"]
    options.SeriesNames (1,2) string = ["FTSE", "HK"]
end

[firstReturns, firstDates] = loadSeries( ...
    options.SourceFiles(1), options.SeriesNames(1));
[secondReturns, secondDates] = loadSeries( ...
    options.SourceFiles(2), options.SeriesNames(2));

[dates, firstRows, secondRows] = intersect(firstDates, secondDates);
returns = [firstReturns(firstRows), secondReturns(secondRows)];
series = options.SeriesNames;

fprintf("Loaded %d observations from %s to %s\n", ...
    size(returns, 1), datestr(dates(1)), datestr(dates(end)));
end

function [returns, dates] = loadSeries(sourceFile, seriesName)
[~, ~, extension] = fileparts(sourceFile);

switch lower(extension)
    case ".mat"
        loadedData = load(sourceFile);
        indexMask = string(loadedData.DataTable.Properties.VariableNames) ...
            == seriesName;
        prices = loadedData.Data(:, indexMask);
        returns = price2ret(prices);
        dates = loadedData.dates(2:end);

    case {".xls", ".xlsx"}
        returnData = readtable(sourceFile, TextType="string");
        dates = datenum(returnData{:, 1});
        returns = returnData{:, seriesName} / 100;

    otherwise
        error("importMarketData:UnsupportedFile", ...
            "Unsupported data source file: %s", sourceFile)
end
end
