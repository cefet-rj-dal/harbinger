# Streaming experiment runner

Runs a reproducible grid of online streaming experiments by combining
detectors, source factories, batch settings, memory policies, and
optional labeled references.

The experiment runner is intentionally lightweight. It reuses the online
session layer and returns both the raw runs and a compact summary table.

## Usage

``` r
har_stream_experiment(
  detectors,
  source_factory,
  warmup_grid,
  batch_grid,
  memory_grid,
  executor = har_online_refit_full(),
  reference = NULL,
  mode = c("auto", "pull", "push"),
  ...
)
```

## Arguments

- detectors:

  Named list of detector objects. An unnamed list is also accepted and
  will be labeled by class.

- source_factory:

  Function that creates a fresh source object for each run. This keeps
  each execution independent and reproducible.

- warmup_grid:

  Integer vector of warm-up sizes.

- batch_grid:

  Integer vector of batch sizes.

- memory_grid:

  List of memory policy objects.

- executor:

  Execution strategy. Defaults to
  [`har_online_refit_full()`](https://cefet-rj-dal.github.io/harbinger/reference/har_online_refit_full.md).

- reference:

  Optional event reference vector.

- mode:

  Session mode: `"auto"`, `"pull"`, or `"push"`.

- ...:

  Additional arguments forwarded to
  [`run_online()`](https://cefet-rj-dal.github.io/harbinger/reference/run_online.md).

## Value

A `har_stream_experiment` object with:

- `runs`: a list of raw run objects containing session, trace, and
  evaluation;

- `summary`: a compact data frame for cross-configuration comparison.

## Examples

``` r
factory <- function() har_source_simulated(c(1, 1, 1, 10, 1, 1))
experiment <- har_stream_experiment(
  detectors = list(page = hcp_page_hinkley(min_instances = 3, threshold = 1)),
  source_factory = factory,
  warmup_grid = 3,
  batch_grid = c(1, 2),
  memory_grid = list(har_memory_full())
)
experiment$summary
#>   detector warmup_size batch_size memory n_batches mean_detection_probability
#> 1     page           3          1   full         3                  0.1666667
#> 2     page           3          2   full         2                  0.1666667
#>   median_detection_probability mean_detection_lag_batches
#> 1                            0                          0
#> 2                            0                          0
#>   median_detection_lag_batches mean_batch_time_sec accuracy precision recall F1
#> 1                            0                   0       NA        NA     NA NA
#> 2                            0                   0       NA        NA     NA NA
```
