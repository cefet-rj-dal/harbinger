gen_data <- function() {
  require(tseries)
  require(forecast)

  examples_anomalies <- list()

  {
    i <- seq(0, 25, 0.25)
    x <- cos(i)
    event <- rep(FALSE, length(x))

    event[50] <- TRUE
    x[50] <- x[50] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    examples_anomalies$simple <- data.frame(serie = x, event = event)
  }

  {
    i <- seq(0, 25, 0.25)
    x <- cos(i)
    event <- rep(FALSE, length(x))

    event[50] <- TRUE
    x[50] <- x[50] - 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    examples_anomalies$contextual <- data.frame(serie = x, event = event)
  }

  { # time series 3
    i <- seq(0, 25, 0.25)
    x <- cos(i)+i
    event <- rep(FALSE, length(x))

    event[50] <- TRUE
    x[50] <- x[50] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    examples_anomalies$trend <- data.frame(serie = x, event = event)
  }

  {
    i <- seq(0, 25, 0.25)
    x <- cos(i)
    event <- rep(FALSE, length(x))

    event[30] <- TRUE
    x[30] <- x[30] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    event[50] <- TRUE
    x[50] <- x[50] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    event[70] <- TRUE
    x[70] <- x[70] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    examples_anomalies$multiple <- data.frame(serie = x, event = event)
  }

  {
    i <- seq(0, 25, 0.25)
    x <- cos(i)
    event <- rep(FALSE, length(x))

    event[50] <- TRUE
    desv <- 3*sd(x[1:(length(x)-1)]-x[2:length(x)])
    x[50:52] <- x[50:52] + desv

    examples_anomalies$sequence <- data.frame(serie = x, event = event)
  }

  { # time series 17
    i <- seq(0, 25, 0.25)
    x <- cos(i)
    event <- rep(FALSE, length(x))

    desv <- 3*sd(x[1:(length(x)-1)]-x[2:length(x)])
    x[12] <- x[12] - desv
    x[24] <- x[24] + desv
    x[38] <- x[38] - desv
    x[50] <- x[50] + desv
    x[90] <- x[90] - desv
    x[102] <- x[102] + desv
    event[c(12,24,38,50,90,102)] <- TRUE

    examples_anomalies$tt <- data.frame(serie = x, event = event)
  }

  { # time series 18
    i <- seq(0, 25, 0.25)
    x <- cos(i)
    event <- rep(FALSE, length(x))

    desv <- 3*sd(x[1:(length(x)-1)]-x[2:length(x)])
    x[12] <- x[12] - desv
    x[24] <- x[24] + desv
    x[38] <- x[38] - desv
    x[50] <- x[50] + desv
    x[85] <- x[85] - desv
    x[97] <- x[97] + desv
    event[c(12,24,38,50,85,97)] <- TRUE

    examples_anomalies$tt_warped <- data.frame(serie = x, event = event)
  }
  return(examples_anomalies)
}

plot_examples <- function(examples_anomalies) {
  font <- theme(text = element_text(size=16))

  for (i in 1:length(examples_anomalies)) {
    data <- examples_anomalies[[i]]
    model <- harbinger()
    model <- fit(model, data$serie)
    detection <- detect(model, data$serie)
    grf <- har_plot(model, data$serie, detection, data$event, idx = 1:nrow(data))
    grf <- grf + ggtitle(names(examples_anomalies)[i])
    grf <- grf + font
    plot(grf)
  }
}

save_examples <- function(examples_anomalies) {
  save(examples_anomalies, file="data/examples_anomalies.RData", compress = TRUE, version = 2)
}

examples_anomalies <- gen_data()
plot_examples(examples_anomalies)
save_examples(examples_anomalies)
