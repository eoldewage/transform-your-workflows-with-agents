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
%   [...] = importMarketData(...,SheetNames=NAMES) reads each Excel series
%   from the corresponding worksheet. Empty sheet names use the first sheet.
%
%   See also load, readtable, price2ret, intersect

arguments
    options.SourceFiles (1,2) string = ...
        ["Data_GlobalIdx1.mat", "AsianIndexReturns.xlsx"]
    options.SeriesNames (1,2) string = ["FTSE", "HK"]
    options.SheetNames (1,2) string = ["", ""]
end

[firstReturns, firstDates] = loadSeries( ...
    options.SourceFiles(1), options.SeriesNames(1), options.SheetNames(1));
[secondReturns, secondDates] = loadSeries( ...
    options.SourceFiles(2), options.SeriesNames(2), options.SheetNames(2));

[dates, firstRows, secondRows] = intersect(firstDates, secondDates);
returns = [firstReturns(firstRows), secondReturns(secondRows)];
series = options.SeriesNames;

fprintf("Loaded %d observations from %s to %s\n", ...
    size(returns, 1), formatDate(dates(1)), formatDate(dates(end)));
end

function [returns, dates] = loadSeries(sourceFile, seriesName, sheetName)
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
        if strlength(sheetName) == 0
            returnData = readtable(sourceFile, TextType="string");
        else
            returnData = readtable(sourceFile, TextType="string", ...
                Sheet=sheetName);
        end
        dates = datenum(returnData{:, 1});
        returns = returnData{:, seriesName} / 100;

    otherwise
        error("importMarketData:UnsupportedFile", ...
            "Unsupported data source file: %s", sourceFile)
end
end

function text = formatDate(dateNumber)
date = datetime(dateNumber, ConvertFrom="datenum", Format="dd-MMM-yyyy");
text = char(string(date));
end
