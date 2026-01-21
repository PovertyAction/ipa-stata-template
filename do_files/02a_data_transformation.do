/*==============================================================================
DATA TRANSFORMATION TECHNIQUES
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Advanced data transformation using Data Carpentry best practices
Input:       data/clean/cleaned_data.dta
Output:      data/clean/transformed_data.dta

Notes:       - Assumes globals are set by 00_run.do
             - Can be run standalone via: do 00_run.do "02a_data_transformation"
             - Implements Data Carpentry transformation techniques
             - Includes variable creation, filtering, and aggregation

References:
- Data Carpentry Stata Economics: https://datacarpentry.github.io/stata-economics/

==============================================================================*/

/*==============================================================================
                    STANDALONE INITIALIZATION
==============================================================================*/
* %%
// Check if already initialized by 00_run.do
if "${project_path}" == "" {

    di _n(2) "{hline 60}"
    di "STANDALONE EXECUTION DETECTED"
    di "{hline 60}"

    // 1. Clear and setup environment
    clear all
    macro drop _all
    capture log close _all
    set more off

    // 2. Find project root with setroot
    capture setroot, verbose
    if _rc != 0 {
        di as error "ERROR: Could not find project root"
        di as error "Ensure setroot is installed: ssc install setroot"
        di as error "Or run from project directory"
        exit 601
    }
    global project_path "${root}"

    // 3. Environment setup with ieboilstart
    ieboilstart, versionnumber(17.0) adopath("${project_path}/ado", strict)

    // 4. Load user configuration (if exists)
    capture confirm file "${project_path}/config.do"
    if _rc == 0 {
        di as text "Loading user configuration from config.do"
        do "${project_path}/config.do"
    }

    // 5. Set default paths
    if "${data_root}" == "" {
        global data_root "${project_path}/data"
    }

    // 6. Define standard paths
    if "${data_raw}" == "" global data_raw "${data_root}/raw"
    if "${data_clean}" == "" global data_clean "${data_root}/clean"
    if "${data_final}" == "" global data_final "${data_root}/final"

    global scripts "${project_path}/do_files"
    global outputs "${project_path}/outputs"
    global logs "${project_path}/logs"
    global tables "${outputs}/tables"
    global figures "${outputs}/figures"

    // 7. Load functions
    do "${scripts}/functions.do"

    // 8. Validate paths
    validate_paths

    di "{hline 60}"
    di "INITIALIZATION COMPLETED"
    di "Project root: ${project_path}"
    di "{hline 60}" _n
}
else {
    di _n "Running via 00_run.do (initialization already complete)" _n
}

* %%
// Start log file
capture log close
log using "${logs}/02a_data_transformation.log", replace

* %%
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

* %%
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
keep if !missing(age) & !missing(income) & !missing(education)

count
local filtered_n = r(N)
local dropped = `original_n' - `filtered_n'

di "Dropped " `dropped' " observations with missing key variables"
di "Remaining observations: " `filtered_n'

* %%
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
generate inc_log = log(income) if income > 0
label variable inc_log "[Derived] Log of total income"

generate inc_per_educ_year = income / education if education > 0
label variable inc_per_educ_year "[Derived] Income per year of education"

* %%
/*==============================================================================
                    AGGREGATION USING EGEN
==============================================================================*/

di _n(2) "{hline 40}"
di "DATA AGGREGATION WITH EGEN"
di "{hline 40}"

// Calculate group statistics by gender and education level
egen inc_mean_by_gender = mean(income), by(female)
label variable inc_mean_by_gender "[Derived] Mean income by gender"

egen inc_mean_by_educ = mean(income), by(educ_level)
label variable inc_mean_by_educ "[Derived] Mean income by education level"

// Count observations by group
egen n_by_age_group = count(id), by(age_group_detailed)
label variable n_by_age_group "[Derived] Count of observations by age group"

// Create percentile ranks
egen inc_rank = rank(income), unique
local ngroups = min(100, _N)
egen inc_percentile = cut(inc_rank), group(`ngroups')
label variable inc_percentile "[Derived] Income percentile (0-`=`ngroups'-1')"

* %%
/*==============================================================================
                    LOOP-BASED PROGRAMMING
==============================================================================*/

di _n(2) "{hline 40}"
di "LOOP-BASED VARIABLE CREATION"
di "{hline 40}"

// Using loops for efficient programming
// Create standardized versions of multiple variables
local vars_to_standardize "age income education"

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

* %%
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

* %%
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
di "Output saved to: ${data_clean}/transformed_data.dta"
di "{hline 60}"

* %%
// Close log
log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
