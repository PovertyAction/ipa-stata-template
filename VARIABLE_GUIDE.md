# Variable Guide for IPA Stata Template Exercise

## Variable Naming Conventions

This document tracks all variables used across the dofiles to ensure consistency and compatibility.

## Raw Data Variables (sample_data.csv)

| Variable | Type | Description |
|----------|------|-------------|
| `ID` | String | Unique identifier |
| `Age` | Numeric | Age in years (18-80) |
| `Gender` | String | "Male" or "Female" |
| `Income` | Numeric | Annual income in dollars |
| `Education` | Numeric | Years of education (6-20) |

## Variables by Dofile

### 01_data_cleaning.do

**Input Variables** (from CSV):

- `ID` → renamed to `id`
- `Age` → renamed to `age`
- `Gender` → renamed to `gender`
- `Income` → renamed to `income`
- `Education` → renamed to `education`

**Created Variables**:

- `female` - Binary indicator (1=female, 0=male)
- `gender` - Numeric with labels (1=Male, 2=Female)
- `log_income` - Natural log of income
- `inc_outlier_flag` - Outlier indicator based on p1/p99
- `age_cat` - Age categories (1="18-29", 2="30-49", 3="50-64", 4="65+")
- `educ_years` - Same as education, renamed for clarity
- `educ_level` - Education categories (1="Primary", 2="Secondary", 3="Tertiary", 4="Graduate")
- `missing_count` - Count of missing values per row
- `complete_case` - Indicator for complete cases

**Note**: The dofile expects to rename `Education` to `educ_years`, but this may conflict with other references. Consider harmonizing.

### 02_data_preparation.do

**Input Variables** (from cleaned_data.dta):

- `id`, `age`, `income`, `log_income`, `female`, `education`

**Created Variables**:

- `age_std` - Standardized age (z-score)
- `income_std` - Standardized income (z-score)
- `female_x_age` - Interaction term
- `female_x_income` - Interaction term
- `age_squared` - Quadratic age term
- `income_quintile` - Income quintiles (1-5)
- `education_level` - Education categories (if not already created)
- `analysis_sample` - Main analysis sample indicator
- `outlier_income` - Income outlier flag (referenced but should exist from 01)
- `male_sample` - Male subsample indicator
- `female_sample` - Female subsample indicator
- `young_sample` - Age < 40 subsample
- `old_sample` - Age >= 40 subsample

### 03_descriptive_analysis.do

**Required Variables**:

- `id` - Identifier
- `analysis_sample` - Sample indicator
- `age`, `income`, `log_income` - Main variables
- `female` - Gender indicator
- `education` or `educ_years` - Education variable
- `education_level` - Education categories
- `age_cat` - Age categories

### 04_main_analysis.do

**Required Variables**:

- `id` - Identifier
- `analysis_sample` - Sample indicator
- `log_income` - Dependent variable
- `female` - Main independent variable
- `age`, `age_squared` - Age variables
- `education` or `educ_years` - Education control
- `female_x_age` - Interaction term

**Optional Variables**:

- `cluster_var` - For clustered standard errors (not in synthetic data)

### 05_robustness_checks.do

**Required Variables**:

- All variables from 04_main_analysis.do
- `income` - For level models
- `education` or `educ_years` - Education
- `analysis_sample` - Sample indicator

**Created Variables**:

- `age_squared` - If not already created
- `age_cubed` - Cubic age term
- `age_spline` - Age spline (breakpoint at 40)
- `expanded_sample` - Alternative sample definition

### 06_generate_figures.do

**Required Variables**:

- `id` - Identifier
- `analysis_sample` - Sample indicator
- `log_income`, `income` - Outcome variables
- `age`, `education` - Continuous variables
- `female` - Gender indicator
- `educ_level` - Education categories (if creating box plots)

**Created Variables** (temporary):

- `fitted_values` - Predicted values from regression
- `residuals` - Regression residuals

### 07_advanced_programming.do

**Required Variables**:
The dofile references variables with different naming:

- `id`
- `age`
- `female`
- `inc_total` - **Note**: This should be `income`
- `inc_total_log` - **Note**: This should be `log_income`
- `educ_years` - Education in years
- `educ_level` - Education categories
- `analysis_sample` - Sample indicator

## Variable Name Inconsistencies to Fix

The current dofiles have some naming inconsistencies:

### Income Variables

- 01-06 use: `income`, `log_income`
- 07 expects: `inc_total`, `inc_total_log`

**Recommended fix**: Update 07 to use `income` and `log_income` for consistency.

### Education Variables

- 01 creates: `educ_years`, `educ_level`
- 02-06 reference: `education` or `educ_years` inconsistently

**Recommended fix**: Standardize on `educ_years` for continuous and `educ_level` for categories.

## Modifications Made for Compatibility

To make the dofiles work with the synthetic data, the following adjustments were needed:

1. **01_data_cleaning.do**:
   - Added line to create `educ_years` from `education`
   - Ensured `income` variable is named correctly

2. **02_data_preparation.do**:
   - References to `outlier_income` should match `inc_outlier_flag` from 01

3. **07_advanced_programming.do**:
   - Should be updated to use `income` instead of `inc_total`
   - Should use `log_income` instead of `inc_total_log`

## Essential Variables Summary

For the pipeline to work correctly, these variables must exist after data cleaning:

| Variable | Type | Required For | Created In |
|----------|------|--------------|------------|
| `id` | String | All scripts | 01 (renamed) |
| `age` | Numeric | All scripts | 01 (renamed) |
| `female` | Binary | Analysis scripts | 01 |
| `income` | Numeric | All scripts | 01 (renamed) |
| `log_income` | Numeric | Analysis scripts | 01 |
| `educ_years` | Numeric | All scripts | 01 |
| `educ_level` | Categorical | Descriptive/figures | 01 |
| `age_cat` | Categorical | Descriptive | 01 |
| `age_squared` | Numeric | Regressions | 02 or later |
| `analysis_sample` | Binary | All analysis | 02 |

## Quick Fix for Variable Names

If you encounter errors about missing variables, add these lines to the relevant dofile:

```stata
// Harmonize income variable names
capture rename income inc_total
capture generate inc_total = income
capture rename log_income inc_total_log
capture generate inc_total_log = log_income

// Harmonize education variable names
capture rename education educ_years
capture generate educ_years = education
```

Or better yet, update the dofiles to use consistent naming throughout.
