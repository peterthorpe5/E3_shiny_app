#' Gene lookup UI.
#'
#' Creates a compact gene lookup panel.
#'
#' @param id Module identifier.
#' @return Shiny UI elements.
gene_lookup_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::textInput(ns("gene_query"), "Gene ID or gene name", value = ""),
    shiny::selectInput(ns("unit"), "Expression unit", choices = c("TPM", "FPKM"), selected = "TPM"),
    shiny::actionButton(ns("lookup"), "Lookup gene", class = "btn-secondary"),
    shinycssloaders::withSpinner(DT::DTOutput(ns("gene_table")))
  )
}

#' Gene lookup server.
#'
#' Performs a simple cross-species gene lookup against the expression table.
#'
#' @param id Module identifier.
#' @param expr_table Reactive returning lazy expression table.
#' @param max_rows Maximum rows collected for display.
#' @return No return value.
gene_lookup_server <- function(id, expr_table, max_rows = 1000L) {
  shiny::moduleServer(id, function(input, output, session) {
    lookup_table <- shiny::eventReactive(input$lookup, {
      shiny::req(input$gene_query)

      query_value <- paste0("%", trimws(input$gene_query), "%")

      expr_table() |>
        dplyr::filter(.data$expression_unit == input$unit) |>
        dplyr::filter(
          stringr::str_like(.data$gene_id, query_value) |
            stringr::str_like(.data$gene_name, query_value)
        ) |>
        dplyr::select(
          .data$species_column,
          .data$experiment_accession,
          .data$gene_id,
          .data$gene_name,
          .data$sample_or_condition,
          .data$organism_part,
          .data$developmental_stage,
          .data$condition,
          .data$expression_value,
          .data$expression_unit
        ) |>
        head(max_rows) |>
        dplyr::collect()
    }, ignoreNULL = FALSE)

    output$gene_table <- DT::renderDT({
      DT::datatable(
        lookup_table(),
        rownames = FALSE,
        filter = "top",
        options = list(
          pageLength = 25,
          scrollX = TRUE,
          deferRender = TRUE
        )
      )
    })
  })
}
