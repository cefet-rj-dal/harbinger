library(tibble)
library(EventDetectR)

source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/harbinger.R")

#========= Data =========
# === WATER QUALITY ===
train <- geccoIC2018Train[16500:18000,]
test <- subset(train, select=c(Time, Trueb))
reference <- subset(train, select=c(Time, EVENT))

# === NONSTATIONARITY ===
source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/nonstationarity_sym.r")
nonstat_ts <- nonstationarity_sym(ts.len=200,ts.mean=0,ts.var=1)
#plot(ts(nonstat_ts),type="l",xlab="time",ylab="x")

test <- data.frame(time=1:length(nonstat_ts),x=nonstat_ts)
reference <- data.frame(time=1:length(nonstat_ts),event=0)
reference[c(200,400,500,600,700,800), "event"] <- 1

#test[runif(200, 1, 1501), "pH"] <- NA

#====== Anomalize ======
#Detect
events_a <- evtdet.anomalize(test,max_anoms=0.2,na.action=na.omit)
#Evaluate
evaluate(events_a, reference, metric="confusion_matrix")
#Plot
print(evtplot(test,events_a, reference))


#====== EventDetect ======
#Detect
events_ed <- evtdet.eventdetect(train)
#Evaluate
evaluate(events_ed, reference, metric="confusion_matrix")


#====== Change point V1 (1999) ======
#Detect
events_cp_v1 <- evtdet.changepoints_v1(test, w=50,na.action=na.omit)
#Evaluate
evaluate(events_cp_v1, reference, metric="confusion_matrix")
#Plot
print(evtplot(test,events_cp_v1, reference))


#====== Auxiliary Model definitions ======
ARIMA <- function(data) forecast::auto.arima(data)
AR <- function(data,p) forecast::Arima(data, order = c(p, 0, 0), seasonal = c(0, 0, 0))
garch <- function(data,spec,...) rugarch::ugarchfit(spec=spec,data=data,solver="hybrid", ...)@fit
ets <- function(data) forecast::ets(ts(data))
linreg <- function(data) {
  #browser()
  data <- as.data.frame(data)
  colnames(data) <- "x"
  data$t <- 1:nrow(data)
  
  #Adjusting a linear regression to the whole window
  lm(x~t, data)
}


#====== Change point V2 (1999) ======
events_cp_v2 <- evtdet.changepoints_v2(test,w=100,mdl=linreg,na.action=na.omit)
evaluate(events_cp_v2, reference, metric="confusion_matrix")
print(evtplot(test,events_cp_v2, reference))


#====== Change point V3 (2005) ======
#Detect
events_cp_v3 <- evtdet.changepoints_v3(test,mdl=ARIMA,m=5,na.action=na.omit)
#Evaluate
evaluate(events_cp_v3, reference, metric="confusion_matrix")
#Plot
print(evtplot(test,events_cp_v3, reference, mark.cp=TRUE))


#====== Adaptive Normalization Outliers ======
#Detect
events_an <- evtdet.an_outliers(test,w=100,alpha=1.5,na.action=na.omit)
#Evaluate
evaluate(events_an, reference, metric="confusion_matrix")
#Plot
print(evtplot(test,events_an, reference))


#====== OTSAD ======
#Detect
events_otsad <- evtdet.otsad(test,method="CpPewma", n.train = 50, alpha0 = 0.9, beta = 0.1, l = 3)
#events_otsad <- evtdet.otsad(test,method="ContextualAnomalyDetector", rest.period = 10, base.threshold = 0.9)
#events_otsad <- evtdet.otsad(test,method="CpKnnCad", n.train = 50, threshold = 1, l = 19, k = 27, ncm.type = "LDCD", reducefp = TRUE)
#events_otsad <- evtdet.otsad(test,method="CpSdEwma", n.train = 50, threshold = 0.02, l = 3)
#events_otsad <- evtdet.otsad(test,method="CpTsSdEwma", n.train = 50, threshold = 0.02, l = 3, m = 20)
#events_otsad <- evtdet.otsad(test,method="IpPewma", alpha0 = 0.9, beta = 0.1, n.train = 50, l = 3, last.res = NULL)
#events_otsad <- evtdet.otsad(test,method="IpKnnCad", n.train = 50, threshold = 1, l = 19, k = 27, ncm.type = "LDCD", reducefp = TRUE, to.next.iteration = NULL)
#Evaluate
evaluate(events_otsad, reference, metric="confusion_matrix")
#Plot
print(evtplot(test,events_otsad, reference))


#====== Outliers ======
#Detect
events_out <- evtdet.changepoints_v1(test, alpha=1.5)
#Evaluate
evaluate(events_out, reference, metric="confusion_matrix")
#Plot
print(evtplot(test,events_out, reference))


#====== Model Outliers ======
#Detect
events_mdl_outlier <- evtdet.mdl_outlier(test,mdl=ARIMA,na.action=na.omit)
#Evaluate
evaluate(events_mdl_outlier, reference, metric="confusion_matrix")
#Plot
print(evtplot(test,events_mdl_outlier, reference))


#====== Model Outliers - GARCH ======
#Garch specs
garch11 <- rugarch::ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)), 
                      mean.model = list(armaOrder = c(1, 1), include.mean = TRUE), 
                      distribution.model = "norm")
#Detect
events_mdl_outlier <- evtdet.mdl_outlier(test,mdl=garch,na.action=na.omit,spec=garch11)
#Evaluate
evaluate(events_mdl_outlier, reference, metric="confusion_matrix")
#Plot
print(evtplot(test,events_mdl_outlier, reference))


#====== Garch Volatility Outliers ======
#Garch specs
garch11 <- rugarch::ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)), 
                               mean.model = list(armaOrder = c(1, 1), include.mean = TRUE), 
                               distribution.model = "norm")
#Detect
events_garch_volatility_outlier <- evtdet.garch_volatility_outlier(test,spec=garch11,alpha=1.5,na.action=na.omit)
#Evaluate
evaluate(events_garch_volatility_outlier, reference, metric="confusion_matrix")
#Plot
print(evtplot(test,events_garch_volatility_outlier, reference))