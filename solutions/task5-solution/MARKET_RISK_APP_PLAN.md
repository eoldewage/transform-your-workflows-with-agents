# MATLAB Market-Risk Dashboard App

## Summary

Build `marketRiskApp.m`, a function-based MATLAB UI that opens with FTSE and
HK analysed. Users can select any two distinct series from the global MAT
file and Asian Excel workbook and see all risk plots in one dashboard.

## Behaviour

- Show residuals, volatility, simulated returns, and tail-event samples in a
  2-by-2 dashboard.
- Start with 200 paths, a 22-day horizon, and a -3% tail threshold.
- Refresh immediately when either selected series changes.
- Apply edited simulation settings only after the user presses Regenerate.
- Use the selected path count and horizon for both the return-path and
  tail-event simulations.

## Implementation

- Extend `importMarketData` so each selected Excel series can identify its
  worksheet while preserving current default behaviour.
- Extract the existing analysis pipeline into a reusable helper for the app
  and workflow script.
- Extend `plotRiskResults` with an embedded, four-axis rendering mode while
  retaining its existing standalone-figure interface.
- Add the app, including source-qualified selectors, status feedback, and
  validation.

## Verification

- Add tests first for cross-format, MAT/MAT, and Excel/Excel imports.
- Add tests for embedded plotting and app refresh/settings behaviour.
- Run focused tests, then the full suite and static checks.
- Create one local Git commit after verification; do not push.
