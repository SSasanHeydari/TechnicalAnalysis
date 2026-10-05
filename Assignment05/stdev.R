stdev <- function(data) {
  if (length(data) == 0) stop("data must not be empty")

  mean_value <- sum(data) / length(data)
  diff_values <- data - mean_value
  squared_diff <- diff_values * diff_values
  variance <- sum(squared_diff) / length(squared_diff)
  standard_deviation <- sqrt(variance)

  return(standard_deviation)
}
