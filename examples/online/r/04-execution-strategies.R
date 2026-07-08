library(daltoolbox)
library(harbinger)

serie <- c(1, 1, 1, 1, 5, 6, 7, 8, 20, 21, 22)

session_refit <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  executor = har_online_refit_full(),
  warmup_size = 3,
  batch_size = 2
)
session_refit <- fit(session_refit)
session_refit <- run_online(session_refit)
print(collect_detection(session_refit))

session_detect_only <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  executor = har_online_detect_only(fit_on_warmup = TRUE),
  warmup_size = 3,
  batch_size = 2
)
session_detect_only <- fit(session_detect_only)
session_detect_only <- run_online(session_detect_only)
print(collect_detection(session_detect_only))

session_incremental <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  executor = har_online_incremental(),
  warmup_size = 3,
  batch_size = 2
)
session_incremental <- fit(session_incremental)
session_incremental <- run_online(session_incremental)
print(collect_detection(session_incremental))
