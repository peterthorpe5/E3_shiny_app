# Utility helpers for command-line scripts.

#' Find the path of the currently running Rscript file.
#'
#' Rscript exposes the script path through a `--file=` command argument. This is
#' more reliable than using `sys.frame()` and works from package source trees,
#' installed packages, and copied repositories.
#'
#' @return Normalised path to the current script.
get_current_script_path <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)

  if (length(file_arg) > 0L) {
    script_path <- sub("^--file=", "", file_arg[[1L]])
    return(normalizePath(script_path, mustWork = TRUE))
  }

  stop(
    "Could not determine the running script path. Run this script with Rscript.",
    call. = FALSE
  )
}

#' Find the repository root from a script inside inst/scripts.
#'
#' @return Normalised repository root path.
get_repo_dir_from_script <- function() {
  script_path <- get_current_script_path()
  normalizePath(file.path(dirname(script_path), "../.."), mustWork = TRUE)
}
