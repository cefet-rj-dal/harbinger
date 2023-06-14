
<!-- README.md is generated from README.Rmd. Please edit that file -->

# harbinger

<!-- badges: start -->
<!-- badges: end -->

Habinger is a framework for event detection in time series.

## Installation

You can install the development version of harbinger from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
library(devtools)
devtools::install_github("cefet-rj-dal/harbinger", force=TRUE, dependencies=FALSE, upgrade="never", build_vignettes = TRUE)
```

## Examples

Examples of Harbinger are available at:
<https://nbviewer.org/github/cefet-rj-dal/harbinger/tree/master/examples/>
They are organized according to general functions, anomalies, change
points, motifs, and multivariate anomaly detection.

``` r
library(harbinger)
#> Registered S3 method overwritten by 'quantmod':
#>   method            from
#>   as.zoo.data.frame zoo
#> Warning: replacing previous import 'dplyr::rename' by 'reshape::rename' when
#> loading 'daltoolbox'
#> Warning: replacing previous import 'class::condense' by 'reshape::condense'
#> when loading 'daltoolbox'
#> Warning: replacing previous import 'dplyr::filter' by 'stats::filter' when
#> loading 'daltoolbox'
#> Warning: replacing previous import 'TSPred::minmax' by 'daltoolbox::minmax'
#> when loading 'harbinger'
#> Warning: replacing previous import 'TSPred::evaluate' by 'daltoolbox::evaluate'
#> when loading 'harbinger'
## basic example code
```
