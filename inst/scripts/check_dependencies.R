#!/usr/bin/env Rscript

required_packages <- c(
  "bslib",
  "dplyr",
  "DT",
  "duckplyr",
  "rlang",
  "shiny",
  "shinycssloaders",
  "stringr",
  "testthat",
  "tibble"
)

missing_packages <- required_packages[!vapply(
  X = required_packages,
  FUN = requireNamespace,
  FUN.VALUE = logical(1),
  quietly = TRUE
)]

if (length(missing_packages) > 0L) {
  stop(
    paste0(
      "Missing required R packages: ",
      paste(missing_packages, collapse = ", ")
    ),
    call. = FALSE
  )
}

message("All required R packages are available.")
