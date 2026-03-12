# installation
# install.packages(c("harbinger", "daltoolbox", "segmented"))

library(daltoolbox)
library(harbinger)

hcp_joinpoint_custom <- function(npsi = 1) {
  obj <- harbinger()
  obj$npsi <- npsi
  class(obj) <- append("hcp_joinpoint_custom", class(obj))
  obj
}

fit.hcp_joinpoint_custom <- function(obj, data, ...) {
  x <- seq_along(data)
  base_model <- stats::lm(data ~ x)
  obj$model <- segmented::segmented(base_model, seg.Z = ~ x, npsi = obj$npsi)
  obj
}

detect.hcp_joinpoint_custom <- function(obj, serie, ...) {
  obj <- obj$har_store_refs(obj, serie)

  if (is.null(obj$model)) {
    obj <- fit(obj, obj$serie)
  }

  cp <- rep(FALSE, length(obj$serie))
  psi <- round(obj$model$psi[, "Est."])
  psi <- psi[psi >= 1 & psi <= length(cp)]
  cp[psi] <- TRUE

  obj$har_restore_refs(obj, change_points = cp)
}

data(examples_changepoints)
dataset <- examples_changepoints$simple

model <- hcp_joinpoint_custom(npsi = 1)
model <- fit(model, dataset$serie)
detection <- detect(model, dataset$serie)

evaluation <- evaluate(model, detection$event, dataset$event)
evaluation$confMatrix

har_plot(model, dataset$serie, detection, dataset$event)
