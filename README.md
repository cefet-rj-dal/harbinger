
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src='https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/inst/logo.png' align='centre' height='150' width='129'/> Harbinger

<!-- badges: start -->

![GitHub Repo
stars](https://img.shields.io/github/stars/cefet-rj-dal/harbinger?logo=Github)
![GitHub Repo stars](https://cranlogs.r-pkg.org/badges/harbinger)
<!-- badges: end -->

Harbinger is a framework for event detection in time series. It provides
an integrated environment for time series anomaly detection, change
points, and motif discovery. It provides a broad range of event
detection methods and functions for plotting and evaluating event
detections.

In the anomaly part, methods are based on machine learning model
deviation (Conv1D, ELM, MLP, LSTM, Random Regression Forest, SVM),
machine learning classification model (Decision Tree, KNN, MLP, Naive
Bayes, Random Forest, SVM), clustering (kmeans and DTW) and statistical
methods (ARIMA, FBIAD, GARCH).

In the change points part, methods are based on linear regression,
ARIMA, ETS, and GARCH. In the motifs part, methods are based on Hash and
Matrix Profile. There are specific methods for multivariate series. The
evaluation of detections includes both traditional and soft computing.

Harbinger architecture is based on Experiment Lines and is built on top
of the DAL Toolbox. Such an organization makes it easy to customize and
add novel methods to the framework.

## Installation

The latest version of Harbinger at CRAN is available at:
<https://CRAN.R-project.org/package=harbinger>

You can install the stable version of Harbinger from CRAN with:

``` r
install.packages("harbinger")
```

You can install the development version of Harbinger from GitHub
<https://github.com/cefet-rj-dal/harbinger> with:

``` r
# install.packages("devtools")
library(devtools)
devtools::install_github("cefet-rj-dal/harbinger", force=TRUE, upgrade="never")
```

## Examples

Examples of Harbinger are organized according to general functions,
anomalies, change points, motifs, and multivariate anomaly detection.

General:
<https://nbviewer.org/github/cefet-rj-dal/harbinger/tree/master/general/>

Anomalies:
<https://nbviewer.org/github/cefet-rj-dal/harbinger/tree/master/anomalies/>

Change points:
<https://nbviewer.org/github/cefet-rj-dal/harbinger/tree/master/change_point/>

Motifs:
<https://nbviewer.org/github/cefet-rj-dal/harbinger/tree/master/motifs/>

Multivariate:
<https://nbviewer.org/github/cefet-rj-dal/harbinger/tree/master/multivariate/>

``` r
library(harbinger)
#> Registered S3 method overwritten by 'quantmod':
#>   method            from
#>   as.zoo.data.frame zoo
## basic example code
```

## Bugs and new features request

<https://github.com/cefet-rj-dal/harbinger/issues>
