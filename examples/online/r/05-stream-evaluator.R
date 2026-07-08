library(daltoolbox)
library(harbinger)

serie <- c(1, 1, 1, 1, 5, 6, 7, 8, 20, 21, 22)
reference <- c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE)

session <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  warmup_size = 3,
  batch_size = 2
)
session <- fit(session)
session <- run_online(session)
trace <- collect_trace(session)

stream_eval <- evaluate(har_stream_eval(), trace, reference = reference)
print(stream_eval$summary)
print(stream_eval$hard_metrics$confMatrix)

stream_eval_threshold <- evaluate(
  har_stream_eval(),
  trace,
  reference = reference,
  probability_threshold = 0.8
)
print(stream_eval_threshold$summary)
print(stream_eval_threshold$threshold_hard_metrics$confMatrix)
