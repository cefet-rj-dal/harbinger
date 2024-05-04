#https://physionet.org/files/mitdb/1.0.0/mitdbdir/records.htm
#https://physionet.org/lightwave/?db=mitdb/1.0.0

library(lubridate)
library(dplyr)
library(daltoolbox)
library(ggplot2)

carrega_data <- function(name) {
  load(sprintf("data-gen/%s.rdata", name))
  load(sprintf("data-gen/%s-anot.rdata", name))
  colnames(data) <- c("v1", "v2")
  data$i <- 1:nrow(data)
  data <- merge(x = data, y = anot, by.x = "i", by.y = "anot", all.x = TRUE)
  data$symbol[is.na(data$symbol)] <- "N"
  data$event <- (data$symbol != "N") & (data$symbol != "/")
  return(data)
}

compute_range <- function(data, time) {
  total <- period_to_seconds(hms("0:30:05"))
  sec <- period_to_seconds(hms("0:00:10"))

  time <- period_to_seconds(hms(time))
  n <- nrow(data)
  i <- time * n/total
  sec <- sec * n/total
  data <- data[(data$i > i - sec) & (data$i < i + sec), ]
  return(data)
}

plot_examples <- function(harexe_motifs) {
  font <- theme(text = element_text(size=16))
  for (i in 1:length(harexe_motifs)) {
    data <- harexe_motifs[[i]]
    model <- harbinger()
    model <- fit(model, data$serie)
    detection <- detect(model, data$serie)
    grf <- har_plot(model, data$serie, detection, data$event, idx = 1:nrow(data)) + font
    grf <- grf + ggtitle(names(harexe_motifs)[i])
    plot(grf)
  }
}

save_examples <- function(harexe_motifs) {
  save(harexe_motifs, file="data/harexe_motifs.RData", compress = TRUE)
}


harexe_motifs <- list()

data <- carrega_data("100")
motif_data <- compute_range(data, "00:25:18")
motif_data <- motif_data |> select(serie = v1, event = event, symbol = symbol)
harexe_motifs$simple <- motif_data

data <- carrega_data("102")
motif_data <- compute_range(data, "00:04:56")
motif_data <- motif_data |> select(serie = v2, event = event, symbol = symbol)
harexe_motifs$example2 <- motif_data

{ # time series 15
  i <- seq(0, 25, 0.25)
  x <- cos(i)+i/10
  sdr <- sd(x[1:(length(x)-1)]-x[2:length(x)])
  event <- rep(FALSE, length(x))

  event[25] <- TRUE
  x[25] <- x[25] + 0.5*sdr
  x[26] <- x[26] + 0.25*sdr
  x[27] <- x[27] + 0.5*sdr
  x[28] <- x[28] + 0.5*sdr

  event[50] <- TRUE
  x[50] <- x[25]
  x[51] <- x[26]
  x[52] <- x[27]
  x[53] <- x[28]

  event[75] <- TRUE
  x[75] <- x[25]
  x[76] <- x[26]
  x[77] <- x[27]
  x[78] <- x[28]

  harexe_motifs$sequence <- data.frame(serie = x, event = event)
}



plot_examples(harexe_motifs)
save_examples(harexe_motifs)


