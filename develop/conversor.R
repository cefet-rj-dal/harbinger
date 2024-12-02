convert_ipynb_to_rmarkdown <- function(input) {
  if (!require("rmarkdown")) return("Missing necessary package: 'rmarkdown'")
  if (!require("markdown")) return("Missing necessary package: 'markdown'")
  if (!require("knitr")) return("Missing necessary package: 'knitr'")

  if (tolower(xfun::file_ext(input)) != "ipynb") {
    return( "Error: Invalid file format" )
  }

  #rmarkdown::convert_ipynb(input)

  rmdfile = xfun::with_ext(input, "Rmd")
  mdfile = xfun::with_ext(input, "md")
  figdir = xfun::with_ext(input, "")

  dir <- dirname(rmdfile)

  unlink("figure", recursive=TRUE)
  unlink(figdir, recursive=TRUE)

  knit(rmdfile, mdfile) # creates md file
  #file.copy(bibs, diroutput, overwrite = TRUE)

  file.rename("figure", figdir)

  data <- readLines(con <- file(mdfile, encoding = "UTF-8"))
  close(con)

  data <- gsub("figure/", sprintf("%s/", basename(figdir)), data)

  writeLines(data, con <- file(mdfile, encoding = "UTF-8"))
  close(con)

  #htmlfile = xfun::with_ext(input, "html")
  #file.remove(htmlfile)
}

dir <- "."

texs <- list.files(path = dir, pattern = ".ipynb$", full.names = TRUE, recursive = TRUE)
for (tex in texs) {
  print(tex)
  convert_ipynb_to_rmarkdown(tex)
}
