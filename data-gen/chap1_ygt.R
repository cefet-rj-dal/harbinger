source("header.R")
library(daltoolbox)
library(harbinger)

load("data/noaa-global/temp_yearly.RData")
data <- temp_yearly
data$event <- FALSE

model <- harbinger()
model <- fit(model, data$temperature)
detection <- detect(model, data$temperature)
grf <- har_plot(model, data$temperature, detection, data$event, idx = data$x) +
  font + 
  scale_x_date(breaks = "10 years",  date_labels = "%Y",  limits = c(as.Date("1850-01-01"), as.Date("2030-01-01"))) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 
save_png(grf, "figures/chap1_ygt.png", 1280, 720)
