convert_ipynb_to_rmarkdown <- function(input) {
  if (!require("rmarkdown")) return("Missing necessary package: 'rmarkdown'")
  if (!require("knitr")) return("Missing necessary package: 'knitr'")

  if (tolower(xfun::file_ext(input)) != "ipynb") {
    return( "Error: Invalid file format" )
  }

  rmarkdown::convert_ipynb(input)
}


dir <- "."

texs <- list.files(path = dir, pattern = ".ipynb$", full.names = TRUE, recursive = TRUE)
for (tex in texs) {
  print(tex)
  convert_ipynb_to_rmarkdown(tex)
}
