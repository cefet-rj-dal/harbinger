library(harbinger)

data(examples_changepoints)
dataset <- examples_changepoints$simple

har_plot(harbinger(), dataset$serie, event = dataset$event)

ma_5 <- mas(dataset$serie, order = 5)
ma_15 <- mas(dataset$serie, order = 15)

har_plot(harbinger(), as.numeric(ma_5), event = dataset$event[5:length(dataset$event)])

har_plot(harbinger(), as.numeric(ma_15), event = dataset$event[15:length(dataset$event)])
