
gen_data <- function() {
  require(tseries)
  require(forecast)

  har_examples <- list()

  { # time series 1
    i <- seq(0, 25, 0.25)
    x <- cos(i)
    event <- rep(FALSE, length(x))

    event[50] <- TRUE
    x[50] <- x[50] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  { # time series 2
    i <- seq(0, 25, 0.25)
    x <- cos(i)
    event <- rep(FALSE, length(x))

    event[50] <- TRUE
    x[50] <- x[50] - 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  { # time series 3
    i <- seq(0, 25, 0.25)
    x <- cos(i)+i
    event <- rep(FALSE, length(x))

    event[50] <- TRUE
    x[50] <- x[50] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  { # time series 4
    i <- seq(0, 25, 0.25)
    x <- i
    event <- rep(FALSE, length(x))

    x[51:101] <- max(x[51:99]) - x[51:101]
    event[50] <- TRUE

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  { # time series 5
    i <- seq(0, 25, 0.25)
    x <- i
    x[51:101] <- max(x[51:99]) - x[51:101]
    event <- rep(FALSE, length(x))

    event[50] <- TRUE
    x[50] <- x[50] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  { # time series 6
    i <- seq(0, 25, 0.25)
    x <- i
    x[51:101] <- max(x[51:99]) - x[51:101]
    event <- rep(FALSE, length(x))

    event[50] <- TRUE
    x[50] <- x[50] - 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  { # time series 7
    i <- seq(0, 25, 0.25)
    x <- cos(i)
    xt <- i
    xt[51:101] <- max(xt[52:100]) - xt[51:101]
    x <- x + xt

    event <- rep(FALSE, length(x))

    event[50] <- TRUE
    x[50] <- x[50] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }


  { # time series 8
    i <- seq(0, 25, 0.25)
    x <- cos(i)
    xt <- i
    xt[51:101] <- max(xt[52:100]) - xt[51:101]
    x <- x + xt

    event <- rep(FALSE, length(x))

    event[50] <- TRUE
    x[50] <- x[50] - 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  nonstationarity_sym <- function(ts.len,ts.mean,ts.var) {
    #x variable (time)
    t <- c(1:ts.len)

    #stationary time series
    set.seed(1234)
    sta <- arima.sim(model=list(ar=0.5), n=ts.len, mean=ts.mean, sd=sqrt(ts.var)) #AR(1)

    #trend-stationary time series
    trend <- 0.04*t
    tsta <- sta + trend

    #level-stationary time series
    increase.level <- 5
    level <- c(rep(ts.mean,ts.len/2),rep(ts.mean+increase.level,ts.len/2))
    lsta <- sta + level

    #heteroscedastic time series (nonstationary in variance)
    increase.var <- 2
    var.level <- c(rep(1,ts.len/2),rep(increase.var,ts.len/2))
    hsta <- sta * var.level

    #difference-stationarity (unit root) (stationary around a stochastic trend)
    set.seed(123)
    dsta <- cumsum(rnorm(ts.len, mean=ts.mean, sd=sqrt(ts.var)))

    return(c(sta,tsta,lsta,hsta,dsta))
  }

  { # time series 9
    x <- nonstationarity_sym(ts.len=200,ts.mean=0,ts.var=1)
    i <- 1:length(x)

    event <- rep(FALSE, length(x))
    event[c(200,400,500,600,700,800)] <- TRUE

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  { # time series 10
    i <- seq(0, 25, 0.25)
    x <- cos(i)
    event <- rep(FALSE, length(x))

    event[30] <- TRUE
    x[30] <- x[30] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    event[50] <- TRUE
    x[50] <- x[50] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    event[70] <- TRUE
    x[70] <- x[70] + 3*sd(x[1:(length(x)-1)]-x[2:length(x)])

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  sta <- function(ts.len,ts.mean,ts.var) {
    t <- c(1:ts.len)

    #stationary time series
    set.seed(1234)
    sta <- arima.sim(model=list(ar=0.5), n=ts.len, mean=ts.mean, sd=sqrt(ts.var)) #AR(1)

    return(sta)
  }

  { # time series 11
    x <- sta(ts.len=200,ts.mean=0,ts.var=1)
    i <- 1:length(x)

    event <- rep(FALSE, length(x))

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  tsta <- function(ts.len,ts.mean,ts.var) {
    t <- c(1:ts.len)

    #stationary time series
    set.seed(1234)
    sta <- arima.sim(model=list(ar=0.5), n=ts.len, mean=ts.mean, sd=sqrt(ts.var)) #AR(1)

    #trend-stationary time series
    trend <- 0.04*t
    tsta <- sta + trend
    return(tsta)
  }

  { # time series 12
    x <- tsta(ts.len=200,ts.mean=0,ts.var=1)
    i <- 1:length(x)

    event <- rep(FALSE, length(x))

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  lsta <- function(ts.len,ts.mean,ts.var) {
    t <- c(1:ts.len)

    #stationary time series
    set.seed(1234)
    sta <- arima.sim(model=list(ar=0.5), n=ts.len, mean=ts.mean, sd=sqrt(ts.var)) #AR(1)

    #level-stationary time series
    increase.level <- 5
    level <- c(rep(ts.mean,ts.len/2),rep(ts.mean+increase.level,ts.len/2))
    lsta <- sta + level
    return(lsta)
  }

  { # time series 13
    x <- lsta(ts.len=200,ts.mean=0,ts.var=1)
    i <- 1:length(x)

    event <- rep(FALSE, length(x))
    event[c(100)] <- TRUE

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  hsta <- function(ts.len,ts.mean,ts.var) {
    t <- c(1:ts.len)

    #stationary time series
    set.seed(1234)
    sta <- arima.sim(model=list(ar=0.5), n=ts.len, mean=ts.mean, sd=sqrt(ts.var)) #AR(1)

    #heteroscedastic time series (nonstationary in variance)
    increase.var <- 2
    var.level <- c(rep(1,ts.len/2),rep(increase.var,ts.len/2))
    hsta <- sta * var.level

    return(hsta)
  }

  { # time series 14
    x <- hsta(ts.len=200,ts.mean=0,ts.var=1)
    i <- 1:length(x)

    event <- rep(FALSE, length(x))
    event[c(100)] <- TRUE

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  { # time series 15
    i <- seq(0, 25, 0.25)
    x <- cos(i)+i/10
    sdr <- sd(x[1:(length(x)-1)]-x[2:length(x)])
    event <- rep(FALSE, length(x))

    event[25] <- TRUE
    x[25] <- x[25] + 0.5*sdr
    x[26] <- x[26] + 0.25*sdr
    x[27] <- x[27] + 0.5*sdr

    event[50] <- TRUE
    x[50] <- x[25]
    x[51] <- x[26]
    x[52] <- x[27]

    event[75] <- TRUE
    x[75] <- x[25]
    x[76] <- x[26]
    x[77] <- x[27]

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  { # time series 16
    i <- seq(0, 25, 0.25)
    x <- cos(i)
    event <- rep(FALSE, length(x))

    event[50] <- TRUE
    desv <- 3*sd(x[1:(length(x)-1)]-x[2:length(x)])
    x[50:52] <- x[50:52] + desv

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  { # time series 17
    i <- seq(0, 28, 0.25)
    x <- cos(i)
    event <- rep(FALSE, length(x))

    desv <- 3*sd(x[1:(length(x)-1)]-x[2:length(x)])
    x[12] <- x[12] - desv
    x[24] <- x[24] + desv
    x[38] <- x[38] - desv
    x[50] <- x[50] + desv
    x[64] <- x[64] - desv
    x[76] <- x[76] + desv
    x[90] <- x[90] - desv
    x[102] <- x[102] + desv
    event[c(12,24,38,50,64,76,90,102)] <- TRUE

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
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
    x[64] <- x[64] - desv
    x[76] <- x[76] + desv
    x[85] <- x[85] - desv
    x[97] <- x[97] + desv
    event[c(12,24,38,50,64,76,85,97)] <- TRUE

    har_examples[[length(har_examples)+1]] <- data.frame(serie = x, event = event)
  }

  return(har_examples)
}


plot_examples <- function(har_examples) {
  for (i in 1:length(har_examples)) {
    data <- har_examples[[i]]
    y <- data$serie
    x <- 1:length(y)
    plot(x = x, y = y)
    lines(x = x, y = y)
  }
}


save_examples <- function(har_examples) {
  save(har_examples, file="./data/har_examples.RData", compress = TRUE)
}


har_examples <- gen_data()
plot_examples(har_examples)
save_examples(har_examples)

