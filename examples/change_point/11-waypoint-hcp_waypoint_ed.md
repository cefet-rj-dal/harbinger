---
title: "11 - Waypoint with Feed-Forward Autoencoder"
output: md_document
---

This notebook shows the `hcp_waypoint()` detector with a plain feed-forward
autoencoder.

The package itself does not depend on `daltoolboxdp`. The example only uses it
at the notebook level.

```r
library(daltoolbox)
library(daltoolboxdp)
library(harbinger)
```

```r
data(examples_changepoints)
dataset <- examples_changepoints$simple
```

```r
model <- hcp_waypoint(
  input_size = 12,
  encode_size = 4,
  warmup = 60,
  retrain_size = 30,
  buffer_size = 40,
  k_factor = 0.35,
  h_low = 3.5,
  h_high = 6,
  prob_tau = 0.997,
  epochs_init = 100,
  epochs_retrain = 100,
  encoderclass = autoenc_ed
)

model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)

print(detection[detection$event, ])
```

```r
har_plot(model, dataset$serie, detection, dataset$event)
```

This is the baseline notebook. It is the best place to understand the method
without extra inductive bias from the encoder architecture.
