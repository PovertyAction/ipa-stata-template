/*==============================================================================
DATA CLEANING
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Clean raw data and prepare for analysis
Input:       data/raw/sample_data.csv
Output:      data/clean/cleaned_data.dta

Notes:       - Follows IPA Data Cleaning Guide and Stata coding standards
             - Implements IPA best practices for raw data management
             - Uses IPA extended missing value conventions
             - All variable names use lowercase with underscores

==============================================================================*/

// Boilerplate code following IPA guidelines
version 17
clear all
macro drop _all
set more off
set varabbrev off

// Define global paths for reproducibility (IPA best practice)
global project_path "`c(pwd)'"
global data_raw "${project_path}/data/raw"
global data_clean "${project_path}/data/clean"
global data_final "${project_path}/data/final"
global outputs "${project_path}/outputs"
global logs "${project_path}/analysis/logs"

// Load standard functions
do "${project_path}/scripts/do/functions.do"

// Validate project structure and dependencies
validate_paths
validate_pipeline

// Start log file
capture log close
log using "analysis/logs/01_data_cleaning.log", replace

/*==============================================================================
                            LOAD RAW DATA
==============================================================================*/

// Load raw data using global path
import delimited "${data_raw}/sample_data.csv", clear

// Assert basic data structure expectations
assert _N > 0
assert _N < 100000  // Reasonable upper bound for sample size

/*==============================================================================
              INITIAL DATA EXPLORATION
==============================================================================*/

// Run comprehensive data quality report
data_quality_report "Raw Data Import"

// 5. Random sample inspection
set seed 12345  // For reproducibility
if _N > 1000 {
    di _n(1) "Large dataset detected. Showing random sample of 10 observations:"
    preserve
    sample 10, count
    list in 1/10
    restore  // This will restore full dataset
}
else {
    di _n(1) "Showing first 10 observations:"
    list in 1/10
}

/*==============================================================================
                            DATA CLEANING
==============================================================================*/

// Rename variables to follow IPA naming conventions (lowercase, underscores)
capture rename ID id
capture rename Age age
capture rename Gender gender
capture rename Income income  // Keep simple name for analysis compatibility
capture rename Education education

// Convert ID to string if not already
capture tostring id, replace

/*==============================================================================
                    KEY VERIFICATION (CRITICAL)
==============================================================================*/

// CRITICAL REQUIREMENT: Verify unique, non-missing keys
// This is the most important standard - data must have valid unique identifiers
verify_keys id

// Document analysis unit for reproducibility (documentation standard)
di _n(2) "{hline 60}"
di "ANALYSIS UNIT DOCUMENTATION"
di "{hline 60}"
di "Unit of analysis: Individual participants"
di "Key variable(s): id"
di "Dataset represents: [Describe what each observation represents]"
di "Time period: [Specify time period if relevant]"
di "Geographic scope: [Specify geographic coverage]"
di "{hline 60}" _n

// Check for and handle missing values using extended missing value conventions
foreach var of varlist _all {
    count if missing(`var')
    if r(N) > 0 {
        di "Variable `var' has " r(N) " missing values"
    }
}

/*==============================================================================
                    DATA QUALITY ASSESSMENT
==============================================================================*/

// Comprehensive data quality checks
di _n(2) "{hline 60}"
di "DATA QUALITY ASSESSMENT"
di "{hline 60}"

// 1. Check for duplicate observations
duplicates report
if r(unique_value) != r(N) {
    di as error "WARNING: " r(N) - r(unique_value) " duplicate observations found"
    duplicates list
}

// 2. Inspect numeric variables for outliers and unreasonable values
foreach var of varlist _all {
    capture confirm numeric variable `var'
    if _rc == 0 {
        quietly summarize `var', detail
        local p1 = r(p1)
        local p99 = r(p99)
        local mean = r(mean)
        local sd = r(sd)

        di _n(1) "Variable `var' quality check:"
        di "  Range: " r(min) " to " r(max)
        di "  Mean: " %9.2f `mean' ", SD: " %9.2f `sd'

        // Flag extreme outliers (beyond 3 standard deviations)
        quietly count if `var' > (`mean' + 3*`sd') | `var' < (`mean' - 3*`sd') & !missing(`var')
        if r(N) > 0 {
            di "  WARNING: " r(N) " extreme outliers (>3 SD from mean)"
        }

        // Check for negative values where inappropriate
        if "`var'" == "age" | "`var'" == "income" | "`var'" == "education" {
            quietly count if `var' < 0 & !missing(`var')
            if r(N) > 0 {
                di as error "  ERROR: " r(N) " negative values in `var' (should be positive)"
            }
        }
    }
}

// 3. Check string variables for consistency
foreach var of varlist _all {
    capture confirm string variable `var'
    if _rc == 0 {
        di _n(1) "String variable `var' unique values:"
        levelsof `var', clean
        local num_unique : word count `r(levels)'
        if `num_unique' > 20 {
            di "  Has " `num_unique' " unique values (showing first 10):"
            levelsof `var' in 1/10, clean
        }
    }
}

// Apply extended missing value standards where appropriate
// .d = "Don't know", .o = "Other", .n = "Not applicable", .r = "Refusal", .s = "Skip"
// Note: This would be customized based on actual survey data structure

// Clean string variables following variable management guidelines
capture {
    // Standardize gender variable using practices
    replace gender = lower(trim(gender)) if !missing(gender)
    replace gender = "male" if inlist(gender, "m", "man", "male")
    replace gender = "female" if inlist(gender, "f", "woman", "female")

    // Convert categorical string to numeric with labels (best practice)
    encode gender, generate(gender_num)
    drop gender
    rename gender_num gender

    // Create indicator variable with descriptive name (naming convention)
    generate female = (gender == 2)  // Assuming "female" is encoded as 2
    label variable female "[Demographics] 1 if female, 0 if male"

    // Add value labels
    label define gender_lbl 1 "Male" 2 "Female"
    label values gender gender_lbl
    label variable gender "[Demographics] Gender of respondent"
}

// Clean numeric variables following practices
capture {
    // Use naming convention and assert reasonable ranges
    assert income >= 0 if !missing(income)
    assert income < 1000000 if !missing(income)  // Reasonable upper bound

    summarize income, detail
    local p99 = r(p99)
    local p1 = r(p1)

    // Flag potential outliers with descriptive variable name
    generate inc_outlier_flag = (income > `p99' | income < `p1') if !missing(income)
    label variable inc_outlier_flag "[Quality] 1 if income is potential outlier (p1/p99)"

    // Log transformation for skewed variables
    generate log_income = log(income) if income > 0
    label variable log_income "[Derived] Log of total income"

    // Compress numeric variables to save space
    compress income log_income
}

// Generate additional variables following conventions
capture {
    // Assert reasonable age range
    assert age >= 0 & age <= 120 if !missing(age)

    // Age categories with naming and labeling
    generate age_cat = .
    replace age_cat = 1 if age >= 18 & age < 30
    replace age_cat = 2 if age >= 30 & age < 50
    replace age_cat = 3 if age >= 50 & age < 65
    replace age_cat = 4 if age >= 65 & !missing(age)

    label define age_cat_lbl 1 "18-29" 2 "30-49" 3 "50-64" 4 "65+"
    label values age_cat age_cat_lbl
    label variable age_cat "[Derived] Age group categories"

    // Education level categories
    generate educ_level = .
    replace educ_level = 1 if educ_years <= 8
    replace educ_level = 2 if educ_years > 8 & educ_years <= 12
    replace educ_level = 3 if educ_years > 12 & educ_years <= 16
    replace educ_level = 4 if educ_years > 16 & !missing(educ_years)

    label define educ_lbl 1 "Primary" 2 "Secondary" 3 "Tertiary" 4 "Graduate"
    label values educ_level educ_lbl
    label variable educ_level "[Derived] Education level"
    label variable educ_years "[Demographics] Years of education"
}

/*==============================================================================
                            DATA VALIDATION
==============================================================================*/

// Data quality checks following IPA practices
describe
summarize
codebook, compact

// Check for duplicates using defensive programming
duplicates report id
if r(unique_value) != r(N) {
    di as error "ERROR: Duplicate IDs found - this violates data integrity!"
    duplicates list id
    error 459  // Halt execution if duplicates found
}

// Additional data validation checks
assert _N > 0  // Ensure data exists
count if missing(id)
if r(N) > 0 {
    di as error "ERROR: Missing ID values found"
    error 459
}

// Generate flag for complete cases
egen missing_count = rowmiss(_all)
generate complete_case = (missing_count == 0)
label variable complete_case "1 if no missing values across all variables"

// Display cleaning summary
di _n(2) "{hline 60}"
di "DATA CLEANING SUMMARY"
di "{hline 60}"
di "Original observations: " _N
count if complete_case == 1
di "Complete cases: " r(N)
di "Variables created: " c(k)
di "{hline 60}"

/*==============================================================================
                            SAVE CLEANED DATA
==============================================================================*/

// Add data signature for integrity checking
datasignature set, reset

// Sort by ID for consistency
sort id

// Save cleaned dataset using global path
save "${data_clean}/cleaned_data.dta", replace

// Close log
log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
