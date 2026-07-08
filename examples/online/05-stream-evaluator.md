---
title: "Streaming Evaluator"
output: rmarkdown::html_document
---



## Objective

This notebook validates `har_stream_eval()` as an independent evaluation layer.

## Prepare a Session


``` r
serie <- c(1, 1, 1, 1, 5, 6, 7, 8, 20, 21, 22)
reference <- c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE)

session <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  warmup_size = 3,
  batch_size = 2
)
session <- fit(session)
session <- run_online(session)
trace <- collect_trace(session)
```

## Evaluate Without Threshold


``` r
stream_eval <- evaluate(har_stream_eval(), trace, reference = reference)
print(stream_eval$summary)
```

```
## $n_observations
## [1] 11
## 
## $n_detected
## [1] 3
## 
## $mean_detection_probability
## [1] 0.2727273
## 
## $median_detection_probability
## [1] 0
## 
## $mean_detection_lag_batches
## [1] 0
## 
## $median_detection_lag_batches
## [1] 0
## 
## $mean_detection_lag_observations
## [1] 2
## 
## $median_detection_lag_observations
## [1] 2
## 
## $zero_lag_rate
## [1] 1
```

``` r
print(stream_eval$hard_metrics$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     3    
## FALSE     1     7
```

## Evaluate With Probability Threshold


``` r
stream_eval_threshold <- evaluate(
  har_stream_eval(),
  trace,
  reference = reference,
  probability_threshold = 0.8
)
print(stream_eval_threshold$summary)
```

```
## $n_observations
## [1] 11
## 
## $n_detected
## [1] 3
## 
## $mean_detection_probability
## [1] 0.2727273
## 
## $median_detection_probability
## [1] 0
## 
## $mean_detection_lag_batches
## [1] 0
## 
## $median_detection_lag_batches
## [1] 0
## 
## $mean_detection_lag_observations
## [1] 2
## 
## $median_detection_lag_observations
## [1] 2
## 
## $zero_lag_rate
## [1] 1
```

``` r
print(stream_eval_threshold$threshold_hard_metrics$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     3    
## FALSE     1     7
```

