# Stata Project Template for Reproducible Research

A template repository for reproducible Stata analysis projects using modern workflow tools and best practices. This template integrates **IPA's Data Cleaning Guide** and Stata coding standards with established practices from leading development economics research groups.

> [!WARNING]
> NEVER COMMIT DATA FILES TO GITHUB.
>
> NEVER USE AI ASSISTANTS WITH PERSONALLY IDENTIFIABLE DATA.
>
> YOU ARE REQUIRED TO REMOVE IDENTIFYING INFORMATION **BEFORE** CONNECTING AI
>
> ASSISTANTS OR STORING IN ANY UNENCRYPTED LOCATION.

## Quick Start (Minimal Setup)

Get started with just **Git** and **Stata** - no additional tools required.

### Prerequisites

- Git installed ([download](https://git-scm.com/))
- Stata 17+ installed and licensed

### Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/PovertyAction/ipa-stata-template.git
   cd ipa-stata-template
   ```

2. **Configure your Stata path**

   Copy `.env-example` to `.env` and set your Stata executable path:

   ```bash
   # Windows example
   STATA_CMD='C:\Program Files\Stata18\StataSE-64.exe'
   STATA_EDITION='se'

   # macOS example
   # STATA_CMD='/Applications/Stata/StataSE.app/Contents/MacOS/StataSE'

   # Linux example
   # STATA_CMD='/usr/local/stata18/stata-se'
   ```

3. **Run the analysis pipeline**

   ```bash
   # From command line (batch mode - recommended for reproducibility)
   stata -e do scripts/do/00_run.do

   # Or open Stata and run interactively
   do scripts/do/00_run.do
   ```

4. **Check outputs**

   - Tables: `outputs/tables/`
   - Figures: `outputs/figures/`
   - Logs: `analysis/logs/`

That's it! You now have a reproducible Stata workflow.

> [!TIP]
> **Want more automation?** See [Advanced Setup](#advanced-setup) below for:
>
> - `just` task runner for common commands
> - `scons` for dependency tracking (rebuild only what changed)
> - `nbstata` for running Stata interactively in VS Code
> - Pre-commit hooks for automatic code quality checks

---

## Project Structure

```text
├── data/
│   ├── raw/           # Original, immutable data files
│   ├── clean/         # Cleaned data (intermediate)
│   └── final/         # Analysis-ready datasets
├── scripts/
│   └── do/            # Stata do-files
│       ├── 00_run.do      # Master do-file (controls pipeline)
│       ├── 01_data_cleaning.do
│       ├── 02_data_preparation.do
│       ├── 03_descriptive_analysis.do
│       ├── 04_main_analysis.do
│       ├── 05_robustness_checks.do
│       └── 06_generate_figures.do
├── ado/               # Local Stata packages (for reproducibility)
├── analysis/logs/     # Log files from Stata runs
├── outputs/
│   ├── tables/        # Regression tables (.tex files)
│   └── figures/       # Figures (.pdf files)
└── documentation/     # Project documentation
```

### Understanding `00_run.do`

The master do-file orchestrates your entire analysis pipeline. It uses control switches to run specific sections:

```stata
// Change to 0 to skip during development
local data_cleaning         = 1
local data_preparation      = 1
local descriptive_analysis  = 1
local main_analysis         = 1
local robustness_checks     = 1
local generate_figures      = 1
```

This allows you to quickly iterate on specific parts without re-running everything.

---

## Advanced Setup

For teams wanting additional automation, code quality tools, and VS Code integration.

### Prerequisites for Advanced Features

- Everything from Quick Start, plus:
- `just` command runner ([install](https://github.com/casey/just#installation))
- For full setup: `uv` Python manager, Node.js (for linting)

### Option A: Task Runner Only (+just)

Install `just` and use simple commands instead of typing full Stata paths:

```bash
# Windows
winget install --id Casey.Just -e

# macOS/Linux
brew install just
```

Now you can run:

```bash
just stata-run          # Run the full pipeline
just stata-config       # Show your Stata configuration
just help               # See available commands
```

### Option B: Full Development Environment

For the complete setup including Python tools, nbstata, and pre-commit hooks:

```bash
just get-started
```

This installs:

- `uv` for Python environment management
- `Git` for version control
- `GitHub CLI` for interaction with GitHub
- `Quarto` for reports and presentations
- `markdownlint-cli2` for Markdown formatting
- Python virtual environment with `nbstata` (run Stata in VS Code/Jupyter)
- Stata packages from `.config/stata/stata_requirements.txt`

After installation, verify your setup:

```bash
just stata-check-installation
```

### VS Code Integration with nbstata

For interactive Stata execution in VS Code (similar to Ctrl+D workflow):

1. Install the [vscode-stata](https://marketplace.visualstudio.com/items?itemName=kylebutts.vscode-stata) extension
2. Test with demo files in `scripts/demo/`
3. Select the nbstata kernel at `.venv/Scripts/python.exe` (Windows) or `.venv/bin/python` (macOS/Linux)

See the [nbstata User Guide](https://hugetim.github.io/nbstata/user_guide.html) for details.

### Dependency Tracking with scons (Advanced)

For large projects where full rebuilds take >5 minutes, use `scons` to only rebuild changed files:

```bash
just stata-build        # Build with dependency tracking
just stata-data         # Build only data pipeline
just stata-analysis     # Build only analysis
just stata-clean        # Clean all outputs
```

The `SConstruct` file defines dependencies between do-files and their outputs. When you modify `01_data_cleaning.do`, scons knows to re-run downstream scripts but not unrelated ones.

> [!NOTE]
> For most projects, the simple `00_run.do` approach is sufficient. Only adopt scons
> if you have genuinely slow builds that would benefit from incremental rebuilding.

---

## Best Practices Built In

### Workflow Features

- **IPA Data Standards**: Follows IPA Data Cleaning Guide and Stata coding best practices
- **Defensive programming**: Uses assert statements and quality checks throughout
- **Extended missing values**: Implements IPA's .d/.o/.n/.r/.s conventions
- **Reproducible package management**: Requirements-based Stata package installation
- **Comprehensive logging**: All Stata runs generate detailed log files
- **Publication-ready outputs**: Tables in LaTeX format, figures in PDF

### Stata Package Management

```bash
# Install all required packages from requirements file
just stata-install-packages
```

Packages are listed in `.config/stata/stata_requirements.txt`.

### Code Quality with stata_linter

```bash
just lint-stata                                    # Lint all do-files
just lint-stata-file scripts/do/01_data_cleaning.do  # Lint specific file
```

Reports saved to `analysis/logs/stata_linter_report.xlsx`.

### IPA Visualizations (for IPA Staff)

```stata
net install github, from("https://haghish.github.io/github/")
github install PovertyAction/ipaplots
```

The template automatically uses IPA branding when `ipaplots` is available.

---

## Troubleshooting

**Command not found errors:**

- Verify Stata path in `.env` file
- Ensure quotes around paths with spaces (Windows)

**Permission errors (macOS/Linux):**

- Check file permissions on Stata executable

**Batch mode issues:**

- Ensure your Stata license supports batch processing

## Acknowledgments and References

This template builds upon established best practices and tools from the development economics and data science communities:

### Primary Guidelines and Standards

- **IPA Data Cleaning Guide** ([Website](https://data.poverty-action.org/data-cleaning/)): Comprehensive guide for data cleaning best practices
    - Organization: Innovations for Poverty Action (IPA)
    - Covers: Raw data management, variable management, dataset documentation, data aggregation

- **IPA Stata Tutorials** ([Website](https://data.poverty-action.org/software/stata/)): Stata coding standards and best practices
    - Organization: Innovations for Poverty Action (IPA)
    - Covers: Stata syntax, data processing, coding standards

- **Data Carpentry Stata Economics** ([Website](https://datacarpentry.github.io/stata-economics/)): Research-grade Stata programming curriculum
    - Organization: Data Carpentry
    - Covers: Data exploration, quality assessment, transformation, combination, programming, loops, advanced techniques
    - License: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

### Core Dependencies

- **statacons** ([GitHub](https://github.com/bquistorff/statacons) | [Documentation](https://bquistorff.github.io/statacons/)): Python package for managing Stata workflows
    - Authors: Brian Quistorff and colleagues
    - License: [MIT License](https://github.com/bquistorff/statacons/blob/main/LICENSE)

- **ipaplots** ([GitHub](https://github.com/PovertyAction/ipaplots)): IPA-branded Stata graphing scheme
    - Authors: Ronny Condor, Kelly Montaño (IPA Peru)
    - Organization: Innovations for Poverty Action
    - Features: Professional visualization theme with IPA branding

### Coding Standards and Best Practices

- **Sean Higgins Stata Guide** ([GitHub](https://github.com/skhiggins/Stata_guide)): Comprehensive coding style and workflow recommendations
    - Author: Sean Higgins
    - License: Creative Commons

- **DIME Analytics Data Handbook** ([Website](https://worldbank.github.io/dime-data-handbook/coding.html)): World Bank DIME team coding standards
    - Organization: World Bank Development Impact Evaluation (DIME)
    - License: [MIT License](https://github.com/worldbank/dime-data-handbook/blob/main/LICENSE)

- **World Bank Reproducible Research Repository** ([GitHub](https://github.com/worldbank/wb-reproducible-research-repository)): Guidelines for reproducible research
    - Organization: World Bank
    - License: [Mozilla Public License 2.0](https://github.com/worldbank/wb-reproducible-research-repository/blob/main/LICENSE)

### Development Tools

- **uv** ([Documentation](https://docs.astral.sh/uv/)): Fast Python package installer and resolver
- **Just** ([GitHub](https://github.com/casey/just)): Command runner for development tasks
- **Quarto** ([Website](https://quarto.org/)): Scientific and technical publishing system

### Advance Workflow with SCons

#### **Automated Build System (Recommended)** - `SConstruct`

```bash
just stata-full     # Complete pipeline with build system
# OR use scons directly:
scons              # Builds entire analysis pipeline
scons data         # Builds only data cleaning/preparation
scons analysis     # Builds only analysis outputs
scons figures      # Builds only figures
scons -c           # Clean all outputs
```

## License

This template is released under the MIT License. See [LICENSE](LICENSE) for details.

While this template is MIT licensed, please respect the licenses of the constituent tools and respect the intellectual contributions of the referenced guides and best practices.
