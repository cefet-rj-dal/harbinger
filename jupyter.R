if (!exists("repos_name"))
  repos_name <<- getOption("repos")[1]

setrepos <- function(repos=repos) {
  repos_name <<- repos
}

load_library <- function(packagename)
{
  if (!require(packagename, character.only = TRUE))
  {
    install.packages(packagename, repos=repos_name, dep=TRUE, quiet = TRUE)
    require(packagename, character.only = TRUE)
  }
}

load_github <- function(gitname)
{
  packagename <- strsplit(gitname,"/")[[1]][2]
  if (!require(packagename, character.only = TRUE))
  {
    devtools::install_github(gitname, force=TRUE, upgrade="never", quiet = TRUE)
    require(packagename, character.only = TRUE)
  }
}


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
  #R CMD check harbinger_1.0.737.tar.gz
  #R CMD check harbinger_1.0.737.tar.gz --as-cran
  
  #upload package
  #https://cran.r-project.org/submit.html  
}
