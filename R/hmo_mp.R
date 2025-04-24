#'@title Motif discovery using Matrix Profile
#'@description Motif discovery using Matrix Profile <doi:10.32614/RJ-2020-021>
#'@param mode mode of computing distance between sequences. Available options include: "stomp", "stamp", "simple", "mstomp", "scrimp", "valmod", "pmp"
#'@param w word size
#'@param qtd number of occurrences to be classified as motifs
#'@return `hmo_mp` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(examples_motifs)
#'
#'#Using sequence example
#'dataset <- examples_motifs$simple
#'head(dataset)
#'
#'# setting up motif discovery method
#'model <- hmo_mp("stamp", 4, 3)
#'
#'# fitting the model
#'model <- fit(model, dataset$serie)
#'
# making detection using hanr_ml
#'detection <- detect(model, dataset$serie)
#'
#'# filtering detected events
#'print(detection[(detection$event),])
#'
#'@export
hmo_mp <- function(mode = "stamp", w, qtd) {
  obj <- harbinger()
  obj$mode <- mode #"stamp", "stomp", "scrimp"
  obj$w <- w
  obj$qtd <- qtd
  class(obj) <- append("hmo_mp", class(obj))
  return(obj)
}

#'@importFrom tsmp tsmp
#'@importFrom tsmp find_motif
#'@exportS3Method detect hmo_mp
detect.hmo_mp <- function(obj, serie, ...) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  n <- length(serie)
  non_na <- which(!is.na(serie))

  serie <- stats::na.omit(serie)

  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)
  if(!(is.numeric(obj$w)&&(obj$w >=4))) stop("Window size must be at least 4", call. = FALSE)
  if(!(is.numeric(obj$qtd)&&(obj$qtd >=3))) stop("the number of selected motifs must be greater than 3", call. = FALSE)

  motifs <- tsmp::tsmp(serie, window_size = obj$w, mode = obj$mode)
  motifs <- tsmp::find_motif(motifs, qtd = obj$qtd)

  outliers <- data.frame(event = rep(FALSE, length(serie)), seq = rep(NA, length(serie)))
  for (i in 1:length(motifs$motif$motif_idx)) {
    mot <- motifs$motif$motif_idx[[i]]
    mot <- c(mot, motifs$motif$motif_neighbor[[i]])
    outliers$event[mot] <- TRUE
    outliers$seq[mot] <- as.character(i)
  }

  detection <- data.frame(idx=1:n, event = FALSE, type="", seq=NA, seqlen = NA)
  detection$event[non_na] <- outliers$event
  detection$type[detection$event[non_na]] <- "motif"
  detection$seq[non_na] <- outliers$seq
  detection$seqlen[detection$event] <- obj$w
  return(detection)
}


