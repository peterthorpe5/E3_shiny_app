#' Apply expression filters.
#'
#' Applies Shiny input filters to a lazy expression table. Collection is not
#' performed here.
#'
#' @param expr_table Lazy expression table.
#' @param filters Named list of filter values.
#' @return Filtered lazy table.
apply_expression_filters <- function(expr_table, filters) {
  filtered_table <- expr_table

  if (!is.null(filters$species_column) && filters$species_column != "All") {
    filtered_table <- filtered_table |>
      dplyr::filter(.data$species_column == filters$species_column)
  }

  if (!is.null(filters$expression_unit) && filters$expression_unit != "All") {
    filtered_table <- filtered_table |>
      dplyr::filter(.data$expression_unit == filters$expression_unit)
  }

  if (!is.null(filters$experiment_accession) && filters$experiment_accession != "All") {
    filtered_table <- filtered_table |>
      dplyr::filter(.data$experiment_accession == filters$experiment_accession)
  }

  if (!is.null(filters$organism_part) && filters$organism_part != "All") {
    filtered_table <- filtered_table |>
      dplyr::filter(.data$organism_part == filters$organism_part)
  }

  if (!is.null(filters$developmental_stage) && filters$developmental_stage != "All") {
    filtered_table <- filtered_table |>
      dplyr::filter(.data$developmental_stage == filters$developmental_stage)
  }

  if (!is.null(filters$condition) && filters$condition != "All") {
    filtered_table <- filtered_table |>
      dplyr::filter(.data$condition == filters$condition)
  }

  if (!is.null(filters$minimum_expression) && !is.na(filters$minimum_expression)) {
    filtered_table <- filtered_table |>
      dplyr::filter(.data$expression_value >= filters$minimum_expression)
  }

  if (!is.null(filters$gene_search) && nzchar(trimws(filters$gene_search))) {
    search_value <- paste0("%", trimws(filters$gene_search), "%")

    filtered_table <- filtered_table |>
      dplyr::filter(
        stringr::str_like(.data$gene_id, search_value) |
          stringr::str_like(.data$gene_name, search_value)
      )
  }

  filtered_table
}

#' Summarise a filtered expression table.
#'
#' Builds a small summary from a filtered lazy expression table.
#'
#' @param filtered_table Filtered lazy expression table.
#' @return Tibble summary after collection.
summarise_expression_selection <- function(filtered_table) {
  filtered_table |>
    dplyr::summarise(
      rows = dplyr::n(),
      genes = dplyr::n_distinct(.data$gene_id),
      experiments = dplyr::n_distinct(.data$experiment_accession),
      groups = dplyr::n_distinct(.data$sample_or_condition),
      .groups = "drop"
    ) |>
    dplyr::collect()
}

#' Collect a limited expression table for display.
#'
#' Selects useful columns and collects only a bounded number of rows for display.
#'
#' @param filtered_table Filtered lazy expression table.
#' @param max_rows Maximum number of rows to collect.
#' @return Collected tibble.
collect_expression_display <- function(filtered_table, max_rows = 1000L) {
  filtered_table |>
    dplyr::select(
      .data$species_column,
      .data$experiment_accession,
      .data$gene_id,
      .data$gene_name,
      .data$sample_or_condition,
      .data$organism_part,
      .data$developmental_stage,
      .data$cultivar,
      .data$genotype,
      .data$condition,
      .data$expression_value,
      .data$expression_unit
    ) |>
    head(max_rows) |>
    dplyr::collect()
}

#' Build metadata coverage summary.
#'
#' Summarises how much metadata is available after filtering.
#'
#' @param filtered_table Filtered lazy expression table.
#' @return Collected tibble with coverage counts.
summarise_metadata_coverage <- function(filtered_table) {
  filtered_table |>
    dplyr::summarise(
      rows = dplyr::n(),
      rows_with_organism_part = sum(!is.na(.data$organism_part)),
      rows_with_developmental_stage = sum(!is.na(.data$developmental_stage)),
      rows_with_condition = sum(!is.na(.data$condition)),
      .groups = "drop"
    ) |>
    dplyr::collect()
}
