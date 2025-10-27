convert_ipynb_to_rmarkdown <- function(input) {
  if (!require("rmarkdown")) return("Missing necessary package: 'rmarkdown'")

  if (tolower(xfun::file_ext(input)) != "ipynb") {
    return( "Error: Invalid file format" )
  }

  rmarkdown::convert_ipynb(input)
}

delete_ipynb <- function(input) {
  file.remove(input)
}

convert_rmd_md <- function(input) {
  if (!require("rmarkdown")) return("Missing necessary package: 'rmarkdown'")
  if (!require("markdown")) return("Missing necessary package: 'markdown'")
  if (!require("knitr")) return("Missing necessary package: 'knitr'")

  if (tolower(xfun::file_ext(input)) != "rmd") {
    return( "Error: Invalid file format" )
  }

  mdfile = xfun::with_ext(input, "md")
  mdfile = gsub("Rmd/", "", mdfile)
  figdir = sprintf("%s/fig/%s", dirname(mdfile), basename(xfun::with_ext(input, "")))

  unlink("figure", recursive=TRUE)
  unlink(figdir, recursive=TRUE)

  knit(input, mdfile) # creates md file

  file.rename("figure", figdir)

  data <- readLines(con <- file(mdfile, encoding = "UTF-8"))
  close(con)

  data <- gsub("figure/", sprintf("fig/%s/", basename(figdir)), data)

  writeLines(data, con <- file(mdfile, encoding = "UTF-8"))
  close(con)

  #htmlfile = xfun::with_ext(input, "html")
  #file.remove(htmlfile)
}



dir <- "Rmd"

texs <- list.files(path = dir, pattern = ".ipynb$", full.names = TRUE, recursive = TRUE)
if (FALSE) {
  for (tex in texs) {
    print(tex)
    convert_ipynb_to_rmarkdown(tex)
  }
}
if (FALSE) {
  for (tex in texs) {
    print(tex)
    delete_ipynb(tex)
  }
}

dir <- "Rmd"
texs <- list.files(path = dir, pattern = ".Rmd$", full.names = TRUE, recursive = TRUE)
if (TRUE) {
  for (tex in texs) {
    print(tex)
    convert_rmd_md(tex)
  }
}
#Procurar por ## Error

#Procurar por ## Error in install.packages : Updating loaded packages
