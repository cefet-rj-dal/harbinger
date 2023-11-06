#'@title Motif discovery using SAX
#'@description Motif discovery using SAX <doi:10.1007/s10618-007-0064-z>
#'@param a alphabet size
#'@param w word size
#'@param qtd number of occurrences to be classified as motifs
#'@return `hmo_sax` object
#'@examples
#'library(daltoolbox)
#'
#'#loading the example database
#'data(har_examples)
#'
#'#Using example 15
#'dataset <- har_examples$example15
#'head(dataset)
#'
#'# setting up time series regression model
#'model <- hmo_sax(26, 3, 3)
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
hmo_sax <- function(a, w, qtd) {
  obj <- harbinger()
  if(!(is.numeric(a)&&(a>=1)&&(a<=26))) stop("alphabet must be between 1 and 26", call. = FALSE)
  obj$a <- a
  obj$w <- w
  obj$qtd <- qtd
  class(obj) <- append("hmo_sax", class(obj))
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
detect.hmo_sax <- function(obj, serie, ...) {
  binning_sax <- function(v, a) {
    p <- base::seq(from = 0, to = 1, by = 1/a)
    q <- stats::quantile(v, p)
    qf <- base::matrix(c(q[1:(length(q)-1)],q[2:(length(q))]), ncol=2)
    vp <- base::cut(v, unique(q), FALSE, include.lowest=TRUE)
    m <- base::tapply(v, vp, mean)
    vm <- m[vp]
    mse <- base::mean((v - vm)^2, na.rm = TRUE)
    return (list(binning=m, bins_factor=vp, q=q, qf=qf, bins=vm, mse=mse))
  }

  convert_to_sax <- function(num, nbase) {
    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    if(nbase < 2 || nbase > stringr::str_length(chars))
      return("")
    newNumber <- ""
    r <- 0
    while(num >= nbase)
    {
      r <- num %% nbase
      newNumber <- base::sprintf("%s%s", substr(chars, r+1, r+1), newNumber)
      num <- as.integer(num / nbase)
    }
    newNumber = base::sprintf("%s%s", substr(chars, num+1, num+1), newNumber)
    return (newNumber)
  }

  convert_to_sax_vec <- function(num, nbase) {
    n <- length(num)
    result <- rep("", n)
    for (i in 1:n) {
      result[i] <- convert_to_sax(num[i], nbase)
    }
    return(result)
  }

  norm_sax <- function (vector, slices)
  {
    vectorNorm <- (vector - base::mean(vector, na.rm = T))/stats::sd(vector, na.rm = T)
    mybin <- binning_sax(vectorNorm, slices)
    i <- base::ceiling(log(slices, 26))
    mycode <- stringr::str_pad(convert_to_sax_vec(0:(slices-1), 26), i, pad="0")
    saxvector <- mycode[mybin$bins_factor]
    return(saxvector)
  }
  i <- 0
  total_count <- 0
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  obj <- obj$har_store_refs(obj, serie)

  tss <- norm_sax(obj$serie, obj$a)
  tsw <- daltoolbox::ts_data(tss, obj$w)
  seq <- base::apply(tsw, MARGIN = 1, function(x) paste(as.vector(x), collapse=""))
  data <- data.frame(i = 1:nrow(tsw), seq)
  result <- data |> dplyr::group_by(seq) |> dplyr::summarise(total_count=dplyr::n())
  result <- result[result$total_count >= obj$qtd,]
  result <- data |> dplyr::arrange(dplyr::desc(total_count)) |> dplyr::select(seq)
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


