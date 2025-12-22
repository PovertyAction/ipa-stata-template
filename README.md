# Stata Project Template for Reproducible Research

A comprehensive template repository for reproducible Stata analysis projects using modern workflow tools and best practices. This template integrates **statacons** for dependency management with **IPA's Data Cleaning Guide** and Stata coding standards, along with established practices from leading development economics research groups.

> [!WARNING]
> NEVER COMMIT DATA FILES TO GITHUB.
>
> NEVER USE AI ASSISTANTS WITH PERSONALLY IDENTIFIABLE DATA.
>
> YOU ARE REQUIRED TO REMOVE IDENTIFIING INFORMATION **BEFORE** CONNECTING AI
>
> ASSISTANTS OR STORING IN ANY UNENCRYPTED LOCATION.

## Objectives

[Include a section describing the objectives of this repository.]

## Directory Structure

[Include a description of the directory structure]

## Development Setup

This repository is meant to be run from either Stata or VSCode.
To run from Stata, use the do files within the `scripts/do` subdirectory.

Our recommended approach is to use VSCode, in order to set up your coding environment in VS Code to work with Stata, follow these instructions:

1. Ensure that Stata is installed and license is added. Make note of where Stata is installed in your operating system.

Common Locations:

* Windows: `C:\Program Files\Stata18\StataSE-64.exe`
* macOS: `/Applications/Stata/StataSE.app/Contents/MacOS/StataSE`
* Linux: `/usr/local/stata18/stata-se`

2. Copy the `.env-example` file to `.env` and set the `STATA_CMD` and `STATA_EDITION`
environment variables that match your operating system and version of Stata.

```markdown
# Common Stata installation paths
# Windows, Stata 18
STATA_CMD='C:\Program Files\Stata18\StataSE-64.exe'
STATA_EDITION='se'

# Windows, Stata 19
# STATA_CMD='C:\Program Files\StataNow19\StataSE-64.exe'
# macOS
# STATA_CMD='/Applications/Stata/StataSE.app/Contents/MacOS/StataSE'
# Linux or WSL
# STATA_CMD='/usr/local/stata18/stata-se'
```

3. Make sure that you have `Just` installed

```bash
# Windows
winget install --id Casey.Just -e
# Mac/Linux using Homebrew
brew install just
```

3. Run the following command to install the necessary software

```bash
just get-started
```

This will make sure that the following are installed:

* `uv` for python environment management
* `Git` for version control
* `GitHub CLI` for interaction with GitHub
* `Quarto` for literate programming, writing reports, generating presentations
* `markdownlint-cli2` for formatting of Markdown documents (including Quarto Markdown)
* Python virtual environment via `uv` is added in `.venv/` at the root of this directory.
* `nbstata` is installed within the Python virtual environment. This will enable you to send code to Stata from VSCode and Jupyter notebooks.
* Stata commands specified in `.config/stata/stata_requirements.txt`

> [!TIP]
> If you want to add Stata requirements, add them to `.config/stata/stata_requirements.txt`
> and then run `just stata-install-packages`

4. The `just get-started` command should set up your VS Code environment to work with Stata.

Confirm that you see the following in the `.venv/etc/nbstata.conf`:

`stata_dir` should be the same as your `STATA_CMD` value and `edition` should be
the same as `STATA_EDITION`.

```yaml
[nbstata]
stata_dir = C:\Program Files\StataNow19
edition = se
splash = False
graph_format = png
graph_width = 5.5in
graph_height = 4in
echo = None
missing = .
browse_auto_height = True
```

If you don't see that information, add the relevant information to `.venv/etc/nbstata.conf`.
Alternatively, you can add the information above to `~/.config/nbstata/nbstata.conf`.

See the `nbstata` [User Guide](https://hugetim.github.io/nbstata/user_guide.html)
for more information

5. Verify your Stata configuration:

```bash
# Test basic Stata access
just stata-check-installation
```

5. Install the [vscode-stata](https://marketplace.visualstudio.com/items?itemName=kylebutts.vscode-stata) extension for VS Code

6. There are two options for testing the `nbstata` integration in VS Code:

* From VS Code, try running code in the `scripts/demo/nbstata-demo.do`.
* From VS Code, try running or rendering the code in `scripts/demo/nbstata-demo.qmd`
* From VS Code, try running or rendering the code in `scripts/demo/nbstata-demo.ipynb`

In each of the cases above, make sure that you select the nbstata Jupyter Kernel
located at `.venv/Scripts/python.exe` (Windows) or `.venv/bin/python` (MacOS, Linux).

### Troubleshooting

**Command not found errors:**

* Verify Stata path in `.env` file
* Check that Stata is installed and accessible
* Ensure quotes around paths with spaces (Windows)

**Permission errors (macOS/Linux):**

* Use `sudo` when creating symlinks
* Check file permissions on Stata executable

**Batch mode issues:**

* Ensure your Stata license supports batch processing
* Some Stata commands may not work in batch mode

## Project Structure

This template follows best practices for Stata project organization:

```text
├── data/
│   ├── raw/           # Original, immutable data files
│   ├── clean/         # Cleaned data (intermediate)
│   └── final/         # Analysis-ready datasets
├── scripts/           # Code
│   ├── demo/            # Demo scripts
│   └── do/            # Stata do-files
│       ├── 00_run.do      # Master do-file
│       ├── 01_data_cleaning.do
│       ├── 02_data_preparation.do
│       ├── 03_descriptive_analysis.do
│       ├── 04_main_analysis.do
│       ├── 05_robustness_checks.do
│       └── 06_generate_figures.do
├── ado/               # User-written Stata packages
├── analysis/logs/     # Log files from Stata runs
├── outputs/
│   ├── tables/        # Regression tables (.tex files)
│   └── figures/       # Figures (.pdf files)
├── documentation/     # Project documentation
└── SConstruct         # statacons workflow definition
```

The `scripts/demo/nbstata-demo.qmd` file provides a Quarto notebook example for interactive Stata analysis.

## Workflow Features

### Automated Dependency Management

* **statacons integration**: Automatically tracks file dependencies and rebuilds only what's necessary
* **Reproducible environments**: Stata packages managed in local `ado/` folder
* **Version control friendly**: All outputs are generated, not committed

### Best Practice Implementation

* **IPA Data Standards**: Follows IPA Data Cleaning Guide and Stata coding best practices
* **Data Carpentry Methods**: Implements research-grade programming techniques for data exploration, transformation, and combination
* **Standardized coding style**: Implementing IPA, Data Carpentry, DIME Analytics, and Sean Higgins guidelines
* **Defensive programming**: Uses assert statements and quality checks throughout
* **Advanced programming**: Includes loops, macros, temporary files, and modular programming
* **Extended missing values**: Implements IPA's .d/.o/.n/.r/.s conventions
* **Code quality enforcement**: Integrated stata_linter for style checking and best practices
* **Reproducible package management**: Requirements-based Stata package installation system
* **Comprehensive logging**: All Stata runs generate detailed log files
* **Publication-ready outputs**: Tables in LaTeX format, figures in PDF

## Using the Template

### 1. Data Preparation

* Place raw data in `data/raw/`
* Modify `scripts/do/01_data_cleaning.do` for your data cleaning steps
* Modify `scripts/do/02_data_preparation.do` for analysis sample creation

### 2. Analysis

* Update analysis scripts (`03_descriptive_analysis.do`, `04_main_analysis.do`, `05_robustness_checks.do`)
* Modify `scripts/do/06_generate_figures.do` for your visualization needs
* Run entire pipeline with `scons` or individual steps with `scons [target]`

### 3. IPA Visualizations (Recommended for IPA Staff)

For IPA staff, install the `ipaplots` package for branded visualizations:

```stata
net install github, from("https://haghish.github.io/github/")
github install PovertyAction/ipaplots
```

The template automatically detects and uses the IPA theme when available, falling back to default schemes otherwise.

### 4. Package Management and Environment Reproducibility

Stata lacks a built-in package manager, making reproducible environments challenging. This template provides a requirements-based system:

```bash
# Install all required packages from requirements file
just stata-install-packages
```

**Package Requirements File**: `scripts/setup/stata_requirements.txt` contains a list of required packages with their installation sources:

```text
# Format: package_name,install_source,install_command
estout,ssc,ssc install estout
reghdfe,ssc,ssc install reghdfe
ipaplots,github,github install PovertyAction/ipaplots
stata_linter,net,net install stata_linter, from(https://raw.githubusercontent.com/worldbank/stata-linter/main)
```

### 5. Code Quality with stata_linter

This template integrates [stata_linter](https://dimewiki.worldbank.org/Stata_Linter) from the World Bank DIME team for enforcing Stata coding best practices:

```bash
# Lint all Stata do-files and generate Excel report
just lint-stata

# Lint a specific do-file
just lint-stata-file scripts/do/01_data_cleaning.do

# Check if stata_linter is installed
just stata-check-linter

# Install stata_linter (included in package requirements)
just stata-install-packages
```

The linter checks for:

* Variable naming conventions
* Proper use of global macros for file paths
* Consistent indentation and spacing
* Deprecated command usage
* Best practices for loops and conditionals

Linting reports are saved to `analysis/logs/stata_linter_report.xlsx` with detailed feedback on code quality issues.

### 6. Generate Reports

Create publication-ready reports that automatically include your Stata outputs:

```bash
# Generate complete analysis and report
just full-analysis-report

# Or generate report from existing outputs
just render-report

# Preview report in browser
just preview-report
```

The Quarto report template automatically integrates your Stata outputs including LaTeX tables and PDF figures.

### 7. Outputs

* Tables will be generated in `outputs/tables/` (LaTeX format)
* Figures will be generated in `outputs/figures/` (PDF format, with IPA branding when available)
* Log files will be saved in `analysis/logs/`
* Reports will be generated in `reports/` (PDF, HTML, or Typst format)

## Acknowledgments and References

This template builds upon established best practices and tools from the development economics and data science communities:

### Primary Guidelines and Standards

* **IPA Data Cleaning Guide** ([Website](https://data.poverty-action.org/data-cleaning/)): Comprehensive guide for data cleaning best practices
    * Organization: Innovations for Poverty Action (IPA)
    * Covers: Raw data management, variable management, dataset documentation, data aggregation

* **IPA Stata Tutorials** ([Website](https://data.poverty-action.org/software/stata/)): Stata coding standards and best practices
    * Organization: Innovations for Poverty Action (IPA)
    * Covers: Stata syntax, data processing, coding standards

* **Data Carpentry Stata Economics** ([Website](https://datacarpentry.github.io/stata-economics/)): Research-grade Stata programming curriculum
    * Organization: Data Carpentry
    * Covers: Data exploration, quality assessment, transformation, combination, programming, loops, advanced techniques
    * License: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

### Core Dependencies

* **statacons** ([GitHub](https://github.com/bquistorff/statacons) | [Documentation](https://bquistorff.github.io/statacons/)): Python package for managing Stata workflows
    * Authors: Brian Quistorff and colleagues
    * License: [MIT License](https://github.com/bquistorff/statacons/blob/main/LICENSE)

* **ipaplots** ([GitHub](https://github.com/PovertyAction/ipaplots)): IPA-branded Stata graphing scheme
    * Authors: Ronny Condor, Kelly Montaño (IPA Peru)
    * Organization: Innovations for Poverty Action
    * Features: Professional visualization theme with IPA branding

### Coding Standards and Best Practices

* **Sean Higgins Stata Guide** ([GitHub](https://github.com/skhiggins/Stata_guide)): Comprehensive coding style and workflow recommendations
    * Author: Sean Higgins
    * License: Creative Commons

* **DIME Analytics Data Handbook** ([Website](https://worldbank.github.io/dime-data-handbook/coding.html)): World Bank DIME team coding standards
    * Organization: World Bank Development Impact Evaluation (DIME)
    * License: [MIT License](https://github.com/worldbank/dime-data-handbook/blob/main/LICENSE)

* **World Bank Reproducible Research Repository** ([GitHub](https://github.com/worldbank/wb-reproducible-research-repository)): Guidelines for reproducible research
    * Organization: World Bank
    * License: [Mozilla Public License 2.0](https://github.com/worldbank/wb-reproducible-research-repository/blob/main/LICENSE)

### Development Tools

* **uv** ([Documentation](https://docs.astral.sh/uv/)): Fast Python package installer and resolver
* **Just** ([GitHub](https://github.com/casey/just)): Command runner for development tasks
* **Quarto** ([Website](https://quarto.org/)): Scientific and technical publishing system

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
