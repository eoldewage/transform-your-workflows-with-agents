function marketData = importMarketData(globalIndexFile, asianIndexFile, options)
%IMPORTMARKETDATA Load aligned FTSE and Asian index returns.

arguments
    globalIndexFile (1, 1) string = "Data_GlobalIdx1.mat"
    asianIndexFile (1, 1) string = "AsianIndexReturns.xlsx"
    options.GlobalIndexSymbol (1, 1) string = "FTSE"
    options.AsianReturnColumn (1, 1) double {mustBeInteger, ...
        mustBeGreaterThanOrEqual(options.AsianReturnColumn, 2)} = 2
    options.AsianDisplayLabel (1, 1) string = "HK"
end

loadedData = load(globalIndexFile);

seriesNames = loadedData.DataTable.Properties.VariableNames;
globalMask = strcmp(seriesNames, options.GlobalIndexSymbol);
globalReturns = price2ret(loadedData.Data(:, globalMask));    % Logarithmic returns

asianTable = readtable(asianIndexFile, VariableNamingRule="preserve");
asianReturns = asianTable{:, options.AsianReturnColumn};
asianDates = parseImportedDates(asianTable{:, 1});
globalDates = datetime(loadedData.dates, ConvertFrom="datenum");

[returnDateTimes, globalDateIndex, asianDateIndex] = intersect( ...
    globalDates(2:end), asianDates, "stable");
if isempty(returnDateTimes)
    error("importMarketData:NoDateOverlap", ...
        "FTSE and Asian index returns do not have overlapping dates.");
end

marketData.Returns = [globalReturns(globalDateIndex), ...
    asianReturns(asianDateIndex) / 100];
marketData.Series = [loadedData.series(globalMask), cellstr(options.AsianDisplayLabel)];
returnDates = datenum(returnDateTimes);
marketData.BaselineDate = returnDates(1) - 1;
marketData.PriceDates = [marketData.BaselineDate; returnDates];
marketData.Dates = marketData.PriceDates;
marketData.Prices = ret2price(marketData.Returns);
marketData.ReturnDates = returnDates;

displayDates = datetime(marketData.PriceDates, ConvertFrom="datenum", Format="dd-MMM-yyyy");
firstObservationLabel = string(displayDates(1));
lastObservationLabel = string(displayDates(end));
fprintf("Loaded %d aligned return observations from %s to %s\n", ...
    size(marketData.Returns, 1), firstObservationLabel, lastObservationLabel);
end

function dates = parseImportedDates(dateValues)
if isdatetime(dateValues)
    dates = dateValues;
    return
end

if isnumeric(dateValues)
    dates = datetime(dateValues, ConvertFrom="excel");
    return
end

dateText = string(dateValues);
if all(contains(dateText, "/"))
    dates = datetime(dateText, InputFormat="dd/MM/uuuu");
else
    dates = datetime(dateText);
end
end
