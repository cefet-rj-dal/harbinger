# Multivariate anomaly detector using PCA

Projects multivariate observations onto principal components and flags
large reconstruction errors as anomalies. Based on classical PCA.

## Usage

``` r
hmu_pca(num_components = NULL, variance = 0.9)
```

## Arguments

- num_components:

  Integer or `NULL`. Number of principal components to retain for
  reconstruction. When `NULL` (default) the number is chosen
  automatically from `variance`.

- variance:

  Numeric in (0, 1\]. Target cumulative proportion of variance used to
  pick `num_components` automatically when it is `NULL`.

## Value

`hmu_pca` object.

## Details

The series is standardized, PCA is computed, and the data are
reconstructed from a **reduced** set of principal components. The
reconstruction error (the part of the signal not captured by the
retained components) is summarized and thresholded as the anomaly score.

Keeping *all* components would reconstruct the data exactly, leaving
only floating-point round-off as the residual (a degenerate detector).
By default `hmu_pca` therefore keeps the leading components that explain
`variance` of the total variance, capped at `ncol - 1` so at least one
component is always dropped. Pass `num_components` to fix the number of
retained components explicitly.

## References

- Jolliffe IT (2002). Principal Component Analysis. Springer.

## Examples

``` r
library(daltoolbox)

# Load multivariate example data
data(examples_harbinger)

# Use a multidimensional time series
dataset <- examples_harbinger$multidimensional
head(dataset)
#>        serie           x event
#> 1 -0.6264538  0.40940184 FALSE
#> 2 -0.8356286  1.58658843 FALSE
#> 3  1.5952808 -0.33090780 FALSE
#> 4  0.3295078 -2.28523554 FALSE
#> 5 -0.8204684  2.49766159 FALSE
#> 6  0.5757814 -0.01339952 FALSE

# Configure PCA-based anomaly detector
model <- hmu_pca()

# Fit the model (example uses first two columns)
model <- fit(model, dataset[,1:2])

# Run detection
detection <- detect(model, dataset[,1:2])

# Show detected anomalies
print(detection[(detection$event),])
#>     idx event    type
#> 113 113  TRUE anomaly
#> 138 138  TRUE anomaly
#> 154 154  TRUE anomaly
#> 158 158  TRUE anomaly
#> 175 175  TRUE anomaly
#> 181 181  TRUE anomaly

# Evaluate detections
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)
#>           event      
#> detection TRUE  FALSE
#> TRUE      0     6    
#> FALSE     1     193  
```
