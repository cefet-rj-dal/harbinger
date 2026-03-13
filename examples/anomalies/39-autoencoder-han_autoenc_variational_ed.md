## Objective

This notebook demonstrates anomaly detection with a variational autoencoder (`han_autoencoder(..., autoenc_variational_ed, ...)`). The VAE learns a probabilistic latent space; reconstruction error (and uncertainty) can indicate anomalies. Steps: load packages/data, visualize, define the architecture/epochs, fit, detect, evaluate, and plot.

## Method at a glance

variational autoencoder (VAE) (encode-decode): A variational autoencoder (VAE) learns a probabilistic latent space and reconstructs windows; high reconstruction error (and uncertainty) signals anomalies. Errors are summarized and thresholded using `harutils()`.

## What you will do

- understand the purpose of the example and when the technique is useful
- follow the workflow from data loading to model fitting and detection
- inspect the evaluation outputs and the diagnostic plots produced by Harbinger

## How to read this walkthrough

The code blocks below follow the same learning rhythm used throughout the collection: prepare the environment, choose the dataset, configure the method, run the analysis, and then inspect the result. Readers who are still learning time-series mining can use that order to understand not only *what* each command does, but also *why* it appears at that stage of the workflow.

As you go through the notebook, read the inline comments inside each chunk as the operational explanation and use the surrounding prose as the conceptual guide.

## Walkthrough







### Prepare the Example

We begin by organizing the environment, loading the packages, and selecting the dataset used in the notebook. This part is intentionally more direct: the goal is to make the starting point explicit before the method-specific reasoning begins.


``` r
# Load required packages
library(daltoolbox)
library(harbinger) 
library(daltoolboxdp)
```






``` r
# Load example datasets bundled with harbinger
data(examples_anomalies)
```




``` r
# Select a simple synthetic time series with labeled anomalies
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







### Interpret the Result Visually

The final plots are not just illustrations. They help the reader connect the method's internal output with the original series, making it easier to see why a point, range, motif, or symbolic pattern was emphasized and whether that emphasis is coherent with the stated objective of the example.


``` r
# Plot the time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-4](fig/39-autoencoder-han_autoenc_variational_ed/unnamed-chunk-4-1.png)







### Configure the Method

The next step is to instantiate the method and, when necessary, fit it to the selected series. This is where the notebook makes its analytical choice explicit: the parameters chosen here determine what kind of pattern the detector or transformer will become sensitive to and how the later outputs should be interpreted.


``` r
# Define variational autoencoder-based detector (autoenc_variational_ed)
  model <- han_autoencoder(3, 2, autoenc_variational_ed, num_epochs = 1500)
```




``` r
# Fit the model
  model <- fit(model, dataset$serie)
```







### Run the Core Analysis

With the environment and the method ready, we execute the central analytical step and inspect its immediate output. This is the point where the abstract idea described earlier becomes operational, so the reader should pay attention to what is produced and how Harbinger standardizes the result.


``` r
# Detect anomalies (reconstruction error -> events)
  detection <- detect(model, dataset$serie)
```




``` r
# Show only timestamps flagged as events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event    type
## 1  50  TRUE anomaly
## 2  52  TRUE anomaly
## 3  59  TRUE anomaly
```







### Evaluate What Was Found

After producing detections or transformed outputs, we compare them with the reference labels whenever they are available. This stage matters because it connects the visual intuition of the method with an explicit measurement of quality, helping the learner understand not only whether the method runs, but how well it behaves.


``` r
# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     2    
## FALSE     0     98
```







### Interpret the Result Visually

The final plots are not just illustrations. They help the reader connect the method's internal output with the original series, making it easier to see why a point, range, motif, or symbolic pattern was emphasized and whether that emphasis is coherent with the stated objective of the example.


``` r
# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-10](fig/39-autoencoder-han_autoenc_variational_ed/unnamed-chunk-10-1.png)




``` r
# Plot residual scores and threshold
  har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-11](fig/39-autoencoder-han_autoenc_variational_ed/unnamed-chunk-11-1.png)

## References

- Sakurada, M., Yairi, T. (2014). Anomaly Detection Using Autoencoders with Nonlinear Dimensionality Reduction. MLSDA 2014.
