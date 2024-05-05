#'@title Motif discovery using xsax
#'@description Motif discovery using xsax <doi:10.1007/s10618-007-0064-z>
#'@param a alphabet size
#'@param w word size
#'@param qtd number of occurrences to be classified as motifs
#'@return `hmo_xsax` object
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
#'model <- hmo_xsax(37, 3, 3)
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
hmo_xsax <- function(a, w, qtd) {
  obj <- harbinger()
  obj$a <- a
  obj$w <- w
  obj$qtd <- qtd

  class(obj) <- append("hmo_xsax", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom stringr str_length
#'@importFrom stringr str_pad
#'@importFrom dplyr group_by
#'@importFrom dplyr summarise
#'@importFrom dplyr arrange
#'@importFrom dplyr select
#'@importFrom dplyr n
#'@importFrom dplyr desc
#'@export
detect.hmo_xsax <- function(obj, serie, ...) {
  i <- 0
  total_count <- 0
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  tsax <- trans_xsax(obj$a)
  tsax <- fit(tsax, obj$serie)
  tss <- transform(tsax, obj$serie)

  tsw <- ts_data(tss, obj$w)
  seq <- apply(tsw, MARGIN = 1, function(x) paste(as.vector(x), collapse=""))
  data <- data.frame(i = 1:nrow(tsw), seq)
  result <- data |> dplyr::group_by(seq) |> dplyr::summarise(total_count=dplyr::n())
  result <- result[result$total_count >= obj$qtd,]
  result <- result |> dplyr::arrange(dplyr::desc(total_count)) |> dplyr::select(seq)
  result <- result$seq
  data <- data[data$seq %in% result,]

  motifs <- NULL
  for (j in 1:length(result)) {
    motif <- data[data$seq == result[j],]
    pos <- NULL
    for (k in 1:obj$w) {
      pos <- c(pos, motif$i + (k - 1))
    }
    data <- data[!(data$i %in% pos),]

    if (nrow(motif) > 0) {
      vec <- motif$i
      svec <- base::split(vec, base::cumsum(c(1, diff(vec) != 1)))
      vec <- base::sapply(svec, min)

      motif <- motif[(motif$i %in% vec),]

      if (length(vec) >= obj$qtd) {
        motifs <- base::rbind(motifs, motif)
      }
    }
  }

  mots <- rep(FALSE, length(obj$serie))
  seqs <- rep(NA, length(obj$serie))
  mots[motifs$i] <- TRUE
  seqs[motifs$i] <- motifs$seq

  detection <- obj$har_restore_refs(obj, anomalies = mots)
  detection$seq <- NA
  detection$seqlen <- NA
  detection$type[detection$type=="anomaly"] <- "motif"
  detection$seq[obj$non_na] <- seqs
  detection$seqlen[obj$non_na] <- obj$w

  return(detection)
}


