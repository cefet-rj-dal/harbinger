## Objective

This notebook demonstrates motif discovery using Matrix Profile with SCRIMP via `hmo_mp("scrimp", ...)`. SCRIMP is an incremental algorithm for computing the matrix profile. Steps: load packages/data, visualize, set subsequence length and count, fit, detect, evaluate, and plot.

## Method at a glance

SCRIMP motif discovery: Matrix Profile methods compute nearest-neighbor distances for subsequences. SCRIMP incrementally approximates the profile and refines it efficiently. Provided via `tsmp` and wrapped by `hmo_mp()`.

## What you will do

- understand the purpose of the example and when the technique is useful
- follow the workflow from data loading to model fitting and detection
- inspect the evaluation outputs and the diagnostic plots produced by Harbinger








### Prepare the Example

This setup anchors the notebook in the specific series used to examine `hmo_mp("scrimp", ...)`. The semantic point is the one stated above: sCRIMP motif discovery: Matrix Profile methods compute nearest-neighbor distances for subsequences, so the raw signal needs to be visible before any fitting step hides that structure behind model output.


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

This first visual pass establishes what the method should react to in the raw series. Keep the method summary in mind here, because sCRIMP motif discovery: Matrix Profile methods compute nearest-neighbor distances for subsequences and the plot tells you whether that structure is clean, weak, local, repeated, or mixed with other effects.


``` r
# Plot the time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/03-matrix-profile-hmo_mp_scrimp/unnamed-chunk-5-1.png)







### Configure the Method

The choices below turn the central modeling idea into concrete parameters. They matter because sCRIMP motif discovery: Matrix Profile methods compute nearest-neighbor distances for subsequences, so each argument controls how strongly the method will emphasize that pattern when it later produces motif candidates.


``` r
# Define Matrix Profile (SCRIMP) motif model
# - second arg: subsequence length (window)
# - third arg: number of motifs to retrieve
  model <- hmo_mp("scrimp", 4, 3)
```




``` r
# Fit the model
  model <- fit(model, dataset$serie)
```







### Run the Core Analysis

This is the moment where the notebook tests its central assumption on actual data. After applying `hmo_mp("scrimp", ...)`, the important question is whether the resulting motif candidates really correspond to the pattern implied by the method description above, rather than to arbitrary numerical variation.


``` r
# Detect motifs
  detection <- detect(model, dataset$serie)
```

```
## 
PRE-SCRIMP [========>------------------]  32% at 77 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [========>------------------]  33% at 79 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [========>------------------]  34% at 81 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [========>------------------]  35% at 83 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [=========>-----------------]  36% at 85 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [=========>-----------------]  37% at 87 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [=========>-----------------]  38% at 89 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [==========>----------------]  39% at 92 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [==========>----------------]  40% at 94 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [==========>----------------]  41% at 96 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [==========>----------------]  42% at 98 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [==========>---------------]  43% at 100 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [===========>--------------]  44% at 102 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [===========>--------------]  45% at 104 it/s, elapsed:  0s, eta:  1s
PRE-SCRIMP [===========>--------------]  46% at 106 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [===========>--------------]  47% at 108 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [============>-------------]  48% at 110 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [============>-------------]  49% at 112 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [============>-------------]  51% at 114 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [============>-------------]  52% at 116 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [=============>------------]  53% at 118 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [=============>------------]  54% at 120 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [=============>------------]  55% at 122 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [=============>------------]  56% at 124 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [==============>-----------]  57% at 126 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [==============>-----------]  58% at 128 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [==============>-----------]  59% at 130 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [===============>----------]  60% at 132 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [===============>----------]  61% at 134 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [===============>----------]  62% at 136 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [===============>----------]  63% at 137 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [================>---------]  64% at 139 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [================>---------]  65% at 141 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [================>---------]  66% at 143 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [================>---------]  67% at 145 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [=================>--------]  68% at 147 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [=================>--------]  69% at 148 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [=================>--------]  70% at 150 it/s, elapsed:  0s, eta:  0s
PRE-SCRIMP [==================>--------]  71% at 87 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [==================>--------]  72% at 88 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [===================>-------]  73% at 89 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [===================>-------]  74% at 90 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [===================>-------]  75% at 92 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [====================>------]  76% at 93 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [====================>------]  77% at 94 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [====================>------]  78% at 95 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [====================>------]  79% at 96 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [=====================>-----]  80% at 97 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [=====================>-----]  81% at 98 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [=====================>-----]  82% at 99 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [=====================>----]  84% at 100 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [=====================>----]  85% at 101 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [=====================>----]  86% at 102 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [======================>---]  87% at 104 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [======================>---]  88% at 105 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [======================>---]  89% at 106 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [======================>---]  90% at 107 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [=======================>--]  91% at 108 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [=======================>--]  92% at 109 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [=======================>--]  93% at 110 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [=======================>--]  94% at 111 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [========================>-]  95% at 112 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [========================>-]  96% at 113 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [========================>-]  97% at 114 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [========================>-]  98% at 115 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [=========================>]  99% at 116 it/s, elapsed:  1s, eta:  0s
PRE-SCRIMP [==========================] 100% at 117 it/s, elapsed:  1s, eta:  0s
## Finished in 0.84 secs
```




``` r
# Show only timestamps flagged as events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##    idx event  type seq seqlen
## 1    6  TRUE motif   3      4
## 2   19  TRUE motif   2      4
## 3   25  TRUE motif   1      4
## 4   31  TRUE motif   3      4
## 5   44  TRUE motif   2      4
## 6   56  TRUE motif   3      4
## 7   69  TRUE motif   2      4
## 8   75  TRUE motif   1      4
## 9   81  TRUE motif   3      4
## 10  94  TRUE motif   2      4
```







### Evaluate What Was Found

The evaluation asks whether the motif candidates produced by `hmo_mp("scrimp", ...)` match the labeled structure on this dataset. Read the scores as evidence about the method's assumptions in practice, not as detached summary numbers.


``` r
# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      2     8    
## FALSE     1     90
```







### Interpret the Result Visually

This visual check puts the model output back on top of the original signal. What matters now is whether the highlighted motif candidates line up with the structure suggested by the method, which is the real semantic test of whether the example is teaching the right lesson.


``` r
# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/03-matrix-profile-hmo_mp_scrimp/unnamed-chunk-11-1.png)

## References

- Yeh, C.-C. M., et al. (2016). Matrix Profile I/II: All-pairs similarity joins and scalable time series motif/discord discovery. IEEE ICDM.
- Tavenard, R., et al. (2020). tsmp: The Matrix Profile in R. The R Journal. doi:10.32614/RJ-2020-021
