library(daltoolbox)
library(harbinger)

data(examples_motifs)
dataset <- examples_motifs$simple
har_plot(harbinger(), dataset$serie, event = dataset$event)

# SAX uses a compact symbolic alphabet
sax_model <- trans_sax(alpha = 8)
sax_model <- fit(sax_model, dataset$serie)
sax_series <- transform(sax_model, dataset$serie)
head(sax_series, 20)

# XSAX uses a larger alphabet for finer symbolic resolution
xsax_model <- trans_xsax(alpha = 16)
xsax_model <- fit(xsax_model, dataset$serie)
xsax_series <- transform(xsax_model, dataset$serie)
head(xsax_series, 20)

# Compare the symbolic encodings side by side
head(
  data.frame(
    value = dataset$serie,
    sax = sax_series,
    xsax = xsax_series
  ),
  20
)
