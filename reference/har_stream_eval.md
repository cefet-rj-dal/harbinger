# Streaming evaluation for online detection

Evaluates structured online traces produced by
[`har_online_session()`](https://cefet-rj-dal.github.io/harbinger/reference/har_online_session.md).
This evaluator complements
[`har_eval()`](https://cefet-rj-dal.github.io/harbinger/reference/har_eval.md)
by computing the metrics introduced in the Nexus paper, namely Detection
Probability (DP) and Detection Lag (DL), while also exposing
conventional end-of-run classification metrics when labels are
available.

## Usage

``` r
har_stream_eval()
```

## Value

A `har_stream_eval` object.

## Examples

``` r
source <- har_source_simulated(c(1, 1, 1, 10, 1, 1))
session <- har_online_session(
  source = source,
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  warmup_size = 3,
  batch_size = 1
)
session <- daltoolbox::fit(session)
session <- run_online(session)
trace <- collect_trace(session)
daltoolbox::evaluate(har_stream_eval(), trace)
#> $summary
#> $summary$n_observations
#> [1] 6
#> 
#> $summary$n_detected
#> [1] 1
#> 
#> $summary$mean_detection_probability
#> [1] 0.1666667
#> 
#> $summary$median_detection_probability
#> [1] 0
#> 
#> $summary$mean_detection_lag_batches
#> [1] 0
#> 
#> $summary$median_detection_lag_batches
#> [1] 0
#> 
#> $summary$mean_detection_lag_observations
#> [1] 1
#> 
#> $summary$median_detection_lag_observations
#> [1] 1
#> 
#> $summary$zero_lag_rate
#> [1] 1
#> 
#> 
#> $by_observation
#>   idx timestamp batch_id_first_seen batch_frequency detection_frequency
#> 1   1        NA                   1               3                   0
#> 2   2        NA                   1               3                   0
#> 3   3        NA                   1               3                   0
#> 4   4        NA                   1               3                   3
#> 5   5        NA                   2               2                   0
#> 6   6        NA                   3               1                   0
#>   first_detected_batch last_detected_batch detection_probability
#> 1                   NA                  NA                     0
#> 2                   NA                  NA                     0
#> 3                   NA                  NA                     0
#> 4                    1                   3                     1
#> 5                   NA                  NA                     0
#> 6                   NA                  NA                     0
#>   detection_lag_batches detection_lag_observations  event_type
#> 1                    NA                         NA       event
#> 2                    NA                         NA       event
#> 3                    NA                         NA       event
#> 4                     0                          1 changepoint
#> 5                    NA                         NA       event
#> 6                    NA                         NA       event
#> 
```
