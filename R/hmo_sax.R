#'@title Motif discovery using SAX
#'@description Motif discovery using SAX
#'@param a alphabet size
#'@param w word size
#'@param qtd number of occurrences to be classified as motifs
#'@return hmo_sax object
#'@examples detector <- harbinger()
#'@export
#'@import stringr
hmo_sax <- function(a, w, qtd) {
  obj <- harbinger()
  obj$a <- a
  obj$w <- w
  obj$qtd <- qtd
  class(obj) <- append("hmo_sax", class(obj))
  return(obj)
}

binning <- function(v, a) {
  p <- seq(from = 0, to = 1, by = 1/a)
  q <- stats::quantile(v, p)
  qf <- matrix(c(q[1:(length(q)-1)],q[2:(length(q))]), ncol=2)
  vp <- cut(v, unique(q), FALSE, include.lowest=TRUE)
  m <- tapply(v, vp, mean)
  vm <- m[vp]
  mse <- mean( (v - vm)^2, na.rm = TRUE)
  return (list(binning=m, bins_factor=vp, q=q, qf=qf, bins=vm, mse=mse))
}

convert_to_base <- function(num, nbase) {
  chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  if(nbase < 2 || nbase > str_length(chars))
    return("")
  newNumber <- ""
  r <- 0
  while(num >= nbase)
  {
    r <- num %% nbase
    newNumber <- sprintf("%s%s", substr(chars, r+1, r+1), newNumber)
    num <- as.integer(num / nbase)
  }
  newNumber = sprintf("%s%s", substr(chars, num+1, num+1), newNumber)
  return (newNumber)
}

convert_to_base_vec <- function(num, nbase) {
  n <- length(num)
  result <- rep("", n)
  for (i in 1:n) {
    result[i] <- convert_to_base(num[i], nbase)
  }
  return(result)
}

norm_sax <- function (vector, slices)
{
  vectorNorm <- (vector - mean(vector, na.rm = T))/stats::sd(vector, na.rm = T)
  mybin <- binning(vectorNorm, slices)
  i <- ceiling(log(slices, 36))
  mycode <- str_pad(convert_to_base_vec(0:(slices-1), 36), i, pad="0")
  saxvector <- mycode[mybin$bins_factor]
  return(saxvector)
}

#'@importFrom stats na.omit
#'@import dplyr
#'@export
detect.hmo_sax <- function(obj, serie, ...) {
  i <- 0
  total_count <- 0
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  n <- length(serie)
  non_na <- which(!is.na(serie))

  serie <- stats::na.omit(serie)

  tss <- norm_sax(serie, obj$a)
  tsw <- ts_data(tss, obj$w)
  seq <- apply(tsw, MARGIN = 1, function(x) paste(as.vector(x), collapse=""))
  data <- data.frame(i = 1:nrow(tsw), seq)
  result <- data |> dplyr::group_by(seq) |> dplyr::summarise(total_count=n()) |> dplyr::filter(total_count >= obj$qtd) |> dplyr::arrange(desc(total_count)) |> dplyr::select(seq)
  result <- result$seq
  data <- data |> dplyr::filter(seq %in% result)

  motifs <- NULL
  for (j in 1:length(result)) {
    motif <- data |> dplyr::filter(seq == result[j])
    pos <- NULL
    for (k in 1:obj$w) {
      pos <- c(pos, motif$i + (k - 1))
    }
    data <- data |> dplyr::filter(!(i %in% pos))

    vec <- motif$i
    svec <- split(vec, cumsum(c(1, diff(vec) != 1)))
    vec <- sapply(svec, min)

    motif <- motif |> dplyr::filter((i %in% vec))

    if (length(vec) >= obj$qtd) {
      motifs <- rbind(motifs, motif)
    }
  }

  outliers <- data.frame(event = rep(FALSE, length(serie)), seq = rep(NA, length(serie)))
  if (!is.null(motifs)) {
    outliers$event[motifs$i] <- TRUE
    outliers$seq[motifs$i] <- motifs$seq
  }

  detection <- data.frame(idx=1:n, event = FALSE, type="", seq=NA, seqlen = NA)
  detection$event[non_na] <- outliers$event
  detection$type[detection$event[non_na]] <- "motif"
  detection$seq[non_na] <- outliers$seq
  detection$seqlen[detection$event] <- obj$w
  return(detection)
}


