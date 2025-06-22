
``` r
# Installing Harbinger
#install.packages"harbinger")
```


``` r
# Loading Harbinger
library(daltoolbox)
library(harbinger) 
```


``` r
# loading the example database
data(examples_changepoints)
model <- harbinger()
```


``` r
# Using the simple time series 
dataset <- examples_changepoints$simple
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-4](fig/examples_changepoints/unnamed-chunk-4-1.png)


``` r
# Using the sinusoidal time series
dataset <- examples_changepoints$sinusoidal
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-5](fig/examples_changepoints/unnamed-chunk-5-1.png)


``` r
# Using the incremental time series
dataset <- examples_changepoints$incremental
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-6](fig/examples_changepoints/unnamed-chunk-6-1.png)


``` r
# Using the abrupt time series 
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
# Using the volatility time series
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
# Using the increasing_amplitude time series
dataset <- examples_changepoints$increasing_amplitude
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-9](fig/examples_changepoints/unnamed-chunk-9-1.png)


``` r
# Using the complex time series
dataset <- examples_changepoints$complex
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-10](fig/examples_changepoints/unnamed-chunk-10-1.png)

