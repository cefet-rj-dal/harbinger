# Calculate soft scores for a detection of events in a time series

The input includes both the detection and the event, as well as a k
parameter that defines the tolerance window for event detection.

## Usage

``` r
soft_scores(detection, event, k)
```

## Value

A list of smooth scores for the detection, which can be used to evaluate
the performance of the event detection algorithm

## Details

The function starts by finding the indices of events and detections, and
creates an anonymous "mu" function to calculate the contributions of
each detection to each event. The "Mu" matrix is then filled with these
values. The function goes on to find, for each detection, the event it
contributes the most to, and for each event, the detections that
contribute the most to it. Then, the detection that most contributes to
each event is chosen and its "soft scores" are calculated
