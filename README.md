# E3 Expression Shiny app

Standalone Shiny application for exploring Expression Atlas-derived expression
and sample metadata prepared by the E3 expression downloader pipeline.

The app reads a DuckDB database that contains lightweight views over Parquet
files. It does **not** load the full expression dataset into R. Filters are
applied lazily through `duckplyr`, and only row-limited display tables are
collected.

## Expected data input

By default the app expects:

```text
/home/pthorpe001/data/2026_E3_protac/analysis/expression_atlas_ftp_full/e3_expression.duckdb
```

You can override this with either an environment variable:

```bash
export E3_EXPRESSION_DUCKDB=/path/to/e3_expression.duckdb
```

or a command-line argument:

```bash
Rscript inst/scripts/run_app.R --duckdb_path=/path/to/e3_expression.duckdb
```

The DuckDB database is a query layer over Parquet files. If the data folder is
copied or moved, rebuild the DuckDB views in the new location using the
expression-downloader repository before launching the app.

## Install and test

```bash
conda activate expression_downloaderR

R CMD INSTALL .

Rscript inst/scripts/check_dependencies.R
Rscript inst/scripts/run_tests.R
```

The test suite covers configuration parsing, SQL/path helpers, DuckDB query
helpers, expression filtering, metadata coverage summaries, UI modules, and the
server modules where practical.

## Run the app

```bash
Rscript inst/scripts/run_app.R \
  --duckdb_path=/path/to/e3_expression.duckdb \
  --host=127.0.0.1 \
  --port=3838
```

Then open:

```text
http://127.0.0.1:3838
```

## Configuration options

```text
--duckdb_path              Path to e3_expression.duckdb
--max_table_rows           Maximum rows collected for table display
--default_expression_unit  TPM or FPKM
--host                     Shiny host, default 127.0.0.1
--port                     Shiny port, default 0 which lets Shiny choose
```

Environment-variable equivalents:

```text
E3_EXPRESSION_DUCKDB
E3_MAX_TABLE_ROWS
E3_DEFAULT_EXPRESSION_UNIT
E3_SHINY_HOST
E3_SHINY_PORT
```

## Development notes

The current app has four main module groups:

```text
R/module_expression_filters.R
R/module_expression_summary.R
R/module_expression_table.R
R/module_gene_lookup.R
```

New project data sources should be added through `R/data_sources.R` and new
query logic should be added through small helper functions in `R/query_helpers.R`.
Avoid collecting large tables inside modules; filter lazily first and collect
only bounded display results.
