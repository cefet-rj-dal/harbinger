### functions for package development


if (FALSE) {
  library(devtools)
  load_all()
}

if (FALSE) {
  library(devtools)
  suppressWarnings(check(vignettes = FALSE))
  load_all()
}

if (FALSE) {
  library(devtools)
  check()
  load_all()
  #'@exportS3Method fit harbinger
  #'@exportS3Method detect harbinger
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
  #create homepage
  #library(devtools)
  #usethis::use_readme_rmd()
}

if (FALSE) {
  #update documentation
  devtools::document()
  devtools::check()
  pkgdown::build_site()
}
if (FALSE) {
  #update homepage - edit README.Rmd
  library(devtools)
  devtools::build_readme()
}

if (FALSE) {
  devtools::install(dependencies = TRUE, build_vignettes = TRUE)
  utils::browseVignettes()
}

if (FALSE) { #build package for cran
  #run in RStudio
  library(devtools)
  pkgbuild::build(manual = TRUE)

  #run in terminal
  #R CMD check harbinger_1.2.747.tar.gz
  #R CMD check harbinger_1.2.747.tar.gz --as-cran

  #upload package
  #https://cran.r-project.org/submit.html
}
