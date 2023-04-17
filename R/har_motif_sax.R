#'@description Ancestor class for time series event detection
#'@details The Harbinger class establishes the basic interface for time series event detection.
#'  Each method should be implemented in a descendant class of Harbinger
#'@return Harbinger object
#'@examples detector <- harbinger()
#'@export

har_motif_sax <- function(a, w, qtd) {
  obj <- harbinger()
  obj$a <- a
  obj$w <- w
  obj$qtd <- qtd
  class(obj) <- append("har_motif_sax", class(obj))
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


norm_sax <- function (vector, slices)
{
  vectorNorm <- (vector - mean(vector, na.rm = T))/stats::sd(vector, na.rm = T)
  mybin <- binning(vectorNorm, slices)
  i <- ceiling(log(slices, 35))
  mycode <- str_pad(strtoi(0:(slices-1), 35), i, pad="0")
  saxvector <- mycode[mybin$bins_factor]
  return(saxvector)
}



#'@export
detect.har_motif_sax <- function(obj, serie) {
  if(is.null(serie)) stop("No data was provided for computation", call. = FALSE)

  n <- length(serie)
  non_na <- which(!is.na(serie))

  serie <- na.omit(serie)

  tss <- norm_sax(serie, obj$a)
  tsw <- ts_data(tss, obj$w)
  seq <- apply(tsw, MARGIN = 1, function(x) paste(as.vector(x), collapse=""))
  data <- data.frame(i = 1:nrow(tsw), seq)
  result <- data |> group_by(seq) |> summarise(total_count=n()) |> filter(total_count >= obj$qtd) |> arrange(desc(total_count)) |> select(seq)
  result <- result$seq
  data <- data |> filter(seq %in% result)

  motifs <- NULL
  for (j in 1:length(result)) {
    motif <- data |> filter(seq == result[j])
    pos <- NULL
    for (k in 1:obj$w) {
      pos <- c(pos, motif$i + (k - 1))
    }
    data <- data |> filter(!(i %in% pos))

    vec <- motif$i
    svec <- split(vec, cumsum(c(1, diff(vec) != 1)))
    vec <- sapply(svec, min)

    motif <- motif |> filter((i %in% vec))

    if (length(vec) >= obj$qtd) {
      motifs <- rbind(motifs, motif)
    }
  }

  outliers <- data.frame(event = rep(FALSE, length(serie)), seq = rep(NA, length(serie)))
  if (!is.null(motifs)) {
    outliers$event[motifs$i] <- TRUE
    outliers$seq[motifs$i] <- motifs$seq
  }

  detection <- data.frame(idx=1:n, event = FALSE, type=NA, seq=NA, seqlen = NA)
  detection$event[non_na] <- outliers$event
  detection$type[detection$event[non_na]] <- "motif"
  detection$seq[non_na] <- outliers$seq
  detection$seqlen[detection$event] <- obj$w
  return(detection)
}


