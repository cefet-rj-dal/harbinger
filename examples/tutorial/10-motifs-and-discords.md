## Objective

This tutorial closes the guided path with repeated-pattern and rare-pattern analysis. The goal is to show that Harbinger is not limited to anomaly or change-point detection: it also supports motif discovery and symbolic pattern analysis.

## Method at a glance

Motifs are repeated subsequences, while discords are unusual subsequences. In this first contact, we use a motif example series and run a symbolic motif-oriented method so the reader can connect the earlier transformation tutorials with downstream sequence analysis.

## What you will do

- load a motif example series
- run a symbolic motif method
- inspect the detected subsequences
- plot the result

## How to read this walkthrough

The code blocks below follow the same learning rhythm used throughout the collection: prepare the environment, choose the dataset, configure the method, run the analysis, and then inspect the result. Readers who are still learning time-series mining can use that order to understand not only *what* each command does, but also *why* it appears at that stage of the workflow.

As you go through the notebook, read the inline comments inside each chunk as the operational explanation and use the surrounding prose as the conceptual guide.

## Walkthrough







### Prepare the Example

We begin by organizing the environment, loading the packages, and selecting the dataset used in the notebook. This part is intentionally more direct: the goal is to make the starting point explicit before the method-specific reasoning begins.


``` r
library(daltoolbox)
library(harbinger)
```



### Interpret the Result Visually

The final plots are not just illustrations. They help the reader connect the method's internal output with the original series, making it easier to see why a point, range, motif, or symbolic pattern was emphasized and whether that emphasis is coherent with the stated objective of the example.


``` r
data(examples_motifs)
dataset <- examples_motifs$simple
har_plot(harbinger(), dataset$serie, event = dataset$event)
```

![plot of chunk unnamed-chunk-2](fig/10-motifs-and-discords/unnamed-chunk-2-1.png)







### Configure the Method

The next step is to instantiate the method and, when necessary, fit it to the selected series. This is where the notebook makes its analytical choice explicit: the parameters chosen here determine what kind of pattern the detector or transformer will become sensitive to and how the later outputs should be interpreted.


``` r
# Configure a symbolic motif detector
model <- hmo_sax(8, 15, 3)
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
head(detection)
```

```
##   idx event type seq seqlen
## 1   1 FALSE       NA     15
## 2   2 FALSE       NA     15
## 3   3 FALSE       NA     15
## 4   4 FALSE       NA     15
## 5   5 FALSE       NA     15
## 6   6 FALSE       NA     15
```







### Interpret the Result Visually

The final plots are not just illustrations. They help the reader connect the method's internal output with the original series, making it easier to see why a point, range, motif, or symbolic pattern was emphasized and whether that emphasis is coherent with the stated objective of the example.


``` r
# Plot the motif-oriented result
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-4](fig/10-motifs-and-discords/unnamed-chunk-4-1.png)

## References

- Lin, J., Keogh, E., Lonardi, S., Chiu, B. (2007). A symbolic representation of time series, with implications for streaming algorithms. Data Mining and Knowledge Discovery, 15, 107-144.
- Ogasawara, E., Salles, R., Porto, F., Pacitti, E. Event Detection in Time Series. Springer, 2025. doi:10.1007/978-3-031-75941-3

