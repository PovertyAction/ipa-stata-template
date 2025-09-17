/*==============================================================================
ADVANCED PROGRAMMING TECHNIQUES
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Advanced Stata programming using Data Carpentry best practices
Input:       data/final/analysis_data.dta
Output:      Various outputs demonstrating advanced techniques

Notes:       - Demonstrates Data Carpentry advanced programming
             - Includes loops, macros, and modular programming
             - Shows temporary variables and file management
             - Implements error handling and defensive programming

References:
- Data Carpentry Stata Economics: https://datacarpentry.github.io/stata-economics/

==============================================================================*/

// Boilerplate code following IPA and Data Carpentry guidelines
version 17
clear all
macro drop _all
set more off
set varabbrev off

// Define global paths for reproducibility (Data Carpentry best practice)
global project_path "`c(pwd)'"
global data_final "${project_path}/data/final"
global outputs "${project_path}/outputs"
global logs "${project_path}/analysis/logs"

// Start log file
capture log close
log using "${logs}/07_advanced_programming.log", replace

/*==============================================================================
                    LOAD ANALYSIS DATA
==============================================================================*/

use "${data_final}/analysis_data.dta", clear

// Verify data integrity
datasignature confirm

// Restrict to analysis sample
keep if analysis_sample == 1

di _n(2) "{hline 60}"
di "ADVANCED PROGRAMMING TECHNIQUES (Data Carpentry)"
di "{hline 60}"
di "Analysis sample: " _N " observations"

/*==============================================================================
                    MACRO TECHNIQUES (Data Carpentry)
==============================================================================*/

di _n(2) "{hline 40}"
di "ADVANCED MACRO PROGRAMMING"
di "{hline 40}"

// Use local macros for flexible programming
local demographic_vars "age female educ_years"
local economic_vars "inc_total inc_total_log"
local derived_vars "age_cat educ_level"

di "Demographic variables: `demographic_vars'"
di "Economic variables: `economic_vars'"
di "Derived variables: `derived_vars'"

// Dynamic variable list creation
local all_analysis_vars "`demographic_vars' `economic_vars' `derived_vars'"
di "All analysis variables: `all_analysis_vars'"

// Macro evaluation with loops
foreach varlist in demographic economic derived {
    local n_vars : word count ``varlist'_vars'
    di "Number of `varlist' variables: `n_vars'"
}

/*==============================================================================
                    ADVANCED LOOPS
==============================================================================*/

di _n(2) "{hline 40}"
di "ADVANCED LOOP TECHNIQUES"
di "{hline 40}"

// Nested loops for complex operations
di "Creating interaction terms using nested loops:"

local group_vars "female educ_level"
local continuous_vars "age inc_total_log"

foreach group_var of local group_vars {
    foreach cont_var of local continuous_vars {
        // Create interaction terms
        quietly levelsof `group_var', local(levels)
        foreach level of local levels {
            tempvar interaction_`group_var'_`cont_var'_`level'
            generate `interaction_`group_var'_`cont_var'_`level'' = ///
                (`group_var' == `level') * `cont_var'

            // Label the interaction term
            local label_text "Interaction: `group_var'=`level' × `cont_var'"
            label variable `interaction_`group_var'_`cont_var'_`level'' "`label_text'"

            di "  Created: `group_var'=`level' × `cont_var'"
        }
    }
}

/*==============================================================================
                    TEMPORARY FILES AND VARIABLES
==============================================================================*/

di _n(2) "{hline 40}"
di "TEMPORARY FILES AND VARIABLES"
di "{hline 40}"

// Data Carpentry: Use tempvar for temporary variables
tempvar age_centered inc_residual predicted_inc

// Create temporary variables for analysis
egen mean_age = mean(age)
generate `age_centered' = age - mean_age
label variable `age_centered' "Age centered at sample mean"

// Data Carpentry: Use tempfile for temporary datasets
tempfile main_data summary_stats

// Save main data temporarily
save `main_data'

// Create summary statistics dataset
preserve
collapse (mean) mean_inc=inc_total (sd) sd_inc=inc_total ///
         (count) n_obs=id, by(educ_level female)

// Save summary statistics
save `summary_stats'
di "Created temporary summary statistics file"

restore

// Merge summary statistics back
merge m:1 educ_level female using `summary_stats', nogenerate

// Create standardized income within groups
generate `inc_residual' = (inc_total - mean_inc) / sd_inc
label variable `inc_residual' "Income standardized within education-gender groups"

/*==============================================================================
                    PRESERVE/RESTORE PROGRAMMING
==============================================================================*/

di _n(2) "{hline 40}"
di "PRESERVE/RESTORE TECHNIQUES"
di "{hline 40}"

// Use preserve/restore for data manipulation
preserve

di "Original dataset has " _N " observations"

// Perform operations that modify the dataset
keep if !missing(inc_total) & !missing(age) & !missing(educ_years)
di "After filtering: " _N " observations"

// Create analysis specific to this subset
summarize inc_total age educ_years

// Calculate correlations
correlate inc_total age educ_years

restore

di "Restored to original dataset with " _N " observations"

/*==============================================================================
                    DYNAMIC VARIABLE GENERATION
==============================================================================*/

di _n(2) "{hline 40}"
di "DYNAMIC VARIABLE GENERATION"
di "{hline 40}"

// Dynamic variable creation using loops and macros
local base_year 2023  // Example base year

// Create year-specific variables dynamically
foreach var in inc_total age {
    // Create base-year reference variable
    generate `var'_base_`base_year' = `var'  // In real data, this would be conditional

    // Create index relative to base year
    generate `var'_index_`base_year' = (`var' / `var'_base_`base_year') * 100

    label variable `var'_base_`base_year' "Base `base_year' value for `var'"
    label variable `var'_index_`base_year' "Index (`base_year'=100) for `var'"

    di "Created dynamic variables for `var' with base year `base_year'"
}

/*==============================================================================
                    ERROR HANDLING AND VALIDATION
==============================================================================*/

di _n(2) "{hline 40}"
di "ERROR HANDLING AND VALIDATION"
di "{hline 40}"

// Robust error handling
capture {
    // Attempt to create a variable that might fail
    generate test_var = inc_total / 0  // This will create missing values

    // Check if the operation succeeded
    count if !missing(test_var)
    if r(N) == 0 {
        di as error "Warning: Division by zero created all missing values"
        drop test_var
    }
}

// Validate data consistency
local validation_errors = 0

// Check for logical inconsistencies
capture {
    count if age < 0
    if r(N) > 0 {
        di as error "Error: " r(N) " observations with negative age"
        local validation_errors = `validation_errors' + 1
    }

    count if inc_total < 0
    if r(N) > 0 {
        di as error "Error: " r(N) " observations with negative income"
        local validation_errors = `validation_errors' + 1
    }
}

if `validation_errors' == 0 {
    di as result "Data validation passed: No logical inconsistencies found"
}
else {
    di as error "Data validation failed: `validation_errors' errors found"
}

/*==============================================================================
                    MODULAR PROGRAMMING EXAMPLE
==============================================================================*/

di _n(2) "{hline 40}"
di "MODULAR PROGRAMMING DEMONSTRATION"
di "{hline 40}"

// Define reusable code blocks
program define create_summary_table
    syntax varlist [if] [in], by(varname) [title(string)]

    marksample touse

    if "`title'" == "" {
        local title "Summary Statistics"
    }

    di _n(1) "`title'"
    di "{hline 50}"

    foreach var of local varlist {
        di _n(1) "Variable: `var'"
        tabstat `var' if `touse', by(`by') statistics(mean sd n) columns(statistics)
    }
end

// Use the custom program
create_summary_table inc_total age, by(female) title("Summary by Gender")

/*==============================================================================
                    ADVANCED FILE MANIPULATION
==============================================================================*/

di _n(2) "{hline 40}"
di "ADVANCED FILE MANIPULATION"
di "{hline 40}"

// Dynamic file operations
local output_files ""

// Create multiple output files using loops
forvalues group = 0/1 {
    preserve

    keep if female == `group'
    local gender = cond(`group', "female", "male")

    // Create group-specific analysis
    summarize inc_total age educ_years

    // Save group-specific dataset
    local filename "${outputs}/analysis_`gender'.dta"
    save "`filename'", replace

    // Add to file list
    local output_files "`output_files' `filename'"

    di "Created analysis file for `gender' group"

    restore
}

di "Created output files: `output_files'"

/*==============================================================================
                    ADVANCED DATA RESHAPING
==============================================================================*/

di _n(2) "{hline 40}"
di "ADVANCED DATA RESHAPING"
di "{hline 40}"

// Complex reshape operations
preserve

// Create example of complex reshape
keep id female age inc_total educ_years
generate observation = _n

// Create multiple measurements per person (simulated panel data)
expand 3
sort id
by id: generate time_period = _n

// Create time-varying variables
generate income_t = inc_total * (0.9 + 0.1 * time_period + uniform() * 0.2)
generate age_t = age + time_period - 1

// Reshape to wide format
reshape wide income_t age_t, i(id) j(time_period)

di "Reshaped to wide format:"
describe income_t* age_t*

// Reshape back to long format
reshape long income_t age_t, i(id) j(time_period)

di "Reshaped back to long format"
list id time_period income_t age_t in 1/15

restore

/*==============================================================================
                    COMPLETION SUMMARY
==============================================================================*/

di _n(2) "{hline 60}"
di "ADVANCED PROGRAMMING DEMONSTRATION COMPLETED"
di "{hline 60}"
di "Techniques demonstrated:"
di "  - Advanced macro programming and evaluation"
di "  - Nested loops and dynamic variable creation"
di "  - Temporary files and variables management"
di "  - Preserve/restore data manipulation"
di "  - Error handling and data validation"
di "  - Modular programming with custom functions"
di "  - Advanced file manipulation"
di "  - Complex data reshaping operations"
di ""
di "{hline 60}"

// Clean up temporary files
capture erase "${outputs}/analysis_female.dta"
capture erase "${outputs}/analysis_male.dta"

// Close log
log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
