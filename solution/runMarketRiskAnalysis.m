function results = runMarketRiskAnalysis(options)
%RUNMARKETRISKANALYSIS Run the FTSE and Asian index market-risk workflow.

arguments
    options.GlobalIndexFile (1, 1) string = "Data_GlobalIdx1.mat"
    options.AsianIndexFile (1, 1) string = "AsianIndexReturns.xlsx"
    options.TrialSize (1, 1) double = 2000
    options.Horizon (1, 1) double = 22
    options.PlotResults (1, 1) logical = true
    options.CloseFigures (1, 1) logical = false
end

if options.CloseFigures
    close all
end

data = importMarketData(options.GlobalIndexFile, options.AsianIndexFile);
model = fitMarketRiskModel(data.Returns);

fprintf("\nfitElapsedSeconds =\n\n   %.4f\n\n", ...
    model.FitElapsedSeconds);
disp("R =")
disp(model.Correlation)
disp("DoF =")
disp(model.DegreesOfFreedom)

sim.TrialSize = options.TrialSize;
sim.Horizon = options.Horizon;
sim.Returns = simulateMarketReturns(options.TrialSize, options.Horizon, model);

tail = analyzeTailRisk(model);

fprintf("\ntailElapsedSeconds =\n\n   %.4f\n\n", tail.ElapsedSeconds);
disp("tailMeanLoss =")
disp(tail.MeanLoss)
disp("tailEventCount =")
disp(tail.EventCount)

if options.PlotResults
    plotRiskResults(data, model, sim, tail);
end

results.MarketData = data;
results.Model = model;
results.Simulation = sim;
results.TailRisk = tail;
end
