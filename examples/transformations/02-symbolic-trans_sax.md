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

## How to read this walkthrough

The code blocks below follow the same learning rhythm used throughout the collection: prepare the environment, choose the dataset, configure the method, run the analysis, and then inspect the result. Readers who are still learning time-series mining can use that order to understand not only *what* each command does, but also *why* it appears at that stage of the workflow.

As you go through the notebook, read the inline comments inside each chunk as the operational explanation and use the surrounding prose as the conceptual guide.

## Walkthrough







### Prepare the Example

We begin by organizing the environment, loading the packages, and selecting the dataset used in the notebook. This part is intentionally more direct: the goal is to make the starting point explicit before the method-specific reasoning begins.


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

The final plots are not just illustrations. They help the reader connect the method's internal output with the original series, making it easier to see why a point, range, motif, or symbolic pattern was emphasized and whether that emphasis is coherent with the stated objective of the example.


``` r
# Plot the original time series
har_plot(harbinger(), dataset$serie, event = dataset$event)
```

![plot of chunk unnamed-chunk-5](fig/02-symbolic-trans_sax/unnamed-chunk-5-1.png)







### Configure the Method

The next step is to instantiate the method and, when necessary, fit it to the selected series. This is where the notebook makes its analytical choice explicit: the parameters chosen here determine what kind of pattern the detector or transformer will become sensitive to and how the later outputs should be interpreted.


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





### Run the Core Analysis

With the environment and the method ready, we execute the central analytical step and inspect its immediate output. This is the point where the abstract idea described earlier becomes operational, so the reader should pay attention to what is produced and how Harbinger standardizes the result.


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

