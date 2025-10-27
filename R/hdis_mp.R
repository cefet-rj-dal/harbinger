#' @title Discord discovery using Matrix Profile
#' @description
#' Discovers rare, dissimilar subsequences (discords) using Matrix Profile as
#' implemented in the `tsmp` package <doi:10.32614/RJ-2020-021>.
#'
#' @param mode Character. Algorithm: one of "stomp", "stamp", "simple",
#'   "mstomp", "scrimp", "valmod", "pmp".
#' @param w Integer. Subsequence window size.
#' @param qtd Integer. Number of discords to return (>= 3 recommended).
#' @return `hdis_mp` object.
#'
#' @examples
#' library(daltoolbox)
#'
#' # Load motif/discord example data
#' data(examples_motifs)
#'
#' # Use a simple sequence example
#' dataset <- examples_motifs$simple
#' head(dataset)
#'
#' # Configure discord discovery via Matrix Profile
#' model <- hdis_mp("stamp", 4, 3)
#'
#' # Fit the model
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected discords
#' print(detection[(detection$event),])
#'
#' @references
#' - Yeh CCM, et al. (2016). Matrix Profile I/II: All-pairs similarity joins and scalable
#'   time series motifs/discrod discovery. IEEE ICDM.
#' - Tavenard R, et al. tsmp: The Matrix Profile in R. The R Journal (2020). doi:10.32614/RJ-2020-021
#'
#'@export
hdis_mp <- function(mode = "stamp", w, qtd) {
  obj <- harbinger()
  obj$mode <- mode #"stamp", "stomp", "scrimp"
  obj$w <- w
  obj$qtd <- qtd
  class(obj) <- append("hdis_mp", class(obj))
  return(obj)
}

#'@importFrom tsmp tsmp
#'@importFrom tsmp find_motif
#'@exportS3Method detect hdis_mp
detect.hdis_mp <- function(obj, serie, ...) {
  # Validate input
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  n <- length(serie)
  non_na <- which(!is.na(serie))

  # Omit NAs for algorithm run
  serie <- stats::na.omit(serie)

  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)
  if(!(is.numeric(obj$w)&&(obj$w >=4))) stop("Window size must be at least 4", call. = FALSE)
  if(!(is.numeric(obj$qtd)&&(obj$qtd >=3))) stop("the number of selected discords must be greater than 3", call. = FALSE)

  # Compute Matrix Profile and extract discord sets
  discords <- tsmp::tsmp(serie, window_size = obj$w, mode = obj$mode)
  discords <- tsmp::find_discord(discords, qtd = obj$qtd)

  outliers <- data.frame(event = rep(FALSE, length(serie)), seq = rep(NA, length(serie)))
  for (i in 1:length(discords$discord$discord_idx)) {
    mot <- discords$discord$discord_idx[[i]]
    mot <- c(mot, discords$discord$discord_neighbor[[i]])
    outliers$event[mot] <- TRUE
    outliers$seq[mot] <- as.character(i)
  }

  # Assemble detection table and restore to original indexing
  detection <- data.frame(idx=1:n, event = FALSE, type="", seq=NA, seqlen = NA)
  detection$event[non_na] <- outliers$event
  detection$type[detection$event[non_na]] <- "motif"
  detection$seq[non_na] <- outliers$seq
  detection$seqlen[detection$event] <- obj$w
  return(detection)
}


