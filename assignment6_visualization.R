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

# Step 2: Visualizing Stock Data

ui <- fluidPage(
  titlePanel("Portfolio Dashboard"),
  sidebarLayout(
    sidebarPanel(
      dateRangeInput(
        "date_range", "Select Date Range:",
        start = start_date, end = end_date,
        min = start_date, max = end_date
      ),
      selectInput(
        "time_frame", "Select Time Frame:",
        choices = c("Daily", "Weekly", "Monthly")
      ),
      checkboxGroupInput(
        "technical_indicators", "Technical Indicators:",
        choices = c("Moving Averages", "RSI", "MACD")
      )
    ),
    mainPanel(
      plotOutput("stock_chart")
    )
  )
)

server <- function(input, output) {

  output$stock_chart <- renderPlot({

    # Filter data based on selected date range
    filtered_data <- stock_data[
      index(stock_data) >= input$date_range[1] &
        index(stock_data) <= input$date_range[2]
    ]

    # Convert data to selected time frame
    if (input$time_frame == "Weekly") {
      filtered_data <- to.weekly(filtered_data, indexAt = "endof")
    } else if (input$time_frame == "Monthly") {
      filtered_data <- to.monthly(filtered_data, indexAt = "endof")
    }

    validate(
      need(NROW(filtered_data) > 0, "No stock data is available for this date range.")
    )

    # Prepare data for ggplot2
    plot_data <- data.frame(
      Date = index(filtered_data),
      Close = as.numeric(Cl(filtered_data))
    )

    number_of_rows <- NROW(filtered_data)

    # Step 3: Calculate technical indicators only when enough data exists
    plot_data$MA20 <- NA_real_
    plot_data$MA50 <- NA_real_
    plot_data$RSI <- NA_real_
    plot_data$MACD <- NA_real_

    if (number_of_rows >= 20) {
      plot_data$MA20 <- as.numeric(SMA(Cl(filtered_data), n = 20))
    }

    if (number_of_rows >= 50) {
      plot_data$MA50 <- as.numeric(SMA(Cl(filtered_data), n = 50))
    }

    if (number_of_rows >= 14) {
      plot_data$RSI <- as.numeric(RSI(Cl(filtered_data), n = 14))
    }

    if (number_of_rows >= 26) {
      macd_values <- MACD(Cl(filtered_data), nFast = 12, nSlow = 26, nSig = 9)
      plot_data$MACD <- as.numeric(macd_values[, 1])
    }

    # Step 4: Moving Average crossover trading rule
    # Buy: MA20 is above MA50
    # Sell: MA20 is below MA50
    # Hold: insufficient data or the averages are equal
    plot_data$Signal <- "Hold"

    if (number_of_rows >= 50) {
      plot_data$Signal <- ifelse(
        is.na(plot_data$MA20) | is.na(plot_data$MA50),
        "Hold",
        ifelse(
          plot_data$MA20 > plot_data$MA50,
          "Buy",
          ifelse(plot_data$MA20 < plot_data$MA50, "Sell", "Hold")
        )
      )
    }

    # Create stock price line chart
    p <- ggplot(plot_data, aes(x = Date, y = Close)) +
      geom_line() +
      labs(
        title = paste(stock_symbol, "Stock Price"),
        x = "Date",
        y = "Closing Price"
      )

    # Add selected technical indicators
    if ("Moving Averages" %in% input$technical_indicators) {
      if (number_of_rows >= 20) {
        p <- p + geom_line(aes(y = MA20, linetype = "MA20"), na.rm = TRUE)
      }
      if (number_of_rows >= 50) {
        p <- p + geom_line(aes(y = MA50, linetype = "MA50"), na.rm = TRUE)
      }
    }

    if ("RSI" %in% input$technical_indicators && number_of_rows >= 14) {
      p <- p + geom_line(aes(y = RSI, linetype = "RSI"), na.rm = TRUE)
    }

    if ("MACD" %in% input$technical_indicators && number_of_rows >= 26) {
      p <- p + geom_line(aes(y = MACD, linetype = "MACD"), na.rm = TRUE)
    }

    # Annotate trading signals on the stock price chart
    annotation_step <- max(1, floor(number_of_rows / 15))
    annotation_data <- plot_data[seq(1, number_of_rows, by = annotation_step), ]

    p <- p +
      geom_text(
        data = annotation_data,
        aes(x = Date, y = Close, label = Signal),
        inherit.aes = FALSE,
        vjust = 1.5,
        check_overlap = TRUE
      )

    print(p)
  })
}

shinyApp(ui = ui, server = server)
