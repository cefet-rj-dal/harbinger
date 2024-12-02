---
title: An R Markdown document converted from "./motifs/hdis_mp_stamp.ipynb"
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
```


```r
#Using the simple time series
dataset <- examples_motifs$mitdb102
head(dataset)
```

```
##         serie event symbol
## 102992 -0.215 FALSE      N
## 102993 -0.210 FALSE      N
## 102994 -0.215 FALSE      N
## 102995 -0.230 FALSE      N
## 102996 -0.220 FALSE      N
## 102997 -0.200 FALSE      N
```


```r
#ploting the time series
plot_ts(x = 1:length(dataset$serie), y = dataset$serie)
```

![plot of chunk unnamed-chunk-4](hdis_mp_stamp/unnamed-chunk-4-1.png)


```r
# establishing the method  
model <- hdis_mp(mode = "stomp", w = 25, qtd = 10)
```


```r
# fitting the model
  model <- fit(model, dataset$serie)
```


```r
# making detections
  suppressMessages(detection <- detect(model, dataset$serie))
```


```r
# filtering detected events
  print(detection |> dplyr::filter(event==TRUE))
```

```
##    idx event  type seq seqlen
## 1 2602  TRUE motif   1     25
## 2 3844  TRUE motif   1     25
## 3 4017  TRUE motif   1     25
## 4 6135  TRUE motif   1     25
```


```r
# evaluating the detections
  evaluation <- evaluate(model, detection$event, dataset$event)
  print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      0     4    
## FALSE     3     7195
```


```r
# ploting the results
  grf <- har_plot(model, dataset$serie, detection, dataset$event)
  plot(grf)
```

![plot of chunk unnamed-chunk-10](hdis_mp_stamp/unnamed-chunk-10-1.png)

