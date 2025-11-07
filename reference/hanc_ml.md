# Anomaly detector based on ML classification

Supervised anomaly detection using a DALToolbox classifier trained with
labeled events. Predictions above a probability threshold are flagged.

A set of preconfigured classification methods are listed at
<https://cefet-rj-dal.github.io/daltoolbox/> (e.g., `cla_majority`,
`cla_dtree`, `cla_knn`, `cla_mlp`, `cla_nb`, `cla_rf`, `cla_svm`).

## Usage

``` r
hanc_ml(model, threshold = 0.5)
```

## Arguments

- model:

  A DALToolbox classification model.

- threshold:

  Numeric. Probability threshold for positive class.

## Value

`hanc_ml` object.

## References

- Bishop CM (2006). Pattern Recognition and Machine Learning. Springer.

- Hyndman RJ, Athanasopoulos G (2021). Forecasting: Principles and
  Practice. OTexts.

- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in
  Time Series. 1st ed. Cham: Springer Nature Switzerland, 2025.
  doi:10.1007/978-3-031-75941-3

## Examples

``` r
library(daltoolbox)

# Load labeled anomaly dataset
data(examples_anomalies)

# Use train-test example
dataset <- examples_anomalies$tt
dataset$event <- factor(dataset$event, labels=c("FALSE", "TRUE"))
slevels <- levels(dataset$event)

# Split into training and test
train <- dataset[1:80,]
test <- dataset[-(1:80),]

# Normalize features
norm <- minmax()
norm <- fit(norm, train)
train_n <- daltoolbox::transform(norm, train)

# Configure a decision tree classifier
model <- hanc_ml(cla_dtree("event", slevels))

# Fit the classifier
model <- fit(model, train_n)

# Evaluate detections on the test set
test_n <- daltoolbox::transform(norm, test)

detection <- detect(model, test_n)
print(detection[(detection$event),])
#> [1] idx   event type 
#> <0 rows> (or 0-length row.names)
```
