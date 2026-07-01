#' Parse simple command-line arguments.
#'
#' Parses arguments of the form `--name=value` or `--flag value` into a named
#' list. Boolean flags without a value are returned as TRUE.
#'
#' @param args Character vector of command-line arguments.
#' @return Named list of parsed values.
parse_cli_args <- function(args = commandArgs(trailingOnly = TRUE)) {
  parsed_args <- list()
  index <- 1L

  while (index <= length(args)) {
    current_arg <- args[[index]]

    if (!startsWith(current_arg, "--")) {
      stop(
        sprintf("Unexpected positional argument: %s", current_arg),
        call. = FALSE
      )
    }

    stripped_arg <- sub("^--", "", current_arg)

    if (grepl("=", stripped_arg, fixed = TRUE)) {
      key <- sub("=.*$", "", stripped_arg)
      value <- sub("^[^=]*=", "", stripped_arg)
      parsed_args[[key]] <- value
      index <- index + 1L
      next
    }

    key <- stripped_arg
    next_index <- index + 1L

    if (next_index <= length(args) && !startsWith(args[[next_index]], "--")) {
      parsed_args[[key]] <- args[[next_index]]
      index <- index + 2L
    } else {
      parsed_args[[key]] <- TRUE
      index <- index + 1L
    }
  }

  parsed_args
}

#' Get the app configuration.
#'
#' Builds a simple app configuration list from defaults, environment variables
#' and optional command-line arguments.
#'
#' @param args Character vector of command-line arguments.
#' @return Named list containing app configuration values.
get_app_config <- function(args = commandArgs(trailingOnly = TRUE)) {
  parsed_args <- parse_cli_args(args = args)

  default_duckdb_path <- paste0(
    "/home/pthorpe001/data/2026_E3_protac/analysis/",
    "expression_atlas_ftp_full/e3_expression.duckdb"
  )

  duckdb_path <- parsed_args$duckdb_path %||%
    Sys.getenv("E3_EXPRESSION_DUCKDB", unset = default_duckdb_path)

  max_table_rows <- as.integer(
    parsed_args$max_table_rows %||%
      Sys.getenv("E3_MAX_TABLE_ROWS", unset = "1000")
  )

  list(
    duckdb_path = duckdb_path,
    max_table_rows = max_table_rows,
    default_expression_unit = parsed_args$default_expression_unit %||%
      Sys.getenv("E3_DEFAULT_EXPRESSION_UNIT", unset = "TPM"),
    host = parsed_args$host %||% Sys.getenv("E3_SHINY_HOST", unset = "127.0.0.1"),
    port = as.integer(parsed_args$port %||% Sys.getenv("E3_SHINY_PORT", unset = "0"))
  )
}

#' Null coalescing operator.
#'
#' Returns `x` unless it is NULL, otherwise returns `y`.
#'
#' @param x Primary value.
#' @param y Fallback value.
#' @return `x` or `y`.
`%||%` <- function(x, y) {
  if (is.null(x)) {
    return(y)
  }

  x
}
