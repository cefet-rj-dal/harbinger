#library(tibble)
#library(EventDetectR)
library(TSPred)

source("develop/har_timeseries.R")
source("develop/old_harbinger.R")

har_examples <- gen_data()

data <- har_examples[[1]]
reference <- data.frame(time = 1:length(data$serie), event = data$event)
reference <- reference[reference$event, ]
data <- data.frame(time = 1:length(data$serie), serie = data$serie)

#====== ChangeFinder (2005) ARIMA
#Detect
events_cf <- har_old_evtdet.changeFinder(data,mdl=har_old_changeFinder.ARIMA,m=5,na.action=na.omit)
#har_old_evaluate
result <- har_old_evaluate(events_cf, reference, metric="confusion_matrix")
print(result)

#====== ChangeFinder (2005) ETS
#Detect
events_cf <- har_old_evtdet.changeFinder(data,mdl=har_old_changeFinder.ets,m=5,na.action=na.omit)
#har_old_evaluate
result <- har_old_evaluate(events_cf, reference, metric="confusion_matrix")
print(result)

#====== ChangeFinder (2005) LR
#Detect
events_cf <- har_old_evtdet.changeFinder(data,mdl=har_old_changeFinder.linreg,m=5,na.action=na.omit)
#har_old_evaluate
result <- har_old_evaluate(events_cf, reference, metric="confusion_matrix")
print(result)

#====== Model Outliers ======
#Detect
events_mdl_outlier <- har_old_evtdet.mdl_outlier(data,mdl=har_old_changeFinder.ARIMA,na.action=na.omit)
#har_old_evaluate
result <- har_old_evaluate(events_mdl_outlier, reference, metric="confusion_matrix")
print(result)

#====== Model Outliers - GARCH ======
#Garch specs
garch <- function(data,spec,...) rugarch::ugarchfit(spec=spec,data=data,solver="hybrid", ...)@fit
garch11 <- rugarch::ugarchspec(variance.model = list(model = "sGARCH", garchOrder = c(1, 1)),
                      mean.model = list(armaOrder = c(1, 1), include.mean = TRUE),
                      distribution.model = "norm")
#Detect
events_mdl_outlier <- har_old_evtdet.mdl_outlier(data,mdl=garch,na.action=na.omit,spec=garch11)
#har_old_evaluate
result <- har_old_evaluate(events_mdl_outlier, reference, metric="confusion_matrix")
print(result)

