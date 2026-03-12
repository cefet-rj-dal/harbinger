## Objective

This tutorial explains how to evaluate detected events in Harbinger. The goal is to compare strict event matching with a softer evaluation that tolerates small timing deviations.

## Method at a glance

Harbinger supports both hard and soft evaluation. Hard evaluation requires the detected event to match the labeled event position directly. Soft evaluation relaxes this and can be more appropriate when a detector finds the right phenomenon but marks it a few timestamps earlier or later.

## What you will do

- run an anomaly detector
- compute hard evaluation metrics
- compute soft evaluation metrics
- compare the two interpretations

## How to read this walkthrough

The code blocks below follow the same learning rhythm used throughout the collection: prepare the environment, choose the dataset, configure the method, run the analysis, and then inspect the result. Readers who are still learning time-series mining can use that order to understand not only *what* each command does, but also *why* it appears at that stage of the workflow.

As you go through the notebook, read the inline comments inside each chunk as the operational explanation and use the surrounding prose as the conceptual guide.

## Walkthrough


``` r
library(daltoolbox)
library(harbinger)
```


``` r
data(examples_anomalies)
dataset <- examples_anomalies$simple
model <- hanr_arima()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
```


``` r
# Hard evaluation: direct match between detected and labeled events
hard_eval <- har_eval()
hard_result <- evaluate(hard_eval, detection$event, dataset$event)
hard_result$confMatrix
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100
```


``` r
# Soft evaluation: tolerates small temporal misalignment
soft_eval <- har_eval_soft()
soft_result <- evaluate(soft_eval, detection$event, dataset$event)
soft_result$confMatrix
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100
```


``` r
# Inspect summary metrics returned by the evaluation objects
hard_result
```

```
## $TP
## [1] 1
## 
## $FP
## [1] 0
## 
## $FN
## [1] 0
## 
## $TN
## [1] 100
## 
## $confMatrix
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100  
## 
## $accuracy
## [1] 1
## 
## $sensitivity
## [1] 1
## 
## $specificity
## [1] 1
## 
## $prevalence
## [1] 0.00990099
## 
## $PPV
## [1] 1
## 
## $NPV
## [1] 1
## 
## $detection_rate
## [1] 0.00990099
## 
## $detection_prevalence
## [1] 0.00990099
## 
## $balanced_accuracy
## [1] 1
## 
## $precision
## [1] 1
## 
## $recall
## [1] 1
## 
## $F1
## [1] 1
```

``` r
soft_result
```

```
## $TPs
## [1] 1
## 
## $FPs
## [1] 0
## 
## $FNs
## [1] 0
## 
## $TNs
## [1] 100
## 
## $confMatrix
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100  
## 
## $accuracy
## [1] 1
## 
## $sensitivity
## [1] 1
## 
## $specificity
## [1] 1
## 
## $prevalence
## [1] 0.00990099
## 
## $PPV
## [1] 1
## 
## $NPV
## [1] 1
## 
## $detection_rate
## [1] 0.00990099
## 
## $detection_prevalence
## [1] 0.00990099
## 
## $balanced_accuracy
## [1] 1
## 
## $precision
## [1] 1
## 
## $recall
## [1] 1
## 
## $F1
## [1] 1
```

## References

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. Springer, 2025. doi:10.1007/978-3-031-75941-3

