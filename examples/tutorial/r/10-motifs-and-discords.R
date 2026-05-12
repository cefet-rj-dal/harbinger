source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/examples/seed.R"))
library(daltoolbox)
library(harbinger)

data(examples_motifs)
dataset <- examples_motifs$simple

har_plot(harbinger(), dataset$serie, event = dataset$event)

model <- hmo_sax(8, 15, 3)
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
head(detection)

har_plot(model, dataset$serie, detection, dataset$event)
