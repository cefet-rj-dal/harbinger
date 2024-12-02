---
title: An R Markdown document converted from "./general/examples_motifs.ipynb"
output: html_document
---


```r
# Harbinger Package
# version 1.1.707

source("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/jupyter.R")

#loading Harbinger
load_library("daltoolbox") 
load_library("harbinger") 
```


```r
#loading the example database
data(examples_motifs)
model <- harbinger()
```


```r
#Using the simple time series 
dataset <- examples_motifs$simple
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-3](examples_motifs/unnamed-chunk-3-1.png)


```r
#Using the sample of mitdb 100 time series 
dataset <- examples_motifs$mitdb100
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-4](examples_motifs/unnamed-chunk-4-1.png)


```r
#Using the sample of mitdb 102 time series 
dataset <- examples_motifs$mitdb102
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
grf <- har_plot(model, dataset$serie, detection, dataset$event)
plot(grf)
```

![plot of chunk unnamed-chunk-5](examples_motifs/unnamed-chunk-5-1.png)

