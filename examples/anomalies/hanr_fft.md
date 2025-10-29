FFT regression anomaly detector: This detector applies high-pass filtering via the discrete Fourier transform. The spectrum is computed with the FFT, a cutoff is selected from the power spectrum to suppress low-frequency components, and the inverse FFT reconstructs a high-pass signal. Residual magnitudes are then summarized and thresholded using `harutils()`.

The FFT-based detector applies a high-pass filter in the frequency domain and flags large deviations between the original and filtered signal. 

Steps:
- Load and visualize a sample anomaly dataset
- Configure and run the FFT detector (`hanr_fft`)
- Inspect detections, evaluate, and plot residuals with thresholds


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

![plot of chunk unnamed-chunk-5](fig/hanr_fft/unnamed-chunk-5-1.png)


``` r
# Configure the FFT-based detector
model <- hanr_fft()
```


``` r
# Fit the detector (no training required, tracks parameters)
model <- fit(model, dataset$serie)
```


``` r
# Run detection to compute residual magnitudes and flags
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
# Evaluate detections against labeled events
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

![plot of chunk unnamed-chunk-11](fig/hanr_fft/unnamed-chunk-11-1.png)


``` r
# Plot residual magnitude and decision thresholds
har_plot(model, attr(detection, "res"), detection, dataset$event, yline = attr(detection, "threshold"))
```

![plot of chunk unnamed-chunk-12](fig/hanr_fft/unnamed-chunk-12-1.png)


References 
- Sobrinho, E. P., Souza, J., Lima, J., Giusti, L., Bezerra, E., Coutinho, R., Baroni, L., Pacitti, E., Porto, F., Belloze, K., Ogasawara, E. Fine-Tuning Detection Criteria for Enhancing Anomaly Detection in Time Series. In: Simpósio Brasileiro de Banco de Dados (SBBD). SBC, 29 Sep. 2025. doi:10.5753/sbbd.2025.247063
