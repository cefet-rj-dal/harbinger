## Custom Change-Point Detector

## Objective

The goal of this example is to show how to integrate a custom change-point detector based on joinpoint regression.

This notebook is not only about the integration contract. It is also meant to motivate a very interpretable idea of change-point detection: sometimes the important event in a series is the point where one trend stops and another begins.

## Why this method matters

Many change-point methods are framed as optimization or segmentation problems. That is useful, but it can feel abstract for readers who think first in terms of regression lines and slope changes. Joinpoint regression gives a more visual intuition: fit piecewise linear behavior and estimate where the line changes direction or slope.

This is a strong custom example because:

- it connects change-point detection with a familiar regression interpretation;
- it shows how external model objects can be wrapped inside Harbinger;
- it motivates structural breaks as changes in trend, not only as generic break indices.

## Method at a glance

The detector first fits a linear model and then refines it with `segmented::segmented()`, which estimates one or more joinpoints. The estimated breakpoint positions are converted into Harbinger's logical event vector and then reused in the regular plotting and evaluation workflow.

Joinpoint or segmented regression is a good custom extension example because it combines a standard regression fit with an explicit estimate of the structural break location. Here we use the `segmented` package and wrap it inside the usual Harbinger interface.


``` r
# installation
# install.packages(c("harbinger", "daltoolbox", "segmented"))

library(daltoolbox)
library(harbinger)
```


``` r
hcp_joinpoint_custom <- function(npsi = 1) {
  obj <- harbinger()
  obj$npsi <- npsi
  class(obj) <- append("hcp_joinpoint_custom", class(obj))
  obj
}

fit.hcp_joinpoint_custom <- function(obj, data, ...) {
  x <- seq_along(data)
  base_model <- stats::lm(data ~ x)
  obj$model <- segmented::segmented(base_model, seg.Z = ~ x, npsi = obj$npsi)
  obj
}

detect.hcp_joinpoint_custom <- function(obj, serie, ...) {
  obj <- obj$har_store_refs(obj, serie)

  if (is.null(obj$model)) {
    obj <- fit(obj, obj$serie)
  }

  cp <- rep(FALSE, length(obj$serie))
  psi <- round(obj$model$psi[, "Est."])
  psi <- psi[psi >= 1 & psi <= length(cp)]
  cp[psi] <- TRUE

  obj$har_restore_refs(obj, change_points = cp)
}
```

We now fit and use the custom joinpoint detector on a simple change-point series.


``` r
data(examples_changepoints)
dataset <- examples_changepoints$simple

model <- hcp_joinpoint_custom(npsi = 1)
model <- fit(model, dataset$serie)
```

```
## Warning in summary.lm(object, ...): essentially perfect fit: summary may be
## unreliable
```

``` r
detection <- detect(model, dataset$serie)
```


``` r
evaluation <- evaluate(model, detection$event, dataset$event)
evaluation$confMatrix
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100
```


``` r
har_plot(model, dataset$serie, detection, dataset$event)
```

```
## Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
## ℹ Please use `linewidth` instead.
## ℹ The deprecated feature was likely used in the harbinger package.
##   Please report the issue at
##   <https://github.com/cefet-rj-dal/harbinger/issues>.
## This warning is displayed once per session.
## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
## generated.
```

![plot of chunk unnamed-chunk-5](fig/custom_change_point/unnamed-chunk-5-1.png)

This example highlights the usual role of a custom change-point extension in Harbinger: fit a structural model, convert the break estimate to the common detection table, and then reuse the regular evaluation and plotting workflow.

## References

- Muggeo, V. M. R. (2003). Estimating regression models with unknown break-points. Statistics in Medicine, 22(19), 3055-3071.
