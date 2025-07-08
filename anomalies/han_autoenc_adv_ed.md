
``` r
# Installing Harbinger
install.packages("harbinger")
```


``` r
# Loading Harbinger
library(daltoolbox)
```

```
## Registered S3 method overwritten by 'quantmod':
##   method            from
##   as.zoo.data.frame zoo
```

```
## Registered S3 methods overwritten by 'forecast':
##   method  from 
##   head.ts stats
##   tail.ts stats
```

```
## 
## Attaching package: 'daltoolbox'
```

```
## The following object is masked from 'package:base':
## 
##     transform
```

``` r
library(daltoolboxdp)
library(harbinger) 
```

```
## Registered S3 methods overwritten by 'tspredit':
##   method           from      
##   [.ts_data        daltoolbox
##   action.ts_reg    daltoolbox
##   evaluate.ts_reg  daltoolbox
##   fit.ts_arima     daltoolbox
##   fit.ts_regsw     daltoolbox
##   predict.ts_arima daltoolbox
##   predict.ts_reg   daltoolbox
##   predict.ts_regsw daltoolbox
```


``` r
# loading the example database
data(examples_anomalies)
```


``` r
# Using the simple time series 
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
# ploting the time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/han_autoenc_adv_ed/unnamed-chunk-5-1.png)


``` r
# establishing han_autoencoder method 
  model <- han_autoencoder(3, 2, autoenc_adv_ed, num_epochs = 1500)
```


``` r
# fitting the model
  model <- fit(model, dataset$serie)
```


``` r
# making detections
  detection <- detect(model, dataset$serie)
```


``` r
# filtering detected events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event    type
## 1  19  TRUE anomaly
## 2  44  TRUE anomaly
```


``` r
# evaluating the detections
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     2    
## FALSE     1     98
```


``` r
# plotting the results
  har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/han_autoenc_adv_ed/unnamed-chunk-11-1.png)

``` r
# plotting the residuals
  har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-12](fig/han_autoenc_adv_ed/unnamed-chunk-12-1.png)
