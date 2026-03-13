## Objective

This Rmd shows supervised anomaly classification using `hanc_ml` with k-Nearest Neighbors (`cla_knn`). It uses labeled events, a simple train/test split, and min-max normalization. Steps: load packages/data, visualize, preprocess, define and fit the classifier, detect, evaluate, and plot results.

## Method at a glance

k-NN classification anomaly detector: Supervised anomaly detection using k-NN classification on labeled data; positive-class probabilities above a threshold indicate events.

## What you will do

- understand the purpose of the example and when the technique is useful
- follow the workflow from data loading to model fitting and detection
- inspect the evaluation outputs and the diagnostic plots produced by Harbinger








### Prepare the Example

This setup anchors the notebook in the specific series used to examine `cla_knn`. The semantic point is the one stated above: k-NN classification anomaly detector: Supervised anomaly detection using k-NN classification on labeled data; positive-class probabilities above a threshold indicate events, so the raw signal needs to be visible before any fitting step hides that structure behind model output.


``` r
# Install Harbinger (only once, if needed)
#install.packages("harbinger")
```






``` r
# Load required packages
library(daltoolbox)
library(harbinger) 
```






``` r
# Load example datasets bundled with harbinger
data(examples_anomalies)
```




``` r
# Use the "tt" time series (labeled)
dataset <- examples_anomalies$tt

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







### Interpret the Result Visually

This first visual pass establishes what the method should react to in the raw series. Keep the method summary in mind here, because k-NN classification anomaly detector: Supervised anomaly detection using k-NN classification on labeled data; positive-class probabilities above a threshold indicate events and the plot tells you whether that structure is clean, weak, local, repeated, or mixed with other effects.


``` r
# Plot the time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/23-classification-hanc_ml_knn/unnamed-chunk-5-1.png)







### Configure the Method

The choices below turn the central modeling idea into concrete parameters. They matter because k-NN classification anomaly detector: Supervised anomaly detection using k-NN classification on labeled data; positive-class probabilities above a threshold indicate events, so each argument controls how strongly the method will emphasize that pattern when it later produces event classifications.


``` r
# Data preprocessing: split and scale


train <- dataset[1:80,]
test <- dataset[-(1:80),]

norm <- minmax()
norm <- fit(norm, train)
train_n <- transform(norm, train)
summary(train_n)
```

```
##      serie          event        
##  Min.   :0.0000   Mode :logical  
##  1st Qu.:0.2859   FALSE:76       
##  Median :0.5348   TRUE :4        
##  Mean   :0.5221                  
##  3rd Qu.:0.7587                  
##  Max.   :1.0000
```




``` r
# Define k-NN classifier for events (hanc_ml + cla_knn)
model <- hanc_ml(cla_knn("event", c("FALSE", "TRUE"), k=3))
```




``` r
# Fit the model on training data
model <- fit(model, train_n)
detection <- detect(model, train_n)
print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event    type
## 1  12  TRUE anomaly
## 2  24  TRUE anomaly
## 3  38  TRUE anomaly
## 4  50  TRUE anomaly
```

``` r
# Evaluate training performance
evaluation <- evaluate(model, detection$event, as.logical(train_n$event))
print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      4     0    
## FALSE     0     76
```







### Interpret the Result Visually

This visual check puts the model output back on top of the original signal. What matters now is whether the highlighted event classifications line up with the structure suggested by the method, which is the real semantic test of whether the example is teaching the right lesson.


``` r
# Plot training detections
  har_plot(model, train_n$serie, detection, as.logical(train_n$event))
```

![plot of chunk unnamed-chunk-9](fig/23-classification-hanc_ml_knn/unnamed-chunk-9-1.png)







### Run the Core Analysis

This is the moment where the notebook tests its central assumption on actual data. After applying `cla_knn`, the important question is whether the resulting event classifications really correspond to the pattern implied by the method description above, rather than to arbitrary numerical variation.


``` r
# Prepare test data (apply same scaler)
  test_n <- transform(norm, test)
```




``` r
# Detect and evaluate on test data
  detection <- detect(model, test_n)

  print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event    type
## 1  10  TRUE anomaly
## 2  21  TRUE anomaly
```

``` r
  evaluation <- evaluate(model, detection$event, as.logical(test_n$event))
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      2     0    
## FALSE     0     19
```







### Interpret the Result Visually

This visual check puts the model output back on top of the original signal. What matters now is whether the highlighted event classifications line up with the structure suggested by the method, which is the real semantic test of whether the example is teaching the right lesson.


``` r
# Plot test detections
  har_plot(model, test_n$serie, detection, as.logical(test_n$event))
```

![plot of chunk unnamed-chunk-12](fig/23-classification-hanc_ml_knn/unnamed-chunk-12-1.png)




``` r
# Plot residual scores and threshold
har_plot(model, attr(detection, "res"), detection, test_n$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-13](fig/23-classification-hanc_ml_knn/unnamed-chunk-13-1.png)

## References

- Bishop, C. M. (2006). Pattern Recognition and Machine Learning. Springer.
- Hyndman, R. J., Athanasopoulos, G. (2021). Forecasting: Principles and Practice. OTexts.
- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. Springer, 2025. doi:10.1007/978-3-031-75941-3
