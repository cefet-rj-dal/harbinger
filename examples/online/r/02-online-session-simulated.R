library(daltoolbox)
library(harbinger)

source(url("https://raw.githubusercontent.com/cefet-rj-dal/harbinger/master/examples/seed.R"))

serie <- c(1, 1, 1, 1, 5, 6, 7, 8, 20, 21, 22)
reference <- c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE)
source_obj <- har_source_simulated(serie)

session <- har_online_session(
  source = source_obj,
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  executor = har_online_refit_full(),
  warmup_size = 3,
  batch_size = 2,
  memory = har_memory_full()
)

session <- fit(session)
session <- run_online(session)

detection <- collect_detection(session)
print(detection)

trace <- collect_trace(session)
print(trace)

batch_log <- collect_batch_log(session)
print(batch_log)

stream_metrics <- evaluate(har_stream_eval(), trace, reference = reference)
print(stream_metrics$summary)
print(stream_metrics$hard_metrics$confMatrix)
