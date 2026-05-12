source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/examples/seed.R"))
# Install Harbinger (if needed)
#install.packages("harbinger")

# Load required packages
library(daltoolbox)
library(harbinger) 

# Load motif example datasets and create a base object
data(examples_motifs)
model <- harbinger()

# Simple synthetic motif dataset
dataset <- examples_motifs$simple
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# ECG sample: MIT-BIH record 100
dataset <- examples_motifs$mitdb100
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)


# ECG sample: MIT-BIH record 102
dataset <- examples_motifs$mitdb102
set_example_seed()
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)
har_plot(model, dataset$serie, detection, dataset$event)

