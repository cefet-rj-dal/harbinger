library(devtools)

devtools::install_github("cefet-rj-dal/harbinger", force=TRUE)
library(harbinger)

devtools::install_github("cefet-rj-dal/harbinger", force=TRUE, dependencies = TRUE, build_vignettes = TRUE)
library(harbinger)
utils::browseVignettes()

