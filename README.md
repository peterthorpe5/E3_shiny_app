# E3 Expression Shiny App

A standalone Shiny application for exploring Expression Atlas-derived expression
and sample metadata produced by the E3 expression downloader pipeline.

The app is deliberately separate from the downloader repository. It expects a
prepared DuckDB file whose views point to the Parquet expression and metadata
folders.

## What the app currently does

The app can:

- filter expression records by species, expression unit, experiment, organism
  part, developmental stage, condition, gene ID/name and minimum expression;
- show summary counts for the current selection;
- show metadata coverage for the current selection;
- display a row-limited expression table;
- search for gene IDs or gene names across the selected expression unit;
- plot selected gene expression as:
  - a mean expression profile,
  - a distribution plot,
  - or a gene-by-group heatmap.

The app applies filters in DuckDB before collecting data into R. This is essential
because the full Expression Atlas-derived table can contain hundreds of millions
of rows.

## Important data layout note

The DuckDB file is a lightweight query layer over Parquet files. It is not the
full data store. If the data folder is copied to a new location, rebuild the
DuckDB views so they point to the local Parquet paths.

The expected data folder contains:

```text
expression_atlas_app_test/
  e3_expression.duckdb
  parquet/
    atlas_expression_long/
    atlas_sample_metadata_long/
    atlas_sample_metadata_wide/
  manifests/
```

## Dependencies

Use the same conda environment as the expression downloader if possible:

```bash
conda activate expression_downloaderR
```

The app requires these R packages:

```text
bslib
dplyr
DT
duckplyr
ggplot2
plotly
rlang
shiny
shinycssloaders
stringr
testthat
tibble
```

Optional but recommended for tests:

```text
DBI
duckdb
```

## Install and test

```bash
cd /path/to/E3_shiny_app

R CMD INSTALL .

Rscript inst/scripts/check_dependencies.R
Rscript inst/scripts/run_tests.R
```

## Run the app

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

## Visualisation tab

The visualisation tab requires a gene ID or gene-name search. This is deliberate:
plotting without a gene query would collect too many rows.

Suggested first test:

```text
Species: Zea_mays
Expression unit: TPM
Gene ID / gene name contains: Zm00001eb
Group expression by: Organism part or Expression group / sample
Plot type: Mean profile
```

The plot data table below the plot shows exactly which rows were collected for
visualisation.

## Development rules

- Keep the app modular.
- Keep data access in `R/data_sources.R` and SQL construction in
  `R/query_helpers.R`.
- Never collect the full expression table into R.
- Add tests for every new helper function.
- Prefer direct DuckDB SQL for small app outputs that need to be collected.
- Use clear Roxygen-style comments above functions.

## Current version

`0.2.1` fixes DuckDB gene-search escaping in the expression table, gene lookup, and visualisation queries. Gene searches now use literal case-insensitive `contains()` SQL rather than `LIKE ... ESCAPE`, which failed on some DuckDB builds. Tests have been expanded to cover this route.


## v0.2.4

- Fixes the expression plot UI test expectation after the gene-search SQL backend changed from `contains()` to `instr()` while keeping the user-facing label as “contains”.
- No runtime code changes are required for this patch; it keeps the app wording user-friendly and the test suite aligned with the UI.


## v0.2.3

- Replaced DuckDB `contains()` gene-search SQL with `instr()` literal substring matching.
- This avoids both `LIKE ... ESCAPE` issues and inconsistent `contains()` behaviour across DuckDB/R builds.
- Added/updated tests so the plotting and gene lookup SQL are exercised through a temporary DuckDB database.


## v0.2.3 notes

This patch fixes the gene-search SQL helper used by the plotting and lookup modules. It uses DuckDB `instr(lower(...), ...) > 0` for literal substring matching and fixes a string-construction bug that could add spaces inside the expression-unit filter.
