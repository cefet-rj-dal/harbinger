# Multivariate anomaly detector using PCA

Projects multivariate observations onto principal components and flags
large reconstruction errors as anomalies. Based on classical PCA.

## Usage

``` r
hmu_pca()
```

## Value

`hmu_pca` object.

## Details

The series is standardized, PCA is computed, and data are reconstructed
from principal components. The reconstruction error is summarized and
thresholded.

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
#> 17   17  TRUE anomaly
#> 94   94  TRUE anomaly
#> 101 101  TRUE anomaly
#> 190 190  TRUE anomaly

# Evaluate detections
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)
#>           event      
#> detection TRUE  FALSE
#> TRUE      0     4    
#> FALSE     1     195  
```
