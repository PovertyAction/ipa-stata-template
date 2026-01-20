# Stata Project Template for Reproducible Research

A template repository for reproducible Stata analysis projects using modern workflow
tools and best practices. This template integrates **IPA's Data Cleaning Guide** and
Stata coding standards with established practices from leading development economics
research groups.

> [!WARNING]
> NEVER COMMIT DATA FILES TO GITHUB.
>
> NEVER USE AI ASSISTANTS WITH PERSONALLY IDENTIFIABLE DATA.
>
> YOU ARE REQUIRED TO REMOVE IDENTIFYING INFORMATION **BEFORE** CONNECTING AI
>
> ASSISTANTS OR STORING IN ANY UNENCRYPTED LOCATION.

## Use This Template

If you want to use this template for your own project:

1. Click the green **Use this template** button at the top of this page
2. Select **Create a new repository**
3. On the "Create a new repository" page:
   1. Start with a template: `PovertyAction/ipa-stata-template`
   2. Include all branches: Off
   3. Select Owner, Repository name, Description, and Configuration as desired.
4. Click the green **Create repository** button.

## Quick Start (Minimal Setup)

> [!TIP]
> If you are new to this repository, start here but be sure to read the full README
> as well as the [Getting Started Guide](./documentation/getting-started.md).

Get started with just **Git** and **Stata** - no additional tools required.

### Prerequisites

- Git installed ([download](https://git-scm.com/))
    - Windows: `winget install --id Git.Git -e`
    - macOS: `brew install git`
    - Linux: Use your package manager, e.g., `sudo apt install git`, `brew install git`
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

3. **One-time setup** (install `setroot` package)

   ```bash
   # From command line - run once to install dependencies
   just stata-setup

   # Or from Stata directly:
   do setup.do
   ```

4. **Run the analysis pipeline**

   ```bash
   # Full pipeline
   just stata-run

   # Or run a single script
   just stata-script 01_data_cleaning

   # Or open Stata and run directly
   # IMPORTANT: First change to the project directory in Stata:
   cd ~/code/ipa-stata-template
   do do_files/00_run.do
   do do_files/00_run.do "01_data_cleaning"  // single script
   ```

   > [!TIP]
   > If you get a "Root folder of project not found" error, make sure you've changed
   > to the project directory in Stata using `cd ~/code/ipa-stata-template` before
   > running the do-file.

5. **Check outputs**

   - Tables: `outputs/tables/`
   - Figures: `outputs/figures/`
   - Logs: `logs/`

That's it! You now have a reproducible Stata workflow.

### How Path Resolution Works

The template uses `setroot` to automatically find the project root by looking for
a `.here` marker file. This means:

- **No `c(pwd)` dependency** - scripts work regardless of where Stata is launched
- **No user-specific `if c(user)` blocks** - paths resolve automatically
- **Full adopath isolation** - only BASE + local `ado/` for reproducibility
- **Runner pattern** - run individual scripts with proper environment setup

### Separating Code and Data Paths

The template supports storing code and data in **separate locations**. This is useful when:

- Data is stored in a Cryptomator vault
- Data is synced via Box/Dropbox/OneDrive to different locations on each machine
- Multiple team members work from different directory structures
- You want to keep large data files outside your git repository

#### Setup for Separate Data Storage

1. **Copy the template file**:

    ```bash
    # Windows Command Prompt or bash
    cp config.do.template config.do

    # Windows PowerShell

    Copy-Item config.do.template config.do
    ```

    > [!IMPORTANT]
    > **Never commit `config.do`** - it's gitignored for a reason (contains user-specific paths).
    > Always commit `config.do.template` so others know how to configure theirs.

2. **Edit `config.do`** to set your data path:

    ```stata
    // Example: Dropbox
    global data_root "C:/Users/YourName/Dropbox/Research/ProjectName/data"

    // Example: External drive (macOS)
    global data_root "/Volumes/ExternalDrive/research-data/ProjectName"
    ```

3. **Run your analysis** as usual - paths are resolved automatically:

    ```bash
    just stata-run
    ```

#### Default Behavior (Everything Together)

If you don't create a `config.do` file, the template uses default paths:

```stata
data/raw/     -> [project_root]/data/raw/
data/clean/   -> [project_root]/data/clean/
data/final/   -> [project_root]/data/final/
```

#### Path Variables Reference

After setup, these globals are available in all scripts:

**Data paths** (customizable via `config.do`):

- `${data_root}` - Root of all data folders
- `${data_raw}` - Raw/original data
- `${data_clean}` - Cleaned data
- `${data_final}` - Final analysis datasets

**Code/output paths** (always in project root):

- `${project_path}` - Project root (from setroot)
- `${scripts}` - Do-files directory
- `${outputs}` - All outputs
- `${tables}` - Regression tables
- `${figures}` - Figures and graphs
- `${logs}` - Log files

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
├── README.md                           # Important information about the project. Keep this updated, provide additional documentation as needed in `/documentation`.
├── .here                               # Project root marker (for setroot)
├── .env                                # Stata configuration (gitignored) (copy from .env-example)
├── config.do.template                  # Template for user-specific data paths
├── config.do                           # User-specific data paths (gitignored) (copy from config.do.template)
├── .config/                            # Configuration files for packages and tools
│   ├── quarto/                         # Config for Quarto formatting Quarto Markdown documents
│   └── stata/                          # Stata package requirements
│       ├── install_packages.do         # Script to install required Stata packages
│       └── stata_requirements.txt      # List of required Stata packages
├── setup.do                            # One-time setup script
├── data/                               # Data files (DO NOT COMMIT SENSITIVE DATA OR LARGE FILES TO GIT/GITHUB)
│   ├── raw/                            # Original, immutable data files
│   ├── clean/                          # Cleaned data (intermediate)
│   └── final/                          # Analysis-ready datasets
├── do_files/                           # Stata do-files (files here are illustrative; actual do-files may vary)
│   ├── 00_run.do                       # Master do-file (controls pipeline + runner)
│   ├── 01_data_cleaning.do
│   ├── 02_data_preparation.do
│   ├── 03_descriptive_analysis.do
│   ├── 04_main_analysis.do
│   ├── 05_robustness_checks.do
│   ├── 06_generate_figures.do
│   └── functions.do                # Reusable helper functions
├── ado/                                # Local Stata packages (for reproducibility)
├── outputs/
│   ├── figures/                        # Figures (.pdf, .png files)
│   └── tables/                         # Regression tables (.tex, .md files)
├── logs/                               # Log files from Stata runs (should be gitignored)
├── reports/                            # Generate reports (e.g., Quarto, LaTeX)
├── src/                                # Additional scripts (e.g., Python for data processing)
└── documentation/                      # Project documentation
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
just stata-setup                    # One-time setup (install setroot + packages)
just stata-run                      # Run the full pipeline
just stata-script 01_data_cleaning  # Run a single script
just stata-config                   # Show your Stata configuration
just help                           # See available commands
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
2. Test with demo files in `do_files/demo/`
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
just lint-stata-file do_files/01_data_cleaning.do  # Lint specific file
```

Reports saved to `logs/stata_linter_report.xlsx`.

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

- **ipaplots** ([GitHub](https://github.com/PovertyAction/ipaplots)): IPA-branded Stata graphing scheme
    - Authors: Ronny Condor, Kelly Montaño (IPA Peru)
    - Organization: Innovations for Poverty Action
    - Features: Professional visualization theme with IPA branding

- (Optional) **statacons** ([GitHub](https://github.com/bquistorff/statacons) | [Documentation](https://bquistorff.github.io/statacons/)): Python package for managing Stata workflows
    - Authors: Brian Quistorff and colleagues
    - License: [MIT License](https://github.com/bquistorff/statacons/blob/main/LICENSE)

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
- **Code and Data for the Social Sciences: A Practitioner's Guide** ([Website](https://web.stanford.edu/~gentzkow/research/CodeAndData.pdf)): Stata coding style guide
    - Authors: Matthew Gentzkow and Jesse M. Shapiro
    - Copyright (c) 2014, Matthew Gentzkow and Jesse M. Shapiro.

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
