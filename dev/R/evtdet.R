#==== evtdet: Function for event detection ====
# input:
#   data: data.frame with one or more variables (time series) where the first variable refers to time.
#   func: function for event detection having 'data' as input and a data.frame with three variables:
#         time (events time/indexes), serie (corresponding time serie) and type (event type) as output.
#   ...: list of parameters for 'func'
# output:
#   data.frame with three variables: time (events time/indexes), serie (corresponding time serie), type (event type).

evtdet <- function(data,func,...){
  if(is.null(data)) stop("No data was provided for computation",call. = FALSE)

  events <- do.call(func,c(list(data),list(...)))

  return(events)
}
