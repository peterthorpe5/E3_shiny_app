#' Expression summary UI.
#'
#' Creates summary cards for the filtered expression table.
#'
#' @param id Module identifier.
#' @return Shiny UI elements.
expression_summary_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    bslib::layout_columns(
      bslib::value_box("Rows", shiny::textOutput(ns("row_count"))),
      bslib::value_box("Genes", shiny::textOutput(ns("gene_count"))),
      bslib::value_box("Experiments", shiny::textOutput(ns("experiment_count"))),
      bslib::value_box("Groups", shiny::textOutput(ns("group_count")))
    ),
    shiny::h4("Metadata coverage"),
    DT::DTOutput(ns("metadata_coverage"))
  )
}

#' Expression summary server.
#'
#' Computes small summaries from a filtered lazy expression table.
#'
#' @param id Module identifier.
#' @param filtered_table Reactive returning a filtered lazy expression table.
#' @return No return value.
expression_summary_server <- function(id, filtered_table) {
  shiny::moduleServer(id, function(input, output, session) {
    summary_table <- shiny::reactive({
      summarise_expression_selection(filtered_table())
    })

    coverage_table <- shiny::reactive({
      summarise_metadata_coverage(filtered_table())
    })

    output$row_count <- shiny::renderText({
      format(summary_table()$rows[[1]], big.mark = ",")
    })

    output$gene_count <- shiny::renderText({
      format(summary_table()$genes[[1]], big.mark = ",")
    })

    output$experiment_count <- shiny::renderText({
      format(summary_table()$experiments[[1]], big.mark = ",")
    })

    output$group_count <- shiny::renderText({
      format(summary_table()$groups[[1]], big.mark = ",")
    })

    output$metadata_coverage <- DT::renderDT({
      DT::datatable(
        coverage_table(),
        rownames = FALSE,
        options = list(dom = "t", paging = FALSE)
      )
    })
  })
}
