# Stata Project Template for Reproducible Research

A comprehensive template repository for reproducible Stata analysis projects using modern workflow tools and best practices. This template integrates **statacons** for dependency management with **IPA's Data Cleaning Guide** and Stata coding standards, along with established practices from leading development economics research groups.

## Quick Start

### For Stata Analysis

**Choose Your Workflow Method:**

#### 1. **Automated Build System (Recommended)** - `SConstruct`

```bash
just stata-full     # Complete pipeline with build system
# OR use scons directly:
scons              # Builds entire analysis pipeline  
scons data         # Builds only data cleaning/preparation
scons analysis     # Builds only analysis outputs
scons figures      # Builds only figures
scons -c           # Clean all outputs
```

#### 2. **Traditional Master Do-File** - `00_run.do`

```bash
just stata-run     # Run traditional master do-file
# OR run directly in Stata:
# do "scripts/do/00_run.do"
```

#### **When to Use Which Method:**

| Use Case | SConstruct (Build System) | 00_run.do (Master Do-File) |
|----------|---------------------------|----------------------------|
| **Development & Iteration** | ✅ **Recommended** - Only rebuilds changed components | ❌ Reruns entire pipeline each time |
| **Production & Final Results** | ✅ **Recommended** - Ensures all dependencies are current | ✅ Good for final validation runs |
| **CI/CD & Automation** | ✅ **Recommended** - Optimal for automated workflows | ✅ Simple for basic automation |
| **Debugging Specific Steps** | ✅ **Excellent** - `scons analysis` runs only analysis steps | ❌ Must modify switches in do-file |
| **New Users/Learning** | ❌ Requires learning SCons concepts | ✅ **Recommended** - Familiar Stata workflow |
| **Collaboration** | ✅ **Excellent** - Automatic dependency tracking | ⚠️ Manual coordination of file changes |
| **Reproducibility** | ✅ **Superior** - Tracks all file dependencies automatically | ✅ Good with proper version control |

#### **Technical Differences:**

**SConstruct (`just stata-full`):**
- ✅ **Selective rebuilding** - Only processes files that have changed or depend on changed files
- ✅ **Automatic dependency tracking** - Updates when `functions.do` or data files change
- ✅ **Parallel processing** - Can run independent steps simultaneously
- ✅ **Build validation** - Ensures all outputs are up-to-date
- ⚠️ **Learning curve** - Requires understanding SCons concepts

**00_run.do (`just stata-run`):**
- ✅ **Familiar workflow** - Standard Stata master do-file approach
- ✅ **Manual control** - Use switches to control which sections run
- ✅ **Easy debugging** - Set switches to run specific analysis sections
- ❌ **Full rebuilds** - Runs entire pipeline regardless of what changed
- ❌ **Manual dependency management** - Must manually track file dependencies

## Development Setup

Development relies on the following software

- **Stata** (MP, SE, or IC) with command line access configured
- `winget` (Windows) or `homebrew` (MacOS/Linux) or `snap` (Linux) for package management and installation
- `git` for source control management
- `just` for running common command line patterns
- `uv` for installing Python and managing virtual environments

This repository uses a `Justfile` for collecting common command line actions that we run
to set up the computing environment and build the assets of the handbook. Note that you
should also have Git installed

To get started, make sure you have `Just` installed on your computer by running the
following from the command line:

| Platform  | Commands                                                            |
| --------- | ------------------------------------------------------------------- |
| Windows   | `winget install Git.Git Casey.Just astral-sh.uv GitHub.cli Posit.Quarto` |
| Mac/Linux | `brew install just uv gh`                                          |

This will make sure that you have the latest version of `Just`, as well as
[uv](https://docs.astral.sh/uv/) (installer for Python) and
[Quarto](https://quarto.org/docs/guide/) (for writing and compiling scientific and
technical documents).

- We use `Just` in order to make it easier for all IPA users to be productive with data
  and technology systems. The goal of using a `Justfile` is to help make the end goal of
  the user easier to achieve without needing to know or remember all of the technical
  details of how we get to that goal.
- We use `uv` to help ease use of Python. `uv` provides a global system for creating and
  building computing environments for Python.
- We use Quarto to allow users to focus on writing and data analytics. Writing in
  markdown, jupyter notebooks, python scripts, R scripts, etc. makes it easier to
  review, update, and deploy technical documentation.
- We also recommend using in Integrated Development Environment (IDE).
  Preferred options are `VS Code` or `Positron`.

| Platform  | Commands                                                            |
| --------- | ------------------------------------------------------------------- |
| Windows   | `winget install Microsoft.VisualStudioCode`                         |
| Mac       | `brew install --cask visual-studio-code`                            |
| Linux     | `sudo snap install code --classic`                                  |

| Platform  | Commands                                                            |
| --------- | ------------------------------------------------------------------- |
| Windows   | `winget install Posit.Positron`                                     |
| Mac       | `brew install --cask positron`                                      |

As a shortcut, if you already have `Just` installed, you can run the following to
install required software and build a python virtual environment that is used to build
the handbook pages:

```bash
just get-started
```

Note: you may need to restart your terminal after running the command above to activate
the installed software.

After the required software is installed, you can activate the Python virtual
environment:

| Shell      | Commands                                |
| ---------- | --------------------------------------- |
| Bash       | `.venv/Scripts/activate`                |
| Powershell | `.venv/Scripts/activate.ps1`            |
| Nushell    | `overlay use .venv/Scripts/activate.nu` |

## Stata Command Line Setup

This template requires Stata to be accessible from the command line. Follow the setup instructions for your platform:

### Configuration

1. **Copy the environment template**:

   ```bash
   cp .env-example .env
   ```

2. **Edit `.env` file** to specify your Stata installation:

   ```bash
   # Example configurations:

   # Windows with Stata/MP in standard location
   STATA_CMD="C:\Program Files\Stata18\StataMP-64.exe"

   # macOS/Linux with Stata in PATH
   STATA_CMD=stata-mp

   # Custom installation path
   STATA_CMD=/usr/local/stata18/stata-mp
   ```

### Platform-Specific Setup

#### Windows

**Option 1: Add Stata to PATH (Recommended)**

1. Find your Stata installation directory (e.g., `C:\Program Files\Stata18\`)
2. Add this directory to your Windows PATH environment variable
3. Use `STATA_CMD=stata-mp` (or `stata-se`, `stata`) in your `.env` file

**Option 2: Use Full Path**

```bash
# In .env file - adjust path to match your installation
STATA_CMD="C:\Program Files\Stata18\StataMP-64.exe"
```

**Common Windows Stata Locations:**

- Stata/MP: `C:\Program Files\Stata18\StataMP-64.exe`
- Stata/SE: `C:\Program Files\Stata18\StataSE-64.exe`
- Stata/IC: `C:\Program Files\Stata18\Stata-64.exe`

#### macOS

**Option 1: Create Command Line Tools (Recommended)**

1. Open Terminal and create symlinks:

   ```bash
   # For Stata/MP
   sudo ln -s /Applications/Stata/StataMP.app/Contents/MacOS/StataMP /usr/local/bin/stata-mp

   # For Stata/SE
   sudo ln -s /Applications/Stata/StataSE.app/Contents/MacOS/StataSE /usr/local/bin/stata-se
   ```

2. Use `STATA_CMD=stata-mp` in your `.env` file

**Option 2: Use Full Path**

```bash
# In .env file
STATA_CMD=/Applications/Stata/StataMP.app/Contents/MacOS/StataMP
```

#### Linux

**Option 1: Stata in PATH**
If Stata was installed system-wide, use:

```bash
# In .env file
STATA_CMD=stata-mp  # or stata-se, stata
```

**Option 2: Custom Installation Path**

```bash
# In .env file - adjust path to your installation
STATA_CMD=/usr/local/stata18/stata-mp
```

### Verification

Test your Stata configuration:

```bash
# Test basic Stata access
just stata-check-installation

# View current configuration
just stata-config

# Test with a simple command
just system-info
```

Expected output should show your Stata version, flavor (MP/SE/IC), and system information.

### Troubleshooting

**Command not found errors:**

- Verify Stata path in `.env` file
- Check that Stata is installed and accessible
- Ensure quotes around paths with spaces (Windows)

**Permission errors (macOS/Linux):**

- Use `sudo` when creating symlinks
- Check file permissions on Stata executable

**Batch mode issues:**

- Ensure your Stata license supports batch processing
- Some Stata commands may not work in batch mode

## Project Structure

This template follows best practices for Stata project organization:

```
├── data/
│   ├── raw/           # Original, immutable data files
│   ├── clean/         # Cleaned data (intermediate)
│   └── final/         # Analysis-ready datasets
├── scripts/do/        # Stata do-files
│   ├── 00_run.do      # Master do-file
│   ├── 01_data_cleaning.do
│   ├── 02_data_preparation.do
│   ├── 03_descriptive_analysis.do
│   ├── 04_main_analysis.do
│   ├── 05_robustness_checks.do
│   └── 06_generate_figures.do
├── ado/               # User-written Stata packages
├── analysis/logs/     # Log files from Stata runs
├── outputs/
│   ├── tables/        # Regression tables (.tex files)
│   └── figures/       # Figures (.pdf files)
├── documentation/     # Project documentation
└── SConstruct         # statacons workflow definition
```

## Workflow Features

### Automated Dependency Management

- **statacons integration**: Automatically tracks file dependencies and rebuilds only what's necessary
- **Reproducible environments**: Stata packages managed in local `ado/` folder
- **Version control friendly**: All outputs are generated, not committed

### Best Practice Implementation

- **IPA Data Standards**: Follows IPA Data Cleaning Guide and Stata coding best practices
- **Data Carpentry Methods**: Implements research-grade programming techniques for data exploration, transformation, and combination
- **Standardized coding style**: Implementing IPA, Data Carpentry, DIME Analytics, and Sean Higgins guidelines
- **Defensive programming**: Uses assert statements and quality checks throughout
- **Advanced programming**: Includes loops, macros, temporary files, and modular programming
- **Extended missing values**: Implements IPA's .d/.o/.n/.r/.s conventions
- **Code quality enforcement**: Integrated stata_linter for style checking and best practices
- **Reproducible package management**: Requirements-based Stata package installation system
- **Comprehensive logging**: All Stata runs generate detailed log files
- **Publication-ready outputs**: Tables in LaTeX format, figures in PDF

## Customizing the Build System (SConstruct)

The `SConstruct` file defines the automated build pipeline and must be updated when you modify the analysis workflow.

### When to Update SConstruct

**Always update `SConstruct` when you:**
- Add new Stata scripts to the analysis pipeline
- Create new output files (tables, figures, datasets)
- Add dependencies between analysis steps
- Modify file paths or naming conventions

### Key Components to Update

#### 1. **Adding New Analysis Scripts**

When adding a new script (e.g., `07_sensitivity_analysis.do`):

```python
# Add new step to SConstruct
sensitivity_analysis = env.StataBuild(
    target=[
        "outputs/tables/sensitivity_results.tex",
        "analysis/logs/07_sensitivity_analysis.log",
    ],
    source="scripts/do/07_sensitivity_analysis.do",
)
Depends(sensitivity_analysis, ["data/final/analysis_data.dta", "scripts/do/functions.do", "ado"])

# Add to aliases
Alias("analysis", [descriptive_analysis, main_analysis, robustness_analysis, sensitivity_analysis])
```

#### 2. **Adding New Output Files**

If your `standard_regression` function creates new table files, update the targets:

```python
main_analysis = env.StataBuild(
    target=[
        "outputs/tables/main_results.tex", 
        "outputs/tables/model1.tex",
        "outputs/tables/model2.tex",
        "outputs/tables/model3.tex",
        "outputs/tables/model4.tex",  # Add new model outputs
        "analysis/logs/04_main_analysis.log"
    ],
    source="scripts/do/04_main_analysis.do",
)
```

#### 3. **Managing Dependencies**

**Critical: All scripts depend on `functions.do`** because they load G&S standardized functions:

```python
# Always include functions.do dependency
Depends(script_name, ["input_data.dta", "scripts/do/functions.do", "ado"])
```

#### 4. **Build Aliases**

Update aliases when adding new components:

```python
Alias("data", [data_clean, data_final])
Alias("analysis", [descriptive_analysis, main_analysis, robustness_analysis, sensitivity_analysis])
Alias("figures", [figures, new_figures])
Alias("all", [data_clean, data_final, descriptive_analysis, main_analysis, robustness_analysis, figures, sensitivity_analysis])
```

### Testing SConstruct Changes

After modifying `SConstruct`:

```bash
# Test individual components
scons data          # Test data pipeline
scons analysis      # Test analysis pipeline  
scons figures       # Test figure generation

# Test full pipeline
scons -c            # Clean all outputs
scons               # Rebuild everything
```

### SConstruct vs 00_run.do Maintenance

| File | When to Update | What to Update |
|------|---------------|----------------|
| **SConstruct** | Adding scripts, changing outputs, modifying dependencies | Build targets, file dependencies, aliases |
| **00_run.do** | Adding scripts, changing control flow | Switch variables, script paths, execution order |

**Both files should be kept in sync** - if you add a new analysis script, update both the SCons build definition and the master do-file switches.

## Using the Template

### 1. Data Preparation

- Place raw data in `data/raw/`
- Modify `scripts/do/01_data_cleaning.do` for your data cleaning steps
- Modify `scripts/do/02_data_preparation.do` for analysis sample creation

### 2. Analysis

- Update analysis scripts (`03_descriptive_analysis.do`, `04_main_analysis.do`, `05_robustness_checks.do`)
- Modify `scripts/do/06_generate_figures.do` for your visualization needs
- Run entire pipeline with `scons` or individual steps with `scons [target]`

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

```
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

- Variable naming conventions
- Proper use of global macros for file paths
- Consistent indentation and spacing
- Deprecated command usage
- Best practices for loops and conditionals

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

- Tables will be generated in `outputs/tables/` (LaTeX format)
- Figures will be generated in `outputs/figures/` (PDF format, with IPA branding when available)
- Log files will be saved in `analysis/logs/`
- Reports will be generated in `reports/` (PDF, HTML, or Typst format)

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

## License

This template is released under the MIT License. See [LICENSE](LICENSE) for details.

While this template is MIT licensed, please respect the licenses of the constituent tools and respect the intellectual contributions of the referenced guides and best practices.
