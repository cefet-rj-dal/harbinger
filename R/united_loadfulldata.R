#' Load full dataset from mini data object
#'
#' The mini datasets stored in `data/` include an `attr(url)` pointing to the
#' full dataset in `harbinger/`. This helper downloads and loads the full data.
#'
#' @param x Dataset object or its name (string or symbol).
#' @param envir Environment to load the full dataset into.
#' @return The full dataset object.
#' @examples
#' data(A1Benchmark)
#' A1Benchmark <- loadfulldata(A1Benchmark)
#' @export
loadfulldata <- function(x, envir = parent.frame()) {
  if (is.character(x)) {
    name <- x
    if (!exists(name, envir = envir, inherits = TRUE)) {
      stop("Object not found in environment: ", name)
    }
    obj <- get(name, envir = envir, inherits = TRUE)
  } else {
    name <- deparse(substitute(x))
    obj <- x
  }

  url <- attr(obj, "url")
  if (is.null(url) || !nzchar(url)) {
    stop("Missing attr(url) on object: ", name)
  }

  tmp <- tempfile(fileext = ".RData")
  utils::download.file(url, tmp, mode = "wb", quiet = TRUE)
  load(tmp, envir = envir)

  if (!exists(name, envir = envir, inherits = FALSE)) {
    stop("Full dataset loaded but object name not found: ", name)
  }
  get(name, envir = envir, inherits = FALSE)
}
