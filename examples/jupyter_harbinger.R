if (!exists("repos_name"))
  repos_name <<- getOption("repos")[1]

setrepos <- function(repos=repos) {
  repos_name <<- repos
}

internal_loadlibrary <- function(packagename)
{
  if (!require(packagename, character.only = TRUE))
  {
    install.packages(packagename, repos=repos_name, dep=TRUE, verbose = FALSE)
    require(packagename, character.only = TRUE)
  }
}


loadlibrary <- function(packagename)
{
  suppressPackageStartupMessages(internal_loadlibrary(packagename))
}

internal_load_harbinger <- function()
{
  library(daltoolbox)

  if (!require("harbinger", character.only = TRUE))
  {
    library(devtools)

    devtools::install_github("cefet-rj-dal/harbinger", force=TRUE, dependencies=FALSE, upgrade="never", build_vignettes = TRUE)

    library(harbinger)
  }
}

load_harbinger <- function()
{
  suppressPackageStartupMessages(internal_load_harbinger())
}

####

if (FALSE) {
  library(devtools)
  load_all()
}

if (FALSE) {
  library(devtools)
  check()
  load_all()
}

if (FALSE) {
  library(devtools)
  suppressWarnings(check(vignettes = FALSE))
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
  pkgdown::build_site()
  usethis::use_pkgdown_github_pages()
}

if (FALSE) {
  devtools::install(dependencies = TRUE, build_vignettes = TRUE)
  utils::browseVignettes()
}

