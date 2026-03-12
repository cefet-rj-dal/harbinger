# installation
# install.packages(c("harbinger", "daltoolbox"))

library(daltoolbox)
library(harbinger)

har_eval_range_custom <- function(alpha = 0.5) {
  obj <- daltoolbox::dal_base()
  obj$alpha <- alpha
  class(obj) <- append("har_eval_range_custom", class(obj))
  obj
}

to_ranges <- function(flags) {
  flags <- as.logical(flags)
  flags[is.na(flags)] <- FALSE

  idx <- which(flags)
  if (length(idx) == 0) {
    return(data.frame(start = integer(0), end = integer(0), length = integer(0)))
  }

  groups <- split(idx, cumsum(c(1, diff(idx) != 1)))
  starts <- vapply(groups, min, integer(1))
  ends <- vapply(groups, max, integer(1))
  data.frame(start = starts, end = ends, length = ends - starts + 1)
}

range_overlap <- function(a_start, a_end, b_start, b_end) {
  max(0, min(a_end, b_end) - max(a_start, b_start) + 1)
}

evaluate.har_eval_range_custom <- function(obj, detection, event, ...) {
  det_ranges <- to_ranges(detection)
  evt_ranges <- to_ranges(event)

  if (nrow(det_ranges) == 0 || nrow(evt_ranges) == 0) {
    return(list(
      precision = 0,
      recall = 0,
      F1 = 0,
      alpha = obj$alpha,
      detected_ranges = det_ranges,
      event_ranges = evt_ranges
    ))
  }

  recall_scores <- numeric(nrow(evt_ranges))
  for (i in seq_len(nrow(evt_ranges))) {
    overlaps <- mapply(
      range_overlap,
      evt_ranges$start[i], evt_ranges$end[i],
      det_ranges$start, det_ranges$end
    )
    best_overlap <- max(overlaps)
    existence_reward <- as.numeric(best_overlap > 0)
    overlap_reward <- best_overlap / evt_ranges$length[i]
    recall_scores[i] <- obj$alpha * existence_reward + (1 - obj$alpha) * overlap_reward
  }

  precision_scores <- numeric(nrow(det_ranges))
  for (i in seq_len(nrow(det_ranges))) {
    overlaps <- mapply(
      range_overlap,
      det_ranges$start[i], det_ranges$end[i],
      evt_ranges$start, evt_ranges$end
    )
    best_overlap <- max(overlaps)
    precision_scores[i] <- best_overlap / det_ranges$length[i]
  }

  precision <- mean(precision_scores)
  recall <- mean(recall_scores)
  F1 <- if ((precision + recall) == 0) 0 else 2 * precision * recall / (precision + recall)

  list(
    precision = precision,
    recall = recall,
    F1 = F1,
    alpha = obj$alpha,
    detected_ranges = det_ranges,
    event_ranges = evt_ranges,
    range_precision_scores = precision_scores,
    range_recall_scores = recall_scores
  )
}

n <- 100
event <- rep(FALSE, n)
detection <- rep(FALSE, n)

# Two true anomalous intervals
event[20:30] <- TRUE
event[60:75] <- TRUE

# One partially early detection, one good overlap, and one false alarm range
detection[18:27] <- TRUE
detection[64:78] <- TRUE
detection[88:92] <- TRUE

list(
  event_ranges = to_ranges(event),
  detection_ranges = to_ranges(detection)
)

# Hard pointwise evaluation is often harsh for sequence anomalies
hard_eval <- evaluate(har_eval(), detection, event)
hard_eval$confMatrix

# Range-aware evaluation gives partial credit for overlapping intervals
range_eval <- evaluate(har_eval_range_custom(alpha = 0.5), detection, event)
range_eval
