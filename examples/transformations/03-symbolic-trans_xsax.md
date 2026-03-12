## Objective

This notebook demonstrates `trans_xsax()`, an extended symbolic transformation for time series. The goal is to show how XSAX increases symbolic resolution relative to SAX by using a larger alphabet.

## Method at a glance

XSAX follows the same general idea as SAX: normalize the series and discretize it into symbols. The difference is that XSAX uses a larger alphanumeric alphabet, which allows a finer symbolic partition of the values.

## What you will do

- load an example motif series from Harbinger
- inspect the original numeric sequence
- configure an XSAX transformer
- transform the series into a richer symbolic encoding
- compare the numeric values with the symbolic codes

## How to read this walkthrough

The code blocks below follow the same learning rhythm used throughout the collection: prepare the environment, choose the dataset, configure the method, run the analysis, and then inspect the result. Readers who are still learning time-series mining can use that order to understand not only *what* each command does, but also *why* it appears at that stage of the workflow.

As you go through the notebook, read the inline comments inside each chunk as the operational explanation and use the surrounding prose as the conceptual guide.

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

![plot of chunk unnamed-chunk-5](fig/03-symbolic-trans_xsax/unnamed-chunk-5-1.png)


``` r
# Configure the XSAX transformer
model <- trans_xsax(alpha = 16)
```


``` r
# Fit and transform the numeric series into an extended symbolic representation
model <- fit(model, dataset$serie)
xsax_series <- transform(model, dataset$serie)
```


``` r
# Inspect the first symbolic values
head(xsax_series, 20)
```

```
##  [1] "6" "6" "6" "5" "4" "3" "2" "2" "1" "0" "0" "0" "0" "0" "0" "0" "1" "1" "2" "3"
```


``` r
# Compare original values with XSAX symbols
comparison <- data.frame(
  idx = seq_along(dataset$serie),
  value = dataset$serie,
  xsax = xsax_series
)
head(comparison, 20)
```

```
##    idx        value xsax
## 1    1  1.000000000    6
## 2    2  0.993912422    6
## 3    3  0.927582562    6
## 4    4  0.806688869    5
## 5    5  0.640302306    4
## 6    6  0.440322362    3
## 7    7  0.220737202    2
## 8    8 -0.003246056    2
## 9    9 -0.216146837    1
## 10  10 -0.403173623    0
## 11  11 -0.551143616    0
## 12  12 -0.649302379    0
## 13  13 -0.689992497    0
## 14  14 -0.669129676    0
## 15  15 -0.586456687    0
## 16  16 -0.445559357    0
## 17  17 -0.253643621    1
## 18  18 -0.021087490    1
## 19  19  0.239204201    2
## 20  20  0.512602153    3
```

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. Springer, 2025. doi:10.1007/978-3-031-75941-3


