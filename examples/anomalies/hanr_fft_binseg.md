FFT Binseg regression anomaly detection: FFT-based high-pass filtering with a cutoff selected via Binary Segmentation on the power spectrum. Frequencies below the detected spectral changepoint are suppressed; anomalies are flagged from the residual magnitude and thresholded using `harutils()`.

This variant combines FFT high-pass filtering with a spectral cutoff chosen by Binary Segmentation (BinSeg) on the power spectrum. 

We will:
- Load and visualize a simple anomaly dataset
- Configure and run `hanr_fft_binseg`
- Inspect detections, evaluate, and plot residual magnitudes and thresholds


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
# Load example anomaly datasets
data(examples_anomalies)
```


``` r
# Select a simple anomaly dataset
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


``` r
# Plot the raw time series
har_plot(harbinger(), dataset$serie)
```

![plot of chunk unnamed-chunk-5](fig/hanr_fft_binseg/unnamed-chunk-5-1.png)


``` r
# Configure the FFT+BinSeg detector
model <- hanr_fft_binseg()
```


``` r
# Fit the detector
model <- fit(model, dataset$serie)
```


``` r
# Run detection
detection <- detect(model, dataset$serie)
```


``` r
# Show detected anomaly indices
print(detection |> dplyr::filter(event == TRUE))
```

```
##   idx event    type
## 1  50  TRUE anomaly
```


``` r
# Evaluate detections against labels
evaluation <- evaluate(model, detection$event, dataset$event)
print(evaluation$confMatrix)
```

```
##           event      
## detection TRUE  FALSE
## TRUE      1     0    
## FALSE     0     100
```


``` r
# Plot detections vs. ground truth
har_plot(model, dataset$serie, detection, dataset$event)
```

![plot of chunk unnamed-chunk-11](fig/hanr_fft_binseg/unnamed-chunk-11-1.png)


``` r
# Plot residual magnitude and decision thresholds
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-12](fig/hanr_fft_binseg/unnamed-chunk-12-1.png)

References 
- Sobrinho, E. P., et al. Fine-Tuning Detection Criteria for Enhancing Anomaly Detection in Time Series. SBBD, 2025. doi:10.5753/sbbd.2025.247063
