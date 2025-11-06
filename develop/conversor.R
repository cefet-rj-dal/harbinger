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

# Root directory containing source Rmd files
dir <- "Rmd"

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
# '<examples-subdir>/fig/<doc-basename>/', render a Word (.docx) under
# 'examples/<folder>/doc/', and also extract a pure R script under
# 'examples/<folder>/r/'.
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

  # Output Word and R script paths go under per-folder destinations:
  # - Word: examples/<folder>/doc/<name>.docx
  # - R:    examples/<folder>/r/<name>.R
  # Determine the immediate folder under 'Rmd/' and base output dir
  folder        <- basename(dirname(input))
  base_out_dir  <- file.path("examples", folder)
  base_filename <- xfun::sans_ext(basename(input))

  docxfile <- file.path(base_out_dir, "doc", paste0(base_filename, ".docx"))
  rfile    <- file.path(base_out_dir, "r",   paste0(base_filename, ".R"))

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

  # Also handle figures created under the Rmd's directory (non-recursive)
  rmd_fig <- file.path(dirname(input), "figure")
  if (dir.exists(rmd_fig)) {
    if (!dir.exists(figdir)) {
      dir.create(figdir, recursive = TRUE, showWarnings = FALSE)
    }
    figs <- list.files(rmd_fig, full.names = TRUE, recursive = FALSE, include.dirs = FALSE)
    if (length(figs) > 0) {
      file.rename(figs, file.path(figdir, basename(figs)))
    }
    unlink(rmd_fig, recursive = TRUE)
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

  # Ensure per-folder 'doc/' destination directory exists for the .docx
  docx_dir <- dirname(docxfile) # 'examples/<folder>/doc'
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

  # Ensure per-folder 'r/' destination directory exists and extract pure R code
  r_dir <- dirname(rfile) # 'examples/<folder>/r'
  if (!dir.exists(r_dir)) {
    dir.create(r_dir, recursive = TRUE, showWarnings = FALSE)
  }
  knitr::purl(input, output = rfile, documentation = 0, quiet = TRUE)
}



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
