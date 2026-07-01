#' Validate the DuckDB database path.
#'
#' Checks that the configured DuckDB file exists before the app starts.
#'
#' @param duckdb_path Path to the DuckDB database.
#' @return Invisibly returns TRUE.
validate_duckdb_path <- function(duckdb_path) {
  if (!file.exists(duckdb_path)) {
    stop(
      paste0(
        "DuckDB database was not found: ", duckdb_path,
        "\nSet E3_EXPRESSION_DUCKDB or pass --duckdb_path."
      ),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

#' Attach a DuckDB file to the duckplyr default connection.
#'
#' Attaches an existing DuckDB file under a stable alias. Existing aliases are
#' detached where possible, which helps during Shiny reloads.
#'
#' @param duckdb_path Path to the DuckDB database.
#' @param alias Alias used for the attachment.
#' @return The sanitised alias used for the attachment.
attach_expression_duckdb <- function(duckdb_path, alias = "expr_app") {
  validate_duckdb_path(duckdb_path = duckdb_path)

  safe_alias <- sanitise_duckdb_alias(alias = alias)
  safe_path <- escape_sql_literal(normalizePath(duckdb_path, mustWork = TRUE))

  detach_sql <- paste0("DETACH DATABASE IF EXISTS ", safe_alias)
  attach_sql <- paste0(
    "ATTACH DATABASE '", safe_path, "' AS ", safe_alias,
    " (READ_ONLY)"
  )

  try(duckplyr::db_exec(detach_sql), silent = TRUE)
  duckplyr::db_exec(attach_sql)

  safe_alias
}

#' Build a SELECT query for an attached DuckDB view.
#'
#' Builds a SQL query against the `main` schema of an attached DuckDB file.
#'
#' @param table_name View or table name.
#' @param alias Attached database alias.
#' @return SQL SELECT statement.
build_attached_view_query <- function(table_name, alias = "expr_app") {
  safe_alias <- sanitise_duckdb_alias(alias = alias)
  safe_table <- quote_duckdb_identifier(identifier = table_name)

  paste0("SELECT * FROM ", safe_alias, ".main.", safe_table)
}

#' Read an attached DuckDB view using duckplyr.
#'
#' Returns a lazy duckplyr frame. Data are not collected into R memory until
#' `collect()` is called downstream.
#'
#' @param table_name View or table name.
#' @param duckdb_path Path to the DuckDB database.
#' @param alias Attached database alias.
#' @return Lazy duckplyr data frame.
read_expression_view <- function(table_name, duckdb_path, alias = "expr_app") {
  attach_expression_duckdb(duckdb_path = duckdb_path, alias = alias)

  duckplyr::read_sql_duckdb(
    build_attached_view_query(table_name = table_name, alias = alias)
  )
}

#' Read expression with sample metadata.
#'
#' Reads the metadata-aware joined expression view from the DuckDB database.
#'
#' @param duckdb_path Path to the DuckDB database.
#' @return Lazy duckplyr data frame.
get_expression_with_metadata <- function(duckdb_path) {
  read_expression_view(
    table_name = "atlas_expression_with_sample_metadata",
    duckdb_path = duckdb_path
  )
}

#' Read expression sample metadata.
#'
#' Reads the joinable wide sample metadata view.
#'
#' @param duckdb_path Path to the DuckDB database.
#' @return Lazy duckplyr data frame.
get_sample_metadata <- function(duckdb_path) {
  read_expression_view(
    table_name = "atlas_sample_metadata_wide_joinable",
    duckdb_path = duckdb_path
  )
}

#' Read expression table without metadata.
#'
#' Reads the long expression table from the DuckDB database.
#'
#' @param duckdb_path Path to the DuckDB database.
#' @return Lazy duckplyr data frame.
get_expression_long <- function(duckdb_path) {
  read_expression_view(
    table_name = "atlas_expression_long",
    duckdb_path = duckdb_path
  )
}

#' Collect distinct values for a column.
#'
#' Collects distinct non-missing values from a lazy table. This is used to
#' populate filter controls.
#'
#' @param table Lazy table.
#' @param column_name Column name to collect.
#' @param limit Maximum number of values to return.
#' @return Character vector of values.
collect_distinct_values <- function(table, column_name, limit = 5000L) {
  column_symbol <- rlang::sym(column_name)

  values <- table |>
    dplyr::filter(!is.na(!!column_symbol)) |>
    dplyr::distinct(!!column_symbol) |>
    dplyr::arrange(!!column_symbol) |>
    head(limit) |>
    dplyr::collect()

  as.character(values[[column_name]])
}
