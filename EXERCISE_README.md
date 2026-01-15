# IPA Stata Template Applied Exercise

## Overview

This exercise provides hands-on practice with the IPA Stata template workflow using a synthetic dataset. You'll learn how to run a complete data analysis pipeline from raw data cleaning through advanced programming techniques.

## Dataset Description

The synthetic dataset (`data/raw/sample_data.csv`) contains **1,000 observations** with the following variables:

### Variables

| Variable | Description | Type | Notes |
|----------|-------------|------|-------|
| `ID` | Unique identifier | String | Contains 3 intentional duplicates for testing |
| `Age` | Age of individual | Numeric | Range: 18-80 years |
| `Gender` | Gender | String | Values: "Male", "Female" |
| `Income` | Annual income | Numeric | Log-normal distribution with outliers |
| `Education` | Years of education | Numeric | Range: 6-20 years |

### Data Features

The dataset includes realistic features for teaching data cleaning:

- **Duplicates**: 3 duplicate IDs to test duplicate detection
- **Missing values**:
  - Income: ~2% missing (20 observations)
  - Education: ~1% missing (10 observations)
- **Outliers**: 5 extreme income values for outlier handling practice
- **Correlations**:
  - Income increases with education (8% per year)
  - Income has a quadratic relationship with age (peaks around 50)
  - Gender pay gap: females earn ~15% less on average

## Exercise Structure

The exercise follows the complete IPA analysis pipeline with 8 dofiles:

### 0. Master Script

- **File**: [`00_run.do`](scripts/do/00_run.do)
- **Purpose**: Runs the entire analysis pipeline
- **What you'll learn**:
  - Project structure and global paths
  - Control switches for flexible workflows
  - Reproducibility best practices

### 1. Data Cleaning

- **File**: [`01_data_cleaning.do`](scripts/do/01_data_cleaning.do)
- **Input**: `data/raw/sample_data.csv`
- **Output**: `data/clean/cleaned_data.dta`
- **What you'll learn**:
  - Loading raw CSV data
  - IPA naming conventions (lowercase with underscores)
  - Key verification (checking for unique IDs)
  - Duplicate detection and handling
  - Missing value management
  - Outlier identification
  - Creating derived variables (age categories, education levels)
  - Data validation and quality checks

### 2. Data Preparation

- **File**: [`02_data_preparation.do`](scripts/do/02_data_preparation.do)
- **Input**: `data/clean/cleaned_data.dta`
- **Output**: `data/final/analysis_data.dta`
- **What you'll learn**:
  - Creating analysis variables
  - Standardization (z-scores)
  - Interaction terms
  - Sample restrictions
  - Creating analysis subsamples

### 3. Descriptive Analysis

- **File**: [`03_descriptive_analysis.do`](scripts/do/03_descriptive_analysis.do)
- **Input**: `data/final/analysis_data.dta`
- **Output**: `outputs/tables/descriptive_stats.tex`
- **What you'll learn**:
  - Summary statistics tables
  - Frequency tables
  - Correlation matrices
  - T-tests and chi-square tests
  - Sample representativeness checks

### 4. Main Analysis

- **File**: [`04_main_analysis.do`](scripts/do/04_main_analysis.do)
- **Input**: `data/final/analysis_data.dta`
- **Output**: `outputs/tables/main_results.tex`
- **What you'll learn**:
  - OLS regression
  - Adding control variables
  - Interaction terms
  - Robust standard errors
  - Hypothesis testing
  - Marginal effects
  - Effect size interpretation

### 5. Robustness Checks

- **File**: [`05_robustness_checks.do`](scripts/do/05_robustness_checks.do)
- **Input**: `data/final/analysis_data.dta`
- **Output**: `outputs/tables/robustness_*.tex`
- **What you'll learn**:
  - Alternative functional forms (linear, log, quadratic)
  - Quantile regression
  - Subsample analysis
  - Outlier sensitivity
  - Alternative sample definitions

### 6. Generate Figures

- **File**: [`06_generate_figures.do`](scripts/do/06_generate_figures.do)
- **Input**: `data/final/analysis_data.dta`
- **Output**: `outputs/figures/*.pdf`
- **What you'll learn**:
  - IPA graph scheme (ipaplots)
  - Publication-ready figures
  - Histograms and distributions
  - Box plots
  - Coefficient plots
  - Marginal effects plots
  - Residual diagnostics
  - Multi-panel figures

### 7. Advanced Programming

- **File**: [`07_advanced_programming.do`](scripts/do/07_advanced_programming.do)
- **Input**: `data/final/analysis_data.dta`
- **Output**: Various
- **What you'll learn**:
  - Advanced macros and loops
  - Temporary files and variables
  - Preserve/restore techniques
  - Dynamic variable creation
  - Error handling
  - Modular programming
  - Data reshaping

## How to Run the Exercise

### Option 1: Run Everything (Recommended for first time)

```stata
cd "C:\Users\IPACOLPC105\scratch\ipa-stata-template"
do scripts/do/00_run.do
```

This will run the complete analysis pipeline from start to finish.

### Option 2: Run Individual Scripts

Run scripts sequentially for step-by-step learning:

```stata
cd "C:\Users\IPACOLPC105\scratch\ipa-stata-template"

// 1. Data cleaning
do scripts/do/01_data_cleaning.do

// 2. Data preparation
do scripts/do/02_data_preparation.do

// 3. Descriptive analysis
do scripts/do/03_descriptive_analysis.do

// 4. Main analysis
do scripts/do/04_main_analysis.do

// 5. Robustness checks
do scripts/do/05_robustness_checks.do

// 6. Generate figures
do scripts/do/06_generate_figures.do

// 7. Advanced programming
do scripts/do/07_advanced_programming.do
```

### Option 3: Selective Execution

Edit the control switches in [`00_run.do`](scripts/do/00_run.do):

```stata
local data_cleaning         = 1  // Set to 0 to skip
local data_preparation      = 1
local descriptive_analysis  = 1
local main_analysis         = 1
local robustness_checks     = 1
local generate_figures      = 1
```

## Expected Outputs

After running the complete pipeline, you should have:

### Data Files

- `data/clean/cleaned_data.dta` - Cleaned dataset
- `data/final/analysis_data.dta` - Analysis-ready dataset

### Log Files

- `analysis/logs/01_data_cleaning.log`
- `analysis/logs/02_data_preparation.log`
- `analysis/logs/03_descriptive_analysis.log`
- `analysis/logs/04_main_analysis.log`
- `analysis/logs/05_robustness_checks.log`
- `analysis/logs/06_generate_figures.log`
- `analysis/logs/07_advanced_programming.log`

### Tables (LaTeX format)

- `outputs/tables/descriptive_stats.tex`
- `outputs/tables/descriptive_by_gender.tex`
- `outputs/tables/correlations.tex`
- `outputs/tables/main_results.tex`
- `outputs/tables/robustness_*.tex`

### Figures (PDF format)

- `outputs/figures/figure1_income_distribution.pdf`
- `outputs/figures/figure2_coefficients.pdf`
- `outputs/figures/figure3_residuals_fitted.pdf`
- `outputs/figures/combined_summary.pdf`
- And more...

## Learning Objectives

By completing this exercise, you will:

1. **Understand the IPA analysis workflow**
   - Structured project organization
   - Reproducible research practices
   - Documentation standards

2. **Master data cleaning techniques**
   - Handling duplicates and missing values
   - Outlier detection
   - Data validation
   - Variable creation and labeling

3. **Conduct professional statistical analysis**
   - Descriptive statistics
   - Regression analysis
   - Robustness checks
   - Model diagnostics

4. **Create publication-ready outputs**
   - LaTeX tables
   - Professional figures
   - Comprehensive documentation

5. **Apply advanced programming concepts**
   - Macros and loops
   - Modular code
   - Error handling
   - Efficient workflows

## Key Findings from the Synthetic Data

When you run the analysis, you should observe:

1. **Gender wage gap**: Female coefficient around -0.15 (15% lower income)
2. **Education returns**: ~8% income increase per year of education
3. **Age-income profile**: Quadratic relationship peaking around age 50
4. **Robust results**: Findings should be consistent across specifications

## Troubleshooting

### Common Issues

1. **Missing packages**: If you encounter errors about missing commands:

   ```stata
   ssc install estout, replace
   ssc install reghdfe, replace
   ssc install coefplot, replace
   ```

2. **Path issues**: Ensure you're running from the project root directory

3. **Log file errors**: Close any open log files before running scripts

4. **Data not found**: Make sure the synthetic data was generated:

   ```bash
   python scripts/python/generate_fake_data.py
   ```

## Additional Resources

- **IPA Data Cleaning Guide**: <https://data.poverty-action.org/data-cleaning/>
- **IPA Stata Tutorials**: <https://data.poverty-action.org/software/stata/>
- **Data Carpentry Stata Economics**: <https://datacarpentry.github.io/stata-economics/>
- **Sean Higgins Stata Guide**: <https://github.com/skhiggins/Stata_guide>
- **DIME Analytics Coding Guide**: <https://worldbank.github.io/dime-data-handbook/coding.html>

## Exercise Extensions

Once you've mastered the basic workflow, try these extensions:

1. **Modify the data generation script** to:
   - Add new variables (race, region, industry)
   - Change the data generating process
   - Increase sample size

2. **Extend the analysis** to:
   - Test different hypotheses
   - Add more control variables
   - Try different estimation methods

3. **Customize the outputs** to:
   - Change table formats
   - Create new visualizations
   - Generate additional diagnostics

4. **Apply to your own data**:
   - Use this template for your research
   - Adapt the workflow to your needs
   - Follow IPA best practices

## Questions and Feedback

If you encounter issues or have suggestions for improving this exercise, please:

- Review the log files for error messages
- Check the IPA resources linked above
- Consult the DIME Analytics guidelines

---

**Generated**: 2026-01-13
**Dataset**: 1,000 synthetic observations
**Purpose**: Training and demonstration of IPA Stata workflows
