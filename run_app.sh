#!/usr/bin/env bash

# Small convenience wrapper for launching the app from the repository root.
# Extra arguments are passed straight through to inst/scripts/run_app.R, for
# example:
#   ./run_app.sh --duckdb_path=/path/to/e3_expression.duckdb --port=3838

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${REPO_DIR}"

Rscript inst/scripts/run_app.R "$@"
