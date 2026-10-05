# BDA400 - Assignment 2: Technical Analysis Using R, Preliminary Stage
# Student: Seyed Sasan Heydari
# Purpose: Load stock market data, compute basic statistics, and display results.

# Required packages
library(quantmod)
library(TTR)

# Calculate the statistical mode of a numeric vector.
calculate_mode <- function(x) {
  x <- na.omit(x)
  if (length(x) == 0) return(NA_real_)
  values <- unique(x)
  values[which.max(tabulate(match(x, values)))]
}

# Read symbols from portfolio.txt and download stock data from Yahoo Finance.
load_stock_data <- function(file = "portfolio.txt",
                            from = Sys.Date() - 365,
                            to = Sys.Date()) {
  symbols <- trimws(readLines(file, warn = FALSE))
  symbols <- symbols[nzchar(symbols)]

  if (length(symbols) == 0) {
    stop("No stock symbols were found in portfolio.txt.")
  }

  stock_data <- list()

  for (symbol in symbols) {
    message("Loading: ", symbol)
    stock_data[[symbol]] <- getSymbols(
      symbol,
      src = "yahoo",
      from = from,
      to = to,
      auto.assign = FALSE
    )
  }

  stock_data
}

# Compute the statistics required by the assignment using closing prices.
calculate_statistics <- function(stock, moving_average_period = 20) {
  prices <- as.numeric(Cl(stock))
  moving_average <- SMA(prices, n = moving_average_period)

  data.frame(
    Mean = mean(prices, na.rm = TRUE),
    Mode = calculate_mode(prices),
    Median = median(prices, na.rm = TRUE),
    Standard_Deviation = sd(prices, na.rm = TRUE),
    Latest_Moving_Average = tail(na.omit(moving_average), 1),
    Moving_Average_Period = moving_average_period
  )
}

# Display recent imported observations for every stock.
display_stock_data <- function(stock_data, rows = 6) {
  for (symbol in names(stock_data)) {
    cat("\n==============================\n")
    cat("Stock:", symbol, "\n")
    cat("==============================\n")
    print(tail(stock_data[[symbol]], rows))
  }
}

# Calculate and display statistics for every stock.
display_statistics <- function(stock_data) {
  results <- lapply(stock_data, calculate_statistics)

  for (symbol in names(results)) {
    cat("\nStatistics for", symbol, "\n")
    print(results[[symbol]])
  }

  invisible(results)
}

# Create a price chart with a 20-day simple moving average.
display_chart <- function(stock, symbol, moving_average_period = 20) {
  chartSeries(
    stock,
    name = paste(symbol, "Stock Price"),
    theme = chartTheme("white"),
    TA = paste0("addSMA(n=", moving_average_period, ")")
  )
}

# -----------------------------
# Run the preliminary analysis
# -----------------------------

stock_data <- load_stock_data("portfolio.txt")

display_stock_data(stock_data)

statistics <- display_statistics(stock_data)

for (symbol in names(stock_data)) {
  display_chart(stock_data[[symbol]], symbol)
}
