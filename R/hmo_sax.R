#' @title Motif discovery using SAX
#' @description
#' Discovers repeated subsequences (motifs) using a Symbolic Aggregate approXimation
#' (SAX) representation <doi:10.1007/s10618-007-0064-z>. Subsequences are discretized
#' and grouped by symbolic words; frequently occurring words indicate motifs.
#'
#' @param a Integer. Alphabet size.
#' @param w Integer. Word/window size.
#' @param qtd Integer. Minimum number of occurrences to classify as a motif.
#' @return `hmo_sax` object.
#'
#' @examples
#' library(daltoolbox)
#'
#' # Load motif example data
#' data(examples_motifs)
#'
#' # Use a simple sequence example
#' dataset <- examples_motifs$simple
#' head(dataset)
#'
#' # Configure SAX-based motif discovery
#' model <- hmo_sax(26, 3, 3)
#'
#' # Fit the model
#' model <- fit(model, dataset$serie)
#'
#' # Run detection
#' detection <- detect(model, dataset$serie)
#'
#' # Show detected motifs
#' print(detection[(detection$event),])
#'
#' @references
#' - Lin J, Keogh E, Lonardi S, Chiu B (2007). A symbolic representation of time series,
#'   with implications for streaming algorithms. Data Mining and Knowledge Discovery 15, 107–144.
#'
#' @export
hmo_sax <- function(a, w, qtd=2) {
  obj <- harbinger()
  if(!(is.numeric(a)&&(a>=1)&&(a<=26))) stop("alphabet must be between 1 and 26", call. = FALSE)
  obj$a <- a
  obj$w <- w
  obj$qtd <- qtd
  class(obj) <- append("hmo_sax", class(obj))
  return(obj)
}

comp_word_entropy <- function(str) {
  x <- strsplit(str, "^")
  x <- x[[1]]
  n <- length(x)
  x <- table(x)
  x <- x / n
  y <- 0
  for (i in 1:length(x)) {
    y <- y - x[i]*log(x[i],2)

  }
  return(y)
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
#'@exportS3Method detect hmo_sax
detect.hmo_sax <- function(obj, serie, ...) {
  i <- 0
  total_count <- 0
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)
  falsemotifs <- round(obj$w/2)

  obj <- obj$har_store_refs(obj, serie)

  tsax <- trans_sax(obj$a)
  tsax <- fit(tsax, obj$serie)
  tss <- daltoolbox::transform(tsax, obj$serie)

  tsw <- tspredit::ts_data(tss, obj$w)
  seq <- base::apply(tsw, MARGIN = 1, function(x) paste(as.vector(x), collapse=""))
  entropy <- base::apply(as.matrix(seq), MARGIN = 1, comp_word_entropy)

  data <- data.frame(i = 1:nrow(tsw), seq, entropy)

  result <- data |> dplyr::group_by(seq) |> dplyr::summarise(total_count=dplyr::n(), entropy=mean(entropy))
  result <- result[result$total_count >= obj$qtd,]
  result <- result |> dplyr::arrange(dplyr::desc(total_count), dplyr::desc(entropy))
  data <- data[data$seq %in% result$seq,]

  motifs <- NULL
  for (j in 1:nrow(result)) {
    motif <- data[data$seq == result$seq[j],]
    if (nrow(motif) > 0) {
      refs <- motif$i
      svec <- base::split(refs, base::cumsum(c(1, diff(refs) != 1)))
      vec <- base::sapply(svec, min)

      motif <- motif[(motif$i %in% vec),]
      if (length(vec) >= obj$qtd) {
        motifs <- base::rbind(motifs, motif)

        pos <- NULL
        for (k in (-falsemotifs):falsemotifs) {
          pos <- c(pos, refs + k)
        }
        data <- data[!(data$i %in% pos),]
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


