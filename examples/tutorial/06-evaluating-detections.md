## Tutorial 06 - Evaluating Detections

Running a detector is only part of the workflow. It is also necessary to decide how detections will be judged. In Harbinger, the same result can be read with strict event matching or with a softer criterion that tolerates small temporal shifts.

This tutorial compares those two views using the same detector output.

The method explained here is evaluation itself. Hard evaluation is exact-event matching, while soft evaluation is a tolerance-based technique that recognizes that, in time series, detecting the right phenomenon a few timestamps early or late may still be useful.

Load the packages, prepare a simple detector, and generate the detections once.

``` r
library(daltoolbox)
library(harbinger)

data(examples_anomalies)
dataset <- examples_anomalies$simple
model <- hanr_arima()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
```

Hard evaluation requires direct agreement between detected and labeled events.

``` r
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

Soft evaluation accepts small temporal misalignment.

``` r
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

Inspect the summary metrics returned by both evaluators.

``` r
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
