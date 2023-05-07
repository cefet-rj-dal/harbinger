source("examples/header.R")
options(scipen=999)
library(ggpmisc)
library(dplyr)
library(stringr)

load("examples/temp_yearly.RData")

#data <- identify(temp_yearly$temperature, 10, 3)

model <- har_motif_sax(10, 3, 3)

model <- fit(model, temp_yearly$temperature)
event <- rep(FALSE, nrow(temp_yearly))

detection <- detect(model, temp_yearly$temperature)

print(detection |> dplyr::filter(event==TRUE))

grf <- plot.harbinger(model, temp_yearly$temperature, detection, event)
plot(grf)
