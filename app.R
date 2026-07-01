# Standalone Shiny app entry point.
#
# This app is deliberately thin: all large data access is pushed through
# duckplyr/DuckDB views, filters are applied lazily, and only bounded result
# tables are collected for display. Keep it this way as new project modules are
# added; the app should orchestrate queries rather than perform heavy imports.

library(bslib)
library(dplyr)
library(DT)
library(duckplyr)
library(shiny)
library(shinycssloaders)
library(stringr)

source("R/utils.R")
source("R/app_config.R")
source("R/data_sources.R")
source("R/query_helpers.R")
source("R/module_expression_filters.R")
source("R/module_expression_summary.R")
source("R/module_expression_table.R")
source("R/module_gene_lookup.R")

# Configuration can come from command-line arguments, environment variables, or
# defaults. See README.md for the supported options.
app_config <- get_app_config(args = commandArgs(trailingOnly = TRUE))

ui <- bslib::page_sidebar(
  title = "E3 Expression Explorer",
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly"),
  sidebar = bslib::sidebar(
    shiny::h4("Expression filters"),
    expression_filters_ui("filters"),
    width = 360
  ),
  shiny::includeCSS("www/app.css"),
  bslib::navset_card_tab(
    bslib::nav_panel(
      "Summary",
      expression_summary_ui("summary")
    ),
    bslib::nav_panel(
      "Expression table",
      expression_table_ui("table")
    ),
    bslib::nav_panel(
      "Gene lookup",
      gene_lookup_ui("gene_lookup")
    ),
    bslib::nav_panel(
      "About",
      shiny::h3("About this app"),
      shiny::p(
        "This app queries Expression Atlas-derived expression and sample metadata ",
        "from DuckDB-backed views produced by the E3 expression downloader pipeline."
      ),
      shiny::p(
        "The app is modular so additional project tables can be added later, ",
        "including E3 ligases, HOGs, identifier aliases, domains, and ",
        "structural/ligandability outputs."
      )
    )
  )
)

server <- function(input, output, session) {
  # Filters are collected as ordinary scalar values.  Summary, table, and gene
  # lookup modules turn those values into SQL and let DuckDB do the heavy work.
  filters <- expression_filters_server(
    id = "filters",
    duckdb_path = app_config$duckdb_path,
    default_expression_unit = app_config$default_expression_unit
  )

  expression_summary_server(
    id = "summary",
    duckdb_path = app_config$duckdb_path,
    filters = filters
  )

  expression_table_server(
    id = "table",
    duckdb_path = app_config$duckdb_path,
    filters = filters,
    max_rows = app_config$max_table_rows
  )

  gene_lookup_server(
    id = "gene_lookup",
    duckdb_path = app_config$duckdb_path,
    max_rows = app_config$max_table_rows
  )
}

shiny::shinyApp(ui = ui, server = server)
