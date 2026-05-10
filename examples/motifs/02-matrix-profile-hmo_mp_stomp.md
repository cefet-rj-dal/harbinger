## Objective

This notebook demonstrates motif discovery using Matrix Profile with the STOMP algorithm via `hmo_mp("stomp", ...)`. It identifies repeated subsequences (motifs) efficiently in long series. Steps: load packages/data, visualize, configure subsequence length and number of motifs, fit, detect, evaluate, and plot.

## Method at a glance

STOMP motif discovery: Matrix Profile methods compute, for each subsequence, the distance to its nearest neighbor subsequence. STOMP is an efficient exact algorithm for long series. Harbinger provides Matrix Profile via `tsmp` and wraps it in `hmo_mp()`.

## What you will do

- understand the purpose of the example and when the technique is useful
- follow the workflow from data loading to model fitting and detection
- inspect the evaluation outputs and the diagnostic plots produced by Harbinger








### Prepare the Example

This setup anchors the notebook in the specific series used to examine `hmo_mp("stomp", ...)`. The semantic point is the one stated above: sTOMP motif discovery: Matrix Profile methods compute, for each subsequence, the distance to its nearest neighbor subsequence, so the raw signal needs to be visible before any fitting step hides that structure behind model output.


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

This first visual pass establishes what the method should react to in the raw series. Keep the method summary in mind here, because sTOMP motif discovery: Matrix Profile methods compute, for each subsequence, the distance to its nearest neighbor subsequence and the plot tells you whether that structure is clean, weak, local, repeated, or mixed with other effects.


``` r
# Plot the time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/02-matrix-profile-hmo_mp_stomp/unnamed-chunk-5-1.png)







### Configure the Method

The choices below turn the central modeling idea into concrete parameters. They matter because sTOMP motif discovery: Matrix Profile methods compute, for each subsequence, the distance to its nearest neighbor subsequence, so each argument controls how strongly the method will emphasize that pattern when it later produces motif candidates.


``` r
# Define Matrix Profile (STOMP) motif model
# - second arg: subsequence length (window)
# - third arg: number of motifs to retrieve
  model <- hmo_mp("stomp", 4, 3)
```




``` r
# Fit the model
  model <- fit(model, dataset$serie)
```







### Run the Core Analysis

This is the moment where the notebook tests its central assumption on actual data. After applying `hmo_mp("stomp", ...)`, the important question is whether the resulting motif candidates really correspond to the pattern implied by the method description above, rather than to arbitrary numerical variation.


``` r
# Detect motifs
  detection <- detect(model, dataset$serie)
```

```
## 
STOMP [=======>------------------------]  23% at 63 it/s, elapsed:  0s, eta:  1s
STOMP [=======>------------------------]  24% at 66 it/s, elapsed:  0s, eta:  1s
STOMP [=======>------------------------]  26% at 68 it/s, elapsed:  0s, eta:  1s
STOMP [=======>------------------------]  27% at 70 it/s, elapsed:  0s, eta:  1s
STOMP [========>-----------------------]  28% at 73 it/s, elapsed:  0s, eta:  1s
STOMP [========>-----------------------]  29% at 75 it/s, elapsed:  0s, eta:  1s
STOMP [========>-----------------------]  30% at 78 it/s, elapsed:  0s, eta:  1s
STOMP [=========>----------------------]  31% at 80 it/s, elapsed:  0s, eta:  1s
STOMP [=========>----------------------]  32% at 82 it/s, elapsed:  0s, eta:  1s
STOMP [=========>----------------------]  33% at 85 it/s, elapsed:  0s, eta:  1s
STOMP [==========>---------------------]  34% at 87 it/s, elapsed:  0s, eta:  1s
STOMP [==========>---------------------]  35% at 89 it/s, elapsed:  0s, eta:  1s
STOMP [==========>---------------------]  36% at 91 it/s, elapsed:  0s, eta:  1s
STOMP [===========>--------------------]  37% at 94 it/s, elapsed:  0s, eta:  1s
STOMP [===========>--------------------]  38% at 96 it/s, elapsed:  0s, eta:  1s
STOMP [===========>--------------------]  39% at 98 it/s, elapsed:  0s, eta:  1s
STOMP [===========>-------------------]  40% at 101 it/s, elapsed:  0s, eta:  1s
STOMP [============>------------------]  41% at 103 it/s, elapsed:  0s, eta:  1s
STOMP [============>------------------]  42% at 105 it/s, elapsed:  0s, eta:  1s
STOMP [============>------------------]  43% at 107 it/s, elapsed:  0s, eta:  1s
STOMP [=============>-----------------]  44% at 110 it/s, elapsed:  0s, eta:  1s
STOMP [=============>-----------------]  45% at 112 it/s, elapsed:  0s, eta:  0s
STOMP [=============>-----------------]  46% at 114 it/s, elapsed:  0s, eta:  0s
STOMP [==============>----------------]  47% at 116 it/s, elapsed:  0s, eta:  0s
STOMP [==============>----------------]  48% at 118 it/s, elapsed:  0s, eta:  0s
STOMP [==============>----------------]  49% at 121 it/s, elapsed:  0s, eta:  0s
STOMP [===============>---------------]  50% at 123 it/s, elapsed:  0s, eta:  0s
STOMP [===============>---------------]  51% at 125 it/s, elapsed:  0s, eta:  0s
STOMP [===============>---------------]  52% at 127 it/s, elapsed:  0s, eta:  0s
STOMP [===============>---------------]  53% at 129 it/s, elapsed:  0s, eta:  0s
STOMP [================>--------------]  54% at 131 it/s, elapsed:  0s, eta:  0s
STOMP [================>--------------]  55% at 133 it/s, elapsed:  0s, eta:  0s
STOMP [================>--------------]  56% at 135 it/s, elapsed:  0s, eta:  0s
STOMP [=================>-------------]  57% at 137 it/s, elapsed:  0s, eta:  0s
STOMP [=================>-------------]  58% at 139 it/s, elapsed:  0s, eta:  0s
STOMP [=================>-------------]  59% at 142 it/s, elapsed:  0s, eta:  0s
STOMP [==================>------------]  60% at 144 it/s, elapsed:  0s, eta:  0s
STOMP [==================>------------]  61% at 146 it/s, elapsed:  0s, eta:  0s
STOMP [==================>------------]  62% at 148 it/s, elapsed:  0s, eta:  0s
STOMP [===================>-----------]  63% at 150 it/s, elapsed:  0s, eta:  0s
STOMP [===================>-----------]  64% at 152 it/s, elapsed:  0s, eta:  0s
STOMP [===================>-----------]  65% at 154 it/s, elapsed:  0s, eta:  0s
STOMP [====================>----------]  66% at 156 it/s, elapsed:  0s, eta:  0s
STOMP [====================>----------]  67% at 158 it/s, elapsed:  0s, eta:  0s
STOMP [====================>----------]  68% at 160 it/s, elapsed:  0s, eta:  0s
STOMP [=====================>---------]  69% at 161 it/s, elapsed:  0s, eta:  0s
STOMP [=====================>---------]  70% at 163 it/s, elapsed:  0s, eta:  0s
STOMP [=====================>---------]  71% at 165 it/s, elapsed:  0s, eta:  0s
STOMP [=====================>---------]  72% at 167 it/s, elapsed:  0s, eta:  0s
STOMP [======================>--------]  73% at 169 it/s, elapsed:  0s, eta:  0s
STOMP [======================>--------]  74% at 171 it/s, elapsed:  0s, eta:  0s
STOMP [======================>--------]  76% at 173 it/s, elapsed:  0s, eta:  0s
STOMP [=======================>-------]  77% at 175 it/s, elapsed:  0s, eta:  0s
STOMP [=======================>-------]  78% at 177 it/s, elapsed:  0s, eta:  0s
STOMP [=======================>-------]  79% at 179 it/s, elapsed:  0s, eta:  0s
STOMP [========================>------]  80% at 180 it/s, elapsed:  0s, eta:  0s
STOMP [========================>------]  81% at 182 it/s, elapsed:  0s, eta:  0s
STOMP [========================>------]  82% at 184 it/s, elapsed:  0s, eta:  0s
STOMP [=========================>-----]  83% at 186 it/s, elapsed:  0s, eta:  0s
STOMP [=========================>-----]  84% at 188 it/s, elapsed:  0s, eta:  0s
STOMP [=========================>-----]  85% at 189 it/s, elapsed:  0s, eta:  0s
STOMP [==========================>----]  86% at 191 it/s, elapsed:  0s, eta:  0s
STOMP [==========================>----]  87% at 193 it/s, elapsed:  0s, eta:  0s
STOMP [==========================>----]  88% at 195 it/s, elapsed:  0s, eta:  0s
STOMP [===========================>---]  89% at 197 it/s, elapsed:  0s, eta:  0s
STOMP [===========================>---]  90% at 198 it/s, elapsed:  0s, eta:  0s
STOMP [===========================>---]  91% at 200 it/s, elapsed:  0s, eta:  0s
STOMP [===========================>---]  92% at 202 it/s, elapsed:  0s, eta:  0s
STOMP [============================>--]  93% at 204 it/s, elapsed:  0s, eta:  0s
STOMP [============================>--]  94% at 205 it/s, elapsed:  0s, eta:  0s
STOMP [============================>--]  95% at 207 it/s, elapsed:  0s, eta:  0s
STOMP [=============================>-]  96% at 209 it/s, elapsed:  0s, eta:  0s
STOMP [=============================>-]  97% at 210 it/s, elapsed:  0s, eta:  0s
STOMP [=============================>-]  98% at 212 it/s, elapsed:  0s, eta:  0s
STOMP [==============================>]  99% at 214 it/s, elapsed:  0s, eta:  0s
STOMP [===============================] 100% at 215 it/s, elapsed:  0s, eta:  0s
## Finished in 0.46 secs
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
## 6   50  TRUE motif   1      4
## 7   56  TRUE motif   3      4
## 8   69  TRUE motif   2      4
## 9   75  TRUE motif   1      4
## 10  81  TRUE motif   3      4
## 11  94  TRUE motif   2      4
```







### Evaluate What Was Found

The evaluation asks whether the motif candidates produced by `hmo_mp("stomp", ...)` match the labeled structure on this dataset. Read the scores as evidence about the method's assumptions in practice, not as detached summary numbers.


``` r
# Evaluate detections against ground-truth labels
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      3     8    
## FALSE     0     90
```







### Interpret the Result Visually

This visual check puts the model output back on top of the original signal. What matters now is whether the highlighted motif candidates line up with the structure suggested by the method, which is the real semantic test of whether the example is teaching the right lesson.


``` r
# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/02-matrix-profile-hmo_mp_stomp/unnamed-chunk-11-1.png)

## References

- Yeh, C.-C. M., et al. (2016). Matrix Profile I/II: All-pairs similarity joins and scalable time series motif/discord discovery. IEEE ICDM.
- Tavenard, R., et al. (2020). tsmp: The Matrix Profile in R. The R Journal. doi:10.32614/RJ-2020-021
