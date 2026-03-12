---
title: "Anomalies — Examples Index"
output: github_document
---

# Anomalies — Examples Index

This folder concentrates the anomaly-detection tutorials that will be published under `/examples/anomalies/`. The collection now follows a learning path: first the reader sees simple or interpretable baselines, then residual-model detectors, then supervised and clustering approaches, and only afterwards the ensemble, autoencoder, and multivariate notebooks.

If the reader is new to Harbinger, follow the groups in order. That progression helps separate the conceptual goal of each family before comparing their plots and thresholds.

## 1. Baseline intuition

- [01-baseline-hanr_histogram.md](/examples/anomalies/01-baseline-hanr_histogram.md) — Histogram-based anomaly detection: A didactic baseline that flags observations falling into rare histogram bins or outside the observed density range.

## 2. Residual and signal-model detectors

- [02-regression-hanr_arima.md](/examples/anomalies/02-regression-hanr_arima.md) — ARIMA regression anomaly detection.
- [03-regression-hanr_fbiad.md](/examples/anomalies/03-regression-hanr_fbiad.md) — FBIAD regression anomaly detection.
- [04-regression-hanr_emd.md](/examples/anomalies/04-regression-hanr_emd.md) — EMD regression anomaly detection.
- [05-regression-hanr_fft.md](/examples/anomalies/05-regression-hanr_fft.md) — FFT regression anomaly detector.
- [06-regression-hanr_fft_amoc.md](/examples/anomalies/06-regression-hanr_fft_amoc.md) — FFT AMOC regression anomaly detection.
- [07-regression-hanr_fft_amoc_cusum.md](/examples/anomalies/07-regression-hanr_fft_amoc_cusum.md) — FFT AMOC CUSUM regression anomaly detection.
- [08-regression-hanr_fft_binseg.md](/examples/anomalies/08-regression-hanr_fft_binseg.md) — FFT Binseg regression anomaly detection.
- [09-regression-hanr_fft_binseg_cusum.md](/examples/anomalies/09-regression-hanr_fft_binseg_cusum.md) — FFT Binseg CUSUM regression anomaly detection.
- [10-regression-hanr_fft_sma.md](/examples/anomalies/10-regression-hanr_fft_sma.md) — FFT SMA regression anomaly detection.
- [11-regression-hanr_garch.md](/examples/anomalies/11-regression-hanr_garch.md) — GARCH-based regression anomaly detection.
- [12-regression-hanr_remd.md](/examples/anomalies/12-regression-hanr_remd.md) — REMD regression anomaly detection.
- [13-regression-hanr_rtad.md](/examples/anomalies/13-regression-hanr_rtad.md) — RTAD regression anomaly detector.
- [14-regression-hanr_wavelet.md](/examples/anomalies/14-regression-hanr_wavelet.md) — Wavelet regression anomaly detection.

## 3. Supervised regression models

- [15-regression-ml-hanr_ml_elm.md](/examples/anomalies/15-regression-ml-hanr_ml_elm.md) — ELM regression anomaly detection.
- [16-regression-ml-hanr_ml_mlp.md](/examples/anomalies/16-regression-ml-hanr_ml_mlp.md) — MLP regression anomaly detection.
- [17-regression-ml-hanr_ml_rf.md](/examples/anomalies/17-regression-ml-hanr_ml_rf.md) — Random Forest regression anomaly detection.
- [18-regression-ml-hanr_ml_svm.md](/examples/anomalies/18-regression-ml-hanr_ml_svm.md) — SVM regression anomaly detection.
- [19-regression-ml-hanr_ml_lstm.md](/examples/anomalies/19-regression-ml-hanr_ml_lstm.md) — LSTM regression anomaly detection.
- [20-regression-ml-hanr_ml_conv1d.md](/examples/anomalies/20-regression-ml-hanr_ml_conv1d.md) — Conv1D regression anomaly detection.

## 4. Supervised classification detectors

- [21-classification-hanc_ml_majority.md](/examples/anomalies/21-classification-hanc_ml_majority.md) — Majority-class classification anomaly detector.
- [22-classification-hanc_ml_dtree.md](/examples/anomalies/22-classification-hanc_ml_dtree.md) — Decision tree classification anomaly detector.
- [23-classification-hanc_ml_knn.md](/examples/anomalies/23-classification-hanc_ml_knn.md) — k-NN classification anomaly detector.
- [24-classification-hanc_ml_nb.md](/examples/anomalies/24-classification-hanc_ml_nb.md) — Naive Bayes classification anomaly detector.
- [25-classification-hanc_ml_rf.md](/examples/anomalies/25-classification-hanc_ml_rf.md) — Random Forest classification anomaly detector.
- [26-classification-hanc_ml_svm.md](/examples/anomalies/26-classification-hanc_ml_svm.md) — SVM classification anomaly detector.
- [27-classification-hanc_ml_mlp.md](/examples/anomalies/27-classification-hanc_ml_mlp.md) — MLP classification anomaly detector.

## 5. Clustering and discord-oriented detectors

- [28-clustering-hanct_kmeans_anomaly.md](/examples/anomalies/28-clustering-hanct_kmeans_anomaly.md) — k-means clustering anomaly detection.
- [29-clustering-hanct_kmeans_discord.md](/examples/anomalies/29-clustering-hanct_kmeans_discord.md) — k-means clustering discord anomaly detection.
- [30-clustering-hanct_dtw_anomaly.md](/examples/anomalies/30-clustering-hanct_dtw_anomaly.md) — DTW-based clustering anomaly detector.
- [31-clustering-hanct_dtw_discord.md](/examples/anomalies/31-clustering-hanct_dtw_discord.md) — DTW-based discord anomaly detection.

## 6. Ensemble strategies

- [32-ensemble-hanr_ensemble.md](/examples/anomalies/32-ensemble-hanr_ensemble.md) — Ensemble anomaly detection.
- [33-ensemble-hanr_ensemble_fuzzy.md](/examples/anomalies/33-ensemble-hanr_ensemble_fuzzy.md) — Ensemble anomaly detection with temporal fuzzification.

## 7. Autoencoders

- [34-autoencoder-han_autoenc_ed.md](/examples/anomalies/34-autoencoder-han_autoenc_ed.md) — Autoencoder (encode-decode).
- [35-autoencoder-han_autoenc_denoise_ed.md](/examples/anomalies/35-autoencoder-han_autoenc_denoise_ed.md) — Denoising autoencoder.
- [36-autoencoder-han_autoenc_conv_ed.md](/examples/anomalies/36-autoencoder-han_autoenc_conv_ed.md) — Convolutional autoencoder.
- [37-autoencoder-han_autoenc_lstm_ed.md](/examples/anomalies/37-autoencoder-han_autoenc_lstm_ed.md) — LSTM autoencoder.
- [38-autoencoder-han_autoenc_stacked_ed.md](/examples/anomalies/38-autoencoder-han_autoenc_stacked_ed.md) — Stacked autoencoder.
- [39-autoencoder-han_autoenc_variational_ed.md](/examples/anomalies/39-autoencoder-han_autoenc_variational_ed.md) — Variational autoencoder (VAE).
- [40-autoencoder-han_autoenc_adv_ed.md](/examples/anomalies/40-autoencoder-han_autoenc_adv_ed.md) — Adversarial autoencoder (AAE).

## 8. Multivariate analysis

- [41-multivariate-hmu_pca.md](/examples/anomalies/41-multivariate-hmu_pca.md) — PCA-based regression anomaly detection for multivariate series.
