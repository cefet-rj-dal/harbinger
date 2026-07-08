---
title: "Streaming Experiment Grid"
output: rmarkdown::html_document
---



## Objective

This notebook validates the experiment-line abstraction for online runs.

## Method at a glance

The experiment runner compares streaming configurations while reusing the same
installed detectors and evaluation objects already exposed by `harbinger`.

## Prepare the Example


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/examples/seed.R"))

serie <- c(1, 1, 1, 1, 5, 6, 7, 8, 20, 21, 22)
reference <- c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE)

factory <- function() har_source_simulated(serie)
```

## Configure the Experiment Grid


``` r
experiment <- har_stream_experiment(
  detectors = list(page = hcp_page_hinkley(min_instances = 3, threshold = 1)),
  source_factory = factory,
  warmup_grid = c(3, 5),
  batch_grid = c(1, 2),
  memory_grid = list(har_memory_full(), har_memory_sliding(2)),
  reference = reference
)
```

## Inspect the Summary


``` r
print(experiment$summary)
```

```
##   detector warmup_size batch_size            memory n_batches
## 1     page           3          1              full         8
## 2     page           3          1 sliding_batches_2         8
## 3     page           3          2              full         4
## 4     page           3          2 sliding_batches_2         4
## 5     page           5          1              full         6
## 6     page           5          1 sliding_batches_2         6
## 7     page           5          2              full         3
## 8     page           5          2 sliding_batches_2         3
##   mean_detection_probability median_detection_probability
## 1                  0.2727273                            0
## 2                  0.2727273                            0
## 3                  0.2727273                            0
## 4                  0.2727273                            0
## 5                  0.2727273                            0
## 6                  0.2727273                            0
## 7                  0.2727273                            0
## 8                  0.2727273                            0
##   mean_detection_lag_batches median_detection_lag_batches mean_batch_time_sec
## 1                          0                            0         0.002500000
## 2                          0                            0         0.003750000
## 3                          0                            0         0.005000000
## 4                          0                            0         0.005000000
## 5                          0                            0         0.000000000
## 6                          0                            0         0.003333333
## 7                          0                            0         0.000000000
## 8                          0                            0         0.000000000
##    accuracy precision recall        F1
## 1 0.6363636      0.00      0       NaN
## 2 0.6363636      0.20      1 0.3333333
## 3 0.6363636      0.00      0       NaN
## 4 0.6363636      0.00      0       NaN
## 5 0.6363636      0.00      0       NaN
## 6 0.7272727      0.25      1 0.4000000
## 7 0.6363636      0.00      0       NaN
## 8 0.6363636      0.00      0       NaN
```

