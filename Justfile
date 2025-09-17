# Set the shell to use
# set shell := ["nu", "-c"]
# Set shell for Windows

set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]
set dotenv-load := true

# Set path to virtual environment's python

venv_dir := ".venv"
python := venv_dir + if os_family() == "windows" { "/Scripts/python.exe" } else { "/bin/python3" }

# Stata configuration - loads from .env file or uses defaults

stata_cmd := env_var_or_default("STATA_CMD", if os_family() == "windows" { "stata-se" } else { "stata-se" })
stata_mode := env_var_or_default("STATA_MODE", "-b")
stata_options := env_var_or_default("STATA_OPTIONS", "")

# Display system information
system-info:
    @echo "CPU architecture: {{ arch() }}"
    @echo "Operating system type: {{ os_family() }}"
    @echo "Operating system: {{ os() }}"
    @echo "Stata command: {{ stata_cmd }}"
    @echo "Stata options: {{ stata_options }}"

# Check Stata installation and version
[windows]
stata-check-installation:
    @echo "Checking Stata installation..."
    @echo "Command: {{ stata_cmd }}"
    @{{ if os_family() == "windows" { "& \"" + stata_cmd + "\"" } else { stata_cmd } }} {{ stata_options }} -e "display \"Stata version: \" c(version); display \"Stata flavor: \" c(flavor); display \"Stata edition: \" c(stata_version); display \"System: \" c(os) \" \" c(machine_type)"

# Check Stata installation and version
[linux]
stata-check-installation:
    @echo "Checking Stata installation..."
    @echo "Command: {{ stata_cmd }}"
    @"{{ stata_cmd }}" {{ stata_options }} -e "display \"Stata version: \" c(version); display \"Stata flavor: \" c(flavor); display \"Stata edition: \" c(stata_version); display \"System: \" c(os) \" \" c(machine_type)"

# Check Stata installation and version
[macos]
stata-check-installation:
    @echo "Checking Stata installation..."
    @echo "Command: {{ stata_cmd }}"
    @"{{ stata_cmd }}" {{ stata_options }} -e "display \"Stata version: \" c(version); display \"Stata flavor: \" c(flavor); display \"Stata edition: \" c(stata_version); display \"System: \" c(os) \" \" c(machine_type)"

# Show Stata configuration
stata-config:
    @echo "=== STATA CONFIGURATION ==="
    @echo "Command: {{ stata_cmd }}"
    @echo "Mode: {{ stata_mode }}"
    @echo "Options: {{ stata_options }}"
    @echo ""
    @echo "To customize, copy .env-example to .env and modify STATA_* variables"

# Install Stata packages from requirements file
[windows]
stata-install-packages: stata-check-installation
    @echo "Installing Stata packages from requirements..."
    @& "{{ stata_cmd }}" {{ stata_options }} do "scripts/setup/install_packages.do"
    @echo "Package installation complete!"

# Install Stata packages from requirements file
[linux]
stata-install-packages: stata-check-installation
    @echo "Installing Stata packages from requirements..."
    @"{{ stata_cmd }}" {{ stata_options }} do "scripts/setup/install_packages.do"
    @echo "Package installation complete!"

# Install Stata packages from requirements file
[macos]
stata-install-packages: stata-check-installation
    @echo "Installing Stata packages from requirements..."
    @"{{ stata_cmd }}" {{ stata_options }} do "scripts/setup/install_packages.do"
    @echo "Package installation complete!"

# Clean venv
clean:
    rm -rf .venv

# Setup environment
get-started: pre-install venv

# Update project software versions in requirements
update-reqs:
    uv lock
    pre-commit autoupdate

# create virtual environment
venv:
    uv sync
    uv tool install pre-commit
    uv run pre-commit install

activate-venv:
    uv shell

# launch jupyter lab
lab:
    uv run jupyter lab

# Preview the quarto project
preview-docs:
    quarto preview

# Build the quarto project
build-docs:
    quarto render

# Render analysis report with Stata outputs
render-report:
    @echo "Rendering analysis report..."
    quarto render reports/analysis_report.qmd

# Render report as PDF
render-pdf:
    @echo "Rendering analysis report as PDF..."
    quarto render reports/analysis_report.qmd --to pdf

# Render report as Typst
render-typst:
    @echo "Rendering analysis report as Typst..."
    quarto render reports/analysis_report.qmd --to typst

# Generate complete analysis and report
# full-analysis-report: stata-full render-report
#     @echo "Complete analysis and report generation finished!"
#     @echo "Stata outputs: outputs/"
#     @echo "Report: reports/analysis_report.pdf"

# Preview analysis report
preview-report:
    quarto preview reports/analysis_report.qmd

# Lint python code
lint-py:
    uv run ruff check

# Format python code
fmt-python:
    uv run ruff format

# Format a single python file, "f"
fmt-py f:
    uv run ruff format {{ f }}

# Lint sql scripts
lint-sql:
    uv run sqlfluff fix --dialect duckdb

# Format all markdown and config files
fmt-markdown:
    markdownlint --config {{ justfile_directory() }}/.markdownlint.yaml "**/*.{md,qmd}" --fix

# Format a single markdown file, "f"
fmt-md f:
    markdownlint --config {{ justfile_directory() }}/.markdownlint.yaml {{ f }} --fix

# Check format of all markdown files
fmt-check-markdown:
    markdownlint --config {{ justfile_directory() }}/.markdownlint.yaml "**/*.{md,qmd}"

# Lint Stata code with stata_linter
[windows]
lint-stata:
    @echo "Linting Stata do-files..."
    @& "{{ stata_cmd }}" {{ stata_options }} -e "stata_linter, path(scripts/do) excel(analysis/logs/stata_linter_report.xlsx) replace"
    @echo "Stata linting report saved to: analysis/logs/stata_linter_report.xlsx"

# Lint Stata code with stata_linter
[linux]
lint-stata:
    @echo "Linting Stata do-files..."
    @"{{ stata_cmd }}" {{ stata_options }} -e "stata_linter, path(scripts/do) excel(analysis/logs/stata_linter_report.xlsx) replace"
    @echo "Stata linting report saved to: analysis/logs/stata_linter_report.xlsx"

# Lint Stata code with stata_linter
[macos]
lint-stata:
    @echo "Linting Stata do-files..."
    @"{{ stata_cmd }}" {{ stata_options }} -e "stata_linter, path(scripts/do) excel(analysis/logs/stata_linter_report.xlsx) replace"
    @echo "Stata linting report saved to: analysis/logs/stata_linter_report.xlsx"

# Lint specific Stata file
[windows]
lint-stata-file f:
    @echo "Linting Stata file: {{ f }}"
    @& "{{ stata_cmd }}" {{ stata_options }} -e "stata_linter, path({{ f }}) excel(analysis/logs/stata_linter_{{ file_stem(f) }}.xlsx) replace"

# Lint specific Stata file
[linux]
lint-stata-file f:
    @echo "Linting Stata file: {{ f }}"
    @"{{ stata_cmd }}" {{ stata_options }} -e "stata_linter, path({{ f }}) excel(analysis/logs/stata_linter_{{ file_stem(f) }}.xlsx) replace"

# Lint specific Stata file
[macos]
lint-stata-file f:
    @echo "Linting Stata file: {{ f }}"
    @"{{ stata_cmd }}" {{ stata_options }} -e "stata_linter, path({{ f }}) excel(analysis/logs/stata_linter_{{ file_stem(f) }}.xlsx) replace"

# Check if stata_linter is installed and provide installation instructions
[windows]
stata-check-linter:
    @echo "Checking for stata_linter installation..."
    @& "{{ stata_cmd }}" {{ stata_options }} -e "capture which stata_linter; if _rc != 0 { di as error `\"stata_linter not installed`\"; di `\"Install with: just stata-install-packages`\" } else { di as result `\"stata_linter is installed and ready to use!`\" }"

# Check if stata_linter is installed and provide installation instructions
[linux]
stata-check-linter:
    @echo "Checking for stata_linter installation..."
    @"{{ stata_cmd }}" {{ stata_options }} -e "capture which stata_linter; if _rc != 0 { di as error \"stata_linter not installed\"; di \"Install with: just stata-install-packages\" } else { di as result \"stata_linter is installed and ready to use!\" }"

# Check if stata_linter is installed and provide installation instructions
[macos]
stata-check-linter:
    @echo "Checking for stata_linter installation..."
    @"{{ stata_cmd }}" {{ stata_options }} -e "capture which stata_linter; if _rc != 0 { di as error \"stata_linter not installed\"; di \"Install with: just stata-install-packages\" } else { di as result \"stata_linter is installed and ready to use!\" }"

fmt-all: lint-py fmt-python lint-sql fmt-markdown lint-stata

# Run Stata analysis using statacons
stata-build:
    uv run scons

# Run specific Stata analysis targets
stata-data:
    uv run scons data

stata-analysis:
    uv run scons analysis

stata-figures:
    uv run scons figures

# Clean Stata outputs
stata-clean:
    uv run scons -c

# Run traditional Stata master do-file (alternative to statacons)
stata-run:
    {{ stata_cmd }} {{ stata_options }} do "scripts/do/00_run.do"

# # View analysis summary from log files
# # stata-summary:
# #     @echo "=== STATA ANALYSIS SUMMARY ==="
# #     @echo "Last modified files in outputs:"
# #     @ls -lt outputs/tables/*.tex outputs/figures/*.pdf 2>/dev/null | head -10 || echo "No output files found"
# #     @echo ""
# #     @echo "Recent log file sizes:"
# #     @ls -lh analysis/logs/*.log 2>/dev/null | tail -5 || echo "No log files found"

# Quick data check - show basic info about analysis data
data-info:
    uv run scons data
    @echo "Analysis data created. Check analysis/logs/ for data cleaning logs."

# Run data quality checks
data-check:
    @echo "Running data quality checks..."
    @{{ stata_cmd }} {{ stata_options }} do "scripts/do/01_data_cleaning.do"
    @echo "Check analysis/logs/01_data_cleaning.log for results"

# Generate only tables (no figures)
stata-tables:
    uv run scons analysis

# Comprehensive analysis pipeline with status updates
stata-full:
    @echo "Starting full Stata analysis pipeline..."
    @echo "Step 1: Data cleaning and preparation"
    uv run scons data
    @echo "Step 2: Analysis and tables"
    uv run scons analysis
    @echo "Step 3: Figures and visualizations"
    uv run scons figures
    @echo "Analysis complete! Check outputs/ for results"

# Enhanced help with better organization
help:
    @echo "=== PROJECT COMMANDS ==="
    @echo "just get-started          - Initial setup (install tools + create venv)"
    @echo "just stata-help           - Show Stata-specific commands"
    @echo "just stata-config         - Show Stata configuration"
    @echo "just system-info          - Display system information"
    @echo ""
    @echo "=== QUICK STARTS ==="
    @echo "just stata-full           - Complete Stata analysis pipeline"
    @echo "just full-analysis-report - Complete analysis + report generation"
    @echo "just render-report        - Generate report from existing outputs"
    @echo "just data-info            - Quick data check"
    @echo "just show-outputs         - View results"
    @echo ""
    @echo "For complete command list, see: just --list"

# Run pre-commit hooks
pre-commit-run:
    pre-commit run

[windows]
pre-install:
    winget install Casey.Just astral-sh.uv GitHub.cli Posit.Quarto OpenJS.NodeJS
    npm install -g markdownlint-cli

[linux]
pre-install:
    brew install just uv gh markdownlint-cli

[macos]
pre-install:
    brew install just uv gh markdownlint-cli
    brew install --cask quarto
