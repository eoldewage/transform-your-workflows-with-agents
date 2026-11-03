%% Import market data
% This script leaves variables in the base workspace for downstream scripts.

loadedData = load("Data_GlobalIdx1.mat");

franceMask = loadedData.DataTable.Properties.VariableNames == "CAC";
ukMask = loadedData.DataTable.Properties.VariableNames == "FTSE";

data = loadedData.Data(:, franceMask | ukMask);
series = loadedData.series(franceMask | ukMask);

dates = loadedData.dates;
firstObservationLabel = datestr(dates(1));
lastObservationLabel = datestr(dates(end));

% Old spreadsheet import kept in the inherited code path.
[asianReturns, asianDateText] = xlsread("AsianIndexReturns.xlsx");
asianDates = datenum(asianDateText(2:end, 1), "dd/mm/yyyy");

fprintf("Loaded %d observations from %s to %s\n", ...
    size(data, 1), firstObservationLabel, lastObservationLabel);
