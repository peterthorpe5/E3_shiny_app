#' Expression filter UI.
#'
#' Creates sidebar controls for filtering the expression table.
#'
#' @param id Module identifier.
#' @return Shiny UI elements.
expression_filters_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::selectInput(ns("species_column"), "Species", choices = "Loading..."),
    shiny::selectInput(ns("expression_unit"), "Expression unit", choices = c("TPM", "FPKM", "All")),
    shiny::selectInput(ns("experiment_accession"), "Experiment", choices = "All"),
    shiny::selectInput(ns("organism_part"), "Organism part", choices = "All"),
    shiny::selectInput(ns("developmental_stage"), "Developmental stage", choices = "All"),
    shiny::selectInput(ns("condition"), "Condition", choices = "All"),
    shiny::textInput(ns("gene_search"), "Gene ID / gene name contains", value = ""),
    shiny::numericInput(ns("minimum_expression"), "Minimum expression", value = 0, min = 0),
    shiny::actionButton(ns("apply_filters"), "Apply filters", class = "btn-primary")
  )
}

#' Expression filter server.
#'
#' Populates filter controls from the lazy expression table and returns a
#' reactive list of filter values when the user applies filters.
#'
#' @param id Module identifier.
#' @param expr_table Reactive returning lazy expression table.
#' @param default_expression_unit Default expression unit.
#' @return Reactive list of filter values.
expression_filters_server <- function(
  id,
  expr_table,
  default_expression_unit = "TPM"
) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::observeEvent(expr_table(), {
      table <- expr_table()

      species <- collect_distinct_values(table, "species_column")
      units <- collect_distinct_values(table, "expression_unit")

      shiny::updateSelectInput(
        session,
        "species_column",
        choices = c("All", species),
        selected = "All"
      )

      shiny::updateSelectInput(
        session,
        "expression_unit",
        choices = c(units, "All"),
        selected = default_expression_unit
      )
    }, once = TRUE)

    shiny::observeEvent(input$species_column, {
      req_table <- expr_table()
      table <- req_table

      if (!is.null(input$species_column) && input$species_column != "All") {
        table <- table |>
          dplyr::filter(.data$species_column == input$species_column)
      }

      experiments <- collect_distinct_values(table, "experiment_accession")
      organism_parts <- collect_distinct_values(table, "organism_part")
      stages <- collect_distinct_values(table, "developmental_stage")
      conditions <- collect_distinct_values(table, "condition")

      shiny::updateSelectInput(
        session,
        "experiment_accession",
        choices = c("All", experiments),
        selected = "All"
      )

      shiny::updateSelectInput(
        session,
        "organism_part",
        choices = c("All", organism_parts),
        selected = "All"
      )

      shiny::updateSelectInput(
        session,
        "developmental_stage",
        choices = c("All", stages),
        selected = "All"
      )

      shiny::updateSelectInput(
        session,
        "condition",
        choices = c("All", conditions),
        selected = "All"
      )
    }, ignoreInit = TRUE)

    # Store the eventReactive in a named object so it can be returned to
    # the main app and tested with shiny::testServer().
    filters <- shiny::eventReactive(input$apply_filters, {
      list(
        species_column = input$species_column,
        expression_unit = input$expression_unit,
        experiment_accession = input$experiment_accession,
        organism_part = input$organism_part,
        developmental_stage = input$developmental_stage,
        condition = input$condition,
        gene_search = input$gene_search,
        minimum_expression = input$minimum_expression
      )
    }, ignoreNULL = FALSE)

    filters
  })
}
