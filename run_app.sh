#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DUCKDB_PATH="${E3_EXPRESSION_DUCKDB:-/home/pthorpe001/data/2026_E3_protac/analysis/expression_atlas_ftp_full/e3_expression.duckdb}"
CONDA_ENV="${E3_SHINY_CONDA_ENV:-expression_downloaderR}"
HOST="${E3_SHINY_HOST:-127.0.0.1}"
PORT="${E3_SHINY_PORT:-3838}"

if command -v conda >/dev/null 2>&1; then
    CONDA_BASE="$(conda info --base)"
    # shellcheck source=/dev/null
    source "${CONDA_BASE}/etc/profile.d/conda.sh"
    conda activate "${CONDA_ENV}"
fi

cd "${REPO_DIR}"

Rscript inst/scripts/run_app.R \
    --duckdb_path="${DUCKDB_PATH}" \
    --host="${HOST}" \
    --port="${PORT}"
