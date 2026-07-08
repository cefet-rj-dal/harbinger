library(daltoolbox)
library(harbinger)

serie <- c(1, 1, 1, 1, 5, 6, 7, 8, 20, 21, 22)

session_full <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  warmup_size = 3,
  batch_size = 2,
  memory = har_memory_full()
)
session_full <- fit(session_full)
session_full <- run_online(session_full)
print(collect_batch_log(session_full))

session_sliding <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  warmup_size = 3,
  batch_size = 2,
  memory = har_memory_sliding(2)
)
session_sliding <- fit(session_sliding)
session_sliding <- run_online(session_sliding)
print(collect_batch_log(session_sliding))

session_last <- har_online_session(
  source = har_source_simulated(serie),
  detector = hcp_page_hinkley(min_instances = 3, threshold = 1),
  warmup_size = 3,
  batch_size = 2,
  memory = har_memory_last_observations(5)
)
session_last <- fit(session_last)
session_last <- run_online(session_last)
print(collect_batch_log(session_last))
