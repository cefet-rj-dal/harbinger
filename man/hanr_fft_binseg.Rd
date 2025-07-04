% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hanr_fft_binseg.R
\name{hanr_fft_binseg}
\alias{hanr_fft_binseg}
\title{Anomaly Detector using FFT with Binary Segmentation Cutoff}
\usage{
hanr_fft_binseg()
}
\value{
\code{hanr_fft_binseg} object
}
\description{
This function implements an anomaly detection method that combines the Fast Fourier daltoolbox::transform (FFT)
with a spectral cutoff strategy based on the Binary Segmentation (BinSeg) algorithm for changepoint detection.

The method analyzes the power spectrum of the input time series and applies the BinSeg algorithm
to identify a changepoint in the spectral density, corresponding to a shift in the frequency content.
Frequencies below this changepoint are considered part of the underlying trend or noise and are removed
from the signal.

The modified spectrum is then transformed back into the time domain via inverse FFT, resulting in
a high-pass filtered version of the series. Anomalies are identified by measuring the distance between
the original and the filtered signal, highlighting unusual deviations from the dominant signal behavior.

This function is part of the HARBINGER framework and returns an object of class \code{hanr_fft_binseg}.
}
\examples{
library(daltoolbox)

#loading the example database
data(examples_anomalies)

#Using simple example
dataset <- examples_anomalies$simple
head(dataset)

# setting up time series fft detector
model <- hanr_fft_binseg()

# fitting the model
model <- fit(model, dataset$serie)

detection <- detect(model, dataset$serie)

# filtering detected events
print(detection[(detection$event),])

}
