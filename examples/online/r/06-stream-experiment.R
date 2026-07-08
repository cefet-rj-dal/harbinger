library(daltoolbox)
library(harbinger)

source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/examples/seed.R"))

serie <- c(1, 1, 1, 1, 5, 6, 7, 8, 20, 21, 22)
reference <- c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE)

factory <- function() har_source_simulated(serie)

experiment <- har_stream_experiment(
  detectors = list(page = hcp_page_hinkley(min_instances = 3, threshold = 1)),
  source_factory = factory,
  warmup_grid = c(3, 5),
  batch_grid = c(1, 2),
  memory_grid = list(har_memory_full(), har_memory_sliding(2)),
  reference = reference
)

print(experiment$summary)
