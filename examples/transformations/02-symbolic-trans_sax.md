## Objective

This notebook demonstrates the `trans_sax()` transformation. The goal is to show how a numeric time series can be converted into a symbolic representation that is easier to compare, summarize, and use in motif or discord analysis.

## Method at a glance

SAX, or Symbolic Aggregate approXimation, z-normalizes a series and discretizes it into a finite alphabet. Instead of working directly with the raw values, we work with symbolic codes that preserve coarse shape information.

## What you will do

- load a motif example series from Harbinger
- inspect the original numeric signal
- configure a SAX transformer with a chosen alphabet size
- transform the series into symbols
- compare the numeric and symbolic views of the same signal








### Prepare the Example

This setup anchors the notebook in the specific series used to examine `02-symbolic-trans_sax`. The semantic point is the one stated above: sAX, or Symbolic Aggregate approXimation, z-normalizes a series and discretizes it into a finite alphabet, so the raw signal needs to be visible before any fitting step hides that structure behind model output.


``` r
# Install Harbinger (if needed)
#install.packages("harbinger")
```






``` r
# Load required packages
library(daltoolbox)
library(harbinger)
```






``` r
# Load example motif datasets
data(examples_motifs)
```




``` r
# Select a simple motif dataset
dataset <- examples_motifs$simple
head(dataset)
```

```
##       serie event
## 1 1.0000000 FALSE
## 2 0.9939124 FALSE
## 3 0.9275826 FALSE
## 4 0.8066889 FALSE
## 5 0.6403023 FALSE
## 6 0.4403224 FALSE
```







### Interpret the Result Visually

This first visual pass establishes what the method should react to in the raw series. Keep the method summary in mind here, because sAX, or Symbolic Aggregate approXimation, z-normalizes a series and discretizes it into a finite alphabet and the plot tells you whether that structure is clean, weak, local, repeated, or mixed with other effects.


``` r
# Plot the original time series
har_plot(harbinger(), dataset$serie, event = dataset$event)
```

![plot of chunk unnamed-chunk-5](fig/02-symbolic-trans_sax/unnamed-chunk-5-1.png)







### Configure the Method

The choices below turn the central modeling idea into concrete parameters. They matter because sAX, or Symbolic Aggregate approXimation, z-normalizes a series and discretizes it into a finite alphabet, so each argument controls how strongly the method will emphasize that pattern when it later produces transformed outputs.


``` r
# Configure the SAX transformer
model <- trans_sax(alpha = 8)
```

```
## Error:
## ! cannot allocate vector of size 3.5 Gb
```




``` r
# Fit and transform the numeric series into symbols
model <- fit(model, dataset$serie)
```

```
## Error:
## ! object 'model' not found
```

``` r
sax_series <- transform(model, dataset$serie)
```

```
## Error:
## ! object 'model' not found
```








``` r
# Inspect the first symbolic values
head(sax_series, 20)
```

```
## Error:
## ! object 'sax_series' not found
```





### Run the Core Analysis

This is the moment where the notebook tests its central assumption on actual data. After applying `02-symbolic-trans_sax`, the important question is whether the resulting transformed outputs really correspond to the pattern implied by the method description above, rather than to arbitrary numerical variation.


``` r
# Compare original values with SAX symbols
comparison <- data.frame(
  idx = seq_along(dataset$serie),
  value = dataset$serie,
  sax = sax_series
)
```

```
## Error:
## ! object 'sax_series' not found
```

``` r
head(comparison, 20)
```

```
## Error:
## ! object 'comparison' not found
```

## References

- Lin, J., Keogh, E., Lonardi, S., Chiu, B. (2007). A symbolic representation of time series, with implications for streaming algorithms. Data Mining and Knowledge Discovery, 15, 107-144.
