# Handover

Current state: clean Git repo at `9a574c7 Initialize MATLAB project`. MATLAB
project exists at `MarketRiskAnalysis.prj`. Baseline tests exist under `tests`
and the last full run passed: `18 passed, 0 failed, 0 incomplete`.

## Findings

1. Model-fit warnings are not surfaced as model quality state

   `fitMarketRiskModel.m` currently allows `fitdist` convergence warnings to
   pass through while still returning results. This is risky because downstream
   simulation treats the marginal fit as valid.

2. Data import is still tightly coupled to one workflow

   `importMarketData.m` hard-codes `FTSE` and assumes the Asian Excel series is
   column 2. That limits reuse.

3. Date handling is legacy and partially synthetic

   `importMarketData.m` uses `datenum` and `datestr`, and invents a baseline
   date with `returnDates(1) - 1`.

4. Plotting is not general despite reusable function shape

   `plotRiskResults.m` always plots asset 1 diagnostics and assumes exactly two
   assets for the tail scatter plot.

5. Top-level runner has interactive side effects

   `runMarketRiskAnalysis.m` calls `close all`, which is surprising for a
   reusable function.

6. Tail-risk analysis has a known scalability smell

   `analyzeTailRisk.m` grows `tailReturnsData` in a loop. It is acceptable for
   the current small workflow but should be cleaned up before scaling.

7. Core options are hard-coded

   `fitMarketRiskModel.m` fixes the ARIMA/GJR model and optimizer options.

## Step-By-Step Plan

1. Establish red/green discipline for each change.

   For every issue below, first add or update one targeted test that captures
   the intended behavior, run that targeted test and confirm red, implement the
   smallest fix, rerun the targeted test, then run the full suite.

2. Add model-fit diagnostics.

   Extend `fitMarketRiskModel` to capture warnings or fit status per asset and
   expose them in `modelResults`. Add tests that verify warning/status metadata
   exists and current warning behavior is documented.

3. Parameterize market import.

   Add name-value options for the global index symbol, Asian return column, and
   display label. Keep defaults as current `FTSE` + `HK`. Update importer tests
   to cover default behavior and one alternate column/symbol fixture.

4. Modernize date/data import carefully.

   Replace `xlsread`, `datenum`, and `datestr` with `readtable` and `datetime`
   where practical. Preserve existing output compatibility or intentionally
   migrate `marketData.Dates` and `ReturnDates` to `datetime` with tests updated
   first.

5. Remove synthetic date ambiguity.

   Replace `returnDates(1) - 1` with an explicit `PriceDates` or `BaselineDate`
   field so plots do not silently treat a fabricated date as real market data.

6. Make plotting configurable and less brittle.

   Add plot options for diagnostic asset index and number of simulation paths.
   Either validate exactly two assets for tail scatter or support pair
   selection. Add tests for short-history validation with a clear custom error
   ID.

7. Remove top-level side effects.

   Replace unconditional `close all` with an option such as
   `CloseFigures=false`, or move figure cleanup responsibility to callers and
   tests.

8. Improve tail-risk allocation.

   Change `analyzeTailRisk` to collect per-trial results in a cell array and
   concatenate once. Existing tail-risk tests should stay green after the
   implementation.

9. Parameterize model specification.

   Add optional model and optimizer inputs to `fitMarketRiskModel`, keeping
   current ARIMA/GJR defaults. Add tests that verify default behavior and
   accepting caller-provided options.

10. Final verification and commit cadence.

    After each verified change, commit locally. Never push or modify remotes
    without explicit user permission. Final acceptance for the improvement
    branch should be `runtests("tests")` passing under the MATLAB project.
