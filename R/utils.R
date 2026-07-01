#' Convert a character value to logical.
#'
#' Converts common command-line and environment variable strings to logical
#' values. Missing or empty values return the supplied default.
#'
#' @param value Character value to convert.
#' @param default Logical value returned for missing or empty input.
#' @return A logical value.
as_cli_logical <- function(value, default = FALSE) {
  if (is.null(value) || length(value) == 0L || is.na(value) || value == "") {
    return(default)
  }

  normalised_value <- tolower(trimws(as.character(value)))

  if (normalised_value %in% c("true", "t", "1", "yes", "y")) {
    return(TRUE)
  }

  if (normalised_value %in% c("false", "f", "0", "no", "n")) {
    return(FALSE)
  }

  stop(
    sprintf("Could not convert '%s' to logical", value),
    call. = FALSE
  )
}

#' Escape a SQL string literal.
#'
#' Escapes single quotes in a character value for safe use in simple SQL strings.
#' This helper is used only for internally generated file paths and aliases.
#'
#' @param value Character value to escape.
#' @return Escaped character value.
escape_sql_literal <- function(value) {
  gsub("'", "''", value, fixed = TRUE)
}

#' Quote a DuckDB identifier.
#'
#' Quotes a schema, table, or column name for DuckDB SQL.
#'
#' @param identifier Identifier to quote.
#' @return Quoted identifier.
quote_duckdb_identifier <- function(identifier) {
  escaped_identifier <- gsub('"', '""', identifier, fixed = TRUE)
  paste0('"', escaped_identifier, '"')
}

#' Create a DuckDB-safe alias.
#'
#' Converts arbitrary text to a simple identifier suitable for a DuckDB database
#' attachment alias.
#'
#' @param alias Input alias.
#' @return Sanitised alias.
sanitise_duckdb_alias <- function(alias) {
  alias <- gsub("[^A-Za-z0-9_]", "_", alias)

  if (!grepl("^[A-Za-z_]", alias)) {
    alias <- paste0("db_", alias)
  }

  alias
}
