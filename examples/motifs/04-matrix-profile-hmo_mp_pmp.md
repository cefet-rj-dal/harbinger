## Objective

This notebook demonstrates motif discovery with the Pan Matrix Profile (`hmo_mp("pmp", ...)`), which summarizes motifs across multiple subsequence lengths. Steps: load packages/data, visualize, configure parameters, fit, detect, evaluate, and plot.

## Method at a glance

PMP motif discovery: PMP (Pan-Matrix Profile) unifies matrix profiles across multiple dimensions or parameters to expose motifs that persist under variations. Harbinger wraps `tsmp` to compute and search the profile.

## What you will do

- understand the purpose of the example and when the technique is useful
- follow the workflow from data loading to model fitting and detection
- inspect the evaluation outputs and the diagnostic plots produced by Harbinger








### Prepare the Example

This setup anchors the notebook in the specific series used to examine `hmo_mp("pmp", ...)`. The semantic point is the one stated above: pMP motif discovery: PMP (Pan-Matrix Profile) unifies matrix profiles across multiple dimensions or parameters to expose motifs that persist under variations, so the raw signal needs to be visible before any fitting step hides that structure behind model output.


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
data(examples_motifs)
```




``` r
# Select a simple example time series
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







### Interpret the Result Visually

This first visual pass establishes what the method should react to in the raw series. Keep the method summary in mind here, because pMP motif discovery: PMP (Pan-Matrix Profile) unifies matrix profiles across multiple dimensions or parameters to expose motifs that persist under variations and the plot tells you whether that structure is clean, weak, local, repeated, or mixed with other effects.


``` r
# Plot the time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/04-matrix-profile-hmo_mp_pmp/unnamed-chunk-5-1.png)







### Configure the Method

The choices below turn the central modeling idea into concrete parameters. They matter because pMP motif discovery: PMP (Pan-Matrix Profile) unifies matrix profiles across multiple dimensions or parameters to expose motifs that persist under variations, so each argument controls how strongly the method will emphasize that pattern when it later produces motif candidates.


``` r
# Define Pan Matrix Profile (PMP) motif model
# - second arg: subsequence length (window)
# - third arg: number of motifs to retrieve
  model <- hmo_mp("pmp", 4, 3)
```




``` r
# Fit the model
  model <- fit(model, dataset$serie)
```







### Run the Core Analysis

This is the moment where the notebook tests its central assumption on actual data. After applying `hmo_mp("pmp", ...)`, the important question is whether the resulting motif candidates really correspond to the pattern implied by the method description above, rather than to arbitrary numerical variation.


``` r
# Detect motifs
  detection <- detect(model, dataset$serie)
```

```
## step: 1/1 binary idx: 1 window: 4
```




``` r
# Show only timestamps flagged as events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##   idx event  type seq seqlen
## 1  19  TRUE motif   3      4
## 2  25  TRUE motif   2      4
## 3  44  TRUE motif   3      4
## 4  50  TRUE motif   2      4
## 5  69  TRUE motif   3      4
## 6  75  TRUE motif   2      4
## 7  94  TRUE motif   3      4
```







### Evaluate What Was Found

The evaluation asks whether the motif candidates produced by `hmo_mp("pmp", ...)` match the labeled structure on this dataset. Read the scores as evidence about the method's assumptions in practice, not as detached summary numbers.


``` r
# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      3     4    
## FALSE     0     94
```







### Interpret the Result Visually

This visual check puts the model output back on top of the original signal. What matters now is whether the highlighted motif candidates line up with the structure suggested by the method, which is the real semantic test of whether the example is teaching the right lesson.


``` r
# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/04-matrix-profile-hmo_mp_pmp/unnamed-chunk-11-1.png)

## References

- Yeh, C.-C. M., et al. (2016). Matrix Profile I/II: All-pairs similarity joins and scalable time series motif/discord discovery. IEEE ICDM.
- Tavenard, R., et al. (2020). tsmp: The Matrix Profile in R. The R Journal. doi:10.32614/RJ-2020-021
