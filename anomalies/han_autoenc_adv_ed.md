# Overview

This Rmd demonstrates anomaly detection with an adversarial autoencoder (`han_autoencoder(..., autoenc_adv_ed, ...)`). The model learns a robust latent representation; anomalies yield higher reconstruction error. Steps: load packages/data, visualize, define the architecture/epochs, fit, detect, evaluate, and plot.


``` r
# Install Harbinger (only once, if needed)
#install.packages("harbinger")
```


``` r
# Load required packages
library(daltoolbox)
```

```
## 
## Anexando pacote: 'daltoolbox'
```

```
## O seguinte objeto é mascarado por 'package:base':
## 
##     transform
```

``` r
library(daltoolboxdp)
```

```
## Registered S3 method overwritten by 'quantmod':
##   method            from
##   as.zoo.data.frame zoo
```

``` r
library(harbinger) 
```


``` r
# Load example datasets bundled with harbinger
data(examples_anomalies)
```


``` r
# Select a simple synthetic time series with labeled anomalies
dataset <- examples_anomalies$simple
head(dataset)
```

```
##       serie event
## 1 1.0000000 FALSE
## 2 0.9689124 FALSE
## 3 0.8775826 FALSE
## 4 0.7316889 FALSE
## 5 0.5403023 FALSE
## 6 0.3153224 FALSE
```


``` r
# Plot the time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/han_autoenc_adv_ed/unnamed-chunk-5-1.png)


``` r
# Define adversarial autoencoder-based detector (autoenc_adv_ed)
  model <- han_autoencoder(3, 2, autoenc_adv_ed, num_epochs = 1500)
```


``` r
# Fit the model
  model <- fit(model, dataset$serie)
```

```
## Warning in system2(python, args, stdout = TRUE): execução do comando
## '"C:/Users/eduar/AppData/Local/R/cache/R/reticulate/uv/cache/archive-v0/n3jrw-3a68KSNon74FalM/Scripts/python.exe"
## -m pip freeze' teve status 1
```

```
## 
```

```
## Warning in py_install(pip_packages, pip = TRUE): An ephemeral virtual environment managed by 'reticulate' is currently in use.
## To add more packages to your current session, call `py_require()` instead
## of `py_install()`. Running:
##   `py_require(c("matplotlib", "numpy", "pandas", "scikit-learn", "scipy", "torch"))`
```

```
## Warning in py_require(packages): After Python has initialized, only `action
## = 'add'` with new packages is supported.
```

```
## Done!
```

```
## No module named 'torch'
```


``` r
# Detect anomalies (reconstruction error -> events)
  detection <- detect(model, dataset$serie)
```

```
## No module named 'torch'
```


``` r
# Show only timestamps flagged as events
  print(detection |> dplyr::filter(event==TRUE))
```

```
## Error: objeto 'detection' não encontrado
```


``` r
# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
```

```
## Error: objeto 'detection' não encontrado
```

``` r
  print(evaluation$confMatrix)
```

```
## Error: objeto 'evaluation' não encontrado
```


``` r
# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
```

```
## Error: objeto 'detection' não encontrado
```

``` r
# Plot residual scores and threshold
  har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

```
## Error: objeto 'detection' não encontrado
```
