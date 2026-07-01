testthat::test_that("expression filters work on in-memory test data", {
  expr <- tibble::tibble(
    species_column = c("Zea_mays", "Zea_mays", "Arabidopsis_thaliana"),
    expression_unit = c("TPM", "FPKM", "TPM"),
    experiment_accession = c("E1", "E1", "E2"),
    organism_part = c("leaf", "leaf", "root"),
    developmental_stage = c("9 day", "9 day", "adult"),
    condition = c("leaf section 1", "leaf section 1", "control"),
    gene_id = c("Zm00001", "Zm00001", "AT1G01010"),
    gene_name = c("", "", "NAC001"),
    expression_value = c(5, 10, 1)
  )

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
})

testthat::test_that("display collection limits rows", {
  expr <- tibble::tibble(
    species_column = rep("Zea_mays", 3),
    experiment_accession = rep("E1", 3),
    gene_id = paste0("gene", 1:3),
    gene_name = rep("", 3),
    sample_or_condition = rep("g1", 3),
    organism_part = rep("leaf", 3),
    developmental_stage = rep("9 day", 3),
    cultivar = rep("B73", 3),
    genotype = rep("wild type genotype", 3),
    condition = rep("leaf section 1", 3),
    expression_value = c(1, 2, 3),
    expression_unit = rep("TPM", 3)
  )

  display <- collect_expression_display(
    filtered_table = expr,
    max_rows = 2L
  )

  testthat::expect_equal(nrow(display), 2L)
})
