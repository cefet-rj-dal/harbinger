## Objective

SAX-based discord discovery identifies rare, dissimilar subsequences by discretizing the series and finding unique words with high entropy. We will:

- Load and visualize a motif/discord dataset
- Configure `hdis_sax(a, w)` and run discovery
- Inspect and evaluate discord occurrences

## Method at a glance

SAX motif discovery: SAX discretizes z-normalized subsequences into symbolic words; discords emerge as rare words or windows with large symbolic distance to their neighbors.

## What you will do

- understand the purpose of the example and when the technique is useful
- follow the workflow from data loading to model fitting and detection
- inspect the evaluation outputs and the diagnostic plots produced by Harbinger








### Prepare the Example

This setup anchors the notebook in the specific series used to examine `09-discord-hdis_sax`. The semantic point is the one stated above: sAX motif discovery: SAX discretizes z-normalized subsequences into symbolic words; discords emerge as rare words or windows with large symbolic distance to their neighbors, so the raw signal needs to be visible before any fitting step hides that structure behind model output.


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
# Load example motif/discord datasets
data(examples_motifs)
```




``` r
# Select an ECG sample (mitdb102)
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







### Interpret the Result Visually

This first visual pass establishes what the method should react to in the raw series. Keep the method summary in mind here, because sAX motif discovery: SAX discretizes z-normalized subsequences into symbolic words; discords emerge as rare words or windows with large symbolic distance to their neighbors and the plot tells you whether that structure is clean, weak, local, repeated, or mixed with other effects.


``` r
# Plot the raw time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/09-discord-hdis_sax/unnamed-chunk-5-1.png)







### Configure the Method

The choices below turn the central modeling idea into concrete parameters. They matter because sAX motif discovery: SAX discretizes z-normalized subsequences into symbolic words; discords emerge as rare words or windows with large symbolic distance to their neighbors, so each argument controls how strongly the method will emphasize that pattern when it later produces discord candidates.


``` r
# Configure SAX-based discord discovery (alphabet=26, word=25)
model <- hdis_sax(26, 25)
```

```
## Warning: internal error 1 in R_decompress1 with libdeflate
```

```
## Error:
## ! lazy-load database 'C:/R/R-4.5.0/library/harbinger/R/harbinger.rdb' is corrupt
```




``` r
# Fit the detector (learns binning thresholds)
model <- fit(model, dataset$serie)
```

```
## Error:
## ! object 'model' not found
```







### Run the Core Analysis

This is the moment where the notebook tests its central assumption on actual data. After applying `09-discord-hdis_sax`, the important question is whether the resulting discord candidates really correspond to the pattern implied by the method description above, rather than to arbitrary numerical variation.


``` r
# Run discord discovery
detection <- detect(model, dataset$serie)
```

```
## Error:
## ! object 'model' not found
```




``` r
# Show detected discord starts
print(detection |> dplyr::filter(event == TRUE))
```

```
## Error:
## ! object 'detection' not found
```







### Evaluate What Was Found

The evaluation asks whether the discord candidates produced by `09-discord-hdis_sax` match the labeled structure on this dataset. Read the scores as evidence about the method's assumptions in practice, not as detached summary numbers.


``` r
# Evaluate detections against labels
evaluation <- evaluate(model, detection$event, dataset$event)
```

```
## Error:
## ! object 'model' not found
```

``` r
print(evaluation$confMatrix)
```

```
## Error:
## ! object 'evaluation' not found
```







### Interpret the Result Visually

This visual check puts the model output back on top of the original signal. What matters now is whether the highlighted discord candidates line up with the structure suggested by the method, which is the real semantic test of whether the example is teaching the right lesson.


``` r
# Plot discords and ground truth
har_plot(model, dataset$serie, detection, dataset$event)
```

```
## Error:
## ! object 'detection' not found
```

## References

- Lin, J., Keogh, E., Lonardi, S., Chiu, B. (2007). A symbolic representation of time series, with implications for streaming algorithms. Data Mining and Knowledge Discovery, 15, 107-144.
