# Getting Started with the Stata Project Template

This guide will help you set up and use this template for your Stata analysis project.

## Prerequisites

1. **Stata** (Stata 17+ recommended)
2. **Python 3.12+** (managed via `uv`)
3. **Just** command runner
4. **Git** for version control

## Setup Steps

### 1. Clone and Setup Environment

```bash
# Clone this template
git clone <your-repo-url>
cd ipa-stata-template

# Install dependencies and setup environment
just get-started

# Activate Python virtual environment
uv shell
```

### 2. Install IPA Visualization Theme (Recommended for IPA Staff)

For IPA staff, install the ipaplots package for branded visualizations:

```stata
net install github, from("https://haghish.github.io/github/")
github install PovertyAction/ipaplots
```

This provides professional, IPA-branded graph themes that will be automatically used in the figure generation scripts.

### 3. Add Your Data

- Place your raw data files in `data/raw/`
- Update the sample CSV file or replace it with your actual data
- Ensure your data file names match those referenced in the do-files

### 4. Customize the Analysis

#### Update Data Cleaning (`scripts/do/01_data_cleaning.do`)

- Modify variable names and cleaning steps for your data
- Add/remove variables as needed
- Update missing value handling logic

#### Update Data Preparation (`scripts/do/02_data_preparation.do`)

- Define your analysis sample criteria
- Create analysis variables specific to your research question
- Set up any subsamples for robustness checks

#### Update Analysis Scripts

- **Descriptive Analysis** (`03_descriptive_analysis.do`): Customize summary statistics
- **Main Analysis** (`04_main_analysis.do`): Add your regression specifications
- **Robustness Checks** (`05_robustness_checks.do`): Define alternative specifications
- **Figures** (`06_generate_figures.do`): Create visualizations for your results

### 5. Configure statacons Dependencies

Edit `SConstruct` to match your file structure:

```python
# Update input file names
data_clean = env.StataBuild(
    target='data/clean/your_cleaned_data.dta',
    source='scripts/do/01_data_cleaning.do'
)
Depends(data_clean, [
    'data/raw/your_raw_data.csv',  # Update this
    'ado'
])
```

## Running the Analysis

### Option 1: Using statacons (Recommended)

```bash
# Run entire analysis pipeline
just stata-build

# Or run specific components
just stata-data      # Data cleaning and preparation only
just stata-analysis  # Analysis and tables only
just stata-figures   # Figures only

# Clean all outputs
just stata-clean
```

### Option 2: Traditional Stata Master Do-File

```bash
# Run master do-file
just stata-run

# Or directly in Stata
# do "scripts/do/00_run.do"
```

## Understanding the Workflow

### statacons Benefits

1. **Automatic dependency tracking**: Only rebuilds files when inputs change
2. **Parallel execution**: Can run independent steps simultaneously
3. **Incremental builds**: Saves time during development
4. **Explicit dependencies**: Makes workflow transparent

### File Dependencies

The default workflow follows this dependency chain:

```
data/raw/sample_data.csv
    ↓ (01_data_cleaning.do)
data/clean/cleaned_data.dta
    ↓ (02_data_preparation.do)
data/final/analysis_data.dta
    ↓ (03,04,05,06_*.do)
outputs/tables/*.tex & outputs/figures/*.pdf
```

## Best Practices

### 1. Research-Grade Standards

- **IPA Data Standards**: Follow IPA Data Cleaning Guide principles
- **Data Carpentry Methods**: Use research-grade programming techniques
  - Comprehensive data exploration and quality assessment
  - Advanced data transformation and combination techniques
  - Loop-based programming for efficiency
  - Modular programming with reusable code
- **Extended missing values**: Use IPA conventions (.d/.o/.n/.r/.s)
- **Variable naming**: Implement descriptive prefixes (e.g., `inc_`, `educ_`)
- **Defensive programming**: Use assert statements and validation checks
- **For IPA staff**: Use ipaplots scheme for branded visualizations

### 2. Data Management

- Never modify files in `data/raw/` (treat as read-only)
- Use global macros for file paths (IPA best practice)
- Use version control for code, not data files
- Document data sources and acquisition in `documentation/`

### 3. Code Organization

- Keep do-files focused on single tasks
- Use descriptive variable names following IPA conventions
- Comment extensively with [Category] prefixes in labels
- Follow the established numbering scheme
- Include quality checks and data validation

### 4. Reproducibility

- Set random seeds explicitly
- Use relative paths via global macros
- Install Stata packages in `ado/` folder
- Test your pipeline on a clean environment

### 5. Output Management

- Tables should be publication-ready LaTeX
- Figures should be high-resolution PDF
- All outputs should be generated, not manually created

## Troubleshooting

### Common Issues

1. **"Command scons not found"**
   - Make sure you've activated the virtual environment: `uv shell`
   - Ensure dependencies installed: `just get-started`

2. **Stata cannot find do-files**
   - Check that you're running from the project root directory
   - Verify file paths in SConstruct match your actual structure

3. **Missing ado files**
   - Install required Stata packages in the `ado/` folder
   - Add any new dependencies to the SConstruct file

4. **Path issues on Windows**
   - Use forward slashes in all file paths
   - Ensure no spaces in file/folder names

### Getting Help

- Check log files in `analysis/logs/` for Stata errors
- Review the statacons documentation: <https://bquistorff.github.io/statacons/>
- Consult the best practice guides referenced in README.md

## Next Steps

1. **Customize for your project**: Update all placeholder text and variable names
2. **Add documentation**: Document your research question and methods
3. **Set up git**: Initialize version control and make initial commit
4. **Test the pipeline**: Run the full workflow to ensure everything works
5. **Share with collaborators**: The template makes onboarding new team members easier

## Advanced Usage

### Adding New Analysis Steps

1. Create new do-file in `scripts/do/`
2. Add corresponding build target in `SConstruct`
3. Specify dependencies using `Depends()`
4. Update master do-file if using traditional workflow

### Custom Stata Settings

- Modify `00_run.do` to change global Stata settings
- Add project-specific ado files to `ado/` folder
- Use `adopath` commands in do-files to manage package locations

### Integration with LaTeX

- Tables are generated in LaTeX format for easy integration
- Use `\input{}` commands in your paper to include tables
- Consider using a document build system like Quarto for full reproducibility
