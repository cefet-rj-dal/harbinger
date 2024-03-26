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

