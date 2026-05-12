# Anomaly Detection Examples

This folder organizes anomaly detection as a progression of modeling ideas. The intention is to help the reader study the families in a useful order: start with simple baselines, then move to residual models, supervised approaches, subsequence similarity methods, score combination, and deep reconstruction models.

If you are learning the area, do not treat this as a flat catalog. The groups below were ordered to make comparisons easier and to help the reader ask better questions at each stage: what counts as unusual, how temporal structure changes the answer, when labels are available, and when stronger models are worth the added complexity.

## Foundations

Start here if you want a first intuition for anomaly detection before dealing with forecasting errors, windows, embeddings, or neural architectures.

- [01-baseline-hanr_histogram.md](/examples/anomalies/01-baseline-hanr_histogram.md) - `hanr_histogram()`: simple baseline based on low-density histogram bins.

## Residual and Signal Models

These notebooks are the natural next step because they explain anomalies through the mismatch between the observed series and a model of expected behavior.

- [10-regression-hanr_arima.md](/examples/anomalies/10-regression-hanr_arima.md) - `hanr_arima()`: anomaly detection from ARIMA residuals.
- [11-regression-hanr_fbiad.md](/examples/anomalies/11-regression-hanr_fbiad.md) - `hanr_fbiad()`: forecasting-based anomaly detection.
- [12-regression-hanr_emd.md](/examples/anomalies/12-regression-hanr_emd.md) - `hanr_emd()`: decomposition-based anomaly detection.
- [13-regression-hanr_fft.md](/examples/anomalies/13-regression-hanr_fft.md) - `hanr_fft()`: spectral modeling for anomaly detection.
- [14-regression-hanr_fft_amoc.md](/examples/anomalies/14-regression-hanr_fft_amoc.md) - `hanr_fft_amoc()`: FFT residual analysis combined with AMOC.
- [15-regression-hanr_fft_amoc_cusum.md](/examples/anomalies/15-regression-hanr_fft_amoc_cusum.md) - `hanr_fft_amoc_cusum()`: FFT, AMOC, and CUSUM in sequence.
- [16-regression-hanr_fft_binseg.md](/examples/anomalies/16-regression-hanr_fft_binseg.md) - `hanr_fft_binseg()`: FFT residual analysis with binary segmentation.
- [17-regression-hanr_fft_binseg_cusum.md](/examples/anomalies/17-regression-hanr_fft_binseg_cusum.md) - `hanr_fft_binseg_cusum()`: FFT, binary segmentation, and CUSUM.
- [18-regression-hanr_fft_sma.md](/examples/anomalies/18-regression-hanr_fft_sma.md) - `hanr_fft_sma()`: FFT residual analysis with smoothing.
- [20-regression-hanr_garch.md](/examples/anomalies/20-regression-hanr_garch.md) - `hanr_garch()`: volatility-aware anomaly detection.
- [21-regression-hanr_remd.md](/examples/anomalies/21-regression-hanr_remd.md) - `hanr_remd()`: robust empirical mode decomposition workflow.
- [22-regression-hanr_rtad.md](/examples/anomalies/22-regression-hanr_rtad.md) - `hanr_rtad()`: residual time-series anomaly detection.
- [23-regression-hanr_wavelet.md](/examples/anomalies/23-regression-hanr_wavelet.md) - `hanr_wavelet()`: wavelet-based anomaly detection.

## Supervised Detectors

Read this group when the dataset includes labels and the goal is no longer only to model normal behavior, but to learn directly from examples of anomalous and non-anomalous cases.

- [30-regression-ml-hanr_ml_elm.md](/examples/anomalies/30-regression-ml-hanr_ml_elm.md) - regression-based anomaly detection with ELM.
- [31-regression-ml-hanr_ml_mlp.md](/examples/anomalies/31-regression-ml-hanr_ml_mlp.md) - regression-based anomaly detection with MLP.
- [32-regression-ml-hanr_ml_rf.md](/examples/anomalies/32-regression-ml-hanr_ml_rf.md) - regression-based anomaly detection with Random Forest.
- [33-regression-ml-hanr_ml_svm.md](/examples/anomalies/33-regression-ml-hanr_ml_svm.md) - regression-based anomaly detection with SVM.
- [34-regression-ml-hanr_ml_lstm.md](/examples/anomalies/34-regression-ml-hanr_ml_lstm.md) - regression-based anomaly detection with LSTM.
- [35-regression-ml-hanr_ml_conv1d.md](/examples/anomalies/35-regression-ml-hanr_ml_conv1d.md) - regression-based anomaly detection with Conv1D.

## Supervised Classifiers

Read this group when anomaly detection is framed directly as labeled classification instead of residual scoring.

- [40-classification-hanc_ml_majority.md](/examples/anomalies/40-classification-hanc_ml_majority.md) - classification baseline with majority class.
- [41-classification-hanc_ml_dtree.md](/examples/anomalies/41-classification-hanc_ml_dtree.md) - classification detector with decision trees.
- [42-classification-hanc_ml_knn.md](/examples/anomalies/42-classification-hanc_ml_knn.md) - classification detector with k-NN.
- [43-classification-hanc_ml_nb.md](/examples/anomalies/43-classification-hanc_ml_nb.md) - classification detector with Naive Bayes.
- [44-classification-hanc_ml_rf.md](/examples/anomalies/44-classification-hanc_ml_rf.md) - classification detector with Random Forest.
- [45-classification-hanc_ml_svm.md](/examples/anomalies/45-classification-hanc_ml_svm.md) - classification detector with SVM.
- [46-classification-hanc_ml_mlp.md](/examples/anomalies/46-classification-hanc_ml_mlp.md) - classification detector with MLP.

## Clustering-Based Anomalies

These methods are useful when similarity between subsequences matters more than a fitted predictive model and the goal is still anomaly scoring rather than explicit discord search.

- [50-clustering-hanct_kmeans_anomaly.md](/examples/anomalies/50-clustering-hanct_kmeans_anomaly.md) - clustering-based anomaly detection with k-means.
- [51-clustering-hanct_dtw_anomaly.md](/examples/anomalies/51-clustering-hanct_dtw_anomaly.md) - anomaly detection with DTW clustering.

## Discord Discovery

These notebooks focus on finding the most unusual subsequences under a similarity notion, which is a different task from generic anomaly scoring.

- [60-discord-hanct_kmeans_discord.md](/examples/anomalies/60-discord-hanct_kmeans_discord.md) - discord-oriented k-means workflow.
- [61-discord-hanct_dtw_discord.md](/examples/anomalies/61-discord-hanct_dtw_discord.md) - discord discovery with DTW clustering.

## Ensembles

Leave this group for later. It is easier to understand score-combination notebooks after the reader already knows the simpler families they combine.

- [70-ensemble-hanr_ensemble.md](/examples/anomalies/70-ensemble-hanr_ensemble.md) - ensemble detector that combines multiple anomaly scores.
- [71-ensemble-hanr_ensemble_fuzzy.md](/examples/anomalies/71-ensemble-hanr_ensemble_fuzzy.md) - ensemble detector with temporal fuzzification.

## Autoencoders

This group focuses on reconstruction-based anomaly detection with neural architectures. Keep it separate from ensembles because the modeling idea is entirely different.

- [80-autoencoder-han_autoenc_ed.md](/examples/anomalies/80-autoencoder-han_autoenc_ed.md) - basic autoencoder for reconstruction-based anomaly detection.
- [81-autoencoder-han_autoenc_denoise_ed.md](/examples/anomalies/81-autoencoder-han_autoenc_denoise_ed.md) - denoising autoencoder.
- [82-autoencoder-han_autoenc_conv_ed.md](/examples/anomalies/82-autoencoder-han_autoenc_conv_ed.md) - convolutional autoencoder.
- [83-autoencoder-han_autoenc_lstm_ed.md](/examples/anomalies/83-autoencoder-han_autoenc_lstm_ed.md) - LSTM autoencoder.
- [84-autoencoder-han_autoenc_stacked_ed.md](/examples/anomalies/84-autoencoder-han_autoenc_stacked_ed.md) - stacked autoencoder.
- [85-autoencoder-han_autoenc_variational_ed.md](/examples/anomalies/85-autoencoder-han_autoenc_variational_ed.md) - variational autoencoder.
- [86-autoencoder-han_autoenc_adv_ed.md](/examples/anomalies/86-autoencoder-han_autoenc_adv_ed.md) - adversarial autoencoder.

## Multivariate Analysis

Finish here if your goal is to move from single-signal intuition to the joint behavior of several variables.

- [90-multivariate-hmu_pca.md](/examples/anomalies/90-multivariate-hmu_pca.md) - PCA-based anomaly detection for multivariate time series.


