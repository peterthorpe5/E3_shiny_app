#' Expression table UI.
#'
#' Creates the filtered expression table panel.
#'
#' @param id Module identifier.
#' @return Shiny UI elements.
expression_table_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::p(
      "The table is row-limited for display. Filters are applied before data are collected."
    ),
    shinycssloaders::withSpinner(DT::DTOutput(ns("expression_table")))
  )
}

#' Expression table server.
#'
#' Collects a limited number of filtered rows for display.
#'
#' @param id Module identifier.
#' @param filtered_table Reactive returning a filtered lazy expression table.
#' @param max_rows Maximum rows collected for display.
#' @return No return value.
expression_table_server <- function(id, filtered_table, max_rows = 1000L) {
  shiny::moduleServer(id, function(input, output, session) {
    output$expression_table <- DT::renderDT({
      display_table <- collect_expression_display(
        filtered_table = filtered_table(),
        max_rows = max_rows
      )

      DT::datatable(
        display_table,
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
