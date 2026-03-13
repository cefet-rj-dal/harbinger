## Custom Evaluation

## Objective

The goal of this example is to show that Harbinger can also be extended on the evaluation side, not only on the detector side.

This is important because event-detection quality depends not only on the detector, but also on how we define a correct match between a detected event and a labeled event.

## Why this method matters

For point anomalies, strict timestamp-level metrics are often acceptable. For collective or sequence anomalies, they can be misleading. If the true anomaly spans a range and the detector overlaps with most of that range, a pointwise confusion matrix may still look harsh simply because the boundaries do not line up exactly.

This is one of the main points emphasized in the recent metric taxonomy by Sorbo and Ruocco: the choice of metric has to reflect the anomaly type and the intended use of the detector. Range-based anomalies should be judged with range-aware metrics.

This example therefore introduces a more interesting custom evaluator than a fixed tolerance window. It is designed for contiguous anomalous intervals and rewards two things:

- whether the detector found the anomalous range at all;
- how much of the true range and the detected range overlap.

## Method at a glance

The evaluator first converts the boolean event vector into contiguous intervals. It then computes a simplified range-based precision and recall inspired by Tatbul et al.:

- recall is computed over true anomaly ranges;
- precision is computed over detected ranges;
- each true range receives partial credit when it is overlapped by a detected range;
- an existence reward and an overlap reward are combined so the score values are intuitive.

This is not a full reimplementation of the Tatbul framework. It is a didactic Harbinger-compatible variant meant to capture the central idea: sequence anomalies should be evaluated as ranges, not just as isolated timestamps.






### Prepare the Example

This setup anchors the notebook in the specific series used to examine `06-evaluation-custom_evaluation`. The semantic point is the one stated above: the evaluator first converts the boolean event vector into contiguous intervals, so the raw signal needs to be visible before any fitting step hides that structure behind model output.


``` r
# installation
# install.packages(c("harbinger", "daltoolbox"))

library(daltoolbox)
library(harbinger)
```





### Define the Support Structures

The code below defines the smallest Harbinger contract needed to express the idea behind this example. Read it in semantic terms: the goal is to encode that the evaluator first converts the boolean event vector into contiguous intervals while still returning objects that Harbinger can plot and evaluate like any native method.


``` r
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
```

We first illustrate the metric on a toy example with contiguous anomalous intervals. This makes the scoring logic easier to understand than starting directly from a detector output.






``` r
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
```

```
## $event_ranges
##   start end length
## 1    20  30     11
## 2    60  75     16
## 
## $detection_ranges
##   start end length
## 1    18  27     10
## 2    64  78     15
## 3    88  92      5
```





### Evaluate What Was Found

The evaluation asks whether the evaluation outputs produced by `06-evaluation-custom_evaluation` match the labeled structure on this dataset. Read the scores as evidence about the method's assumptions in practice, not as detached summary numbers.


``` r
# Hard pointwise evaluation is often harsh for sequence anomalies
hard_eval <- evaluate(har_eval(), detection, event)
hard_eval$confMatrix
```

```
##           event      
## detection TRUE  FALSE
## TRUE      20    10   
## FALSE     7     63
```




``` r
# Range-aware evaluation gives partial credit for overlapping intervals
range_eval <- evaluate(har_eval_range_custom(alpha = 0.5), detection, event)
range_eval
```

```
## $precision
## [1] 0.5333333
## 
## $recall
## [1] 0.8693182
## 
## $F1
## [1] 0.6610856
## 
## $alpha
## [1] 0.5
## 
## $detected_ranges
##   start end length
## 1    18  27     10
## 2    64  78     15
## 3    88  92      5
## 
## $event_ranges
##   start end length
## 1    20  30     11
## 2    60  75     16
## 
## $range_precision_scores
## [1] 0.8 0.8 0.0
## 
## $range_recall_scores
## [1] 0.8636364 0.8750000
```

This example shows that a custom evaluator in Harbinger only needs to respect the `evaluate()` contract. Once that is done, it becomes possible to compare detectors under a policy that is much better aligned with collective anomalies and sequence anomalies.

## References

- Sorbo, S., Ruocco, M. (2024). Navigating the metric maze: a taxonomy of evaluation metrics for anomaly detection in time series. Data Mining and Knowledge Discovery, 38, 1027-1068. https://doi.org/10.1007/s10618-023-00988-8
- Tatbul, N., Lee, T. J., Zdonik, S., Alam, M., Gottschlich, J. (2018). Precision and Recall for Time Series. Advances in Neural Information Processing Systems 31.
