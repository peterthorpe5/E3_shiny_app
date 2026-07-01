testthat::test_that("validate_duckdb_path accepts existing files and rejects missing files", {
  existing_file <- tempfile(fileext = ".duckdb")
  missing_file <- tempfile(fileext = ".duckdb")
  writeLines("placeholder", existing_file)

  testthat::expect_true(validate_duckdb_path(existing_file))
  testthat::expect_error(validate_duckdb_path(missing_file), "DuckDB database was not found")
})

testthat::test_that("attached view SQL uses a sanitised alias and main schema", {
  query <- build_attached_view_query(
    table_name = "atlas_expression_long",
    alias = "expr-app"
  )

  testthat::expect_equal(
    query,
    'SELECT * FROM expr_app.main."atlas_expression_long"'
  )
})

testthat::test_that("collect_distinct_values returns sorted non-missing values", {
  values <- collect_distinct_values(
    table = tibble::tibble(species_column = c("Zea_mays", NA, "Arabidopsis_thaliana", "Zea_mays")),
    column_name = "species_column"
  )

  testthat::expect_equal(values, c("Arabidopsis_thaliana", "Zea_mays"))
})

testthat::test_that("DuckDB reader wrappers query expected views", {
  testthat::skip_if_not_installed("DBI")
  testthat::skip_if_not_installed("duckdb")
  testthat::skip_if_not_installed("duckplyr")

  duckdb_path <- tempfile(fileext = ".duckdb")
  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = duckdb_path, read_only = FALSE)

  DBI::dbExecute(
    con,
    "CREATE TABLE atlas_expression_long AS
     SELECT 'Zea_mays' AS species_column,
            'TPM' AS expression_unit,
            'E1' AS experiment_accession,
            'Zm00001' AS gene_id,
            '' AS gene_name,
            'g1' AS sample_or_condition,
            5.0 AS expression_value"
  )

  DBI::dbExecute(
    con,
    "CREATE VIEW atlas_expression_with_sample_metadata AS
     SELECT *, 'leaf' AS organism_part, '9 day' AS developmental_stage,
            'leaf section 1' AS condition
     FROM atlas_expression_long"
  )

  DBI::dbExecute(
    con,
    "CREATE VIEW atlas_sample_metadata_wide_joinable AS
     SELECT 'Zea_mays' AS species_column,
            'E1' AS experiment_accession,
            'g1' AS sample_or_condition,
            'leaf' AS organism_part"
  )

  DBI::dbDisconnect(con, shutdown = TRUE)

  expr <- get_expression_long(duckdb_path = duckdb_path) |>
    dplyr::collect()
  expr_meta <- get_expression_with_metadata(duckdb_path = duckdb_path) |>
    dplyr::collect()
  meta <- get_sample_metadata(duckdb_path = duckdb_path) |>
    dplyr::collect()

  testthat::expect_equal(expr$species_column[[1]], "Zea_mays")
  testthat::expect_equal(expr_meta$organism_part[[1]], "leaf")
  testthat::expect_equal(meta$sample_or_condition[[1]], "g1")
})
