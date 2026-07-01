testthat::test_that("command-line parser handles values and flags", {
  args <- parse_cli_args(c(
    "--duckdb_path=/tmp/test.duckdb",
    "--host", "0.0.0.0",
    "--flag"
  ))

  testthat::expect_equal(args$duckdb_path, "/tmp/test.duckdb")
  testthat::expect_equal(args$host, "0.0.0.0")
  testthat::expect_true(args$flag)
})

testthat::test_that("logical conversion handles common values", {
  testthat::expect_true(as_cli_logical("true"))
  testthat::expect_true(as_cli_logical("1"))
  testthat::expect_false(as_cli_logical("false"))
  testthat::expect_false(as_cli_logical("0"))
})

testthat::test_that("app config uses command-line values", {
  config <- get_app_config(c(
    "--duckdb_path=/tmp/example.duckdb",
    "--max_table_rows=123",
    "--default_expression_unit=FPKM"
  ))

  testthat::expect_equal(config$duckdb_path, "/tmp/example.duckdb")
  testthat::expect_equal(config$max_table_rows, 123L)
  testthat::expect_equal(config$default_expression_unit, "FPKM")
})
