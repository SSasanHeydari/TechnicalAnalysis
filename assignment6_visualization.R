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

# User interface
ui <- fluidPage(
  titlePanel("Portfolio Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      dateRangeInput(
        "date_range",
        "Select Date Range:",
        start = start_date,
        end = end_date,
        min = start_date,
        max = end_date
      ),
      
      selectInput(
        "time_frame",
        "Select Time Frame:",
        choices = c("Daily", "Weekly", "Monthly")
      ),

      # Step 3: Select technical indicators to overlay
      checkboxGroupInput(
        "technical_indicators",
        "Technical Indicators:",
        choices = c("Moving Averages", "RSI", "MACD")
      )
    ),
    
    mainPanel(
      plotOutput("stock_chart")
    )
  )
)

# Server
server <- function(input, output) {
  
  output$stock_chart <- renderPlot({
    
    # Filter data based on selected date range
    filtered_data <- stock_data[
      index(stock_data) >= input$date_range[1] &
        index(stock_data) <= input$date_range[2]
    ]
    
    # Convert data to the selected time frame
    if (input$time_frame == "Weekly") {
      filtered_data <- to.weekly(filtered_data, indexAt = "endof")
    } else if (input$time_frame == "Monthly") {
      filtered_data <- to.monthly(filtered_data, indexAt = "endof")
    }
    
    # Prepare data for ggplot2
    plot_data <- data.frame(
      Date = index(filtered_data),
      Close = as.numeric(Cl(filtered_data))
    )

    # Step 3: Calculate technical indicators
    plot_data$MA20 <- as.numeric(SMA(Cl(filtered_data), n = 20))
    plot_data$MA50 <- as.numeric(SMA(Cl(filtered_data), n = 50))
    plot_data$RSI <- as.numeric(RSI(Cl(filtered_data), n = 14))

    macd_values <- MACD(Cl(filtered_data), nFast = 12, nSlow = 26, nSig = 9)
    plot_data$MACD <- as.numeric(macd_values[, 1])
    
    # Create stock price line chart
    p <- ggplot(plot_data, aes(x = Date, y = Close)) +
      geom_line() +
      labs(
        title = paste(stock_symbol, "Stock Price"),
        x = "Date",
        y = "Closing Price"
      )

    # Add selected technical indicators as additional layers
    if ("Moving Averages" %in% input$technical_indicators) {
      p <- p +
        geom_line(aes(y = MA20, linetype = "MA20")) +
        geom_line(aes(y = MA50, linetype = "MA50"))
    }

    if ("RSI" %in% input$technical_indicators) {
      p <- p +
        geom_line(aes(y = RSI, linetype = "RSI"))
    }

    if ("MACD" %in% input$technical_indicators) {
      p <- p +
        geom_line(aes(y = MACD, linetype = "MACD"))
    }
    
    print(p)
  })
}

# Run the Shiny application
shinyApp(ui = ui, server = server)
