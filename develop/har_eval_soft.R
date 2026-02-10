#' @title Evaluation of event detection (SoftED)
#' @description Soft evaluation of event detection using SoftED <doi:10.48550/arXiv.2304.00439>.
#' @param sw_size Integer. Tolerance window size for soft matching.
#' @return `har_eval_soft` object
#'
#' @examples
#' library(daltoolbox)
#'
#' # Load anomaly example data
#' data(examples_anomalies)
#'
#' # Use the simple series
#' dataset <- examples_anomalies$simple
#' head(dataset)
#'
#' # Configure a change-point detector (GARCH)
#' model <- hcp_garch()
#'
#' # Fit the detector
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected events
#' print(detection[(detection$event),])
#'
#' # Evaluate detections (SoftED)
#' evaluation <- evaluate(har_eval_soft(), detection$event, dataset$event)
#' print(evaluation$confMatrix)
#'
#' # Plot the results
#' grf <- har_plot(model, dataset$serie, detection, dataset$event)
#' plot(grf)
#'
#' @references
#' - Salles, R., Lima, J., Reis, M., Coutinho, R., Pacitti, E., Masseglia, F., Akbarinia, R.,
#'   Chen, C., Garibaldi, J., Porto, F., Ogasawara, E. SoftED: Metrics for soft evaluation of
#'   time series event detection. Computers and Industrial Engineering, 2024.
#'   doi:10.1016/j.cie.2024.110728
#'@export
har_eval_soft <- function(sw_size = 15) {
  obj <- har_eval()
  obj$sw_size <- sw_size
  class(obj) <- append("har_eval_soft", class(obj))
  return(obj)
}


#'@importFrom daltoolbox evaluate
#'@importFrom RcppHungarian HungarianSolver
#'@exportS3Method evaluate har_eval_soft
evaluate.har_eval_soft <- function(obj, detection, event, ...) {
  soft_scores <- function(detection, event, k){
    detection_score <- function(d, e, k) {
      pmax(pmin((d - (e - k)) / k, ((e + k) - d) / k), 0)
    }

    complex_cases_association <- function(D_mini, E_mini, k) {
      n <- length(D_mini)
      m <- length(E_mini)

      Mu <- matrix(NA, nrow = n, ncol = m)
      for (j in 1:m) {
        for (i in 1:n) {
          Mu[i, j] <- detection_score(D_mini[i], E_mini[j], k)
        }
      }

      associationMatrix <- RcppHungarian::HungarianSolver(-1 * Mu)
      scores <- Mu[associationMatrix$pairs]
      return(scores)
    }
    # --- end of internal functions ---

    # detection and event are boolean arrays
    D <- which(detection)
    n <- length(D)
    E <- which(event)
    m <- length(E)

    # Create the initial segments and sort them
    segments <- t(vapply(E, function(x) c(inf = x - k, sup = x + k), numeric(2)))

    # Function to merge overlapping intervals
    merge_intervals <- function(intervals) {
      merged <- list()
      current <- intervals[1, ]
      if (nrow(intervals) > 1) {
        for (i in 2:nrow(intervals)) {
          interval <- intervals[i, ]
          if (interval["inf"] <= current["sup"]) {
            current["sup"] <- max(current["sup"], interval["sup"])
          } else {
            merged[[length(merged) + 1]] <- current
            current <- interval
          }
        }
      }
      merged[[length(merged) + 1]] <- current
      merged_matrix <- do.call(rbind, merged)  # check if this is really necessary
      return(merged_matrix)
    }

    merged_segments <- merge_intervals(segments)

    # For each merged segment, create a group with 2 vectors: D_mini and E_mini
    groups <- lapply(1:nrow(merged_segments), function(i) {
      seg <- merged_segments[i, ]

      D_mini <- D[D >= seg["inf"] & D <= seg["sup"]]
      E_mini <- E[E >= seg["inf"] & E <= seg["sup"]]

      list(D_mini = D_mini, E_mini = E_mini)
    })

    S_d <- rep(0, length(D))
    S_d_counter <- 1

    for (idx in seq_along(groups)) {
      D_mini <- groups[[idx]]$D_mini
      E_mini <- groups[[idx]]$E_mini

      n <- length(D_mini)
      m <- length(E_mini)

      if (n==1 && m==1) # Direct association
      {
        S_d[S_d_counter] <- detection_score(D_mini[1],E_mini[1],k)
        S_d_counter <- S_d_counter+1
      }
      else if (n==1 && m>1) { # one D to multiple E -> take the max
        valores <- detection_score(D_mini[1], E_mini, k)
        S_d[S_d_counter] <- max(valores)
        S_d_counter <- S_d_counter+1
      }
      else if (n>1 && m==1) { # multiple D to one E -> take the max
        valores <- detection_score(D_mini, E_mini[1], k)
        S_d[S_d_counter] <- max(valores)
        S_d_counter <- S_d_counter+1
      }
      else if (n > 1 && m > 1) {
        scores <- complex_cases_association(D_mini, E_mini, k)
        S_d[S_d_counter:(S_d_counter + length(scores) - 1)] <- scores
        S_d_counter <- S_d_counter + length(scores)
      }
    }
    return(S_d)
  }

  detection[is.na(detection)] <- FALSE

  if((sum(detection)==0) || (sum(event)==0)){
    return(evaluate(har_eval(), detection, event))
  }

  scores <- soft_scores(detection, event, obj$sw_size)

  m <- length(which(event))
  t <- length(event)

  TPs <- sum(scores)
  FPs <- sum(1-scores)
  FNs <- m-TPs
  TNs <- (t-m)-FPs

  confMatrix <- as.table(matrix(c(as.character(TRUE),as.character(FALSE),
                                  round(TPs,2),round(FPs,2),
                                  round(FNs,2),round(TNs,2)), nrow = 3, ncol = 2, byrow = TRUE,
                                dimnames = list(c("detection", "TRUE","FALSE"),
                                                c("event", ""))))

  accuracy <- (TPs+TNs)/(TPs+FPs+FNs+TNs)
  sensitivity <- TPs/(TPs+FNs)
  specificity <- TNs/(FPs+TNs)
  prevalence <- (TPs+FNs)/(TPs+FPs+FNs+TNs)
  PPV <- (sensitivity * prevalence)/((sensitivity*prevalence) + ((1-specificity)*(1-prevalence)))
  NPV <- (specificity * (1-prevalence))/(((1-sensitivity)*prevalence) + ((specificity)*(1-prevalence)))
  detection_rate <- TPs/(TPs+FPs+FNs+TNs)
  detection_prevalence <- (TPs+FPs)/(TPs+FPs+FNs+TNs)
  balanced_accuracy <- (sensitivity+specificity)/2
  precision <- TPs/(TPs+FPs)
  recall <- TPs/(TPs+FNs)

  beta <- 1
  F1 <- (1+beta^2)*precision*recall/((beta^2 * precision)+recall)

  s_metrics <- list(TPs=TPs,FPs=FPs,FNs=FNs,TNs=TNs,confMatrix=confMatrix,accuracy=accuracy,
                    sensitivity=sensitivity, specificity=specificity,
                    prevalence=prevalence, PPV=PPV, NPV=NPV,
                    detection_rate=detection_rate, detection_prevalence=detection_prevalence,
                    balanced_accuracy=balanced_accuracy, precision=precision,
                    recall=recall, F1=F1)

  return(s_metrics)
}



