/*==============================================================================
RELIABILITY ANALYSIS: ENDLINE VS BACKCHECK
================================================================================

Project:     [Project Name - CUSTOMIZE]
Author:      [Author Name - CUSTOMIZE]
Date:        `c(current_date)'
Purpose:     Assess data quality and measurement reliability by comparing
             endline and backcheck measurements using Bland-Altman analysis,
             ICC, and quality flags

Input:       ${data_processed}/merged_analysis_data.dta
Output:      - ${tables}/reliability_results.dta
             - ${tables}/reliability_analysis_results.xlsx
             - ${tables}/reliability_analysis_results.csv
             - ${tables}/flagged_observations.xlsx
             - ${figures}/*_bland_altman.png
             - ${figures}/*_scatter_agreement.png
             - ${data_processed}/merged_analysis_data_flag.dta

Dependencies: Must run 00_setup_config.do and 01_load_explore.do first
             (or run 00_run_all.do)

Notes:       - Performs Bland-Altman analysis for agreement
             - Calculates ICC (Intraclass Correlation Coefficient)
             - Flags observations exceeding quality thresholds
             - Creates diagnostic plots
             - Can be run standalone if prior steps completed

References:
- IPA Data Management Guide: https://www.poverty-action.org/
- Bland & Altman (1986): Statistical methods for assessing agreement
- ICC interpretation: Poor (<0.50), Moderate (0.50-0.75), Good (0.75-0.90), Excellent (>0.90)

==============================================================================*/

// Boilerplate code following IPA best practices
version 16
clear all
set more off
set varabbrev off

di _n(2) "{hline 80}"
di "RELIABILITY ANALYSIS: ENDLINE VS BACKCHECK"
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
di "Input data: ${data_processed}/merged_analysis_data.dta"
di "Output tables: ${tables}/"
di "Output figures: ${figures}/"

// Start log file
local log_date = subinstr("`c(current_date)'", " ", "_", .)
local log_time = subinstr("`c(current_time)'", ":", "_", .)
log using "${logs}/04_reliability_analysis_`log_date'_`log_time'.log", replace text

di _n "Log file created: ${logs}/04_reliability_analysis_`log_date'_`log_time'.log"

/*==============================================================================
                    2. LOAD DATA AND VERIFY STRUCTURE
==============================================================================*/

di _n(2) ">>> SECTION 2: LOAD DATA AND VERIFY STRUCTURE <<<"

// Load merged dataset
use "${data_processed}/merged_analysis_data.dta", clear

di "Data loaded successfully"
di "Total observations: " _N
di "Total variables: " c(k)

// Verify merge indicators exist
capture confirm variable in_endline in_backcheck
if _rc == 0 {
    di _n "Sample composition:"
    tab in_endline in_backcheck, mi
}
else {
    di _n "WARNING: Merge indicators not found. Creating from scratch..."
    gen in_endline = 1
    gen in_backcheck = 1
}

/*==============================================================================
                    3. IDENTIFY AVAILABLE ENDLINE-BACKCHECK PAIRS
==============================================================================*/

di _n(2) ">>> SECTION 3: IDENTIFYING ENDLINE-BACKCHECK PAIRS <<<"

// Identify which outcome pairs exist for endline-backcheck comparison
di _n "Checking for endline-backcheck variable pairs..."

local el_bc_pairs ""
foreach var of global all_outcomes {
    capture confirm variable `var'_el
    local el_exists = (_rc == 0)

    capture confirm variable `var'_bc
    local bc_exists = (_rc == 0)

    if `el_exists' & `bc_exists' {
        di "  ✓ `var': Both endline and backcheck exist"
        local el_bc_pairs "`el_bc_pairs' `var'"
    }
}

global el_bc_pairs "`el_bc_pairs'"
di _n "Total endline-backcheck pairs found: `: word count $el_bc_pairs'"

// Filter for numeric variable pairs only
di _n "Filtering for numeric variable pairs..."

local numeric_el_bc_pairs ""
foreach var of global el_bc_pairs {
    // Check if both endline and backcheck versions are numeric
    capture confirm numeric variable `var'_el
    local el_numeric = (_rc == 0)

    capture confirm numeric variable `var'_bc
    local bc_numeric = (_rc == 0)

    if `el_numeric' & `bc_numeric' {
        di "  ✓ `var': Both versions are numeric - INCLUDED"
        local numeric_el_bc_pairs "`numeric_el_bc_pairs' `var'"
    }
    else {
        di "  ✗ `var': Non-numeric - EXCLUDED"
    }
}

global numeric_el_bc_pairs "`numeric_el_bc_pairs'"
di _n "Total numeric pairs for reliability analysis: `: word count $numeric_el_bc_pairs'"

// Exit if no pairs found
if "`: word count $numeric_el_bc_pairs'" == "0" {
    di _n "{red}ERROR: No numeric endline-backcheck pairs found for analysis!{reset}"
    di "Please check:"
    di "  1. Data has been properly merged with _el and _bc suffixes"
    di "  2. Variables are defined in 00_setup_config.do"
    di "  3. Backcheck data exists and was properly loaded"
    exit 198
}

/*==============================================================================
                    4. DEFINE QUALITY THRESHOLDS
==============================================================================*/

di _n(2) ">>> SECTION 4: DEFINING QUALITY THRESHOLDS <<<"

// CUSTOMIZE: Define acceptable difference thresholds for each variable type
// These follow WHO/IPA standards for anthropometric measurements

di "Setting quality thresholds based on measurement type:"

foreach var of global numeric_el_bc_pairs {
    // Weight measurements: ±0.1 kg threshold
    if regexm("`var'", "weight|c1_") {
        local threshold_`var' = $threshold_weight
        di "  `var': Weight threshold = $threshold_weight kg"
    }
    // Height measurements: ±0.5 cm threshold
    else if regexm("`var'", "height|c2_") {
        local threshold_`var' = $threshold_height
        di "  `var': Height threshold = $threshold_height cm"
    }
    // Arm circumference: ±0.5 cm threshold
    else if regexm("`var'", "arm|muac|c3_|c4_") {
        local threshold_`var' = $threshold_muac
        di "  `var': MUAC threshold = $threshold_muac cm"
    }
    // Default threshold for other measurements
    else {
        local threshold_`var' = 0.5
        di "  `var': Default threshold = 0.5"
    }
}

/*==============================================================================
                    5. PERFORM RELIABILITY ANALYSIS
==============================================================================*/

di _n(2) ">>> SECTION 5: PERFORMING RELIABILITY ANALYSIS <<<"

// Create file to store reliability results
tempname reliability_results
postfile `reliability_results' str30 variable n_pairs ///
    mean_el sd_el mean_bc sd_bc ///
    mean_diff mad mean_abs_pct_diff ///
    bias sd_diff loa_lower loa_upper ///
    icc icc_lb icc_ub icc_category ///
    n_flagged pct_flagged threshold ///
    using "${tables}/reliability_results.dta", replace

// Loop through each available numeric endline-backcheck pair
local n_analyzed = 0
foreach var of global numeric_el_bc_pairs {

    di _n(2) "{hline 70}"
    di "Analyzing Reliability: `var'"
    di "{hline 70}"

    // Count non-missing pairs
    quietly count if !missing(`var'_el) & !missing(`var'_bc)
    local n_pairs = r(N)

    if `n_pairs' >= $min_obs_analysis {

        /*--- A. DESCRIPTIVE STATISTICS ---*/
        quietly summarize `var'_el
        local mean_el = r(mean)
        local sd_el = r(sd)

        quietly summarize `var'_bc
        local mean_bc = r(mean)
        local sd_bc = r(sd)

        /*--- B. DIFFERENCE STATISTICS ---*/
        // Calculate difference (endline - backcheck)
        capture drop diff_bc_`var'
        quietly gen diff_bc_`var' = `var'_el - `var'_bc if !missing(`var'_el) & !missing(`var'_bc)

        // Mean difference (bias)
        quietly summarize diff_bc_`var'
        local bias = r(mean)
        local sd_diff = r(sd)

        // Mean absolute difference (MAD)
        capture drop abs_diff_bc_`var'
        quietly gen abs_diff_bc_`var' = abs(diff_bc_`var')
        quietly summarize abs_diff_bc_`var'
        local mad = r(mean)

        // Mean absolute percentage difference
        capture drop pct_diff_bc_`var'
        quietly gen pct_diff_bc_`var' = 100 * abs(diff_bc_`var') / ((`var'_el + `var'_bc) / 2) ///
            if (`var'_el + `var'_bc) > 0
        quietly summarize pct_diff_bc_`var'
        local mean_abs_pct_diff = r(mean)

        /*--- C. BLAND-ALTMAN ANALYSIS ---*/
        // Limits of agreement (mean ± 1.96 SD)
        local loa_lower = `bias' - 1.96 * `sd_diff'
        local loa_upper = `bias' + 1.96 * `sd_diff'

        // Create mean for Bland-Altman plot
        capture drop mean_bc_`var'
        quietly gen mean_bc_`var' = (`var'_el + `var'_bc) / 2

        /*--- D. INTRACLASS CORRELATION COEFFICIENT (ICC) ---*/
        // Reshape data for ICC calculation using loneway
        preserve
            keep if !missing(`var'_el) & !missing(`var'_bc)
            keep childid `var'_el `var'_bc
            gen id = _n
            reshape long `var'_, i(id) j(measurement) string

            // Calculate ICC using loneway command
            quietly loneway `var'_ id
            local icc = r(rho)

            // Calculate approximate 95% CI for ICC
            // Note: This is a simplified approximation
            local icc_se = sqrt((1-`icc')^2 / `n_pairs')
            local icc_lb = max(0, `icc' - 1.96 * `icc_se')
            local icc_ub = min(1, `icc' + 1.96 * `icc_se')
        restore

        // Categorize ICC quality
        local icc_category = 0  // Poor
        if `icc' >= $icc_excellent {
            local icc_category = 3  // Excellent
        }
        else if `icc' >= $icc_good {
            local icc_category = 2  // Good
        }
        else if `icc' >= $icc_moderate {
            local icc_category = 1  // Moderate
        }

        /*--- E. FLAG OBSERVATIONS EXCEEDING THRESHOLDS ---*/
        local threshold = `threshold_`var''
        capture drop flag_`var'
        quietly gen flag_`var' = (abs(diff_bc_`var') > `threshold') if !missing(diff_bc_`var')
        quietly count if flag_`var' == 1
        local n_flagged = r(N)
        local pct_flagged = (`n_flagged' / `n_pairs') * 100

        /*--- F. DISPLAY RESULTS ---*/
        di "  N pairs: " `n_pairs'

        di _n "  Descriptive Statistics:"
        di "    Endline:   Mean = " %9.3f `mean_el' ", SD = " %9.3f `sd_el'
        di "    Backcheck: Mean = " %9.3f `mean_bc' ", SD = " %9.3f `sd_bc'

        di _n "  Difference Statistics:"
        di "    Bias (mean difference) = " %9.3f `bias'
        di "    SD of differences = " %9.3f `sd_diff'
        di "    Mean absolute difference (MAD) = " %9.3f `mad'
        di "    Mean absolute % difference = " %9.2f `mean_abs_pct_diff' "%"

        di _n "  Bland-Altman Limits of Agreement:"
        di "    Lower limit = " %9.3f `loa_lower'
        di "    Upper limit = " %9.3f `loa_upper'

        di _n "  Intraclass Correlation Coefficient:"
        di "    ICC = " %9.3f `icc' " (95% CI: [" %9.3f `icc_lb' ", " %9.3f `icc_ub' "])"

        if `icc_category' == 3 {
            di "    Interpretation: EXCELLENT reliability (ICC >= 0.90)"
        }
        else if `icc_category' == 2 {
            di "    Interpretation: GOOD reliability (0.75 <= ICC < 0.90)"
        }
        else if `icc_category' == 1 {
            di "    Interpretation: MODERATE reliability (0.50 <= ICC < 0.75)"
        }
        else {
            di "    Interpretation: POOR reliability (ICC < 0.50)"
        }

        di _n "  Quality Flags (threshold = " `threshold' "):"
        di "    N flagged = " `n_flagged' " (" %5.2f `pct_flagged' "%)"

        /*--- G. POST RESULTS ---*/
        post `reliability_results' ("`var'") (`n_pairs') ///
            (`mean_el') (`sd_el') (`mean_bc') (`sd_bc') ///
            (`mean_diff') (`mad') (`mean_abs_pct_diff') ///
            (`bias') (`sd_diff') (`loa_lower') (`loa_upper') ///
            (`icc') (`icc_lb') (`icc_ub') (`icc_category') ///
            (`n_flagged') (`pct_flagged') (`threshold')

        /*--- H. CREATE BLAND-ALTMAN PLOT ---*/
        preserve
            keep if !missing(`var'_el) & !missing(`var'_bc)

            twoway (scatter diff_bc_`var' mean_bc_`var', mcolor(navy%50) msize(small)) ///
                   (function y = `bias', range(mean_bc_`var') lcolor(red) lpattern(solid) lwidth(medium)) ///
                   (function y = `loa_lower', range(mean_bc_`var') lcolor(red) lpattern(dash)) ///
                   (function y = `loa_upper', range(mean_bc_`var') lcolor(red) lpattern(dash)), ///
                title("`var': Bland-Altman Plot") ///
                subtitle("Endline vs Backcheck Agreement") ///
                xtitle("Mean of Endline and Backcheck") ///
                ytitle("Difference (Endline - Backcheck)") ///
                legend(order(1 "Observations" 2 "Mean difference" 3 "Limits of agreement") ///
                       pos(6) ring(0) col(3) size(small)) ///
                note("Bias = " %5.3f `bias' ", LoA = [" %5.3f `loa_lower' ", " %5.3f `loa_upper' "]" ///
                     "ICC = " %5.3f `icc' ", N = " `n_pairs') ///
                scheme(s2color)
            graph export "${figures}/`var'_bland_altman.png", replace width(1200)
        restore

        /*--- I. CREATE SCATTER PLOT WITH IDENTITY LINE ---*/
        preserve
            keep if !missing(`var'_el) & !missing(`var'_bc)

            // Get range for identity line
            quietly summarize `var'_el
            local min1 = r(min)
            local max1 = r(max)
            quietly summarize `var'_bc
            local min2 = r(min)
            local max2 = r(max)
            local min_val = min(`min1', `min2')
            local max_val = max(`max1', `max2')

            twoway (scatter `var'_bc `var'_el, mcolor(navy%50) msize(small)) ///
                   (function y = x, range(`min_val' `max_val') lcolor(red) lpattern(dash) lwidth(medium)), ///
                title("`var': Endline vs Backcheck") ///
                subtitle("Agreement Assessment") ///
                xtitle("Endline Measurement") ///
                ytitle("Backcheck Measurement") ///
                legend(order(1 "Observations" 2 "Perfect agreement line") ///
                       ring(0) pos(5) size(small)) ///
                note("ICC = " %5.3f `icc' ", N = " `n_pairs') ///
                aspect(1) ///
                scheme(s2color)
            graph export "${figures}/`var'_scatter_agreement.png", replace width(1200)
        restore

        local n_analyzed = `n_analyzed' + 1
        di "  ✓ Analysis and plots saved"

    }
    else {
        di "  ⚠ WARNING: Insufficient observations (N = `n_pairs' < $min_obs_analysis) - SKIPPED"
    }
}

postclose `reliability_results'

di _n(2) "{hline 80}"
di "RELIABILITY ANALYSIS COMPLETED"
di "{hline 80}"
di "Total variables analyzed: `n_analyzed'"

// Save dataset with flags
save "${data_processed}/merged_analysis_data_flag.dta", replace
di _n "Flagged dataset saved: ${data_processed}/merged_analysis_data_flag.dta"

/*==============================================================================
                    6. EXPORT RESULTS TABLE
==============================================================================*/

di _n(2) ">>> SECTION 6: EXPORTING RESULTS TABLE <<<"

// Load and format results table
use "${tables}/reliability_results.dta", clear

// Create formatted ICC category label
gen icc_label = ""
replace icc_label = "Poor" if icc_category == 0
replace icc_label = "Moderate" if icc_category == 1
replace icc_label = "Good" if icc_category == 2
replace icc_label = "Excellent" if icc_category == 3

// Add descriptive variable labels (optional)
gen label = ""
// CUSTOMIZE: Add labels as needed

// Reorder variables for clean display
order variable label n_pairs mean_el sd_el mean_bc sd_bc ///
      bias sd_diff mad mean_abs_pct_diff ///
      loa_lower loa_upper icc icc_lb icc_ub icc_label ///
      threshold n_flagged pct_flagged

// Format for display
format mean_* sd_* bias mad %9.3f
format loa_* icc* %9.3f
format mean_abs_pct_diff pct_flagged %9.2f
format threshold %9.2f

// Display results
di _n "Reliability Analysis Results:"
di "{hline 80}"
list variable n_pairs bias mad icc icc_label pct_flagged, ///
    clean noobs separator(0)

// Export to Excel
export excel using "${tables}/reliability_analysis_results.xlsx", ///
    firstrow(variables) replace

// Export to CSV
export delimited using "${tables}/reliability_analysis_results.csv", ///
    delimiter(",") replace

di _n "Results exported to:"
di "  - ${tables}/reliability_analysis_results.xlsx"
di "  - ${tables}/reliability_analysis_results.csv"

/*==============================================================================
                    7. CREATE FLAGGED OBSERVATIONS REPORT
==============================================================================*/

di _n(2) ">>> SECTION 7: CREATING FLAGGED OBSERVATIONS REPORT <<<"

use "${data_processed}/merged_analysis_data_flag.dta", clear

// Identify all flag variables
quietly ds flag_*
local flag_vars "`r(varlist)'"

if "`flag_vars'" != "" {
    // Create indicator for any flag
    egen any_flag = rowmax(`flag_vars')

    // Keep only flagged observations
    keep if any_flag == 1

    if _N > 0 {
        // Keep relevant variables
        keep childid `flag_vars' *_el *_bc diff_bc_* abs_diff_bc_*

        // Export flagged observations
        export excel using "${tables}/flagged_observations.xlsx", ///
            firstrow(variables) replace

        di "Total flagged observations: " _N
        di "Flagged observations exported to: ${tables}/flagged_observations.xlsx"

        // Display summary by variable
        di _n "Flagged observations by variable:"
        foreach flag_var of local flag_vars {
            quietly count if `flag_var' == 1
            if r(N) > 0 {
                local var_name = subinstr("`flag_var'", "flag_", "", .)
                di "  `var_name': " r(N) " observations flagged"
            }
        }
    }
    else {
        di "No observations exceeded quality thresholds"
    }
}
else {
    di "No flag variables found in dataset"
}

/*==============================================================================
                    8. SUMMARY STATISTICS
==============================================================================*/

di _n(2) ">>> SECTION 8: SUMMARY STATISTICS <<<"

use "${tables}/reliability_results.dta", clear

di _n "Reliability Analysis Summary:"
di "{hline 80}"

// Total analyzed
quietly count
di "Total outcome variables analyzed: " r(N)

// ICC categories
di _n "ICC Distribution:"
quietly count if icc_category == 3
di "  Excellent reliability (ICC >= 0.90): " r(N) " (" %4.1f (r(N)/_N*100) "%)"

quietly count if icc_category == 2
di "  Good reliability (0.75 <= ICC < 0.90): " r(N) " (" %4.1f (r(N)/_N*100) "%)"

quietly count if icc_category == 1
di "  Moderate reliability (0.50 <= ICC < 0.75): " r(N) " (" %4.1f (r(N)/_N*100) "%)"

quietly count if icc_category == 0
di "  Poor reliability (ICC < 0.50): " r(N) " (" %4.1f (r(N)/_N*100) "%)"

// Flagging rates
quietly summarize pct_flagged
di _n "Quality Flags:"
di "  Mean percentage flagged: " %5.2f r(mean) "%"
di "  Median percentage flagged: " %5.2f r(p50) "%"
di "  Range: " %5.2f r(min) "% to " %5.2f r(max) "%"

// Bias assessment
quietly summarize abs(bias)
di _n "Bias Assessment:"
di "  Mean absolute bias: " %5.3f r(mean)
di "  Maximum absolute bias: " %5.3f r(max)

/*==============================================================================
                    9. CLEANUP AND COMPLETION
==============================================================================*/

di _n(2) "{hline 80}"
di "RELIABILITY ANALYSIS COMPLETED SUCCESSFULLY"
di "{hline 80}" _n

di "Output files created:"
di "  1. ${tables}/reliability_results.dta (raw results)"
di "  2. ${tables}/reliability_analysis_results.xlsx (formatted results)"
di "  3. ${tables}/reliability_analysis_results.csv (formatted results)"
di "  4. ${tables}/flagged_observations.xlsx (quality flags)"
di "  5. ${figures}/*_bland_altman.png (Bland-Altman plots)"
di "  6. ${figures}/*_scatter_agreement.png (scatter plots)"
di "  7. ${data_processed}/merged_analysis_data_flag.dta (dataset with flags)"
di "  8. ${logs}/04_reliability_analysis_`log_date'_`log_time'.log (analysis log)"

di _n "Analysis completed: `c(current_date)' `c(current_time)'"
di "{hline 80}" _n

log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
