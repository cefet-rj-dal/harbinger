library(daltoolbox)
library(harbinger)

data(examples_motifs)
dataset <- examples_motifs$simple
har_plot(harbinger(), dataset$serie, event = dataset$event)

# Configure a symbolic motif detector
model <- hmo_sax(8, 15, 3)
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
head(detection)

# Plot the motif-oriented result
har_plot(model, dataset$serie, detection, dataset$event)
