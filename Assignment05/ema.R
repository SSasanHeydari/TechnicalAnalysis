ema <- function(data, period) {
  if (length(data) == 0) stop("data must not be empty")
  if (period <= 0 || period != as.integer(period)) stop("period must be a positive integer")

  multiplier <- 2 / (period + 1)
  ema_values <- numeric(length(data))

  for (i in 1:length(data)) {
    if (i == 1) {
      ema_values[i] <- data[i]
    } else {
      ema_values[i] <- (data[i] - ema_values[i - 1]) * multiplier + ema_values[i - 1]
    }
  }

  return(ema_values)
}
