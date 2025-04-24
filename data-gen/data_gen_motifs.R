#https://physionet.org/files/mitdb/1.0.0/mitdbdir/records.htm
#https://physionet.org/lightwave/?db=mitdb/1.0.0

gen_data <- function() {
  require(lubridate)
  require(dplyr)
  require(daltoolbox)

  examples_motifs <- list()

  { # simple motif
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

    examples_motifs$simple <- data.frame(serie = x, event = event)
  }


  { #mitdb

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

    data <- carrega_data("100")
    motif_data <- compute_range(data, "00:25:18")
    motif_data <- motif_data |> select(serie = v1, event = event, symbol = symbol)
    examples_motifs$mitdb100 <- motif_data

    data <- carrega_data("102")
    motif_data <- compute_range(data, "00:04:56")
    motif_data <- motif_data |> select(serie = v2, event = event, symbol = symbol)
    examples_motifs$mitdb102 <- motif_data
  }

  return(examples_motifs)
}

plot_examples <- function(examples_motifs) {
  font <- theme(text = element_text(size=16))
  for (i in 1:length(examples_motifs)) {
    data <- examples_motifs[[i]]
    model <- harbinger()
    model <- fit(model, data$serie)
    detection <- detect(model, data$serie)
    grf <- har_plot(model, data$serie, detection, data$event, idx = 1:nrow(data))
    grf <- grf + ggtitle(names(examples_motifs)[i])
    grf <- grf + font
    plot(grf)
  }
}

save_examples <- function(examples_motifs) {
  save(examples_motifs, file="data/examples_motifs.RData", compress = TRUE, version = 2)
}


examples_motifs <- gen_data()
plot_examples(examples_motifs)
save_examples(examples_motifs)


