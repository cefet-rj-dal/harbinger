gen_data <- function() {
  require(tseries)
  require(forecast)

  examples_harbinger <- list()

  { # nonstationarity
    nonstationarity_sym <- function(ts.len,ts.mean,ts.var) {
      #x variable (time)
      t <- c(1:ts.len)

      #stationary time series
      set.seed(1)
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
      set.seed(1)
      dsta <- cumsum(rnorm(ts.len, mean=ts.mean, sd=sqrt(ts.var)))

      return(c(sta,tsta,lsta,hsta,dsta))
    }

    x <- nonstationarity_sym(ts.len=200,ts.mean=0,ts.var=1)
    i <- 1:length(x)

    event <- rep(FALSE, length(x))
    event[c(200,400,500,600,700,800)] <- TRUE

    examples_harbinger$nonstationarity <- data.frame(serie = x, event = event)
  }

  { # global temperature yearly
    load("data-gen/temp_yearly.RData")
    data <- temp_yearly
    colnames(data) <- c("i", "serie")
    data$event <- FALSE

    examples_harbinger$global_temperature_yearly <- data
  }

  { # global temperature monthly
    load("data-gen/temp_monthly.RData")
    data <- temp_monthly
    colnames(data) <- c("i", "serie")
    data$event <- FALSE

    examples_harbinger$global_temperature_monthly <- data
  }

  {
    set.seed(1)
    n <- 200
    data <- data.frame(serie=rnorm(n), x=rnorm(n))
    data$drift <- ((data$serie > 0) & (data$x > 0)) | ( (data$serie < 0) & (data$x < 0))
    tsantes <- data[data$drift==FALSE,]
    posdrift <- nrow(tsantes) + 1
    tsdepois <- data[data$drift==TRUE,]
    data <- rbind(tsantes, tsdepois)
    rownames(data) <- 1:nrow(data)
    data$drift <- NULL
    data$event <- FALSE
    data$event[posdrift] <- TRUE

    examples_harbinger$multidimensional <- data
  }

  {
    require(readxl)
    require(dplyr)

    seattle <- read_excel("data-gen/seattle.xlsx")
    seattle$Day <- 1:nrow(seattle)
    seattle$Week <- as.integer(seattle$Day/7) + 1
    seattle$serie <- seattle$Avg...5
    seattle$min <- seattle$Min...6
    seattle$max <- seattle$Max...4
    seattle$serie <- (seattle$serie - 32)/1.8
    seattle$min <- (seattle$min - 32)/1.8
    seattle$max <- (seattle$max - 32)/1.8

    seattle <- seattle |> select(day = Day, week = Week, serie = serie, min = min, max = max)

    seattle_daily <- seattle |> select(i = day, serie = serie, min = min, max = max)
    seattle_daily$event <- FALSE
    seattle_daily$event[78:79] <- TRUE

    seattle_week <- seattle |> select(i = week, serie = serie, min = min, max = max) |> group_by(i) |> summarise(min = min(min), serie = mean(serie), max = max(max))
    seattle_week$event <- FALSE
    seattle_week$event[12] <- TRUE


    examples_harbinger$seattle_week <- seattle_week
    examples_harbinger$seattle_daily <- seattle_daily
  }

  return(examples_harbinger)
}

plot_examples <- function(examples_harbinger) {
  require(ggplot2)
  font <- theme(text = element_text(size=16))

  for (i in 1:length(examples_harbinger)) {
    data <- examples_harbinger[[i]]
    model <- harbinger()
    model <- fit(model, data$serie)
    detection <- detect(model, data$serie)
    grf <- har_plot(model, data$serie, detection, data$event, idx = 1:nrow(data))
    grf <- grf + ggtitle(names(examples_harbinger)[i])
    grf <- grf + font
    plot(grf)
  }
}

save_examples <- function(examples_harbinger) {
  save(examples_harbinger, file="data/examples_harbinger.RData", compress = TRUE, version = 2)
}

examples_harbinger <- gen_data()
plot_examples(examples_harbinger)
save_examples(examples_harbinger)

