# installation
# install.packages(c("harbinger", "daltoolbox", "dtwclust"))

library(daltoolbox)
library(harbinger)

hmo_dtw_cluster_custom <- function(w = 20, centers = 3, min_cluster_size = 3) {
  obj <- harbinger()
  obj$w <- w
  obj$centers <- centers
  obj$min_cluster_size <- min_cluster_size
  class(obj) <- append("hmo_dtw_cluster_custom", class(obj))
  obj
}

fit.hmo_dtw_cluster_custom <- function(obj, data, ...) {
  windows <- tspredit::ts_data(data, obj$w)
  subsequences <- lapply(seq_len(nrow(windows)), function(i) as.numeric(windows[i, ]))

  obj$model <- dtwclust::tsclust(
    series = subsequences,
    type = "partitional",
    k = obj$centers,
    distance = "dtw_basic",
    centroid = "dba",
    seed = 1L,
    trace = FALSE
  )
  obj
}

detect.hmo_dtw_cluster_custom <- function(obj, serie, ...) {
  n <- length(serie)
  non_na <- which(!is.na(serie))
  serie_clean <- stats::na.omit(serie)

  if (length(serie_clean) < obj$w) {
    stop("Window size must be smaller than the series length.", call. = FALSE)
  }

  if (is.null(obj$model)) {
    obj <- fit(obj, serie_clean)
  }

  cluster_id <- obj$model@cluster
  cluster_sizes <- table(cluster_id)
  selected_clusters <- names(cluster_sizes[cluster_sizes >= obj$min_cluster_size])

  out <- data.frame(event = rep(FALSE, length(serie_clean)), seq = rep(NA, length(serie_clean)))
  if (length(selected_clusters) > 0) {
    seq_counter <- 1
    for (cluster_name in selected_clusters) {
      positions <- which(cluster_id == as.integer(cluster_name))

      # Keep non-overlapping representatives so one motif family does not flood the plot
      selected_positions <- integer(0)
      last_position <- -Inf
      for (pos in positions) {
        if ((pos - last_position) >= obj$w) {
          selected_positions <- c(selected_positions, pos)
          last_position <- pos
        }
      }

      out$event[selected_positions] <- TRUE
      out$seq[selected_positions] <- as.character(seq_counter)
      seq_counter <- seq_counter + 1
    }
  }

  detection <- data.frame(idx = 1:n, event = FALSE, type = "", seq = NA, seqlen = NA)
  detection$event[non_na] <- out$event
  detection$type[detection$event] <- "motif"
  detection$seq[non_na] <- out$seq
  detection$seqlen[detection$event] <- obj$w
  detection
}

data(examples_motifs)
dataset <- examples_motifs$simple

model <- hmo_dtw_cluster_custom(w = 15, centers = 3, min_cluster_size = 3)
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)

head(detection[detection$event, ])

har_plot(model, dataset$serie, detection, dataset$event)
