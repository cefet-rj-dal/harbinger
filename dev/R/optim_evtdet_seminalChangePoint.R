optim.evtdet.seminalChangePoint <- function(test,par_options=expand.grid(w=seq(0.01,0.1,0.02)*nrow(test)),...){
  eval <- data.frame()
  events_list <- NULL
  for(par in 1:nrow(par_options)){

    events <- tryCatch(evtdet.seminalChangePoint(test,
                                                 w=par_options[par,"w"],...),
                       error = function(e) NULL)

    eval_par <- tryCatch(evaluate(events, reference, metric="F1"),
                         error = function(e) NA)

    if(!is.null(events)) events_list[[par]] <- events
    else events_list[[par]] <- NA

    eval <- rbind(eval,cbind(par_options[par,],F1=eval_par))
  }

  events <- events_list[[which.max(eval$F1)]]
  par <- par_options[which.max(eval$F1),]
  rank <- eval

  return(list(par=par,events=events,rank=rank))
}
