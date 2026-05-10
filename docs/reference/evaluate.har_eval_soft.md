# Evaluate the quality of an event detection model against a reference dataset

It receives as input an object, a "detection" matrix with the detections
made by the model and an "event" matrix with the true events

## Usage

``` r
# S3 method for har_eval_soft
evaluate(obj, detection, event, ...)
```

## Arguments

- obj:

  detector

- detection:

  detected observations

- event:

  labeled events

- ...:

  optional arguments.

## Value

A list of performance measures for detection

## Examples

``` r
detector <- harbinger()
```
