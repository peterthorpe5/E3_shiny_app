testthat::test_that("expression filter server returns applied filter values", {
  testthat::skip_if_not_installed("shiny")

  shiny::testServer(
    app = expression_filters_server,
    args = list(
      expr_table = shiny::reactive(make_test_expression_tbl()),
      default_expression_unit = "TPM"
    ),
    {
      session$setInputs(
        species_column = "Zea_mays",
        expression_unit = "TPM",
        experiment_accession = "E1",
        organism_part = "leaf",
        developmental_stage = "9 day",
        condition = "leaf section 1",
        gene_search = "Zm",
        minimum_expression = 2,
        apply_filters = 1
      )

      testthat::expect_equal(filters()$species_column, "Zea_mays")
      testthat::expect_equal(filters()$expression_unit, "TPM")
      testthat::expect_equal(filters()$minimum_expression, 2)
    }
  )
})

testthat::test_that("expression summary server renders numeric summaries", {
  testthat::skip_if_not_installed("shiny")

  shiny::testServer(
    app = expression_summary_server,
    args = list(filtered_table = shiny::reactive(make_test_expression_tbl())),
    {
      testthat::expect_equal(output$row_count, "4")
      testthat::expect_equal(output$gene_count, "3")
      testthat::expect_equal(output$experiment_count, "3")
      testthat::expect_equal(output$group_count, "2")
    }
  )
})

testthat::test_that("expression table server renders a DT object", {
  testthat::skip_if_not_installed("shiny")
  testthat::skip_if_not_installed("DT")

  shiny::testServer(
    app = expression_table_server,
    args = list(
      filtered_table = shiny::reactive(make_test_expression_tbl()),
      max_rows = 2L
    ),
    {
      testthat::expect_error(output$expression_table, NA)
    }
  )
})

testthat::test_that("gene lookup server returns matching gene rows", {
  testthat::skip_if_not_installed("shiny")
  testthat::skip_if_not_installed("DT")

  shiny::testServer(
    app = gene_lookup_server,
    args = list(
      expr_table = shiny::reactive(make_test_expression_tbl()),
      max_rows = 10L
    ),
    {
      session$setInputs(gene_query = "NAC", unit = "TPM", lookup = 1)
      testthat::expect_error(output$gene_table, NA)
    }
  )
})
