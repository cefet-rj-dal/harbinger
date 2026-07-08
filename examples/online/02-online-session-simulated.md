---
title: "Online Session with Simulated Source"
output: rmarkdown::html_document
---



## Objective

This notebook validates the minimum end-to-end online workflow in `harbinger`
using the installed package interface.

## Method at a glance

The workflow combines:

- a simulated source
- an online session
- a batch execution strategy
- a memory policy
- trace-based evaluation with Detection Probability and Detection Lag

## Prepare the Example


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/examples/seed.R"))

serie <- c(1, 1, 1, 1, 5, 6, 7, 8, 20, 21, 22)
reference <- c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE)
source_obj <- har_source_simulated(serie)
```

## Configure the Online Session


``` r
session <- har_online_session(
  source = source_obj,
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  executor = har_online_refit_full(),
  warmup_size = 3,
  batch_size = 2,
  memory = har_memory_full()
)
```

## Run the Online Workflow


``` r
session <- fit(session)
session <- run_online(session)
```

## Inspect Final Detection


``` r
detection <- collect_detection(session)
print(detection)
```

```
##    idx event        type detection_probability detection_lag_batches detection_lag_observations
## 1    1 FALSE                                 0                    NA                         NA
## 2    2 FALSE                                 0                    NA                         NA
## 3    3 FALSE                                 0                    NA                         NA
## 4    4 FALSE                                 0                    NA                         NA
## 5    5  TRUE changepoint                     1                     0                          2
## 6    6 FALSE                                 0                    NA                         NA
## 7    7 FALSE                                 0                    NA                         NA
## 8    8  TRUE changepoint                     1                     0                          2
## 9    9 FALSE                                 0                    NA                         NA
## 10  10 FALSE                                 0                    NA                         NA
## 11  11  TRUE changepoint                     1                     0                          2
```

## Inspect the Trace


``` r
trace <- collect_trace(session)
print(trace)
```

```
##    idx timestamp batch_id_first_seen batch_frequency detection_frequency first_detected_batch last_detected_batch detection_probability detection_lag_batches
## 1    1        NA                   1               4                   0                   NA                  NA                     0                    NA
## 2    2        NA                   1               4                   0                   NA                  NA                     0                    NA
## 3    3        NA                   1               4                   0                   NA                  NA                     0                    NA
## 4    4        NA                   1               4                   0                   NA                  NA                     0                    NA
## 5    5        NA                   1               4                   4                    1                   4                     1                     0
## 6    6        NA                   2               3                   0                   NA                  NA                     0                    NA
## 7    7        NA                   2               3                   0                   NA                  NA                     0                    NA
## 8    8        NA                   3               2                   2                    3                   4                     1                     0
## 9    9        NA                   3               2                   0                   NA                  NA                     0                    NA
## 10  10        NA                   4               1                   0                   NA                  NA                     0                    NA
## 11  11        NA                   4               1                   1                    4                   4                     1                     0
##    detection_lag_observations  event_type
## 1                          NA       event
## 2                          NA       event
## 3                          NA       event
## 4                          NA       event
## 5                           2 changepoint
## 6                          NA       event
## 7                          NA       event
## 8                           2 changepoint
## 9                          NA       event
## 10                         NA       event
## 11                          2 changepoint
```

## Inspect the Batch Log


``` r
batch_log <- collect_batch_log(session)
print(batch_log)
```

```
##   batch_id memory_size fit_time_sec detect_time_sec total_time_sec
## 1        1           5            0           0.000          0.000
## 2        2           7            0           0.001          0.001
## 3        3           9            0           0.000          0.000
## 4        4          11            0           0.001          0.001
```

## Evaluate the Stream Behavior


``` r
stream_metrics <- evaluate(har_stream_eval(), trace, reference = reference)
print(stream_metrics$summary)
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
print(stream_metrics$hard_metrics$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     3    
## FALSE     1     7
```

