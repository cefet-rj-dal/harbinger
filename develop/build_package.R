library(devtools)
load_all()

if (FALSE) {
  library(devtools)
  check()
  load_all()
}

if (FALSE) {
  library(devtools)
  document()
  load_all()
}

if (FALSE) {
  library(devtools)
  devtools::build_manual()
}

if (FALSE) {
  library(devtools)
  usethis::use_readme_rmd()
}

if (FALSE) {
  library(devtools)
  devtools::build_readme()
}

if (FALSE) {
  pkgdown::build_site()  ## para ver o resultado, o site fica muito legal
  #usethis::use_pkgdown_github_pages()
}

if (FALSE) {
  devtools::install(dependencies = TRUE, build_vignettes = TRUE)
  utils::browseVignettes()
}

