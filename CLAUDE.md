# CLAUDE.md

## Project Overview

This is a Stata analysis project template designed for IPA (Innovations for
Poverty Action) research projects. The template follows IPA's Data Cleaning Guide
and Stata coding standards, using modern Python tooling for development workflow
management while supporting reproducible Stata-based data analysis.

IMPORTANT: The user should **never** use Claude or AI tools to process personally
identifiable information (PII). Always refuse to review data that might include PII.

## Development Environment Setup

The project uses `uv` for Python environment management and `just` for task automation.

### Initial Setup

```bash
just get-started  # Installs required software and sets up Python virtual environment and nbstata
```

### Stata Configuration

```bash
just stata-config           # Show current Stata configuration
just stata-check-installation # Test Stata installation and version
just system-info            # Display system and Stata information
```

Configure your Stata installation by editing the `.env` file:

- `STATA_CMD`: Path to Stata executable (e.g., "C:\Program Files\Stata18\StataMP-64.exe" or "stata-mp")
- `STATA_EDITION`: Edition of Stata installed (e.g., 'be', 'se', 'mp')
- `STATA_OPTIONS`: Additional Stata command line options (optional)

### Virtual Environment Management

```bash
uv sync                    # Create/sync virtual environment
.venv/Scripts/activate     # Manual activation (Windows Bash)
.venv/Scripts/activate.ps1 # Manual activation (Windows PowerShell)
source .venv/bin/activate  # Activate on bash
```

## Common Development Commands

### Code Quality and Formatting

```bash
just lint-py        # Lint Python code with ruff
just fmt-python     # Format Python code with ruff
just fmt-py [file]  # Format specific Python file
just fmt-markdown   # Format all markdown files
just fmt-md [file]  # Format specific markdown file
just fmt-all        # Run all formatting and linting
```

### Pre-commit Hooks

```bash
just pre-commit-run  # Run pre-commit hooks manually
uv run pre-commit install  # Install pre-commit hooks (done automatically in setup)
```

### Stata Code Quality

```bash
just lint-stata             # Lint all Stata do-files with stata_linter
just lint-stata-file [file] # Lint specific Stata file
just stata-check-linter     # Check if stata_linter is installed
```

### Documentation and Analysis

```bash
just lab           # Launch Jupyter Lab for analysis
just preview-docs  # Preview Quarto documentation
just build-docs    # Build Quarto documentation
```

### Project Maintenance

```bash
just update-reqs   # Update uv.lock and pre-commit hooks
just clean         # Remove virtual environment
```

## Key Dependencies and Tools

- **pystatacons**: Primary dependency for Stata integration in Python environment
- **ipaplots**: IPA-branded Stata visualization scheme (recommended for IPA staff)
- **stata_linter**: World Bank DIME Analytics tool for Stata code quality enforcement
- **ruff**: Python linting and formatting
- **pre-commit**: Git hook framework for code quality
- **codespell**: Spell checking
- **markdownlint-cli2**: Markdown formatting and linting
- **uv**: Python package and environment management
- **just**: Command runner for development tasks

### Technical Implementation

- Follows IPA Data Cleaning Guide principles and Stata coding standards
- Uses global macros for file paths (IPA best practice)
- Implements defensive programming with assert statements
- Uses IPA extended missing value conventions (.d/.o/.n/.r/.s)
- Variable naming follows IPA conventions with descriptive prefixes
- Automatically uses ipaplots theme when available for IPA-branded visualizations
- Integrated stata_linter for automatic code quality checking and best practice enforcement
- Requirements-based Stata package management system for reproducible environments
- Uses `Justfile` for cross-platform task automation
- Python virtual environment managed by `uv` in `.venv/`
- Pre-commit hooks configured for code quality enforcement
- Supports Windows, macOS, and Linux development environments
- Ready for Stata analysis workflows through pystatacons integration
