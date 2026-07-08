library(harbinger)

sim_source <- har_source_simulated(c(10, 11, 12))
print(source_info(sim_source))
print(next_observation(sim_source))

df <- data.frame(ts = 1:3, value = c(5, 6, 7), other = c(50, 60, 70))
df_source <- har_source_dataframe(df, timestamp_col = "ts", value_cols = c("value", "other"))
print(source_info(df_source))
print(next_observation(df_source))

callback_values <- list(
  list(value = 100, timestamp = 1),
  list(value = 101, timestamp = 2),
  NULL
)
cursor <- 0
cb_source <- har_source_callback(function() {
  cursor <<- cursor + 1
  callback_values[[cursor]]
})
print(source_info(cb_source))
print(next_observation(cb_source))
print(next_observation(cb_source))
print(next_observation(cb_source))

kafka_source <- har_source_kafka(
  topic = "sensor-events",
  bootstrap_servers = c("broker1:9092"),
  group_id = "harbinger-consumer"
)
print(source_info(kafka_source))
try(next_observation(kafka_source))
