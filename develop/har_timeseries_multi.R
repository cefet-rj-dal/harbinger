gen_data_multi <- function() {
  require(tseries)
  require(forecast)

  har_examples_multi <- list()

  { # time series 1
    i <- seq(-1, 1, 2/100)
    x <- 2*cos(i)
    x[50] <- x[50]
    y <- rep(0, length(i))
    y[as.logical((1:length(i)) %% 2)] <- 1
    y[50] <- 0.4257812
    event <- rep(FALSE, length(x))
    event[50] <- TRUE
    har_examples_multi[[length(har_examples_multi)+1]] <- data.frame(x = x, y = y, event = event)
  }

  return (har_examples_multi)
}


save_examples_multi <- function(har_examples_multi) {
  save(har_examples_multi, file="./data/har_examples_multi.RData", compress = TRUE)
}

plot_examples_multi <- function(har_examples_multi) {
  for (i in 1:length(har_examples_multi)) {
    data <- har_examples_multi[[i]]
    data <- data[,!(colnames(data) %in% c("event"))]
    x <- 1:nrow(data)
    for (j in 1:ncol(data)){
      plot(x = x, y = data[,j])
      lines(x = x, y = data[,j])
    }
  }
}

har_examples_multi <- gen_data_multi()
plot_examples_multi(har_examples_multi)
save_examples_multi(har_examples_multi)
