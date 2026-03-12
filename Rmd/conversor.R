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
log_dir <- file.path("examples", "logs")
if (!dir.exists(log_dir)) {
  dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
}
log_file <- file.path(log_dir, sprintf("conversion-%s.log", format(Sys.time(), "%Y%m%d-%H%M%S")))

append_log <- function(...) {
  cat(..., file = log_file, append = TRUE, sep = "")
}

format_calls <- function(calls) {
  if (length(calls) == 0) {
    return("<no call stack available>")
  }
  lines <- vapply(seq_along(calls), function(i) {
    call_txt <- paste(deparse(calls[[i]]), collapse = " ")
    sprintf("%03d: %s", i, call_txt)
  }, character(1))
  paste(lines, collapse = "\n")
}

record_condition <- function(phase, input, err) {
  append_log(
    "\n",
    strrep("=", 80), "\n",
    sprintf("[%s] %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), phase),
    sprintf("file: %s\n", input),
    sprintf("message: %s\n", conditionMessage(err)),
    sprintf("call: %s\n", paste(deparse(conditionCall(err)), collapse = " ")),
    "stack:\n",
    format_calls(sys.calls()), "\n"
  )
}

run_phase <- function(inputs, phase, converter) {
  results <- vector("list", length(inputs))
  names(results) <- inputs

  for (i in seq_along(inputs)) {
    input <- inputs[[i]]
    print(sprintf("[%s] %s", phase, input))

    result <- tryCatch({
      converter(input)
      list(ok = TRUE, input = input, phase = phase, message = NULL)
    }, error = function(err) {
      record_condition(phase, input, err)
      list(ok = FALSE, input = input, phase = phase, message = conditionMessage(err))
    })

    results[[i]] <- result
  }

  results
}

summarize_phase <- function(results, phase) {
  ok <- sum(vapply(results, function(x) isTRUE(x$ok), logical(1)))
  fail <- length(results) - ok
  cat(sprintf("[%s] ok=%d fail=%d\n", phase, ok, fail))
  invisible(list(ok = ok, fail = fail))
}

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

# Normalize the relative path under 'Rmd/' so that:
# - every regular subfolder becomes a subfolder under 'examples/'
# - the special leading folder 'examples/' is dropped to avoid
#   creating 'examples/examples/...'
normalize_examples_rel <- function(path) {
  rel <- gsub("^Rmd/", "", path)
  rel <- gsub("^examples/", "", rel)
  rel
}

# Build output paths for a source .Rmd
build_output_paths <- function(input) {
  rel_input      <- normalize_examples_rel(input)
  rel_md         <- xfun::with_ext(rel_input, "md")
  rel_dir        <- dirname(rel_md)
  base_filename  <- xfun::sans_ext(basename(rel_md))
  mdfile         <- file.path("examples", rel_md)
  base_out_dir   <- if (rel_dir == ".") "examples" else file.path("examples", rel_dir)
  docxfile       <- file.path(base_out_dir, "doc", paste0(base_filename, ".docx"))
  rfile          <- file.path(base_out_dir, "r", paste0(base_filename, ".R"))
  figdir         <- file.path(dirname(mdfile), "fig", base_filename)

  list(
    mdfile = mdfile,
    docxfile = docxfile,
    rfile = rfile,
    figdir = figdir
  )
}

# Knit an .Rmd to .md under 'examples/' and relocate figures to
# '<examples-subdir>/fig/<doc-basename>/'.
convert_rmd_md <- function(input) {
  # Require needed packages; keep behavior consistent with original
  if (!require("rmarkdown")) return("Missing necessary package: 'rmarkdown'")
  if (!require("markdown"))  return("Missing necessary package: 'markdown'")
  if (!require("knitr"))     return("Missing necessary package: 'knitr'")

  # Validate extension
  if (tolower(xfun::file_ext(input)) != "rmd") {
    return("Error: Invalid file format")
  }

  paths  <- build_output_paths(input)
  mdfile <- paths$mdfile
  figdir <- paths$figdir

  # Ensure 'examples/' destination directory exists for the .md
  md_dir <- dirname(mdfile)
  if (!dir.exists(md_dir)) {
    dir.create(md_dir, recursive = TRUE, showWarnings = FALSE)
  }

  # Clean any previous temporary and destination figure folders
  unlink("figure", recursive = TRUE)   # knitr default temporary figure dir
  unlink(figdir, recursive = TRUE)     # destination for this document's figures
  
  # Ensure destination 'fig' base folder exists before moving
  fig_base <- dirname(figdir) # '<md-dir>/fig'
  if (!dir.exists(fig_base)) {
    dir.create(fig_base, recursive = TRUE, showWarnings = FALSE)
  }

  # Knit Rmd -> md (knitr will write figures under './figure' by default)
  knit(input, mdfile)

  # Move figures from './figure' to '<md-dir>/fig/<doc-basename>/' if they exist
  if (dir.exists("figure")) {
    file.rename("figure", figdir)
  }

  # Also handle figures created under the Rmd's directory (non-recursive)
  rmd_fig <- file.path(dirname(input), "figure")
  if (dir.exists(rmd_fig)) {
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
}

# Render an .Rmd to .docx under 'examples/<subdir>/doc/'.
convert_rmd_docx <- function(input) {
  if (!require("rmarkdown")) return("Missing necessary package: 'rmarkdown'")

  if (tolower(xfun::file_ext(input)) != "rmd") {
    return("Error: Invalid file format")
  }

  paths <- build_output_paths(input)
  docxfile <- paths$docxfile
  docx_dir <- dirname(docxfile)
  if (!dir.exists(docx_dir)) {
    dir.create(docx_dir, recursive = TRUE, showWarnings = FALSE)
  }

  rmarkdown::render(
    input,
    output_format = "word_document",
    output_file   = basename(docxfile),
    output_dir    = dirname(docxfile)
  )
}

# Extract a pure .R script under 'examples/<subdir>/r/'.
convert_rmd_r <- function(input) {
  if (!require("knitr")) return("Missing necessary package: 'knitr'")

  if (tolower(xfun::file_ext(input)) != "rmd") {
    return("Error: Invalid file format")
  }

  paths <- build_output_paths(input)
  rfile <- paths$rfile
  if (basename(rfile) == "README.R") {
    return(invisible(NULL))
  }
  r_dir <- dirname(rfile)
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

# Convert all .Rmd under 'Rmd/' in phases:
# 1. generate all Markdown files
# 2. generate all Word files
# 3. generate all extracted R scripts
texs <- list.files(path = dir, pattern = ".Rmd$", full.names = TRUE, recursive = TRUE)
if (TRUE) {
  append_log(sprintf("Conversion run started at %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
  append_log(sprintf("Working directory: %s\n", normalizePath(getwd(), winslash = "/")))

  md_results <- run_phase(texs, "rmd->md", convert_rmd_md)
  docx_results <- run_phase(texs, "rmd->docx", convert_rmd_docx)
  r_results <- run_phase(texs, "rmd->r", convert_rmd_r)

  md_summary <- summarize_phase(md_results, "rmd->md")
  docx_summary <- summarize_phase(docx_results, "rmd->docx")
  r_summary <- summarize_phase(r_results, "rmd->r")

  total_fail <- md_summary$fail + docx_summary$fail + r_summary$fail
  if (total_fail > 0) {
    cat(sprintf("Conversion finished with failures. Log: %s\n", log_file))
  } else {
    cat("Conversion finished without failures.\n")
  }
}

# To-do checks (manual):
# - Search for '## Error' in outputs
# - Search for '## Error in install.packages : Updating loaded packages'
