library(harbinger)

data(examples_changepoints)
dataset <- examples_changepoints$simple

# Original signal
har_plot(harbinger(), dataset$serie, event = dataset$event)

# Two smoothing levels
ma_5 <- mas(dataset$serie, order = 5)
ma_15 <- mas(dataset$serie, order = 15)

# Plot the smoother with a smaller window
har_plot(harbinger(), as.numeric(ma_5), event = dataset$event[5:length(dataset$event)])

# Plot the smoother with a larger window
har_plot(harbinger(), as.numeric(ma_15), event = dataset$event[15:length(dataset$event)])
