/*==============================================================================
ADVANCED PROGRAMMING TECHNIQUES
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Advanced Stata programming using Data Carpentry best practices
Input:       data/final/analysis_data.dta
Output:      Various outputs demonstrating advanced techniques

Notes:       - Assumes globals are set by 00_run.do
             - Can be run standalone via: do 00_run.do "07_advanced_programming"
             - Demonstrates Data Carpentry advanced programming
             - Includes loops, macros, and modular programming
             - Shows temporary variables and file management
             - Implements error handling and defensive programming

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
local demographic_vars "age female education"
local economic_vars "income log_income"
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
local continuous_vars "age log_income"

foreach group_var of local group_vars {
    foreach cont_var of local continuous_vars {
        // Create interaction terms
        quietly levelsof `group_var', local(levels)
        foreach level of local levels {
            tempvar interaction_`group_var'_`cont_var'_`level'
            generate `interaction_`group_var'_`cont_var'_`level'' = ///
                (`group_var' == `level') * `cont_var'

            // Label the interaction term
            local label_text "Interaction: `group_var'=`level' x `cont_var'"
            label variable `interaction_`group_var'_`cont_var'_`level'' "`label_text'"

            di "  Created: `group_var'=`level' x `cont_var'"
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
collapse (mean) mean_inc=income (sd) sd_inc=income ///
         (count) n_obs=id, by(educ_level female)

// Save summary statistics
save `summary_stats'
di "Created temporary summary statistics file"

restore

// Merge summary statistics back
merge m:1 educ_level female using `summary_stats', nogenerate

// Create standardized income within groups
generate `inc_residual' = (income - mean_inc) / sd_inc
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
keep if !missing(income) & !missing(age) & !missing(education)
di "After filtering: " _N " observations"

// Create analysis specific to this subset
summarize income age education

// Calculate correlations
correlate income age education

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
foreach var in income age {
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
    generate test_var = income / 0  // This will create missing values

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

    count if income < 0
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
create_summary_table income age, by(female) title("Summary by Gender")

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
    summarize income age education

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
keep id female age income education
generate observation = _n

// Create multiple measurements per person (simulated panel data)
expand 3
sort id
by id: generate time_period = _n

// Create time-varying variables
generate income_t = income * (0.9 + 0.1 * time_period + uniform() * 0.2)
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
