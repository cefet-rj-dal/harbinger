---
title: "Online Source Family"
output: rmarkdown::html_document
---



## Objective

This notebook validates the online source family independently of the rest of
the streaming workflow.

## Simulated Source


``` r
sim_source <- har_source_simulated(c(10, 11, 12))
print(source_info(sim_source))
```

```
## $name
## [1] "simulated"
## 
## $type
## [1] "simulated"
## 
## $n
## [1] 3
## 
## $cursor
## [1] 0
```

``` r
print(next_observation(sim_source))
```

```
## $source
## $name
## [1] "simulated"
## 
## $data
## [1] 10 11 12
## 
## $cursor
## [1] 1
## 
## $n
## [1] 3
## 
## attr(,"class")
## [1] "har_source_simulated" "har_source"           "dal_base"            
## 
## $observation
## $observation$idx
## [1] 1
## 
## $observation$value
## [1] 10
## 
## $observation$timestamp
## [1] NA
## 
## $observation$payload
## [1] 10
## 
## 
## $available
## [1] TRUE
```

## Data-frame Source


``` r
df <- data.frame(ts = 1:3, value = c(5, 6, 7), other = c(50, 60, 70))
df_source <- har_source_dataframe(df, timestamp_col = "ts", value_cols = c("value", "other"))
print(source_info(df_source))
```

```
## $name
## [1] "dataframe"
## 
## $type
## [1] "dataframe"
## 
## $n
## [1] 3
## 
## $cursor
## [1] 0
## 
## $timestamp_col
## [1] "ts"
## 
## $value_cols
## [1] "value" "other"
```

``` r
print(next_observation(df_source))
```

```
## $source
## $name
## [1] "dataframe"
## 
## $data
##   value other
## 1     5    50
## 2     6    60
## 3     7    70
## 
## $timestamp
## [1] 1 2 3
## 
## $cursor
## [1] 1
## 
## $n
## [1] 3
## 
## $timestamp_col
## [1] "ts"
## 
## $value_cols
## [1] "value" "other"
## 
## attr(,"class")
## [1] "har_source_dataframe" "har_source_simulated" "har_source"          
## [4] "dal_base"            
## 
## $observation
## $observation$idx
## [1] 1
## 
## $observation$value
##   value other
## 1     5    50
## 
## $observation$timestamp
## [1] 1
## 
## $observation$payload
##   value other
## 1     5    50
## 
## 
## $available
## [1] TRUE
```

## Callback Source


``` r
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
```

```
## $name
## [1] "callback"
## 
## $type
## [1] "callback"
## 
## $cursor
## [1] 0
```

``` r
print(next_observation(cb_source))
```

```
## $source
## $name
## [1] "callback"
## 
## $poll_fn
## function () 
## {
##     cursor <<- cursor + 1
##     callback_values[[cursor]]
## }
## <environment: 0x0000013406640af8>
## 
## $cursor
## [1] 1
## 
## attr(,"class")
## [1] "har_source_callback" "har_source"          "dal_base"           
## 
## $observation
## $observation$value
## [1] 100
## 
## $observation$timestamp
## [1] 1
## 
## $observation$idx
## [1] 1
## 
## $observation$payload
## [1] 100
## 
## 
## $available
## [1] TRUE
```

``` r
print(next_observation(cb_source))
```

```
## $source
## $name
## [1] "callback"
## 
## $poll_fn
## function () 
## {
##     cursor <<- cursor + 1
##     callback_values[[cursor]]
## }
## <environment: 0x0000013406640af8>
## 
## $cursor
## [1] 1
## 
## attr(,"class")
## [1] "har_source_callback" "har_source"          "dal_base"           
## 
## $observation
## $observation$value
## [1] 101
## 
## $observation$timestamp
## [1] 2
## 
## $observation$idx
## [1] 1
## 
## $observation$payload
## [1] 101
## 
## 
## $available
## [1] TRUE
```

``` r
print(next_observation(cb_source))
```

```
## $source
## $name
## [1] "callback"
## 
## $poll_fn
## function () 
## {
##     cursor <<- cursor + 1
##     callback_values[[cursor]]
## }
## <environment: 0x0000013406640af8>
## 
## $cursor
## [1] 0
## 
## attr(,"class")
## [1] "har_source_callback" "har_source"          "dal_base"           
## 
## $observation
## NULL
## 
## $available
## [1] FALSE
```

## Kafka Stub


``` r
kafka_source <- har_source_kafka(
  topic = "sensor-events",
  bootstrap_servers = c("broker1:9092"),
  group_id = "harbinger-consumer"
)
print(source_info(kafka_source))
```

```
## $name
## [1] "kafka"
## 
## $type
## [1] "kafka_stub"
## 
## $topic
## [1] "sensor-events"
## 
## $bootstrap_servers
## [1] "broker1:9092"
## 
## $group_id
## [1] "harbinger-consumer"
## 
## $initialized
## [1] FALSE
```

``` r
try(next_observation(kafka_source))
```

```
## Error : Kafka source is configured only as a stub. Attach a Python collector via reticulate.
```

