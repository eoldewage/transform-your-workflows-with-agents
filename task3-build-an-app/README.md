# Market Risk Analysis

MATLAB project for analyzing market risk across aligned UK FTSE and Asian
index returns. The workflow imports market data, fits ARIMA/GJR marginal
models, fits a t copula, simulates return paths, analyzes tail events, and
plots the results.

## Getting Started

Open `MarketRiskAnalysis.prj` in MATLAB so the project manages the MATLAB
path. Then run:

```matlab
results = runMarketRiskAnalysis;
```

To run without plots:

```matlab
results = runMarketRiskAnalysis(PlotResults=false);
```

## Tests

Run the full baseline test suite with:

```matlab
results = runtests("tests");
```
