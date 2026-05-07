---
title: "11 - Waypoint with Autoencoder and CUSUM"
output: md_document
---

This notebook shows the `hcp_waypoint()` detector using the `daltoolbox`
autoencoder abstraction and a real implementation from `daltoolboxdp` as the
concrete model.

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

If you want a deeper architecture, keep the same detector and only switch the
constructor, for example `autoenc_lstm_ed`, `autoenc_conv_ed`, or
`autoenc_variational_ed`, depending on what is available in your environment.
