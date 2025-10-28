################################################################################
# Converter utilities
# - convert_ipynb_to_rmarkdown: converts .ipynb to .Rmd using rmarkdown
# - delete_ipynb: removes a .ipynb file
# - convert_rmd_md: knits .Rmd to .md and relocates figures to a per-doc folder
#
#
# Notes:
# - Adds comments for clarity and light refactor for readability.
# - Ensures destination figure folder exists before moving figures to avoid
#   copy/move failures.
################################################################################

# Convert a Jupyter notebook (.ipynb) to R Markdown (.Rmd)
convert_ipynb_to_rmarkdown <- function(input) {
  # Require rmarkdown without attaching; return a clear message if missing
  if (!require("rmarkdown")) return("Missing necessary package: 'rmarkdown'")

  # Validate extension
  if (tolower(xfun::file_ext(input)) != "ipynb") {
    return("Error: Invalid file format")
  }

  # Perform conversion
  rmarkdown::convert_ipynb(input)
}

# Delete a .ipynb file (helper)
delete_ipynb <- function(input) {
  file.remove(input)
}

# Knit an .Rmd to .md under 'examples/', move figures to
# '<examples-subdir>/fig/<doc-basename>/', render a Word (.docx)
# under top-level 'examples-word/', and also extract a pure R script under
# 'examples-r/'.
convert_rmd_md <- function(input) {
  # Require needed packages; keep behavior consistent with original
  if (!require("rmarkdown")) return("Missing necessary package: 'rmarkdown'")
  if (!require("markdown"))  return("Missing necessary package: 'markdown'")
  if (!require("knitr"))     return("Missing necessary package: 'knitr'")

  # Validate extension
  if (tolower(xfun::file_ext(input)) != "rmd") {
    return("Error: Invalid file format")
  }

  # Output Markdown path goes under top-level 'examples/' directory
  # Preserve sub-structure after removing the leading 'Rmd/'
  md_rel  <- gsub("^Rmd/", "", xfun::with_ext(input, "md"))
  mdfile  <- file.path("examples", md_rel)

  # Output Word path goes under top-level 'examples-word/' directory
  # Preserve sub-structure after removing the leading 'Rmd/'
  docx_rel <- gsub("^Rmd/", "", xfun::with_ext(input, "docx"))
  docxfile <- file.path("examples-word", docx_rel)

  # Output R script path goes under top-level 'examples-r/' directory
  # Preserve sub-structure after removing the leading 'Rmd/'
  r_rel  <- gsub("^Rmd/", "", xfun::with_ext(input, "R"))
  rfile  <- file.path("examples-r", r_rel)

  # Destination figure directory: '<md-dir>/fig/<rmd-basename>/'
  figdir <- file.path(dirname(mdfile), "fig", basename(xfun::with_ext(input, "")))

  # Ensure 'examples/' destination directory exists for the .md
  md_dir <- dirname(mdfile)
  if (!dir.exists(md_dir)) {
    dir.create(md_dir, recursive = TRUE, showWarnings = FALSE)
  }

  # Clean any previous temporary and destination figure folders
  unlink("figure", recursive = TRUE)   # knitr default temporary figure dir
  unlink(figdir, recursive = TRUE)     # destination for this document's figures

  # Knit Rmd -> md (knitr will write figures under './figure' by default)
  knit(input, mdfile)

  # Ensure destination 'fig' base folder exists before moving
  fig_base <- dirname(figdir) # '<md-dir>/fig'
  if (!dir.exists(fig_base)) {
    dir.create(fig_base, recursive = TRUE, showWarnings = FALSE)
  }

  # Move figures from './figure' to '<md-dir>/fig/<doc-basename>/' if they exist
  if (dir.exists("figure")) {
    file.rename("figure", figdir)
  }

  # Post-process the generated Markdown to update figure paths
  con_in <- file(mdfile, encoding = "UTF-8")
  on.exit(close(con_in), add = TRUE)
  data <- readLines(con_in)

  # Replace knitr's 'figure/' prefix with our final folder
  data <- gsub("figure/", sprintf("fig/%s/", basename(figdir)), data)

  con_out <- file(mdfile, encoding = "UTF-8")
  on.exit(close(con_out), add = TRUE)
  writeLines(data, con_out)

  # Optional: remove intermediate HTML if produced by other workflows
  # htmlfile <- xfun::with_ext(input, "html")
  # if (file.exists(htmlfile)) file.remove(htmlfile)

  # Ensure 'word/' destination directory exists for the .docx
  docx_dir <- dirname(docxfile)
  if (!dir.exists(docx_dir)) {
    dir.create(docx_dir, recursive = TRUE, showWarnings = FALSE)
  }

  # Additionally render Word document into the 'word/' destination
  # Use rmarkdown::render to produce .docx under word/
  rmarkdown::render(
    input,
    output_format = "word_document",
    output_file   = basename(docxfile),
    output_dir    = dirname(docxfile)
  )

  # Ensure 'examples-r/' destination directory exists and extract pure R code
  r_dir <- dirname(rfile)
  if (!dir.exists(r_dir)) {
    dir.create(r_dir, recursive = TRUE, showWarnings = FALSE)
  }
  knitr::purl(input, output = rfile, documentation = 0, quiet = TRUE)
}


# Root directory containing source Rmd files
dir <- "Rmd"

# Convert .ipynb -> .Rmd (disabled by default; enable by toggling to TRUE)
texs <- list.files(path = dir, pattern = ".ipynb$", full.names = TRUE, recursive = TRUE)
if (FALSE) {
  for (tex in texs) {
    print(tex)
    convert_ipynb_to_rmarkdown(tex)
  }
}

# Optionally remove original .ipynb after conversion (disabled by default)
if (FALSE) {
  for (tex in texs) {
    print(tex)
    delete_ipynb(tex)
  }
}

# Knit all .Rmd under 'Rmd/' to Markdown (enabled)
dir <- "Rmd"
texs <- list.files(path = dir, pattern = ".Rmd$", full.names = TRUE, recursive = TRUE)
if (TRUE) {
  for (tex in texs) {
    print(tex)
    convert_rmd_md(tex)
  }
}

# To-do checks (manual):
# - Search for '## Error' in outputs
# - Search for '## Error in install.packages : Updating loaded packages'
