# ==============================================================================
# IPA Stata Template - Justfile
# ==============================================================================
#
# Quick reference:
#   just get-started           - Setup project environment
#   just stata-setup           - One-time Stata setup (install setroot + packages)
#   just stata-run             - Run the full analysis pipeline
#   just stata-script <name>   - Run a single script (e.g., 01_data_cleaning)
#   just stata-config          - Show Stata configuration
#   just help                  - Show available commands
#
# For full command list: just --list
# ==============================================================================

set windows-shell := ["powershell.exe", "-NoLogo", "-Command"]
set dotenv-load := true

# Configuration variables

venv_dir := ".venv"
python := venv_dir + if os_family() == "windows" { "/Scripts/python.exe" } else { "/bin/python3" }

# Stata configuration - loads from .env file or uses defaults

stata_cmd := env_var_or_default("STATA_CMD", "stata-se")
stata_edition := env_var_or_default("STATA_EDITION", "se")
stata_mode := env_var_or_default("STATA_MODE", "-e")
stata_options := env_var_or_default("STATA_OPTIONS", "")

# ==============================================================================
# ESSENTIAL COMMANDS - Start here
# ==============================================================================

# Display system information
system-info:
    @echo "CPU architecture: {{ arch() }}"
    @echo "Operating system type: {{ os_family() }}"
    @echo "Stata command: {{ stata_cmd }}"
    @echo "Stata options: {{ stata_options }}"

# Clean venv
clean:
    rm -rf .venv

# Setup environment
get-started: pre-install venv stata-install-packages
    @echo "Project setup complete! Virtual environment created and Stata packages installed."
    @echo "To start working, activate the virtual environment:"
    @echo "{{ if os_family() == "windows" { ".venv\\Scripts\\activate" } else { "source .venv/bin/activate" } }}"

# Update project software versions in requirements
update-reqs:
    uv lock
    pre-commit autoupdate

# create virtual environment
venv:
    uv sync
    uv run python -m nbstata.install --sys-prefix --conf-file
    uv run python -c "import re;from pathlib import Path;c=Path('.venv/etc/nbstata.conf');d=str(Path(r'{{ stata_cmd }}').parent);e='{{ stata_edition }}';t=re.sub(r'^stata_dir =.*$',lambda m:'stata_dir = '+d,c.read_text(),flags=re.MULTILINE);c.write_text(re.sub(r'^edition =.*$',lambda m:'edition = '+e,t,flags=re.MULTILINE))"
    uv tool install pre-commit
    uv run pre-commit install

# Show Stata configuration
stata-config:
    @echo "=== STATA CONFIGURATION ==="
    @echo "Command: {{ stata_cmd }}"
    @echo "Mode: {{ stata_mode }}"
    @echo "Options: {{ stata_options }}"
    @echo ""
    @echo "To customize, copy .env-example to .env and modify STATA_* variables"

# Run an individual Stata do-file
[windows]
stata-do dofile:
    @echo "Running Stata do file..."
    @Start-Process -FilePath "{{ stata_cmd }}" -ArgumentList '{{ stata_mode }}', 'do', '{{ dofile }}' -Wait -NoNewWindow

# Run an individual Stata do-file
[linux]
stata-do dofile:
    @echo "Running Stata do file..."
    "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do "{{ dofile }}"

# Run an individual Stata do-file
[macos]
stata-do dofile:
    @echo "Running Stata do file..."
    "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do "{{ dofile }}"

# Run traditional Stata master do-file (the main way to run your analysis)
[windows]
stata-run:
    @Start-Process -FilePath "{{ stata_cmd }}" -ArgumentList '{{ stata_mode }}', 'do', 'do_files/00_run.do' -Wait -NoNewWindow -PassThru ; $log = Get-Content 00_run.log -Tail 40 ; $log ; if ($p.ExitCode -ne 0) { exit $p.ExitCode } ; if ($log -match '^\s*r\(\d+\);') { exit 1 }

# Run traditional Stata master do-file (the main way to run your analysis)
[linux]
stata-run:
    @echo "Running Stata analysis pipeline..."
    "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do "do_files/00_run.do"
    @echo "Pipeline running. Check the log file: 00_run.log"

# Run traditional Stata master do-file (the main way to run your analysis)
[macos]
stata-run:
    @echo "Running Stata analysis pipeline..."
    "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do "do_files/00_run.do"
    @echo "Pipeline running. Check the log file: 00_run.log"

# Run one-time project setup (install setroot and packages)
[windows]
stata-setup: venv
    @echo "Running one-time project setup..."
    @& "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do "setup.do"

# Run one-time project setup (install setroot and packages)
[linux]
stata-setup: venv
    @echo "Running one-time project setup..."
    "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do "setup.do"

# Run one-time project setup (install setroot and packages)
[macos]
stata-setup: venv
    @echo "Running one-time project setup..."
    "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do "setup.do"

# Run a specific analysis script via the runner pattern

# Usage: just stata-script 01_data_cleaning
[windows]
stata-script script:
    @echo "Running script: {{ script }}"
    @& "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do "do_files/00_run.do" "{{ script }}"

# Run a specific analysis script via the runner pattern

# Usage: just stata-script 01_data_cleaning
[linux]
stata-script script:
    @echo "Running script: {{ script }}"
    "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do "do_files/00_run.do" "{{ script }}"

# Run a specific analysis script via the runner pattern

# Usage: just stata-script 01_data_cleaning
[macos]
stata-script script:
    @echo "Running script: {{ script }}"
    "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do "do_files/00_run.do" "{{ script }}"

# ==============================================================================
# SETUP & INSTALLATION
# ==============================================================================

# Check Stata installation and version
[windows]
stata-check-installation: stata-config
    @echo "Checking Stata installation..."
    @'display "Stata version: " c(version)', 'display "Stata flavor: " c(flavor)', 'display "Stata edition: " c(edition_real)', 'display "System: " c(os) " " c(machine_type)' | Set-Content "_stata_check.do"
    @& "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do "_stata_check.do"
    @Start-Sleep -Seconds 2
    @Get-Content "_stata_check.log" | Select-String -Pattern "^Stata (version|flavor|edition)|^System:"
    @Remove-Item "_stata_check.do", "_stata_check.log" -ErrorAction SilentlyContinue; $null

# Check Stata installation and version
[linux]
stata-check-installation: stata-config
    @echo "Checking Stata installation..."
    @"{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} "display \"Stata version: \" c(version); display \"Stata flavor: \" c(flavor); display \"Stata edition: \" c(edition_real); display \"System: \" c(os) \" \" c(machine_type)"

# Check Stata installation and version
[macos]
stata-check-installation: stata-config
    @echo "Checking Stata installation..."
    @"{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} "display \"Stata version: \" c(version); display \"Stata flavor: \" c(flavor); display \"Stata edition: \" c(edition_real); display \"System: \" c(os) \" \" c(machine_type)"

# Install Stata packages from requirements file
[windows]
stata-install-packages: stata-check-installation
    @echo "Installing Stata packages from requirements..."
    @& "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do ".config/stata/install_packages.do"
    @echo "Check Stata installation..."

# Install Stata packages from requirements file
[linux]
stata-install-packages: stata-check-installation
    @echo "Installing Stata packages from requirements..."
    @"{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do ".config/stata/install_packages.do"
    @echo "Check Stata installation..."

# Install Stata packages from requirements file
[macos]
stata-install-packages: stata-check-installation
    @echo "Installing Stata packages from requirements..."
    @"{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} do ".config/stata/install_packages.do"
    @echo "Check Stata installation..."

# ==============================================================================
# ADVANCED - Python/Jupyter integration
# Requires: uv, Python, nbstata setup (run 'just get-started' first)
# ==============================================================================

# Launch Jupyter Lab for interactive analysis
lab:
    uv run jupyter lab

# ==============================================================================
# DOCUMENTATION & REPORTS
# ==============================================================================

# Render analysis report with Stata outputs
render-report path:
    @echo "Rendering analysis report..."
    quarto render {{ path }}

# Render report as html
render-html path:
    @echo "Rendering analysis report as HTML..."
    quarto render {{ path }} --to html

# Render report as PDF
render-pdf path:
    @echo "Rendering analysis report as PDF..."
    quarto render {{ path }} --to typst

# Render report as DOCX (Word)
render-docx path:
    @echo "Rendering analysis report as DOCX..."
    quarto render {{ path }} --to docx
    @echo "Adding custom cover page..."
    uv run python reports/merge_cover_page.py

# Preview analysis report
preview-report path:
    quarto preview {{ path }}

# Convert PDF figures to PNG for DOCX compatibility
convert-figures:
    @echo "Converting PDF figures to PNG..."
    uv run python reports/convert_figures.py

# ==============================================================================
# CODE QUALITY & FORMATTING
# ==============================================================================

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
    markdownlint-cli2 --config {{ justfile_directory() }}/.markdownlint.yaml "**/*.{md,qmd}" "#.venv" --fix

# Format a single markdown file, "f"
fmt-md f:
    markdownlint-cli2 --config {{ justfile_directory() }}/.markdownlint.yaml {{ f }} --fix

# Check format of all markdown files
fmt-check-markdown:
    markdownlint-cli2 --config {{ justfile_directory() }}/.markdownlint.yaml "**/*.{md,qmd}" "#.venv"

# Lint Stata code with stata_linter
[windows]
lint-stata:
    @echo "Linting Stata do-files..."
    @& "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} "stata_linter, path(do_files) excel(logs/stata_linter_report.xlsx) replace"
    @echo "Stata linting report saved to: logs/stata_linter_report.xlsx"

# Lint Stata code with stata_linter
[linux]
lint-stata:
    @echo "Linting Stata do-files..."
    @"{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} "stata_linter, path(do_files) excel(logs/stata_linter_report.xlsx) replace"
    @echo "Stata linting report saved to: logs/stata_linter_report.xlsx"

# Lint Stata code with stata_linter
[macos]
lint-stata:
    @echo "Linting Stata do-files..."
    @"{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} "stata_linter, path(do_files) excel(logs/stata_linter_report.xlsx) replace"
    @echo "Stata linting report saved to: logs/stata_linter_report.xlsx"

# Lint specific Stata file
[windows]
lint-stata-file f:
    @echo "Linting Stata file: {{ f }}"
    @& "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} "stata_linter, path({{ f }}) excel(logs/stata_linter_{{ file_stem(f) }}.xlsx) replace"

# Lint specific Stata file
[linux]
lint-stata-file f:
    @echo "Linting Stata file: {{ f }}"
    @"{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} "stata_linter, path({{ f }}) excel(logs/stata_linter_{{ file_stem(f) }}.xlsx) replace"

# Lint specific Stata file
[macos]
lint-stata-file f:
    @echo "Linting Stata file: {{ f }}"
    @"{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} "stata_linter, path({{ f }}) excel(logs/stata_linter_{{ file_stem(f) }}.xlsx) replace"

# Check if stata_linter is installed and provide installation instructions
[windows]
stata-check-linter:
    @echo "Checking for stata_linter installation..."
    @& "{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} "capture which stata_linter; if _rc != 0 { di as error `\"stata_linter not installed`\"; di `\"Install with: just stata-install-packages`\" } else { di as result `\"stata_linter is installed and ready to use!`\" }"

# Check if stata_linter is installed and provide installation instructions
[linux]
stata-check-linter:
    @echo "Checking for stata_linter installation..."
    @"{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} "capture which stata_linter; if _rc != 0 { di as error \"stata_linter not installed\"; di \"Install with: just stata-install-packages\" } else { di as result \"stata_linter is installed and ready to use!\" }"

# Check if stata_linter is installed and provide installation instructions
[macos]
stata-check-linter:
    @echo "Checking for stata_linter installation..."
    @"{{ stata_cmd }}" {{ stata_options }} {{ stata_mode }} "capture which stata_linter; if _rc != 0 { di as error \"stata_linter not installed\"; di \"Install with: just stata-install-packages\" } else { di as result \"stata_linter is installed and ready to use!\" }"

fmt-all: lint-py fmt-python lint-sql fmt-markdown lint-stata

# ==============================================================================
# ADVANCED - Dependency tracking with scons
# For large projects where rebuild time matters (>5 min builds)
# Only use if your full pipeline is genuinely slow
# ==============================================================================

# Run Stata analysis using statacons (rebuilds only changed files)
stata-build:
    uv run scons

# Run specific Stata analysis targets
stata-data:
    uv run scons data

stata-analysis:
    uv run scons analysis

stata-figures:
    uv run scons figures

# Clean Stata outputs (preserves .gitkeep files)
stata-clean:
    uv run scons -c

# Quick data check - show basic info about analysis data
data-info:
    uv run scons data
    @echo "Analysis data created. Check logs/ for data cleaning logs."

# Run data quality checks
data-check:
    @echo "Running data quality checks..."
    @{{ stata_cmd }} {{ stata_options }} {{ stata_mode }} do "do_files/01_data_cleaning.do"
    @echo "Check logs/01_data_cleaning.log for results"

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

# ==============================================================================
# HELP & UTILITIES
# ==============================================================================

# Enhanced help with better organization
help:
    @echo "=== PROJECT COMMANDS ==="
    @echo "just get-started          - Initial setup (install tools + create venv)"
    @echo "just stata-setup          - One-time Stata setup (install setroot + packages)"
    @echo "just stata-config         - Show Stata configuration"
    @echo "just system-info          - Display system information"
    @echo ""
    @echo "=== STATA ANALYSIS ==="
    @echo "just stata-run            - Run full analysis pipeline"
    @echo "just stata-script <name>  - Run single script (e.g., 01_data_cleaning)"
    @echo "just stata-do <file>      - Run any do-file directly"
    @echo ""
    @echo "=== ADVANCED (scons) ==="
    @echo "just stata-full           - Complete Stata analysis with dependency tracking"
    @echo "just stata-build          - Build with scons (only rebuilds changed files)"
    @echo ""
    @echo "For complete command list, see: just --list"

# Run pre-commit hooks
pre-commit-run:
    pre-commit run

# ==============================================================================
# PLATFORM-SPECIFIC INSTALLATION (called by get-started)
# ==============================================================================

[windows]
pre-install:
    winget install astral-sh.uv Git.Git GitHub.cli Posit.Quarto OpenJS.NodeJS
    npm install -g markdownlint-cli2

[linux]
pre-install:
    brew install uv gh markdownlint-cli2

[macos]
pre-install:
    brew install uv gh markdownlint-cli2
    brew install --cask quarto
