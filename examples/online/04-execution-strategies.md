---
title: "Online Execution Strategies"
output: rmarkdown::html_document
---



## Objective

This notebook validates the three execution strategies exposed by the online
layer.

## Prepare the Base Series


``` r
serie <- c(1, 1, 1, 1, 5, 6, 7, 8, 20, 21, 22)
```

## Full Refit Strategy


``` r
session_refit <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  executor = har_online_refit_full(),
  warmup_size = 3,
  batch_size = 2
)
session_refit <- fit(session_refit)
session_refit <- run_online(session_refit)
print(collect_detection(session_refit))
```

```
##    idx event        type detection_probability detection_lag_batches
## 1    1 FALSE                                 0                    NA
## 2    2 FALSE                                 0                    NA
## 3    3 FALSE                                 0                    NA
## 4    4 FALSE                                 0                    NA
## 5    5  TRUE changepoint                     1                     0
## 6    6 FALSE                                 0                    NA
## 7    7 FALSE                                 0                    NA
## 8    8  TRUE changepoint                     1                     0
## 9    9 FALSE                                 0                    NA
## 10  10 FALSE                                 0                    NA
## 11  11  TRUE changepoint                     1                     0
##    detection_lag_observations
## 1                          NA
## 2                          NA
## 3                          NA
## 4                          NA
## 5                           2
## 6                          NA
## 7                          NA
## 8                           2
## 9                          NA
## 10                         NA
## 11                          2
```

## Detect-only Strategy


``` r
session_detect_only <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  executor = har_online_detect_only(fit_on_warmup = TRUE),
  warmup_size = 3,
  batch_size = 2
)
session_detect_only <- fit(session_detect_only)
session_detect_only <- run_online(session_detect_only)
print(collect_detection(session_detect_only))
```

```
##    idx event        type detection_probability detection_lag_batches
## 1    1 FALSE                                 0                    NA
## 2    2 FALSE                                 0                    NA
## 3    3 FALSE                                 0                    NA
## 4    4 FALSE                                 0                    NA
## 5    5  TRUE changepoint                     1                     0
## 6    6 FALSE                                 0                    NA
## 7    7 FALSE                                 0                    NA
## 8    8  TRUE changepoint                     1                     0
## 9    9 FALSE                                 0                    NA
## 10  10 FALSE                                 0                    NA
## 11  11  TRUE changepoint                     1                     0
##    detection_lag_observations
## 1                          NA
## 2                          NA
## 3                          NA
## 4                          NA
## 5                           2
## 6                          NA
## 7                          NA
## 8                           2
## 9                          NA
## 10                         NA
## 11                          2
```

## Incremental Strategy


``` r
session_incremental <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  executor = har_online_incremental(),
  warmup_size = 3,
  batch_size = 2
)
session_incremental <- fit(session_incremental)
session_incremental <- run_online(session_incremental)
print(collect_detection(session_incremental))
```

```
##    idx event        type detection_probability detection_lag_batches
## 1    1 FALSE                                 0                    NA
## 2    2 FALSE                                 0                    NA
## 3    3 FALSE                                 0                    NA
## 4    4 FALSE                                 0                    NA
## 5    5  TRUE changepoint                     1                     0
## 6    6 FALSE                                 0                    NA
## 7    7 FALSE                                 0                    NA
## 8    8  TRUE changepoint                     1                     0
## 9    9 FALSE                                 0                    NA
## 10  10 FALSE                                 0                    NA
## 11  11  TRUE changepoint                     1                     0
##    detection_lag_observations
## 1                          NA
## 2                          NA
## 3                          NA
## 4                          NA
## 5                           2
## 6                          NA
## 7                          NA
## 8                           2
## 9                          NA
## 10                         NA
## 11                          2
```

