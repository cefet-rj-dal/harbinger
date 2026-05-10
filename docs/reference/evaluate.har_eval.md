# Evaluates the model based on a confusion matrix

It takes three arguments: obj: an object to store the evaluation
results; detection: a boolean vector that indicates whether or not the
model detected an event; event: a boolean vector that indicates whether
the event occurred or not

## Usage

``` r
# S3 method for har_eval
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

An object of the "hard evaluation" class updated with the calculated
metrics

## Examples

``` r
detector <- harbinger()
```
