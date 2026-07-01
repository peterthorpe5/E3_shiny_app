#!/usr/bin/env Rscript

repo_dir <- normalizePath(file.path(dirname(sys.frame(1)$ofile), "../.."), mustWork = TRUE)
setwd(repo_dir)

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
message("DuckDB path: ", app_config$duckdb_path)
message("Host: ", shiny_args$host %||% "default")
message("Port: ", shiny_args$port %||% "default")

do.call(shiny::runApp, shiny_args)
