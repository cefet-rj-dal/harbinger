---
title: "Online Memory Policies"
output: rmarkdown::html_document
---



## Objective

This notebook validates how different memory policies affect the in-memory
window seen by the online session.

## Prepare a Common Series


``` r
serie <- c(1, 1, 1, 1, 5, 6, 7, 8, 20, 21, 22)
```

## Full Memory


``` r
session_full <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  warmup_size = 3,
  batch_size = 2,
  memory = har_memory_full()
)
session_full <- fit(session_full)
session_full <- run_online(session_full)
print(collect_batch_log(session_full))
```

```
##   batch_id memory_size fit_time_sec detect_time_sec total_time_sec
## 1        1           5            0               0              0
## 2        2           7            0               0              0
## 3        3           9            0               0              0
## 4        4          11            0               0              0
```

## Sliding Batch Memory


``` r
session_sliding <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  warmup_size = 3,
  batch_size = 2,
  memory = har_memory_sliding(2)
)
session_sliding <- fit(session_sliding)
session_sliding <- run_online(session_sliding)
print(collect_batch_log(session_sliding))
```

```
##   batch_id memory_size fit_time_sec detect_time_sec total_time_sec
## 1        1           5            0            0.00           0.00
## 2        2           7            0            0.01           0.01
## 3        3           9            0            0.02           0.02
## 4        4           6            0            0.00           0.00
```

## Last-observation Memory


``` r
session_last <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  warmup_size = 3,
  batch_size = 2,
  memory = har_memory_last_observations(5)
)
session_last <- fit(session_last)
session_last <- run_online(session_last)
print(collect_batch_log(session_last))
```

```
##   batch_id memory_size fit_time_sec detect_time_sec total_time_sec
## 1        1           5            0               0              0
## 2        2           7            0               0              0
## 3        3           7            0               0              0
## 4        4           7            0               0              0
```

