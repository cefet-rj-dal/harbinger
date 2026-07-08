# Evaluate a streaming trace

Computes trace-level summaries and, when a reference label vector is
provided, combines them with the standard Harbinger hard evaluation.

## Usage

``` r
# S3 method for class 'har_stream_eval'
evaluate(obj, detection, reference = NULL, probability_threshold = NULL, ...)
```

## Arguments

- obj:

  A `har_stream_eval` object.

- detection:

  Trace data frame returned by
  [`collect_trace()`](https://cefet-rj-dal.github.io/harbinger/reference/collect_trace.md).

- reference:

  Optional logical or numeric event reference aligned with the
  observation index.

- probability_threshold:

  Optional DP threshold used to derive an additional filtered detection
  vector.

- ...:

  Unused.

## Value

A named list with per-observation trace metrics and aggregate summaries.
The returned list always includes:

- `summary`: aggregate DP and DL statistics;

- `by_observation`: the original trace table.

When `reference` is provided, it also includes:

- `hard_metrics`: standard final binary evaluation using
  [`har_eval()`](https://cefet-rj-dal.github.io/harbinger/reference/har_eval.md).

When `probability_threshold` is provided, it also includes:

- `threshold`: the threshold value;

- `threshold_detection`: logical vector derived from DP filtering.

When both `reference` and `probability_threshold` are provided, it also
includes:

- `threshold_hard_metrics`: hard evaluation after DP thresholding.
