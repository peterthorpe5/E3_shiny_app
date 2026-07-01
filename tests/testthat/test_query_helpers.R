testthat::test_that("expression filters apply species, unit, metadata and expression thresholds", {
  expr <- make_test_expression_tbl()

  filtered <- apply_expression_filters(
    expr_table = expr,
    filters = list(
      species_column = "Zea_mays",
      expression_unit = "TPM",
      experiment_accession = "All",
      organism_part = "leaf",
      developmental_stage = "All",
      condition = "All",
      minimum_expression = 2,
      gene_search = "Zm"
    )
  )

  testthat::expect_equal(nrow(filtered), 1L)
  testthat::expect_equal(filtered$expression_unit, "TPM")
  testthat::expect_equal(filtered$organism_part, "leaf")
})

testthat::test_that("expression filters allow All values to pass through", {
  expr <- make_test_expression_tbl()

  filtered <- apply_expression_filters(
    expr_table = expr,
    filters = list(
      species_column = "All",
      expression_unit = "All",
      experiment_accession = "All",
      organism_part = "All",
      developmental_stage = "All",
      condition = "All",
      minimum_expression = NA_real_,
      gene_search = ""
    )
  )

  testthat::expect_equal(nrow(filtered), nrow(expr))
})

testthat::test_that("gene search matches gene IDs and gene names", {
  expr <- make_test_expression_tbl()

  by_id <- apply_expression_filters(
    expr_table = expr,
    filters = list(gene_search = "Zm00002")
  )

  by_name <- apply_expression_filters(
    expr_table = expr,
    filters = list(gene_search = "NAC")
  )

  testthat::expect_equal(by_id$gene_id, "Zm00002")
  testthat::expect_equal(by_name$gene_name, "NAC001")
})

testthat::test_that("expression selection summary counts rows, genes, experiments and groups", {
  summary <- summarise_expression_selection(make_test_expression_tbl())

  testthat::expect_equal(summary$rows, 4L)
  testthat::expect_equal(summary$genes, 3L)
  testthat::expect_equal(summary$experiments, 3L)
  testthat::expect_equal(summary$groups, 2L)
})

testthat::test_that("display collection keeps expected columns and limits rows", {
  display <- collect_expression_display(
    filtered_table = make_test_expression_tbl(),
    max_rows = 2L
  )

  testthat::expect_equal(nrow(display), 2L)
  testthat::expect_true("species_column" %in% names(display))
  testthat::expect_true("expression_value" %in% names(display))
})

testthat::test_that("metadata coverage summary counts non-missing metadata", {
  coverage <- summarise_metadata_coverage(make_test_expression_tbl())

  testthat::expect_equal(coverage$rows, 4L)
  testthat::expect_equal(coverage$rows_with_organism_part, 3)
  testthat::expect_equal(coverage$rows_with_developmental_stage, 3)
  testthat::expect_equal(coverage$rows_with_condition, 3)
})
