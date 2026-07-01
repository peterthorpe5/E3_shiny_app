#!/usr/bin/env Rscript

source(file.path(dirname(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[[1L]]), mustWork = TRUE)), "script_utils.R"))

repo_dir <- get_repo_dir_from_script()
setwd(repo_dir)

testthat::test_dir("tests/testthat")
