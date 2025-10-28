This notebook demonstrates several change-point patterns in the example datasets and how to visualize detections. We iterate across series and apply: fit, detect, plot.


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
# Load change-point example datasets and create a base object
data(examples_changepoints)
model <- harbinger()
```


``` r
# Simple change point
dataset <- examples_changepoints$simple
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-4](fig/examples_changepoints/unnamed-chunk-4-1.png)


``` r
# Sinusoidal pattern with regime shift
dataset <- examples_changepoints$sinusoidal
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-5](fig/examples_changepoints/unnamed-chunk-5-1.png)


``` r
# Incremental trend changes
dataset <- examples_changepoints$incremental
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-6](fig/examples_changepoints/unnamed-chunk-6-1.png)


``` r
# Abrupt level shift
dataset <- examples_changepoints$abrupt
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)
```

```
## Don't know how to automatically pick scale for object of type <ts>. Defaulting to continuous.
```

![plot of chunk unnamed-chunk-7](fig/examples_changepoints/unnamed-chunk-7-1.png)


``` r
# Volatility (variance) change
dataset <- examples_changepoints$volatility
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)
```

```
## Don't know how to automatically pick scale for object of type <ts>. Defaulting to continuous.
```

![plot of chunk unnamed-chunk-8](fig/examples_changepoints/unnamed-chunk-8-1.png)


``` r
# Increasing amplitude
dataset <- examples_changepoints$increasing_amplitude
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-9](fig/examples_changepoints/unnamed-chunk-9-1.png)


``` r
# Complex multi-regime series
dataset <- examples_changepoints$complex
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-10](fig/examples_changepoints/unnamed-chunk-10-1.png)

