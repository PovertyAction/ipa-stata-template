/*==============================================================================
ENUMERATOR AND TIME EFFECTS ANALYSIS
================================================================================

Project:     [Project Name - CUSTOMIZE]
Author:      [Author Name - CUSTOMIZE]
Date:        `c(current_date)'
Purpose:     Analyze enumerator and time effects on measurement reliability
             by regressing absolute differences on enumerator ID and time

Input:       ${data_processed}/merged_analysis_data_flag.dta
Output:      - ${tables}/enumerator_effects_regression.xlsx
             - ${tables}/enumerator_effects_regression.csv
             - ${tables}/enumerator_effects_summary.xlsx

Dependencies: Must run 00_setup_config.do, 01_load_explore.do, and
             04_reliability_analysis.do first (or run 00_run_all.do)

Notes:       - Examines whether certain enumerators have systematic differences
             - Tests if time between surveys affects measurement reliability
             - Provides coefficients with significance stars
             - Useful for quality control and training needs assessment
             - Can be run standalone if prior steps completed

References:
- IPA Data Quality Assurance: https://www.poverty-action.org/
- Field staff performance monitoring best practices

==============================================================================*/

// Boilerplate code following IPA best practices
version 16
clear all
set more off
set varabbrev off

di _n(2) "{hline 80}"
di "ENUMERATOR AND TIME EFFECTS ANALYSIS"
di "{hline 80}" _n

/*==============================================================================
                    1. SETUP AND CONFIGURATION
==============================================================================*/

di ">>> SECTION 1: SETUP AND CONFIGURATION <<<"

// Check if globals are defined (if running standalone)
capture confirm existence $project_path
if _rc != 0 {
    di _n "Globals not found. Running configuration file..."
    do "scripts/do/impact/00_setup_config.do"
}

di "Project path: $project_path"
di "Input data: ${data_processed}/merged_analysis_data_flag.dta"
di "Output tables: ${tables}/"

// Start log file
local log_date = subinstr("`c(current_date)'", " ", "_", .)
local log_time = subinstr("`c(current_time)'", ":", "_", .)
log using "${logs}/05_enumerator_effects_`log_date'_`log_time'.log", replace text

di _n "Log file created: ${logs}/05_enumerator_effects_`log_date'_`log_time'.log"

/*==============================================================================
                    2. LOAD DATA AND VERIFY STRUCTURE
==============================================================================*/

di _n(2) ">>> SECTION 2: LOAD DATA AND VERIFY STRUCTURE <<<"

// Load flagged dataset with reliability variables
capture confirm file "${data_processed}/merged_analysis_data_flag.dta"
if _rc != 0 {
    di _n "{red}ERROR: Flagged dataset not found!{reset}"
    di "Please run 04_reliability_analysis.do first"
    exit 601
}

use "${data_processed}/merged_analysis_data_flag.dta", clear

di "Data loaded successfully"
di "Total observations: " _N
di "Total variables: " c(k)

/*==============================================================================
                    3. PREPARE TIME DIFFERENCE VARIABLE
==============================================================================*/

di _n(2) ">>> SECTION 3: PREPARING TIME DIFFERENCE VARIABLE <<<"

// Calculate time difference between endline and backcheck
capture confirm variable subdate_el subdate_bc
if _rc == 0 {
    // Generate time difference in days
    capture drop time_diff_days
    gen time_diff_days = subdate_bc - subdate_el

    di "Time difference variable created: time_diff_days"

    // Summary statistics
    summarize time_diff_days, detail

    di _n "Time difference distribution:"
    di "  Mean: " %6.2f r(mean) " days"
    di "  Median: " %6.2f r(p50) " days"
    di "  Range: " %6.2f r(min) " to " %6.2f r(max) " days"

    // Tab for quick overview
    tab time_diff_days, mi
}
else {
    di _n "{red}WARNING: Cannot calculate time difference (subdate variables not found){reset}"
    di "Creating placeholder time_diff_days = 0"
    gen time_diff_days = 0
}

/*==============================================================================
                    4. IDENTIFY ENUMERATOR VARIABLE
==============================================================================*/

di _n(2) ">>> SECTION 4: IDENTIFYING ENUMERATOR VARIABLE <<<"

// Check for enumerator ID variable (endline)
capture confirm variable enum_id_el
if _rc == 0 {
    di "Enumerator ID variable found: enum_id_el"

    // Get list of unique enumerator IDs
    quietly levelsof enum_id_el, local(enum_list)
    local n_enums : word count `enum_list'

    di "Number of unique enumerators: `n_enums'"

    // Display enumerator distribution
    tab enum_id_el, mi
}
else {
    di _n "{red}ERROR: Enumerator ID variable (enum_id_el) not found!{reset}"
    di "This analysis requires enumerator identifiers."
    di "Please ensure enum_id exists in endline data."
    exit 111
}

/*==============================================================================
                    5. CHECK AVAILABLE DIFFERENCE VARIABLES
==============================================================================*/

di _n(2) ">>> SECTION 5: CHECKING AVAILABLE DIFFERENCE VARIABLES <<<"

// Identify all absolute difference variables from reliability analysis
quietly ds abs_diff_bc_*
local abs_diff_vars "`r(varlist)'"

if "`abs_diff_vars'" == "" {
    di _n "{red}ERROR: No absolute difference variables found!{reset}"
    di "Please run 04_reliability_analysis.do first to create abs_diff_bc_* variables"
    exit 111
}

di "Found `: word count `abs_diff_vars'' absolute difference variables:"
foreach var of local abs_diff_vars {
    local base_var = subinstr("`var'", "abs_diff_bc_", "", .)
    di "  - `base_var'"
}

// Use the numeric pairs global if available, otherwise infer from variables
capture confirm existence $numeric_el_bc_pairs
if _rc == 0 {
    di _n "Using pre-defined numeric pairs from global: $numeric_el_bc_pairs"
}
else {
    // Infer from abs_diff variables
    local numeric_el_bc_pairs ""
    foreach var of local abs_diff_vars {
        local base_var = subinstr("`var'", "abs_diff_bc_", "", .)
        local numeric_el_bc_pairs "`numeric_el_bc_pairs' `base_var'"
    }
    global numeric_el_bc_pairs "`numeric_el_bc_pairs'"
    di _n "Inferred numeric pairs from data: $numeric_el_bc_pairs"
}

/*==============================================================================
                    6. RUN REGRESSIONS FOR EACH VARIABLE
==============================================================================*/

di _n(2) ">>> SECTION 6: RUNNING ENUMERATOR EFFECTS REGRESSIONS <<<"

// Save the original dataset
tempfile original_data
save `original_data', replace

// Count how many variables we'll analyze
local n_vars : word count $numeric_el_bc_pairs
di _n "Number of variables to analyze: `n_vars'"
di "Number of enumerators: `n_enums'"

// Run regressions and store coefficients for each variable
local regression_count = 0
foreach var of global numeric_el_bc_pairs {
    use `original_data', clear

    // Check if abs_diff variable exists
    capture confirm variable abs_diff_bc_`var'
    if _rc == 0 {
        di _n(2) "{hline 70}"
        di "Running regression for: `var'"
        di "{hline 70}"

        // Count non-missing observations
        quietly count if !missing(abs_diff_bc_`var') & !missing(enum_id_el) & !missing(time_diff_days)
        local n_obs = r(N)

        if `n_obs' < $min_obs_analysis {
            di "  ⚠ WARNING: Insufficient observations (`n_obs' < $min_obs_analysis) - skipping"
            continue
        }

        di "  N observations: `n_obs'"

        // Run regression: abs_diff ~ enum_id + time_diff
        capture quietly regress abs_diff_bc_`var' i.enum_id_el time_diff_days
        if _rc != 0 {
            di "  ⚠ WARNING: Regression failed (error `=_rc') - skipping"
            continue
        }

        // Display results with stars
        di _n "  Regression results (* p<0.10, ** p<0.05, *** p<0.01):"
        estimates table, star(0.10 0.05 0.01) stats(N r2 r2_a)

        // Test joint significance of enumerator effects
        quietly testparm i.enum_id_el
        local f_stat = r(F)
        local f_pval = r(p)

        di _n "  Joint test of enumerator effects:"
        di "    F-statistic = " %9.3f `f_stat'
        di "    P-value = " %9.4f `f_pval'

        if `f_pval' < 0.05 {
            di "    Interpretation: Significant enumerator effects detected (p < 0.05)"
        }
        else {
            di "    Interpretation: No significant enumerator effects (p >= 0.05)"
        }

        // Store degrees of freedom and coefficients
        local df_r = e(df_r)
        local r2 = e(r2)

        // Store all enumerator coefficients
        foreach enum of local enum_list {
            capture {
                local coef_`enum' = _b[`enum'.enum_id_el]
                local se_`enum' = _se[`enum'.enum_id_el]
            }
        }

        // Store time and constant coefficients
        capture {
            local coef_time = _b[time_diff_days]
            local se_time = _se[time_diff_days]
            local coef_cons = _b[_cons]
            local se_cons = _se[_cons]
        }

        // Create results dataset for this variable
        clear
        set obs `=`n_enums' + 2'
        gen str30 parameter = ""
        gen coef_`var' = .
        gen se_`var' = .
        gen pval_`var' = .

        local row = 1
        foreach enum of local enum_list {
            replace parameter = "Enum_`enum'" in `row'
            if "`coef_`enum''" != "" & "`se_`enum''" != "" {
                local t = `coef_`enum'' / `se_`enum''
                local pval = 2 * ttail(`df_r', abs(`t'))
                replace coef_`var' = `coef_`enum'' in `row'
                replace se_`var' = `se_`enum'' in `row'
                replace pval_`var' = `pval' in `row'
            }
            local row = `row' + 1
        }

        // Time difference coefficient
        replace parameter = "Time_diff_days" in `row'
        if "`coef_time'" != "" & "`se_time'" != "" {
            local t = `coef_time' / `se_time'
            local pval = 2 * ttail(`df_r', abs(`t'))
            replace coef_`var' = `coef_time' in `row'
            replace se_`var' = `se_time' in `row'
            replace pval_`var' = `pval' in `row'
        }
        local row = `row' + 1

        // Constant
        replace parameter = "Constant" in `row'
        if "`coef_cons'" != "" & "`se_cons'" != "" {
            local t = `coef_cons' / `se_cons'
            local pval = 2 * ttail(`df_r', abs(`t'))
            replace coef_`var' = `coef_cons' in `row'
            replace se_`var' = `se_cons' in `row'
            replace pval_`var' = `pval' in `row'
        }

        tempfile temp_`var'
        save `temp_`var'', replace

        local regression_count = `regression_count' + 1
        di "  ✓ Regression completed and stored"
    }
    else {
        di _n "  ⚠ WARNING: abs_diff_bc_`var' does not exist - skipping"
    }
}

di _n(2) "{hline 80}"
di "REGRESSIONS COMPLETED"
di "{hline 80}"
di "Total regressions run: `regression_count'"

/*==============================================================================
                    7. MERGE ALL REGRESSION RESULTS
==============================================================================*/

di _n(2) ">>> SECTION 7: MERGING REGRESSION RESULTS <<<"

// Create base dataset with parameters
clear
set obs `=`n_enums' + 2'
gen str30 parameter = ""

local row = 1
foreach enum of local enum_list {
    replace parameter = "Enum_`enum'" in `row'
    local row = `row' + 1
}
replace parameter = "Time_diff_days" in `row'
local row = `row' + 1
replace parameter = "Constant" in `row'

// Merge each variable's coefficients
foreach var of global numeric_el_bc_pairs {
    capture confirm file `temp_`var''
    if _rc == 0 {
        merge 1:1 parameter using `temp_`var'', nogenerate
    }
}

// Create string versions with stars and standard errors
foreach var of global numeric_el_bc_pairs {
    capture confirm variable coef_`var'
    if _rc == 0 {
        gen str30 `var'_str = ""

        // Format: coefficient (SE) with significance stars
        replace `var'_str = string(coef_`var', "%9.4f") if !missing(coef_`var')

        // Add stars based on p-value
        replace `var'_str = `var'_str + "***" if pval_`var' < 0.01 & !missing(pval_`var')
        replace `var'_str = `var'_str + "**" if pval_`var' >= 0.01 & pval_`var' < 0.05 & !missing(pval_`var')
        replace `var'_str = `var'_str + "*" if pval_`var' >= 0.05 & pval_`var' < 0.10 & !missing(pval_`var')

        // Add standard errors in parentheses
        gen str30 `var'_se_str = "(" + string(se_`var', "%9.4f") + ")" if !missing(se_`var')

        // Drop numeric versions for cleaner display
        drop coef_`var' se_`var' pval_`var'
    }
}

/*==============================================================================
                    8. EXPORT RESULTS
==============================================================================*/

di _n(2) ">>> SECTION 8: EXPORTING RESULTS <<<"

// Display the coefficient table
di _n(2) "{hline 80}"
di "ENUMERATOR EFFECTS ON MEASUREMENT RELIABILITY"
di "(* p<0.10, ** p<0.05, *** p<0.01)"
di "{hline 80}" _n
list, clean noobs separator(0)

// Export coefficients to Excel
export excel using "${tables}/enumerator_effects_regression.xlsx", ///
    firstrow(variables) replace

// Export coefficients to CSV
export delimited using "${tables}/enumerator_effects_regression.csv", ///
    delimiter(",") replace

di _n "Regression results exported to:"
di "  - ${tables}/enumerator_effects_regression.xlsx"
di "  - ${tables}/enumerator_effects_regression.csv"

/*==============================================================================
                    9. CREATE SUMMARY STATISTICS TABLE
==============================================================================*/

di _n(2) ">>> SECTION 9: CREATING SUMMARY STATISTICS <<<"

// Load original data to create enumerator summary
use `original_data', clear

// Create summary statistics by enumerator
preserve
    // Collapse to enumerator level
    collapse (count) n_obs = childid ///
             (mean) mean_time_diff = time_diff_days, ///
             by(enum_id_el)

    // Add average absolute differences by enumerator
    merge 1:m enum_id_el using `original_data', keep(match) nogenerate

    // Calculate mean absolute differences for each variable
    foreach var of global numeric_el_bc_pairs {
        capture confirm variable abs_diff_bc_`var'
        if _rc == 0 {
            bysort enum_id_el: egen mean_abs_diff_`var' = mean(abs_diff_bc_`var')
        }
    }

    // Keep one row per enumerator
    bysort enum_id_el: keep if _n == 1

    // Keep relevant variables
    keep enum_id_el n_obs mean_time_diff mean_abs_diff_*

    // Sort by enumerator ID
    sort enum_id_el

    // Display summary
    di _n "Summary statistics by enumerator:"
    list, clean noobs separator(0)

    // Export to Excel
    export excel using "${tables}/enumerator_effects_summary.xlsx", ///
        firstrow(variables) replace

    di _n "Summary statistics exported to:"
    di "  - ${tables}/enumerator_effects_summary.xlsx"
restore

/*==============================================================================
                    10. INTERPRETATION GUIDANCE
==============================================================================*/

di _n(2) ">>> SECTION 10: INTERPRETATION GUIDANCE <<<"

di _n "How to interpret these results:"
di "{hline 80}"
di "1. ENUMERATOR COEFFICIENTS:"
di "   - Positive coefficient: Enumerator has larger differences (lower reliability)"
di "   - Negative coefficient: Enumerator has smaller differences (higher reliability)"
di "   - Stars indicate statistical significance"
di "   - Use for quality control and targeted training"
di ""
di "2. TIME DIFFERENCE COEFFICIENT:"
di "   - Positive: Longer time gaps lead to larger differences"
di "   - Negative: Longer time gaps lead to smaller differences (unusual)"
di "   - Helps determine optimal backcheck timing"
di ""
di "3. SIGNIFICANCE STARS:"
di "   - *** p < 0.01 (highly significant)"
di "   - ** p < 0.05 (significant)"
di "   - * p < 0.10 (marginally significant)"
di "   - No star: Not statistically significant"
di ""
di "4. NEXT STEPS:"
di "   - Review enumerators with consistently high positive coefficients"
di "   - Consider retraining for enumerators with significant effects"
di "   - Adjust backcheck timing if time effects are significant"
di "{hline 80}"

/*==============================================================================
                    11. CLEANUP AND COMPLETION
==============================================================================*/

di _n(2) "{hline 80}"
di "ENUMERATOR EFFECTS ANALYSIS COMPLETED SUCCESSFULLY"
di "{hline 80}" _n

di "Output files created:"
di "  1. ${tables}/enumerator_effects_regression.xlsx (coefficients with stars)"
di "  2. ${tables}/enumerator_effects_regression.csv (coefficients with stars)"
di "  3. ${tables}/enumerator_effects_summary.xlsx (summary by enumerator)"
di "  4. ${logs}/05_enumerator_effects_`log_date'_`log_time'.log (analysis log)"

di _n "Analysis completed: `c(current_date)' `c(current_time)'"
di "{hline 80}" _n

log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
