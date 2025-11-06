STAMP motif discovery: Matrix Profile methods compute, for each subsequence, the distance to its nearest neighbor subsequence, enabling efficient discovery of repeated patterns (motifs). STAMP uses random sampling to approximate the Matrix Profile with scalability to long series. In Harbinger this is provided via `tsmp` and wrapped by `hmo_mp()`.

Objectives: This Rmd demonstrates motif discovery using Matrix Profile with the STAMP algorithm via `hmo_mp("stamp", ...)`. It finds repeated subsequences (motifs) in a time series. Steps: load packages/data, visualize the series, define the motif model (subsequence length and number of motifs), fit, detect, evaluate, and plot.


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


``` r
# Plot the time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/hmo_mp_stamp/unnamed-chunk-5-1.png)


``` r
# Define Matrix Profile (STAMP) motif model
# - first arg: algorithm name
# - second arg: subsequence length (window)
# - third arg: number of motifs to retrieve
  model <- hmo_mp("stamp", 4, 3)
```


``` r
# Fit the model
  model <- fit(model, dataset$serie)
```


``` r
# Detect motifs
  detection <- detect(model, dataset$serie)
```

```
## 
STAMP [==>-----------------------------]  10% at 46 it/s, elapsed:  0s, eta:  2s
STAMP [===>----------------------------]  11% at 51 it/s, elapsed:  0s, eta:  2s
STAMP [===>----------------------------]  12% at 55 it/s, elapsed:  0s, eta:  2s
STAMP [===>----------------------------]  13% at 59 it/s, elapsed:  0s, eta:  1s
STAMP [====>---------------------------]  14% at 63 it/s, elapsed:  0s, eta:  1s
STAMP [====>---------------------------]  15% at 67 it/s, elapsed:  0s, eta:  1s
STAMP [====>---------------------------]  16% at 71 it/s, elapsed:  0s, eta:  1s
STAMP [=====>--------------------------]  17% at 76 it/s, elapsed:  0s, eta:  1s
STAMP [=====>--------------------------]  18% at 80 it/s, elapsed:  0s, eta:  1s
STAMP [=====>--------------------------]  19% at 84 it/s, elapsed:  0s, eta:  1s
STAMP [======>-------------------------]  20% at 87 it/s, elapsed:  0s, eta:  1s
STAMP [======>-------------------------]  21% at 91 it/s, elapsed:  0s, eta:  1s
STAMP [======>-------------------------]  22% at 95 it/s, elapsed:  0s, eta:  1s
STAMP [=======>------------------------]  23% at 99 it/s, elapsed:  0s, eta:  1s
STAMP [=======>-----------------------]  24% at 103 it/s, elapsed:  0s, eta:  1s
STAMP [=======>-----------------------]  26% at 106 it/s, elapsed:  0s, eta:  1s
STAMP [=======>-----------------------]  27% at 110 it/s, elapsed:  0s, eta:  1s
STAMP [========>----------------------]  28% at 114 it/s, elapsed:  0s, eta:  1s
STAMP [========>----------------------]  29% at 117 it/s, elapsed:  0s, eta:  1s
STAMP [========>----------------------]  30% at 121 it/s, elapsed:  0s, eta:  1s
STAMP [========>----------------------]  31% at 124 it/s, elapsed:  0s, eta:  1s
STAMP [=========>---------------------]  32% at 128 it/s, elapsed:  0s, eta:  1s
STAMP [=========>---------------------]  33% at 131 it/s, elapsed:  0s, eta:  1s
STAMP [=========>---------------------]  34% at 135 it/s, elapsed:  0s, eta:  0s
STAMP [==========>--------------------]  35% at 138 it/s, elapsed:  0s, eta:  0s
STAMP [==========>--------------------]  36% at 141 it/s, elapsed:  0s, eta:  0s
STAMP [==========>--------------------]  37% at 145 it/s, elapsed:  0s, eta:  0s
STAMP [===========>-------------------]  38% at 148 it/s, elapsed:  0s, eta:  0s
STAMP [===========>-------------------]  39% at 151 it/s, elapsed:  0s, eta:  0s
STAMP [===========>-------------------]  40% at 155 it/s, elapsed:  0s, eta:  0s
STAMP [============>------------------]  41% at 158 it/s, elapsed:  0s, eta:  0s
STAMP [============>------------------]  42% at 161 it/s, elapsed:  0s, eta:  0s
STAMP [============>------------------]  43% at 164 it/s, elapsed:  0s, eta:  0s
STAMP [=============>-----------------]  44% at 167 it/s, elapsed:  0s, eta:  0s
STAMP [=============>-----------------]  45% at 170 it/s, elapsed:  0s, eta:  0s
STAMP [=============>-----------------]  46% at 173 it/s, elapsed:  0s, eta:  0s
STAMP [==============>----------------]  47% at 176 it/s, elapsed:  0s, eta:  0s
STAMP [==============>----------------]  48% at 179 it/s, elapsed:  0s, eta:  0s
STAMP [==============>----------------]  49% at 182 it/s, elapsed:  0s, eta:  0s
STAMP [===============>---------------]  50% at 185 it/s, elapsed:  0s, eta:  0s
STAMP [===============>---------------]  51% at 188 it/s, elapsed:  0s, eta:  0s
STAMP [===============>---------------]  52% at 191 it/s, elapsed:  0s, eta:  0s
STAMP [===============>---------------]  53% at 194 it/s, elapsed:  0s, eta:  0s
STAMP [================>--------------]  54% at 197 it/s, elapsed:  0s, eta:  0s
STAMP [================>--------------]  55% at 200 it/s, elapsed:  0s, eta:  0s
STAMP [================>--------------]  56% at 203 it/s, elapsed:  0s, eta:  0s
STAMP [=================>-------------]  57% at 205 it/s, elapsed:  0s, eta:  0s
STAMP [=================>-------------]  58% at 208 it/s, elapsed:  0s, eta:  0s
STAMP [=================>-------------]  59% at 211 it/s, elapsed:  0s, eta:  0s
STAMP [==================>------------]  60% at 214 it/s, elapsed:  0s, eta:  0s
STAMP [==================>------------]  61% at 216 it/s, elapsed:  0s, eta:  0s
STAMP [==================>------------]  62% at 219 it/s, elapsed:  0s, eta:  0s
STAMP [===================>-----------]  63% at 222 it/s, elapsed:  0s, eta:  0s
STAMP [===================>-----------]  64% at 225 it/s, elapsed:  0s, eta:  0s
STAMP [===================>-----------]  65% at 227 it/s, elapsed:  0s, eta:  0s
STAMP [====================>----------]  66% at 230 it/s, elapsed:  0s, eta:  0s
STAMP [====================>----------]  67% at 232 it/s, elapsed:  0s, eta:  0s
STAMP [====================>----------]  68% at 235 it/s, elapsed:  0s, eta:  0s
STAMP [=====================>---------]  69% at 237 it/s, elapsed:  0s, eta:  0s
STAMP [=====================>---------]  70% at 240 it/s, elapsed:  0s, eta:  0s
STAMP [=====================>---------]  71% at 242 it/s, elapsed:  0s, eta:  0s
STAMP [=====================>---------]  72% at 245 it/s, elapsed:  0s, eta:  0s
STAMP [======================>--------]  73% at 247 it/s, elapsed:  0s, eta:  0s
STAMP [======================>--------]  74% at 250 it/s, elapsed:  0s, eta:  0s
STAMP [======================>--------]  76% at 252 it/s, elapsed:  0s, eta:  0s
STAMP [=======================>-------]  77% at 255 it/s, elapsed:  0s, eta:  0s
STAMP [=======================>-------]  78% at 257 it/s, elapsed:  0s, eta:  0s
STAMP [=======================>-------]  79% at 259 it/s, elapsed:  0s, eta:  0s
STAMP [========================>------]  80% at 262 it/s, elapsed:  0s, eta:  0s
STAMP [========================>------]  81% at 264 it/s, elapsed:  0s, eta:  0s
STAMP [========================>------]  82% at 266 it/s, elapsed:  0s, eta:  0s
STAMP [=========================>-----]  83% at 269 it/s, elapsed:  0s, eta:  0s
STAMP [=========================>-----]  84% at 271 it/s, elapsed:  0s, eta:  0s
STAMP [=========================>-----]  85% at 273 it/s, elapsed:  0s, eta:  0s
STAMP [==========================>----]  86% at 276 it/s, elapsed:  0s, eta:  0s
STAMP [==========================>----]  87% at 278 it/s, elapsed:  0s, eta:  0s
STAMP [==========================>----]  88% at 280 it/s, elapsed:  0s, eta:  0s
STAMP [===========================>---]  89% at 282 it/s, elapsed:  0s, eta:  0s
STAMP [===========================>---]  90% at 284 it/s, elapsed:  0s, eta:  0s
STAMP [===========================>---]  91% at 287 it/s, elapsed:  0s, eta:  0s
STAMP [===========================>---]  92% at 289 it/s, elapsed:  0s, eta:  0s
STAMP [============================>--]  93% at 291 it/s, elapsed:  0s, eta:  0s
STAMP [============================>--]  94% at 293 it/s, elapsed:  0s, eta:  0s
STAMP [============================>--]  95% at 295 it/s, elapsed:  0s, eta:  0s
STAMP [=============================>-]  96% at 297 it/s, elapsed:  0s, eta:  0s
STAMP [=============================>-]  97% at 299 it/s, elapsed:  0s, eta:  0s
STAMP [=============================>-]  98% at 301 it/s, elapsed:  0s, eta:  0s
STAMP [==============================>]  99% at 303 it/s, elapsed:  0s, eta:  0s
STAMP [===============================] 100% at 305 it/s, elapsed:  0s, eta:  0s
## Finished in 0.32 secs
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


``` r
# Plot detections over the series
  har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/hmo_mp_stamp/unnamed-chunk-11-1.png)

References 
- Yeh, C.-C. M., et al. (2016). Matrix Profile I/II: All-pairs similarity joins and scalable time series motif/discord discovery. IEEE ICDM.
- Tavenard, R., et al. (2020). tsmp: The Matrix Profile in R. The R Journal. doi:10.32614/RJ-2020-021
