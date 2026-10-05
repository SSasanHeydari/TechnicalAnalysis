# BDA400 Assignment 2 - Technical Analysis Using R, Preliminary Stage

**Student:** Seyed Sasan Heydari  
**Course:** BDA400 - Data Science Tools and Techniques

## Objective

This folder contains the preliminary stage of the Technical Analysis project. The work demonstrates how to configure an R environment for stock analysis, load a portfolio of stock symbols, download market data, calculate basic statistics, and display the results.

## Files

- `portfolio.txt` - stock symbols used in the analysis.
- `technical_analysis.R` - R functions and execution code for importing stock data, calculating statistics, displaying data, and creating stock charts.
- `screenshots/` - screenshots used to document the setup and execution process.

## Required R Packages

The analysis uses:

```r
install.packages("quantmod")
install.packages("TTR")
```

Load the packages with:

```r
library(quantmod)
library(TTR)
```

## Portfolio

The preliminary portfolio contains:

- AAPL
- MSFT
- GOOG

## Functions

### load_stock_data()

Reads stock symbols from `portfolio.txt` and downloads market data from Yahoo Finance using `quantmod::getSymbols()`.

### calculate_statistics()

Uses closing prices to calculate:

- Mean
- Mode
- Median
- Standard deviation
- 20-day simple moving average

### display_stock_data()

Displays recent observations from each imported stock dataset.

### display_statistics()

Displays the calculated statistics for each stock.

### display_chart()

Creates a stock price chart and adds a 20-day simple moving average.

## Running the Analysis

Set the R working directory to the `Assignment02` folder, then run:

```r
source("technical_analysis.R")
```

Internet access is required while running the script because stock data is downloaded from Yahoo Finance.

## Documentation Checklist

Screenshots should be captured for the final report showing:

1. GitHub repository and Assignment02 folder.
2. R and RStudio installation/setup.
3. Installation/loading of `quantmod` and `TTR`.
4. `portfolio.txt`.
5. Successful stock-data import.
6. Displayed stock data.
7. Calculated statistics.
8. Stock charts with the moving average.

The screenshots and final report will be added after the code is executed locally in RStudio.
