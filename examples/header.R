library(devtools)
#devtools::install_github("cefet-rj-dal/daltoolbox", force=TRUE)
#devtools::install_github("cefet-rj-dal/harbinger", force=TRUE)

library(forecast)
library(ggplot2)
library(dplyr)
library(reshape)
library(RColorBrewer)
source("examples/graphics.R")
library(readr)
library(tseries)
library(TSPred)
library(daltoolbox)
library(harbinger)
library(gridExtra)

data(har_examples)

save_png <- function(grf, filename, width, height) {
  png(file=filename, width=width, height=height)
  plot(grf)
  dev.off()
}

bp.test <- function(serie) {
  library(lmtest)
  data <- data.frame(x = 1:length(serie), y = serie)
  fit <- lm(y ~ x, data = data)
  return(bptest(fit))
}

nonstationary.test <- function(serie) {
  return(data.frame(adf = round(adf.test(serie)$p.value, 2),
    PP = round(PP.test(as.vector(serie))$p.value, 2),
    bp = round(bp.test(serie)$p.value, 2)))
}

colors <- brewer.pal(9, 'Set1')[c(1:5,7:9)]
font <- theme(text = element_text(size=16))

prepare_grf <- function(grf, xlabel) {
  grf <- grf + theme_bw(base_size = 10)
  grf <- grf + theme(plot.title = element_blank())
  grf <- grf + theme(panel.grid.major = element_blank())
  grf <- grf + theme(panel.grid.minor = element_blank())
  grf <- grf + ylab(xlabel)
  grf <- grf + xlab("time")
  grf <- grf + font
  return(grf)
}

