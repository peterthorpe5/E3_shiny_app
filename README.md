# E3 Expression Shiny app

This repository contains a standalone Shiny application for exploring the
Expression Atlas-derived expression layer produced by the E3 expression
downloader pipeline.

The app is intentionally separate from the downloader.  It reads a prepared
DuckDB file whose views point to Parquet expression and metadata datasets.

## Expected data input

The app expects a DuckDB file with views such as:

- `atlas_expression_long`
- `atlas_expression_tpm`
- `atlas_expression_fpkm`
- `atlas_sample_metadata_long`
- `atlas_sample_metadata_wide`
- `atlas_sample_metadata_wide_joinable`
- `atlas_expression_with_sample_metadata`

For example:

```bash
/Users/PThorpe001/Downloads/expression_atlas_app_test/e3_expression.duckdb
```

If the data folder has been copied from the cluster, rebuild the DuckDB views on
that machine before running the app.  The Parquet files are the real portable
data; the DuckDB file is a lightweight query layer over those files.

## Install

```bash
conda activate expression_downloaderR
R CMD INSTALL .
```

## Test

```bash
Rscript inst/scripts/check_dependencies.R
Rscript inst/scripts/run_tests.R
```

The test suite covers the utility helpers, command-line parsing, SQL builders,
DuckDB reader wrappers, query/filter helpers, Shiny UI modules, Shiny server
modules, and script path helpers.  Tests that need optional packages such as
`DBI` and `duckdb` are skipped if those packages are not available.

## Run

```bash
Rscript inst/scripts/run_app.R \
  --duckdb_path=/Users/PThorpe001/Downloads/expression_atlas_app_test/e3_expression.duckdb \
  --host=127.0.0.1 \
  --port=3838
```

Then open:

```text
http://127.0.0.1:3838
```

## Notes on performance

The app is designed to filter lazily through DuckDB/duckplyr and only collect
small, bounded tables for display.  Filter choices are read from lightweight
views where possible:

- species, expression units and experiments from `atlas_expression_long`
- tissue/stage/condition choices from `atlas_sample_metadata_wide_joinable`

This avoids populating controls from the very large joined expression-metadata
view during app start-up.

## Version notes

### v0.1.4

- Optimised filter loading so the app does not derive species choices from the
  huge joined expression-metadata table.
- Added direct DuckDB filter-choice helpers.
- Added broader tests for all newly added helpers.
- Added more Roxygen-style comments and script comments.

### v0.1.3

- Expanded tests and comments.

### v0.1.2

- Fixed test helper paths.

### v0.1.1

- Fixed Rscript path detection.
