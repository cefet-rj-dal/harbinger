nonstationarity_sym <- function(ts.len,ts.mean,ts.var){
  require(tseries)
  require(forecast)
  
  #x variable (time)
  t <- c(1:ts.len)
  
  #stationary time series
  set.seed(1234)
  sta <- arima.sim(model=list(ar=0.5), n=ts.len, mean=ts.mean, sd=sqrt(ts.var)) #AR(1)
  
  #test of stationarity OK!
  #adf.test(sta)
  
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
  
  #test of nonstationarity OK!
  #adf.test(dsta)
  
  c(sta,tsta,lsta,hsta,dsta)
}