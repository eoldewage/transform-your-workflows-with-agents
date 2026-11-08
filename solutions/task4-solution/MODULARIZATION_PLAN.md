# Modularization Plan

## Goal

Keep `runMarketRiskAnalysis.m` as the entry-point script. Make supporting
workflows reusable functions and characterize their behavior with focused,
simulated-data regression tests.

## Workflow

Each slice follows red-green-refactor development:

1. Write the focused test before changing behavior.
2. Run that test before the full suite.
3. Run the full suite after the focused test passes.
4. Commit verified changes locally. Do not contact a remote repository.

## Slices

1. Add a temporary-file, simulated-data characterization test for
   `importMarketData`.
2. Refactor `simulateMarketReturns` to accept the shared `modelData` struct
   and add a fixed-RNG regression baseline.
3. Update `analyzeTailRisk` to use the shared simulation interface while
   preserving its current result structure and regression baseline.
4. Convert `plotRiskResults` into a function that accepts an analysis struct
   and returns figure handles. Add a simulated-data graphics test.

## Interfaces

`simulateMarketReturns` will use:

```matlab
simulatedReturns = simulateMarketReturns(modelData, numTrials, horizon);
```

`plotRiskResults` will use:

```matlab
figureHandles = plotRiskResults(analysisData);
```

`analysisData` contains dates, series names, returns, residuals, variances,
simulation settings, simulated returns, and tail-risk results.
