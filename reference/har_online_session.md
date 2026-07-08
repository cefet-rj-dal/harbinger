# Harbinger online session

Creates and runs a streaming session that reuses existing Harbinger
detectors without changing their offline APIs. The session layer is
intentionally additive: it orchestrates ingestion, batching, memory
management, tracing, and evaluation support around the detector already
provided by the package.

The session supports:

- pull sources through
  [`next_observation()`](https://cefet-rj-dal.github.io/harbinger/reference/next_observation.md)

- push ingestion through
  [`ingest()`](https://cefet-rj-dal.github.io/harbinger/reference/ingest.md)

- full or bounded memory policies

- explicit execution strategies

- structured tracing for Detection Probability (DP) and Detection Lag
  (DL)

## Usage

``` r
har_online_session(
  source,
  detector,
  executor = har_online_refit_full(),
  warmup_size = 30,
  batch_size = 30,
  memory = har_memory_full(),
  mode = c("auto", "pull", "push")
)
```

## Arguments

- source:

  Streaming source object. May be `NULL` for push-only sessions.

- detector:

  Any existing Harbinger detector.

- executor:

  Execution strategy. Defaults to
  [`har_online_refit_full()`](https://cefet-rj-dal.github.io/harbinger/reference/har_online_refit_full.md).

- warmup_size:

  Number of initial observations consumed before regular streaming
  detection starts.

- batch_size:

  Number of new observations required to trigger one online detection
  cycle.

- memory:

  Memory policy. Defaults to
  [`har_memory_full()`](https://cefet-rj-dal.github.io/harbinger/reference/har_memory_full.md).

- mode:

  Session mode:

  - `"auto"`: behaves like pull mode when a source is available and like
    push mode when `source = NULL`;

  - `"pull"`: observations are requested through
    `next_observation(source)`;

  - `"push"`: observations must be provided explicitly through
    [`ingest()`](https://cefet-rj-dal.github.io/harbinger/reference/ingest.md).

## Value

A `har_online_session` object.

## Examples

``` r
source <- har_source_simulated(c(10, 11, 12, 20, 12, 11, 10))
session <- har_online_session(
  source = source,
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  warmup_size = 3,
  batch_size = 2
)
session <- daltoolbox::fit(session)
session <- run_online(session)
head(collect_detection(session))
#>   idx event        type detection_probability detection_lag_batches
#> 1   1 FALSE                                 0                    NA
#> 2   2 FALSE                                 0                    NA
#> 3   3  TRUE changepoint                     1                     0
#> 4   4 FALSE                                 0                    NA
#> 5   5 FALSE                                 0                    NA
#> 6   6 FALSE                                 0                    NA
#>   detection_lag_observations
#> 1                         NA
#> 2                         NA
#> 3                          2
#> 4                         NA
#> 5                         NA
#> 6                         NA
```
