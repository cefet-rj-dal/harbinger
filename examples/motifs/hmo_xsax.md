XSAX extends SAX to a larger alphanumeric alphabet, enabling finer symbolic resolution for motif discovery. In this tutorial we:

- Load and visualize a motif dataset
- Configure `hmo_xsax(a, w, qtd)` and run detection
- Inspect and evaluate motif occurrences


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
# Load example motif datasets
data(examples_motifs)
```


``` r
# Select the simple motif dataset
dataset <- examples_motifs$simple
head(dataset)
```

```
##       serie event
## 1 1.0000000 FALSE
## 2 0.9939124 FALSE
## 3 0.9275826 FALSE
## 4 0.8066889 FALSE
## 5 0.6403023 FALSE
## 6 0.4403224 FALSE
```


``` r
# Plot the raw time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/hmo_xsax/unnamed-chunk-5-1.png)


``` r
# Configure XSAX motif discovery (alphabet=37, word=3, min occurrences=3)
model <- hmo_xsax(37, 3, 3)
```


``` r
# Fit the detector (learns binning thresholds)
model <- fit(model, dataset$serie)
```


``` r
# Run motif discovery
detection <- detect(model, dataset$serie)
```


``` r
# Show detected motif starts
print(detection |> dplyr::filter(event == TRUE))
```

```
##   idx event  type    seq seqlen
## 1  25  TRUE motif 0N0P0R      3
## 2  50  TRUE motif 0N0P0R      3
## 3  75  TRUE motif 0N0P0R      3
```


``` r
# Evaluate detections against labels
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      3     0    
## FALSE     0     98
```


``` r
# Plot motifs and ground truth
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/hmo_xsax/unnamed-chunk-11-1.png)

