#!/usr/bin/env Rscript

# Launch the Shiny app from the source repository. Command-line arguments are
# parsed by R/app_config.R, so the same script can be used locally, on a cluster
# login node with SSH tunnelling, or against a copied DuckDB/Parquet dataset.

source(file.path(dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[[1L]]), mustWork = TRUE)), "script_utils.R"))

repo_dir <- get_repo_dir_from_script()
setwd(repo_dir)

# These source calls keep the script useful even when the package has not yet
# been installed after local edits.
source("R/utils.R")
source("R/app_config.R")

app_config <- get_app_config(args = commandArgs(trailingOnly = TRUE))

shiny_args <- list(
  appDir = repo_dir,
  launch.browser = FALSE
)

if (!is.na(app_config$port) && app_config$port > 0L) {
  shiny_args$port <- app_config$port
}

if (!is.null(app_config$host) && nzchar(app_config$host)) {
  shiny_args$host <- app_config$host
}

message("Starting E3 Expression Shiny app")
message("Repository: ", repo_dir)
message("DuckDB path: ", app_config$duckdb_path)
message("Host: ", shiny_args$host %||% "default")
message("Port: ", shiny_args$port %||% "default")

do.call(shiny::runApp, shiny_args)
