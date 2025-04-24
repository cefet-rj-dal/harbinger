gen_data <- function() {
  require(tseries)
  require(forecast)

  examples_changepoints <- list()

  { # simple
    i <- seq(0, 25, 0.25)
    x <- i
    event <- rep(FALSE, length(x))

    x[51:101] <- max(x[51:99]) - x[51:101]
    event[50] <- TRUE

    examples_changepoints$simple <- data.frame(serie = x, event = event)
  }

  { # senoid
    i <- seq(0, 6*pi, 6*pi/100)
    xa <- i[1:50] + sin(i[1:50])
    x <- i[51] + sin(i[51])
    xb <- rev(xa)
    x <- c(xa, xb)

    event <- rep(FALSE, length(x))
    event[50] <- TRUE

    examples_changepoints$sinusoidal <- data.frame(serie = x, event = event)
  }

  { # incremental
    nonstationarity_sym <- function(ts.len,ts.mean,ts.var) {
      #x variable (time)
      t <- c(1:ts.len)

      #stationary time series
      set.seed(1)
      sta <- arima.sim(model=list(ar=0.5), n=ts.len, mean=ts.mean, sd=sqrt(ts.var)) #AR(1)

      #trend-stationary time series
      trend <- 0.04*t
      tsta <- sta + trend

      return(c(sta,tsta))
    }

    x <- nonstationarity_sym(ts.len=100,ts.mean=0,ts.var=1)
    i <- 1:length(x)

    event <- rep(FALSE, length(x))
    event[c(100)] <- TRUE

    examples_changepoints$incremental <- data.frame(serie = x, event = event)
  }

  { # abrupt
    lsta <- function(ts.len,ts.mean,ts.var) {
      t <- c(1:ts.len)

      #stationary time series
      set.seed(1)
      sta <- arima.sim(model=list(ar=0.5), n=ts.len, mean=ts.mean, sd=sqrt(ts.var)) #AR(1)

      #level-stationary time series
      increase.level <- 5
      level <- c(rep(ts.mean,ts.len/2),rep(ts.mean+increase.level,ts.len/2))
      lsta <- sta + level
      return(lsta)
    }

    x <- lsta(ts.len=200,ts.mean=0,ts.var=1)
    i <- 1:length(x)

    event <- rep(FALSE, length(x))
    event[c(100)] <- TRUE

    examples_changepoints$abrupt <- data.frame(serie = x, event = event)
  }

  { # volatility
    hsta <- function(ts.len,ts.mean,ts.var) {
      t <- c(1:ts.len)

      #stationary time series
      set.seed(1)
      sta <- arima.sim(model=list(ar=0.5), n=ts.len, mean=ts.mean, sd=sqrt(ts.var)) #AR(1)

      #heteroscedastic time series (nonstationary in variance)
      increase.var <- 2
      var.level <- c(rep(1,ts.len/2),rep(increase.var,ts.len/2))
      hsta <- sta * var.level

      return(hsta)
    }

    x <- hsta(ts.len=200,ts.mean=0,ts.var=1)
    i <- 1:length(x)

    event <- rep(FALSE, length(x))
    event[c(100)] <- TRUE

    examples_changepoints$volatility <- data.frame(serie = x, event = event)
  }

  {
    i <- seq(0, 100, 0.1)
    x <- cos(i)*rev(i)

    event <- rep(FALSE, length(x))

    event[200] <- TRUE
    event[500] <- TRUE
    event[700] <- TRUE

    x[200] <- x[200] + 1.5*sd(x[(200-25):(200+25)])
    x[500] <- x[500] + 1.5*sd(x[(500-25):(500+25)])
    x[700] <- x[700] + 1.5*sd(x[(700-25):(700+25)])
    dataset <- data.frame(serie = x, event = event)

    plot(dataset$serie, t="l")

    #Série 3: amplitude varia (CP) e anomalias proporcionais (fora)  -- AN eCP
    i <- seq(0, 50, 0.1)
    x <- c(sin(i), sin(i)*3)

    event <- rep(FALSE, length(x))

    event[200] <- TRUE
    event[500] <- TRUE
    event[700] <- TRUE

    x[200] <- x[200] + 1.5*sd(x[(200-25):(200+25)])
    x[700] <- x[700] + 1.5*sd(x[(700-25):(700+25)])
    examples_changepoints$increasing_amplitude <- data.frame(serie = x, event = event)
  }

  {
    set.seed(1)
    n <- 100
    x <- c(sin((1:n)/pi), 2*sin((1:n)/pi), 10 + sin((1:n)/pi), 10-10/n*(1:n)+sin((1:n)/pi)/2, sin((1:n)/pi)/2)
    event <- rep(FALSE, length(x))
    event[c(100,200,300,400)] <- TRUE
    examples_changepoints$complex <- data.frame(serie = x, event = event)
  }

  return(examples_changepoints)
}

plot_examples <- function(examples_changepoints) {
  require(ggplot2)
  font <- theme(text = element_text(size=16))
  for (i in 1:length(examples_changepoints)) {
    data <- examples_changepoints[[i]]
    model <- harbinger()
    model <- fit(model, data$serie)
    detection <- detect(model, data$serie)
    grf <- har_plot(model, data$serie, detection, data$event, idx = 1:nrow(data))
    grf <- grf + ggtitle(names(examples_changepoints)[i])
    grf <- grf + font
    plot(grf)
  }
}

save_examples <- function(examples_changepoints) {
  save(examples_changepoints, file="data/examples_changepoints.RData", compress = TRUE, version = 2)
}

examples_changepoints <- gen_data()
plot_examples(examples_changepoints)
save_examples(examples_changepoints)
