#!/usr/bin/env Rscript

repo_dir <- normalizePath(file.path(dirname(sys.frame(1)$ofile), "../.."), mustWork = TRUE)
setwd(repo_dir)

testthat::test_dir("tests/testthat")
