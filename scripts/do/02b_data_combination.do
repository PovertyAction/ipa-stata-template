/*==============================================================================
DATA COMBINATION TECHNIQUES
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Demonstrate data combination using Data Carpentry best practices
Input:       Multiple datasets for merging and appending examples
Output:      data/final/combined_data.dta

Notes:       - Implements Data Carpentry merge and append techniques
             - Demonstrates best practices for data combination
             - Includes validation and error checking

References:
- Data Carpentry Stata Economics: https://datacarpentry.github.io/stata-economics/

==============================================================================*/

// Boilerplate code following IPA guidelines
version 17
clear all
macro drop _all
set more off
set varabbrev off

// Define global paths for reproducibility
global project_path "`c(pwd)'"
global data_clean "${project_path}/data/clean"
global data_final "${project_path}/data/final"
global logs "${project_path}/analysis/logs"

// Start log file
capture log close
log using "${logs}/02b_data_combination.log", replace

/*==============================================================================
                    CREATE EXAMPLE DATASETS FOR DEMONSTRATION
==============================================================================*/

di _n(2) "{hline 60}"
di "DATA COMBINATION USING DATA CARPENTRY METHODS"
di "{hline 60}"

// Load the main dataset
use "${data_clean}/cleaned_data.dta", clear

// Create example datasets to demonstrate combination techniques
preserve

// Create Dataset 1: Additional demographic information
keep if _n <= 20  // Keep first 20 observations
keep id female age
generate country = "Country_A" if _n <= 10
replace country = "Country_B" if _n > 10
generate survey_year = 2023
save "${data_clean}/demo_demographics.dta", replace

// Create Dataset 2: Economic information
restore
preserve
keep if _n <= 15  // Overlap with first dataset
keep id inc_total educ_years
generate employment_status = "Employed" if uniform() > 0.3
replace employment_status = "Unemployed" if missing(employment_status)
save "${data_clean}/demo_economics.dta", replace

// Create Dataset 3: Additional survey wave (for appending)
restore
preserve
replace id = id + 1000  // Different IDs to simulate different wave
keep id female age inc_total
generate survey_wave = 2
save "${data_clean}/demo_wave2.dta", replace

restore

/*==============================================================================
                    APPENDING DATA
==============================================================================*/

di _n(2) "{hline 40}"
di "APPENDING DATASETS"
di "{hline 40}"

// Append datasets with same variables, different observations
use "${data_clean}/cleaned_data.dta", clear

// Add survey wave identifier to original data
generate survey_wave = 1
label variable survey_wave "Survey wave number"

count
local wave1_n = r(N)
di "Wave 1 observations: " `wave1_n'

// Append second wave
append using "${data_clean}/demo_wave2.dta"

// Fill in missing survey_wave for appended data
replace survey_wave = 2 if missing(survey_wave)

count
local total_n = r(N)
local wave2_n = `total_n' - `wave1_n'

di "Wave 2 observations: " `wave2_n'
di "Total after append: " `total_n'

// Always check append results
tab survey_wave, missing

/*==============================================================================
                    MERGING DATA
==============================================================================*/

di _n(2) "{hline 40}"
di "MERGING DATASETS"
di "{hline 40}"

// Start fresh with main dataset for merge demonstration
use "${data_clean}/cleaned_data.dta", clear
keep if _n <= 20  // Keep subset for clear demonstration

count
local master_n = r(N)
di "Master dataset observations: " `master_n'

/*------------------------------------------------------------------------------
                    Many-to-One Merge
------------------------------------------------------------------------------*/

// Demonstrate many-to-one merge
di _n(1) "=== MANY-TO-ONE MERGE ==="

// First merge: Add demographic information
merge 1:1 id using "${data_clean}/demo_demographics.dta", keep(master match)

// Always examine merge results
di "Merge results for demographics:"
tab _merge
rename _merge _merge_demo

// Second merge: Add economic information
merge 1:1 id using "${data_clean}/demo_economics.dta", keep(master match)

di "Merge results for economic information:"
tab _merge
rename _merge _merge_econ

// Validate merge results
di _n(1) "Post-merge validation:"
count
di "Final observations: " r(N)

count if !missing(country)
di "Observations with country info: " r(N)

count if !missing(employment_status)
di "Observations with employment info: " r(N)

/*==============================================================================
                    ADVANCED COMBINATION TECHNIQUES
==============================================================================*/

di _n(2) "{hline 40}"
di "ADVANCED COMBINATION METHODS"
di "{hline 40}"

// Create summary statistics before combination
preserve

// Create aggregate dataset by gender
collapse (mean) avg_income=inc_total (count) n_obs=id, by(female)
list

// Save aggregate data
tempfile gender_stats
save `gender_stats'

restore

// Merge aggregate statistics back to individual data
merge m:1 female using `gender_stats', keep(master match) nogenerate

label variable avg_income "[Derived] Average income by gender"
label variable n_obs "[Derived] Count of observations by gender"

/*==============================================================================
                    DATA COMBINATION VALIDATION
==============================================================================*/

di _n(2) "{hline 40}"
di "DATA COMBINATION VALIDATION"
di "{hline 40}"

// Comprehensive validation of combined dataset

// 1. Check for missing key identifiers
count if missing(id)
if r(N) > 0 {
    di as error "ERROR: " r(N) " observations missing ID"
}

// 2. Check for duplicate identifiers after combination
duplicates report id
if r(unique_value) != r(N) {
    di as error "ERROR: Duplicate IDs found after combination"
    duplicates list id
}

// 3. Validate that merges worked as expected
di _n(1) "Merge validation summary:"
di "Observations with demographics data: "
count if _merge_demo == 3
di "  Matched: " r(N)

di "Observations with economics data: "
count if _merge_econ == 3
di "  Matched: " r(N)

// 4. Check data consistency across merged variables
foreach var in female age {
    capture {
        quietly count if !missing(`var')
        di "Variable `var' non-missing: " r(N)
    }
}

/*==============================================================================
                    LOOP-BASED DATA COMBINATION
==============================================================================*/

di _n(2) "{hline 40}"
di "LOOP-BASED COMBINATION EXAMPLE"
di "{hline 40}"

// Use loops for multiple file combination
// Create example of combining multiple years of data

preserve

// Create example yearly datasets
forvalues year = 2020/2022 {
    clear
    set obs 10
    generate id = _n + (`year' - 2020) * 10
    generate year = `year'
    generate income_`year' = 30000 + uniform() * 20000

    tempfile data_`year'
    save `data_`year''

    di "Created dataset for year `year'"
}

// Combine all years using loop
clear
forvalues year = 2020/2022 {
    append using `data_`year''
}

// Check combined data
tab year
di "Total observations across all years: " _N

restore

/*==============================================================================
                    FINAL DATA PREPARATION
==============================================================================*/

di _n(2) "{hline 40}"
di "FINAL DATA PREPARATION"
di "{hline 40}"

// Clean up merge indicators and prepare final dataset
drop _merge_demo _merge_econ

// Add metadata about data combination
generate data_source = "Combined from multiple sources"
label variable data_source "Description of data combination"

// Final variable labeling
label variable country "[External] Country identifier"
label variable survey_year "[External] Survey year"
label variable employment_status "[External] Employment status"

// Compress and optimize dataset
compress

// Final data summary
describe
di _n(1) "Final combined dataset summary:"
di "Observations: " _N
di "Variables: " c(k)

/*==============================================================================
                    SAVE FINAL COMBINED DATASET
==============================================================================*/

// Save final dataset with descriptive name
save "${data_final}/combined_data.dta", replace

// Clean up temporary files
erase "${data_clean}/demo_demographics.dta"
erase "${data_clean}/demo_economics.dta"
erase "${data_clean}/demo_wave2.dta"

di _n(2) "{hline 60}"
di "DATA COMBINATION COMPLETED"
di "Techniques demonstrated:"
di "  - Appending datasets (adding observations)"
di "  - Many-to-one merging (adding variables)"
di "  - Merge validation and error checking"
di "  - Advanced combination with aggregation"
di "  - Loop-based combination workflows"
di "Output saved to: data/final/combined_data.dta"
di "{hline 60}"

// Close log
log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
