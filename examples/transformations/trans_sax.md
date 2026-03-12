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

## Walkthrough


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


``` r
# Plot the original time series
har_plot(harbinger(), dataset$serie, event = dataset$event)
```

![plot of chunk unnamed-chunk-5](fig/trans_sax/unnamed-chunk-5-1.png)


``` r
# Configure the SAX transformer
model <- trans_sax(alpha = 8)
```


``` r
# Fit and transform the numeric series into symbols
model <- fit(model, dataset$serie)
sax_series <- transform(model, dataset$serie)
```


``` r
# Inspect the first symbolic values
head(sax_series, 20)
```

```
##  [1] "D" "D" "D" "C" "C" "B" "B" "B" "A" "A" "A" "A" "A" "A" "A" "A" "A" "A" "B" "B"
```


``` r
# Compare original values with SAX symbols
comparison <- data.frame(
  idx = seq_along(dataset$serie),
  value = dataset$serie,
  sax = sax_series
)
head(comparison, 20)
```

```
##    idx        value sax
## 1    1  1.000000000   D
## 2    2  0.993912422   D
## 3    3  0.927582562   D
## 4    4  0.806688869   C
## 5    5  0.640302306   C
## 6    6  0.440322362   B
## 7    7  0.220737202   B
## 8    8 -0.003246056   B
## 9    9 -0.216146837   A
## 10  10 -0.403173623   A
## 11  11 -0.551143616   A
## 12  12 -0.649302379   A
## 13  13 -0.689992497   A
## 14  14 -0.669129676   A
## 15  15 -0.586456687   A
## 16  16 -0.445559357   A
## 17  17 -0.253643621   A
## 18  18 -0.021087490   A
## 19  19  0.239204201   B
## 20  20  0.512602153   B
```

## References

- Lin, J., Keogh, E., Lonardi, S., Chiu, B. (2007). A symbolic representation of time series, with implications for streaming algorithms. Data Mining and Knowledge Discovery, 15, 107-144.
