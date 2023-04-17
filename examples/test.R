source("examples/header.R")
options(scipen=999)
library(ggpmisc)
library(dplyr)
library(stringr)

load("examples/temp_yearly.RData")

#data <- identify(temp_yearly$temperature, 10, 3)

model <- har_motif_sax(16, 3, 3)

model <- fit(model, temp_yearly$temperature)
event <- rep(FALSE, nrow(temp_yearly))

detection <- detect(model, temp_yearly$temperature)

i <- detection$seq == "393939"

detection$event[i] <- FALSE
detection$type[i] <- NA
detection$seq[i] <- NA
detection$seqlen[i] <- NA


print(detection |> dplyr::filter(event==TRUE))

grf <- plot.harbinger(model, temp_yearly$temperature, detection, event)
plot(grf)
