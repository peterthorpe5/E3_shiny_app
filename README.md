# E3 Expression Shiny App

Standalone Shiny app for exploring the Expression Atlas-derived expression layer
created by the E3 expression downloader pipeline.

The app is intentionally separate from the downloader repo. It reads the prepared
DuckDB/Parquet-backed output but does not download or rebuild expression data.

## Expected input

Default DuckDB path:

```text
/home/pthorpe001/data/2026_E3_protac/analysis/expression_atlas_ftp_full/e3_expression.duckdb
```

The app expects the DuckDB database to contain these views:

```text
atlas_expression_long
atlas_expression_tpm
atlas_expression_fpkm
atlas_sample_metadata_long
atlas_sample_metadata_wide
atlas_sample_metadata_wide_joinable
atlas_expression_with_sample_metadata
```

## Conda dependencies

Use the existing `expression_downloaderR` environment if it already contains
Shiny, duckplyr and DT. Otherwise install the missing packages using conda where
possible:

```bash
conda activate expression_downloaderR

mamba install -c conda-forge \
  r-shiny \
  r-bslib \
  r-dplyr \
  r-duckplyr \
  r-dt \
  r-stringr \
  r-tibble \
  r-testthat \
  r-shinycssloaders
```

If `mamba` is unavailable, use `conda install` with the same package list.

## Install and test

From the app repository root:

```bash
R CMD INSTALL .
Rscript inst/scripts/run_tests.R
```

## Run the app

```bash
./run_app.sh
```

Or explicitly:

```bash
Rscript inst/scripts/run_app.R \
  --duckdb_path=/home/pthorpe001/data/2026_E3_protac/analysis/expression_atlas_ftp_full/e3_expression.duckdb \
  --host=0.0.0.0 \
  --port=3838
```

For local testing, omit `--host` and `--port`:

```bash
Rscript inst/scripts/run_app.R \
  --duckdb_path=/home/pthorpe001/data/2026_E3_protac/analysis/expression_atlas_ftp_full/e3_expression.duckdb
```

## Configuration

The DuckDB path can be set using an environment variable:

```bash
export E3_EXPRESSION_DUCKDB=/path/to/e3_expression.duckdb
Rscript inst/scripts/run_app.R
```

or with a command-line argument:

```bash
Rscript inst/scripts/run_app.R --duckdb_path=/path/to/e3_expression.duckdb
```

Command-line arguments take priority over environment variables.

## App modules

Current modules:

```text
Expression filters
Expression table
Expression summary
Gene lookup
```

Planned future modules:

```text
E3 ligase table
HOG / orthogroup table
Identifier alias table
Domain annotation table
Structural / AlphaFold / ligandability table
Candidate ranking table
```

## Important scaling rule

The app uses lazy DuckDB/duckplyr queries. Do not call `collect()` until the data
have already been filtered and row-limited.
