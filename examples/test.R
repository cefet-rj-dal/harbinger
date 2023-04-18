#source("examples/header.R")
options(scipen=999)
library(ggpmisc)
library(dplyr)
library(stringr)

#load("examples/temp_yearly.RData")

data <- har_examples[[15]]

model <- har_motif_sax(25, 3, 3)

model <- fit(model, data$serie)
event <- rep(FALSE, nrow(data))

detection <- detect(model, data$serie)

print(detection |> dplyr::filter(event==TRUE))

grf <- plot.harbinger(model, data$serie, detection, data$event)
plot(grf)
