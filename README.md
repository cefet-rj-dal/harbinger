
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src='https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/inst/logo.png' alt='Logo do pacote Harbinger' align='centre' height='150' width='129'/> Harbinger

<!-- badges: start -->

![GitHub
Stars](https://img.shields.io/github/stars/cefet-rj-dal/harbinger?logo=Github)
![CRAN Downloads](https://cranlogs.r-pkg.org/badges/harbinger)
<!-- badges: end -->

**Harbinger** is a framework for event detection in time series. It
provides an integrated environment for anomaly detection, change point
detection, and motif discovery. Harbinger offers a broad range of
methods and functions for plotting and evaluating detected events.

For anomaly detection, methods are based on: - Machine learning model
deviation: Conv1D, ELM, MLP, LSTM, Random Regression Forest, and SVM -
Classification models: Decision Tree, KNN, MLP, Naive Bayes, Random
Forest, and SVM - Clustering: k-means and DTW - Statistical techniques:
ARIMA, FBIAD, GARCH

For change point detection, Harbinger includes: - Linear regression,
ARIMA, ETS, and GARCH-based approaches - Classic methods such as AMOC,
ChowTest, Binary Segmentation (BinSeg), GFT, and PELT

For motif discovery, it provides: - Methods based on Hashing and Matrix
Profile

Harbinger also supports **multivariate time series analysis** and
**event evaluation** using both traditional and soft computing metrics.

The architecture of Harbinger is based on **Experiment Lines** and is
built on top of the [DAL
Toolbox](https://github.com/cefet-rj-dal/daltoolbox). This design makes
it easy to extend and integrate new methods into the framework.

------------------------------------------------------------------------

## Installation

The latest version of Harbinger is available on CRAN:

``` r
install.packages("harbinger")
```

You can install the development version from GitHub:

``` r
# install.packages("devtools")
library(devtools)
devtools::install_github("cefet-rj-dal/harbinger", force = TRUE, upgrade = "never")
```

------------------------------------------------------------------------

## Examples

Examples of Harbinger are organized by application area:

- [General](https://github.com/cefet-rj-dal/harbinger/tree/master/general)
- [Anomalies](https://github.com/cefet-rj-dal/harbinger/tree/master/anomalies)
- [Change
  points](https://github.com/cefet-rj-dal/harbinger/tree/master/change_point)
- [Motifs](https://github.com/cefet-rj-dal/harbinger/tree/master/motifs)

``` r
library(harbinger)
#> Registered S3 method overwritten by 'quantmod':
#>   method            from
#>   as.zoo.data.frame zoo
#> Registered S3 methods overwritten by 'forecast':
#>   method  from 
#>   head.ts stats
#>   tail.ts stats

#loading the example database
data(examples_anomalies)

#model
model <- harbinger()

#stub detector
detection <- detect(model, examples_anomalies$simple$serie)

# filtering detected events
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
print(detection |> dplyr::filter(event==TRUE))
#> [1] idx   event type 
#> <0 rows> (or 0-length row.names)
```

------------------------------------------------------------------------

## Bug reports and feature requests

If you find any bugs or would like to suggest new features, please
submit an issue here:

<https://github.com/cefet-rj-dal/harbinger/issues>
