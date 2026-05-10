# Evaluate the performance of the event detection model against true events

Takes as input a "Harbinger" object, a set of event detection (stored as
a data frame) and a set of true events (also stored as a data frame)

## Usage

``` r
# S3 method for harbinger
evaluate(obj, detection, event, evaluation = har_eval(), ...)
```

## Arguments

- obj:

  detector

- detection:

  detected observations

- event:

  labeled events

- evaluation:

  evaluation object

- ...:

  optional arguments.

## Value

The result of the evaluation

## Examples

``` r
detector <- harbinger()
```
