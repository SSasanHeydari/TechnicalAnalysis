# Assignment 6: Technical Analysis Using R - Visualization Phase
# BDA400 - Data Science Tools and Techniques
# Seyed Sasan Heydari

# Step 1: Data Collection and Setup
library(shiny)
library(ggplot2)
library(quantmod)

# Stock settings
stock_symbol <- "AAPL"
start_date <- "2023-01-01"
end_date <- "2023-07-01"

# Fetch historical stock data from Yahoo Finance
stock_data <- getSymbols(
  stock_symbol,
  src = "yahoo",
  from = start_date,
  to = end_date,
  auto.assign = FALSE
)

# Display the first rows of the data
head(stock_data)
