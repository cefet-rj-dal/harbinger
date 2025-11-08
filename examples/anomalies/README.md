---
title: "Anomalies — Examples Index"
output: github_document
---

# Anomalies — Examples Index

This directory contains example R Markdown notebooks for anomaly detection in Harbinger. Each link opens an `.md` with a short, focused tutorial.

## Examples

- [han_autoenc_adv_ed.md](han_autoenc_adv_ed.md) — Adversarial Autoencoder (encode-decode): An adversarial autoencoder (AAE) augments a standard encoder-decoder with an adversarial objective on the latent code.
- [han_autoenc_conv_ed.md](han_autoenc_conv_ed.md) — Convolutional autoencoder (encode-decode): A convolutional autoencoder reconstructs windows via Conv1D layers; high reconstruction error indicates anomalies.
- [han_autoenc_denoise_ed.md](han_autoenc_denoise_ed.md) — Denoise Autoencoder (encode-decode): A denoising autoencoder reconstructs clean inputs from noisy windows, improving robustness.
- [han_autoenc_ed.md](han_autoenc_ed.md) — Autoencoder (encode-decode): An autoencoder reconstructs sliding windows; large reconstruction errors indicate anomalies.
- [han_autoenc_lstm_ed.md](han_autoenc_lstm_ed.md) — LSTM autoencoder (encode-decode): An LSTM autoencoder learns temporal dependencies by encoding and decoding sequences; large reconstruction error flags anomalies.
- [han_autoenc_stacked_ed.md](han_autoenc_stacked_ed.md) — Stacked autoencoder (encode-decode): A stacked autoencoder deepens encoder/decoder layers to capture richer nonlinear structure; large reconstruction error flags anomalies.
- [han_autoenc_variational_ed.md](han_autoenc_variational_ed.md) — variational autoencoder (VAE) (encode-decode): A variational autoencoder (VAE) learns a probabilistic latent space and reconstructs windows; high reconstruction error (and uncertainty) signals anomalies.
- [hanc_ml_dtree.md](hanc_ml_dtree.md) — Decision tree classification anomaly detector: Supervised anomaly detection using a classifier trained on labeled events; predictions above a probability threshold are flagged.
- [hanc_ml_knn.md](hanc_ml_knn.md) — k-NN classification anomaly detector: Supervised anomaly detection using k-NN classification on labeled data; positive-class probabilities above a threshold indicate events.
- [hanc_ml_majority.md](hanc_ml_majority.md) — Majority-class classification anomaly detector: Supervised anomaly detection using a majority-class baseline to illustrate the `hanc_ml` interface.
- [hanc_ml_mlp.md](hanc_ml_mlp.md) — MLP classification anomaly detector: Supervised anomaly detection with a neural network classifier (MLP) trained on labeled events; predicted probabilities above a threshold are flagged.
- [hanc_ml_nb.md](hanc_ml_nb.md) — Naive Bayes classification anomaly detector: Supervised anomaly detection using Naive Bayes classification on labeled sequences; positive-class probabilities above the threshold indicate events.
- [hanc_ml_rf.md](hanc_ml_rf.md) — Random Forest classification anomaly detection: Supervised anomaly detection with a Random Forest classifier trained on labeled events; predicted probabilities above a threshold are flagged.
- [hanc_ml_svm.md](hanc_ml_svm.md) — SVM classification anomaly detector: Supervised anomaly detection with an SVM classifier trained on labeled events; positive-class probabilities above a threshold correspond to detected events.
- [hanct_dtw_anomaly.md](hanct_dtw_anomaly.md) — DTW-based clustering anomaly detector: This approach applies Dynamic Time Warping (DTW) within a clustering framework.
- [hanct_dtw_discord.md](hanct_dtw_discord.md) — DTW-based discord anomaly detection: Dynamic Time Warping (DTW) clustering over subsequences; windows with large DTW distance to their nearest centroid are flagged as discords.
- [hanct_kmeans_anomaly.md](hanct_kmeans_anomaly.md) — k-means clustering anomaly detection: This approach applies k-means clustering to either points (`seq = 1`) or sliding-window subsequences (`seq > 1`).
- [hanct_kmeans_discord.md](hanct_kmeans_discord.md) — K-means clustering discord anomaly detection: K-means clustering over sliding-window subsequences; windows far from their nearest centroid are flagged as discords.
- [hanr_arima.md](hanr_arima.md) — ARIMA regression anomaly detection: This detector fits an ARIMA(p, d, q) model to the series and uses large standardized residuals as anomaly evidence.
- [hanr_emd.md](hanr_emd.md) — EMD regression anomaly detection: This detector uses Empirical Mode Decomposition (CEEMD) to extract intrinsic mode functions (IMFs) and isolates high-frequency components that capture abrupt deviations.
- [hanr_ensemble_fuzzy.md](hanr_ensemble_fuzzy.md) — Ensemble Fuzzy anomaly detection: Ensemble voting with temporal fuzzification merges detections within a tolerance window into a single event before voting, reducing duplicate triggers and aligning with ground-truth granularity.
- [hanr_ensemble.md](hanr_ensemble.md) — Ensemble anomaly detection: Majority-vote ensemble across multiple detectors, optionally with temporal fuzzification to combine nearby detections into a single event.
- [hanr_fbiad.md](hanr_fbiad.md) — FBIAD regression anomaly detection: Forward and Backward Inertial Anomaly Detector compares each point against forward and backward inertia, flagging observations that break both temporal tendencies.
- [hanr_fft_amoc_cusum.md](hanr_fft_amoc_cusum.md) — FFT AMOC CUSUM regression anomaly detection: This hybrid detector computes the FFT and transforms the power spectrum with CUSUM to emphasize gradual spectral shifts.
- [hanr_fft_amoc.md](hanr_fft_amoc.md) — FFT AMOC regression anomaly detection: FFT-based high-pass filtering with an automatic cutoff selected via AMOC on the power spectrum.
- [hanr_fft_binseg_cusum.md](hanr_fft_binseg_cusum.md) — FFT Binseg CUSUM regression anomaly detection: FFT-based filtering with a cutoff determined by applying CUSUM to the spectrum and locating a changepoint via Binary Segmentation.
- [hanr_fft_binseg.md](hanr_fft_binseg.md) — FFT Binseg regression anomaly detection: FFT-based high-pass filtering with a cutoff selected via Binary Segmentation on the power spectrum.
- [hanr_fft_sma.md](hanr_fft_sma.md) — FFT SMA regression anomaly detection: Adaptive FFT + moving average: estimates a dominant frequency from the spectrum to set the smoothing window, computes residuals (original minus smoothed), and flags large residuals as anomalies with `harutils()` thresholding.
- [hanr_fft.md](hanr_fft.md) — FFT regression anomaly detector: This detector applies high-pass filtering via the discrete Fourier transform.
- [hanr_garch.md](hanr_garch.md) — GARCH-based regression anomaly detection: This detector estimates a GARCH model to capture conditional heteroskedasticity and flags observations with large standardized residuals as anomalies.
- [hanr_ml_conv1d.md](hanr_ml_conv1d.md) — Conv1d regression anomaly detection: Model-deviation detection using ML regression: a Conv1D forecaster predicts the next value from a sliding window; large prediction errors are flagged as anomalies.
- [hanr_ml_elm.md](hanr_ml_elm.md) — ELM regression anomaly detection: Model-deviation detection using ML regression: an ELM forecaster predicts the next value from a sliding window; large prediction errors are flagged as anomalies.
- [hanr_ml_lstm.md](hanr_ml_lstm.md) — LSTM regression anomaly detection: Model-deviation detection using ML regression: an LSTM forecaster predicts the next value from a sliding window; large prediction errors are flagged as anomalies.
- [hanr_ml_mlp.md](hanr_ml_mlp.md) — MLP regression anomaly detection: Model-deviation detection using ML regression: an MLP forecaster predicts the next value from a sliding window; large prediction errors are flagged as anomalies.
- [hanr_ml_rf.md](hanr_ml_rf.md) — Random Forest regression anomaly detection: Model-deviation detection using ML regression: a Random Forest forecaster predicts the next value from a sliding window; large prediction errors are flagged as anomalies.
- [hanr_ml_svm.md](hanr_ml_svm.md) — SVM regression anomaly detection: Model-deviation detection using ML regression: an SVM forecaster predicts the next value from a sliding window; large prediction errors are flagged as anomalies.
- [hanr_remd.md](hanr_remd.md) — REMD regression anomaly detection: REMD combines Empirical Mode Decomposition with ARIMA modeling: IMFs capture nonstationary structure and ARIMA models residual dynamics.
- [hanr_rtad.md](hanr_rtad.md) — RTAD regression anomaly detector: RTAD adapts to local dynamics using EMD-derived components and robust dispersion within sliding windows.
- [hanr_wavelet.md](hanr_wavelet.md) — Wavelet regression anomaly detection: Multi-resolution analysis via MODWT wavelet decomposition; detail coefficients are aggregated to form a magnitude signal.
- [hmu_pca.md](hmu_pca.md) — PCA-based regression anomaly detection: Projects multivariate observations onto principal components and reconstructs data; large reconstruction errors indicate anomalies.

