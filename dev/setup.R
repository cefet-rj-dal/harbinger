"SETUP DE SISTEMA PARA CRIAÇÃO DE PACOTES"

install.packages(c("devtools", "roxygen2", "testthat", "knitr"))
library(devtools)

"to simulate installing and loading a package, during interactive development"
load_all()
"If that same functionality is used inside an R package"
pkgload::load_all()


use_testthat()
usethis::use_testthat()

"The following code installs the development versions of devtools and usethis,
 which may be important during the revision of the book"

devtools::install_github("r-lib/devtools")
devtools::install_github("r-lib/usethis")


"source no git = https://github.com/cefet-rj-pratica-pesquisa/tema4/blob/main/harbinger.R"

.libPaths() "ver qual biblioteca está ativa"


"testar se o setup está feito"
library(devtools)
has_devel()
Y

"Avaliar nomes de pacotes"
install.packages(c("available"))
library(available)
available("harbinger") "esse nome procede"


"CRIAR PACOTE"
"In RStudio, do File > New Project > New Directory > R Package."
"This ultimately calls usethis::create_package(), so really there’s just one way."

"Caminho para o pacote, falta criar ainda"
# create_package("path/to/package/pkgname")
# load_all(), test(), and check().

write('PATH="${RTOOLS40_HOME}\\usr\\bin;${PATH}"', file = "~/.Renviron", append = TRUE)

Sys.which("make")

install.packages("C:/Users/eduar/Documents/harbinger", repos=NULL, type="source")
install.packages("harbinger", type = "source")
library("harbinger")
.libPaths()



