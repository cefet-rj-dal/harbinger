library(harbinger)

source_obj <- har_source_kafka(
  topic = "sensor-events",
  bootstrap_servers = c("broker1:9092", "broker2:9092"),
  group_id = "harbinger-consumer"
)

print(source_info(source_obj))

try(next_observation(source_obj))
