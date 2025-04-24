#'@title Discord discovery using SAX
#'@description Discord discovery using SAX <doi:10.1007/s10618-007-0064-z>
#'@param a alphabet size
#'@param w word size
#'@param qtd number of occurrences to be classified as discords
#'@return `hdis_sax` object
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
#'# setting up discord discovery method
#'model <- hdis_sax(26, 3, 3)
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
hdis_sax <- function(a, w, qtd=2) {
  obj <- harbinger()
  if(!(is.numeric(a)&&(a>=1)&&(a<=26))) stop("alphabet must be between 1 and 26", call. = FALSE)
  obj$a <- a
  obj$w <- w
  obj$qtd <- qtd
  class(obj) <- append("hdis_sax", class(obj))
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
#'@exportS3Method detect hdis_sax
detect.hdis_sax <- function(obj, serie, ...) {
  i <- 0
  total_count <- 0
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  tsax <- trans_sax(obj$a)
  tsax <- fit(tsax, obj$serie)
  tss <- transform(tsax, obj$serie)

  tsw <- daltoolbox::ts_data(tss, obj$w)
  seq <- base::apply(tsw, MARGIN = 1, function(x) paste(as.vector(x), collapse=""))
  entropy <- base::apply(as.matrix(seq), MARGIN = 1, comp_word_entropy)

  data <- data.frame(i = 1:nrow(tsw), seq, entropy)

  result <- data |> dplyr::group_by(seq) |> dplyr::summarise(total_count=dplyr::n(), entropy=mean(entropy))
  discords_seq <- result[result$total_count == 1,]
  discords_seq <- discords_seq |> dplyr::arrange(dplyr::desc(entropy))
  result <- result[result$total_count > 1,]
  result <- result |> dplyr::arrange(dplyr::desc(total_count), dplyr::desc(entropy))
  data <- data[data$seq %in% result$seq,]

  motifs <- data
  pos <- NULL
  for (k in -obj$w:obj$w) {
    pos <- c(pos, motifs$i + k)
  }
  pos <- pos[pos > 0]

  data <- data.frame(i = 1:nrow(tsw), seq, entropy)
  data  <- data[-pos,]

  discords <- NULL
  for (j in 1:nrow(discords_seq)) {
    discord <- data[data$seq == discords_seq$seq[j],]
    if (nrow(discord) > 0) {
      refs <- discord$i
      discords <- base::rbind(discords, discord)

      pos <- NULL
      for (k in -obj$w:obj$w) {
        pos <- c(pos, refs + k)
      }
      data <- data[!(data$i %in% pos),]
    }
  }

  mots <- rep(FALSE, length(obj$serie))
  seqs <- rep(NA, length(obj$serie))
  mots[discords$i] <- TRUE
  seqs[discords$i] <- discords$seq

  detection <- obj$har_restore_refs(obj, anomalies = mots)
  detection$seq <- NA
  detection$seqlen <- NA
  detection$type[detection$type=="anomaly"] <- "motif"
  detection$seq[obj$non_na] <- seqs
  detection$seqlen[obj$non_na] <- obj$w

  return(detection)
}


