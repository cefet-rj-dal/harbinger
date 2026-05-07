This notebook shows the `hcp_waypoint()` detector with a convolutional
autoencoder.

The package itself does not depend on `daltoolboxdp`. The example only
uses it at the notebook level.

    library(daltoolbox)
    library(daltoolboxdp)
    library(harbinger)

    data(examples_changepoints)
    dataset <- examples_changepoints$simple

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
      encoderclass = autoenc_conv_ed
    )

    model <- fit(model, dataset$serie)
    detection <- detect(model, dataset$serie)

    print(detection[detection$event, ])

    har_plot(model, dataset$serie, detection, dataset$event)

This version emphasizes local patterns inside the window. It is a useful
third example because it often sits between the simplicity of a dense
autoencoder and the stronger temporal bias of an LSTM.
