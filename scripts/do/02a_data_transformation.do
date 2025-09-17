/*==============================================================================
DATA TRANSFORMATION TECHNIQUES
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Advanced data transformation using Data Carpentry best practices
Input:       data/clean/cleaned_data.dta
Output:      data/clean/transformed_data.dta

Notes:       - Implements Data Carpentry transformation techniques
             - Includes variable creation, filtering, and aggregation
             - Demonstrates loop-based programming for efficiency

References:
- Data Carpentry Stata Economics: https://datacarpentry.github.io/stata-economics/

==============================================================================*/

// Boilerplate code
version 17
clear all
macro drop _all
set more off
set varabbrev off

// Define global paths for reproducibility
global project_path "`c(pwd)'"
global data_clean "${project_path}/data/clean"
global logs "${project_path}/analysis/logs"

// Start log file
capture log close
log using "${logs}/02a_data_transformation.log", replace

/*==============================================================================
                            LOAD CLEANED DATA
==============================================================================*/

use "${data_clean}/cleaned_data.dta", clear

// Verify data integrity
datasignature confirm

di _n(2) "{hline 60}"
di "DATA TRANSFORMATION"
di "{hline 60}"
di "Starting observations: " _N

/*==============================================================================
                    FILTERING DATA
==============================================================================*/

di _n(2) "{hline 40}"
di "FILTERING DATA"
di "{hline 40}"

// Keep only observations with non-missing key variables
count
local original_n = r(N)

// Use filtering approach
keep if !missing(age) & !missing(inc_total) & !missing(educ_years)

count
local filtered_n = r(N)
local dropped = `original_n' - `filtered_n'

di "Dropped " `dropped' " observations with missing key variables"
di "Remaining observations: " `filtered_n'

/*==============================================================================
                    VARIABLE CREATION
==============================================================================*/

di _n(2) "{hline 40}"
di "CREATING NEW VARIABLES"
di "{hline 40}"

// 1. Basic variable generation
generate age_squared = age^2
label variable age_squared "[Derived] Age squared for quadratic models"

// 2. Conditional variable creation
generate age_group_detailed = .
replace age_group_detailed = 1 if age >= 18 & age <= 25
replace age_group_detailed = 2 if age > 25 & age <= 35
replace age_group_detailed = 3 if age > 35 & age <= 50
replace age_group_detailed = 4 if age > 50 & !missing(age)

label define age_detail_lbl 1 "18-25" 2 "26-35" 3 "36-50" 4 "51+"
label values age_group_detailed age_detail_lbl
label variable age_group_detailed "[Derived] Detailed age categories"

// 3. Income transformations
generate inc_log = log(inc_total) if inc_total > 0
label variable inc_log "[Derived] Log of total income"

generate inc_per_educ_year = inc_total / educ_years if educ_years > 0
label variable inc_per_educ_year "[Derived] Income per year of education"

/*==============================================================================
                    AGGREGATION USING EGEN
==============================================================================*/

di _n(2) "{hline 40}"
di "DATA AGGREGATION WITH EGEN"
di "{hline 40}"

// Calculate group statistics by gender and education level
egen inc_mean_by_gender = mean(inc_total), by(female)
label variable inc_mean_by_gender "[Derived] Mean income by gender"

egen inc_mean_by_educ = mean(inc_total), by(educ_level)
label variable inc_mean_by_educ "[Derived] Mean income by education level"

// Count observations by group
egen n_by_age_group = count(id), by(age_group_detailed)
label variable n_by_age_group "[Derived] Count of observations by age group"

// Create percentile ranks
egen inc_rank = rank(inc_total), unique
egen inc_percentile = cut(inc_rank), group(100)
label variable inc_percentile "[Derived] Income percentile (0-99)"

/*==============================================================================
                    LOOP-BASED PROGRAMMING
==============================================================================*/

di _n(2) "{hline 40}"
di "LOOP-BASED VARIABLE CREATION"
di "{hline 40}"

// Using loops for efficient programming
// Create standardized versions of multiple variables
local vars_to_standardize "age inc_total educ_years"

foreach var of local vars_to_standardize {
    // Create z-scores (standardized variables)
    egen `var'_std = std(`var')
    label variable `var'_std "[Derived] Standardized `var' (z-score)"

    // Create percentile ranks
    egen `var'_pctile = rank(`var'), unique
    replace `var'_pctile = (`var'_pctile - 1) / (_N - 1) * 100
    label variable `var'_pctile "[Derived] Percentile rank of `var'"

    di "Created standardized variables for: `var'"
}

// Loop through age groups to create interaction terms
forvalues i = 1/4 {
    generate female_x_age_group`i' = female * (age_group_detailed == `i')
    label variable female_x_age_group`i' "[Derived] Female × Age group `i' interaction"
}

/*==============================================================================
                    FINAL DATA CHECKS AND SAVE
==============================================================================*/

// Always check your transformations
di _n(2) "{hline 40}"
di "FINAL DATA QUALITY CHECKS"
di "{hline 40}"

// Check that new variables were created successfully
describe *_std *_pctile female_x_age_group*

// Verify no missing values introduced inappropriately
foreach var of varlist *_std *_pctile {
    count if missing(`var')
    if r(N) > 0 {
        di "WARNING: `var' has " r(N) " missing values"
    }
}

// Summary of transformation results
count
di "Final dataset has " r(N) " observations and " c(k) " variables"

// Save transformed dataset
compress
save "${data_clean}/transformed_data.dta", replace

di _n(2) "{hline 60}"
di "DATA TRANSFORMATION COMPLETED"
di "Transformations applied:"
di "  - Filtered data for completeness"
di "  - Created derived variables"
di "  - Generated group statistics"
di "  - Applied loop-based standardization"
di "  - Created interaction terms"
di "Output saved to: data/clean/transformed_data.dta"
di "{hline 60}"

// Close log
log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
