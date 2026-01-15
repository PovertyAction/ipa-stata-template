/*==============================================================================
IMPACT ANALYSIS: BASELINE VS ENDLINE
================================================================================

Project:     [Project Name - CUSTOMIZE]
Author:      [Author Name - CUSTOMIZE]
Date:        `c(current_date)'
Purpose:     Analyze impact by comparing baseline and endline measurements
             using paired t-tests, effect sizes, and visualizations

Input:       ${data_processed}/merged_analysis_data.dta
Output:      - ${tables}/impact_results.dta
             - ${tables}/impact_analysis_results.xlsx
             - ${tables}/impact_analysis_results.csv
             - ${figures}/*_beforeafter_boxplot.png
             - ${figures}/*_beforeafter_means.png

Dependencies: Must run 00_setup_config.do and 01_load_explore.do first
             (or run 00_run_all.do)

Notes:       - Performs paired t-tests for all numeric baseline-endline pairs
             - Calculates Cohen's d effect sizes
             - Creates before-after visualizations
             - Exports results in multiple formats
             - Can be run standalone if prior steps completed

References:
- IPA Data Management Guide: https://www.poverty-action.org/
- Cohen's d interpretation: Small (0.2), Medium (0.5), Large (0.8)

==============================================================================*/

// Boilerplate code following IPA best practices
version 16
clear all
set more off
set varabbrev off

di _n(2) "{hline 80}"
di "IMPACT ANALYSIS: BASELINE VS ENDLINE"
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
log using "${logs}/03_impact_analysis_`log_date'_`log_time'.log", replace text

di _n "Log file created: ${logs}/03_impact_analysis_`log_date'_`log_time'.log"

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
capture confirm variable in_baseline in_endline
if _rc == 0 {
    di _n "Sample composition:"
    tab in_baseline in_endline, mi
}
else {
    di _n "WARNING: Merge indicators not found. Creating from scratch..."
    gen in_baseline = 1
    gen in_endline = 1
}

/*==============================================================================
                    3. IDENTIFY AVAILABLE BASELINE-ENDLINE PAIRS
==============================================================================*/

di _n(2) ">>> SECTION 3: IDENTIFYING BASELINE-ENDLINE PAIRS <<<"

// Identify which outcome pairs exist for baseline-endline comparison
di _n "Checking for baseline-endline variable pairs..."

local bl_el_pairs ""
foreach var of global all_outcomes {
    capture confirm variable `var'_bl
    local bl_exists = (_rc == 0)

    capture confirm variable `var'_el
    local el_exists = (_rc == 0)

    if `bl_exists' & `el_exists' {
        di "  ✓ `var': Both baseline and endline exist"
        local bl_el_pairs "`bl_el_pairs' `var'"
    }
}

global bl_el_pairs "`bl_el_pairs'"
di _n "Total baseline-endline pairs found: `: word count $bl_el_pairs'"

// Filter for numeric variable pairs only
di _n "Filtering for numeric variable pairs..."

local numeric_bl_el_pairs ""
foreach var of global bl_el_pairs {
    // Check if both baseline and endline versions are numeric
    capture confirm numeric variable `var'_bl
    local bl_numeric = (_rc == 0)

    capture confirm numeric variable `var'_el
    local el_numeric = (_rc == 0)

    if `bl_numeric' & `el_numeric' {
        di "  ✓ `var': Both versions are numeric - INCLUDED"
        local numeric_bl_el_pairs "`numeric_bl_el_pairs' `var'"
    }
    else {
        di "  ✗ `var': Non-numeric - EXCLUDED"
    }
}

global numeric_bl_el_pairs "`numeric_bl_el_pairs'"
di _n "Total numeric pairs for analysis: `: word count $numeric_bl_el_pairs'"

// Exit if no pairs found
if "`: word count $numeric_bl_el_pairs'" == "0" {
    di _n "{red}ERROR: No numeric baseline-endline pairs found for analysis!{reset}"
    di "Please check:"
    di "  1. Data has been properly merged with _bl and _el suffixes"
    di "  2. Variables are defined in 00_setup_config.do"
    di "  3. Variables exist in the input datasets"
    exit 198
}

/*==============================================================================
                    4. PERFORM IMPACT ANALYSIS
==============================================================================*/

di _n(2) ">>> SECTION 4: PERFORMING IMPACT ANALYSIS <<<"

// Create file to store impact results
tempname impact_results
postfile `impact_results' str30 variable n_pairs ///
    mean_bl sd_bl mean_el sd_el ///
    mean_diff se_diff t_stat p_value ///
    cohens_d effect_size_cat ///
    lower_ci upper_ci ///
    using "${tables}/impact_results.dta", replace

// Loop through each available numeric baseline-endline pair
local n_analyzed = 0
foreach var of global numeric_bl_el_pairs {

    di _n(2) "{hline 70}"
    di "Analyzing: `var'"
    di "{hline 70}"

    // Count non-missing pairs
    quietly count if !missing(`var'_bl) & !missing(`var'_el)
    local n_pairs = r(N)

    if `n_pairs' >= $min_obs_analysis {

        /*--- A. DESCRIPTIVE STATISTICS ---*/
        quietly summarize `var'_bl
        local mean_bl = r(mean)
        local sd_bl = r(sd)

        quietly summarize `var'_el
        local mean_el = r(mean)
        local sd_el = r(sd)

        /*--- B. CALCULATE DIFFERENCE ---*/
        // Drop existing diff variable if it exists
        capture drop diff_`var'
        quietly gen diff_`var' = `var'_el - `var'_bl if !missing(`var'_bl) & !missing(`var'_el)

        quietly summarize diff_`var'
        local mean_diff = r(mean)
        local sd_diff = r(sd)
        local se_diff = r(sd) / sqrt(r(N))

        /*--- C. PAIRED T-TEST ---*/
        quietly ttest `var'_el == `var'_bl
        local t_stat = r(t)
        local p_value = r(p)

        /*--- D. EFFECT SIZE (COHEN'S D) ---*/
        // Cohen's d = mean difference / baseline SD
        local cohens_d = `mean_diff' / `sd_bl'

        // Categorize effect size
        local effect_size_cat = 0
        if abs(`cohens_d') >= $effect_large {
            local effect_size_cat = 3  // Large
        }
        else if abs(`cohens_d') >= $effect_medium {
            local effect_size_cat = 2  // Medium
        }
        else if abs(`cohens_d') >= $effect_small {
            local effect_size_cat = 1  // Small
        }

        /*--- E. 95% CONFIDENCE INTERVAL ---*/
        local lower_ci = `mean_diff' - 1.96 * `se_diff'
        local upper_ci = `mean_diff' + 1.96 * `se_diff'

        /*--- F. DISPLAY RESULTS ---*/
        di "  N pairs: " `n_pairs'
        di "  Baseline:  Mean = " %9.3f `mean_bl' ", SD = " %9.3f `sd_bl'
        di "  Endline:   Mean = " %9.3f `mean_el' ", SD = " %9.3f `sd_el'
        di "  Difference: Mean = " %9.3f `mean_diff' " (SE = " %9.3f `se_diff' ")"
        di "  t-statistic = " %9.3f `t_stat' ", p-value = " %9.4f `p_value'
        di "  Cohen's d = " %9.3f `cohens_d'

        // Interpretation
        if `p_value' < 0.001 {
            di "  Statistical significance: *** (p < 0.001)"
        }
        else if `p_value' < 0.01 {
            di "  Statistical significance: ** (p < 0.01)"
        }
        else if `p_value' < 0.05 {
            di "  Statistical significance: * (p < 0.05)"
        }
        else {
            di "  Statistical significance: Not significant (p >= 0.05)"
        }

        if `effect_size_cat' == 3 {
            di "  Effect size: LARGE (|d| >= 0.8)"
        }
        else if `effect_size_cat' == 2 {
            di "  Effect size: MEDIUM (0.5 <= |d| < 0.8)"
        }
        else if `effect_size_cat' == 1 {
            di "  Effect size: SMALL (0.2 <= |d| < 0.5)"
        }
        else {
            di "  Effect size: NEGLIGIBLE (|d| < 0.2)"
        }

        di "  95% CI: [" %9.3f `lower_ci' ", " %9.3f `upper_ci' "]"

        /*--- G. POST RESULTS ---*/
        post `impact_results' ("`var'") (`n_pairs') ///
            (`mean_bl') (`sd_bl') (`mean_el') (`sd_el') ///
            (`mean_diff') (`se_diff') (`t_stat') (`p_value') ///
            (`cohens_d') (`effect_size_cat') ///
            (`lower_ci') (`upper_ci')

        /*--- H. CREATE VISUALIZATIONS ---*/
        preserve
            keep if !missing(`var'_bl) & !missing(`var'_el)

            // Create long format for plotting
            gen id_plot = _n
            reshape long `var'_, i(id_plot) j(timepoint) string

            // Create numeric timepoint
            gen time = 1 if timepoint == "bl"
            replace time = 2 if timepoint == "el"

            label define time_lbl 1 "Baseline" 2 "Endline"
            label values time time_lbl

            // Box plot
            graph box `var'_, over(time) ///
                title("`var': Baseline vs Endline") ///
                ytitle("`var'") ///
                note("N = `n_pairs' matched pairs" ///
                     "Mean difference = " %5.3f `mean_diff' ", p = " %5.4f `p_value' ///
                     "Cohen's d = " %5.3f `cohens_d') ///
                scheme(s2color)
            graph export "${figures}/`var'_beforeafter_boxplot.png", replace width(1200)

            // Mean plot with error bars
            collapse (mean) mean=`var'_ (sd) sd=`var'_ (count) n=`var'_, by(time)
            gen se = sd / sqrt(n)
            gen ci_lower = mean - 1.96*se
            gen ci_upper = mean + 1.96*se

            twoway (rcap ci_lower ci_upper time, lcolor(navy)) ///
                   (scatter mean time, mcolor(navy) msize(large) msymbol(O)), ///
                title("`var': Baseline to Endline") ///
                ytitle("Mean `var'") ///
                xlabel(1 "Baseline" 2 "Endline") ///
                legend(off) ///
                note("Error bars show 95% CI" ///
                     "Mean difference = " %5.3f `mean_diff' ", p = " %5.4f `p_value') ///
                scheme(s2color)
            graph export "${figures}/`var'_beforeafter_means.png", replace width(1200)
        restore

        local n_analyzed = `n_analyzed' + 1
        di "  ✓ Analysis and plots saved"

    }
    else {
        di "  ⚠ WARNING: Insufficient observations (N = `n_pairs' < $min_obs_analysis) - SKIPPED"
    }
}

postclose `impact_results'

di _n(2) "{hline 80}"
di "IMPACT ANALYSIS COMPLETED"
di "{hline 80}"
di "Total variables analyzed: `n_analyzed'"

/*==============================================================================
                    5. EXPORT RESULTS TABLE
==============================================================================*/

di _n(2) ">>> SECTION 5: EXPORTING RESULTS TABLE <<<"

// Load and format results table
use "${tables}/impact_results.dta", clear

// Add descriptive variable labels
gen label = ""

// Add labels for anthropometric variables
foreach var of global anthro_outcomes {
    capture local var_label : variable label `var'_bl
    if _rc == 0 & "`var_label'" != "" {
        replace label = "`var_label'" if variable == "`var'"
    }
}

// Add labels for IDELA variables
foreach var of global idela_outcomes {
    capture local var_label : variable label `var'_bl
    if _rc == 0 & "`var_label'" != "" {
        replace label = "`var_label'" if variable == "`var'"
    }
}

// Create formatted effect size label
gen effect_size_label = ""
replace effect_size_label = "Negligible" if effect_size_cat == 0
replace effect_size_label = "Small" if effect_size_cat == 1
replace effect_size_label = "Medium" if effect_size_cat == 2
replace effect_size_label = "Large" if effect_size_cat == 3

// Create significance stars
gen significance = ""
replace significance = "***" if p_value < 0.001
replace significance = "**" if p_value >= 0.001 & p_value < 0.01
replace significance = "*" if p_value >= 0.01 & p_value < 0.05
replace significance = "" if p_value >= 0.05

// Reorder variables for clean display
order variable label n_pairs mean_bl sd_bl mean_el sd_el mean_diff ///
      se_diff lower_ci upper_ci t_stat p_value significance ///
      cohens_d effect_size_label

// Format for display
format mean_* sd_* se_* %9.3f
format t_stat cohens_d %9.3f
format p_value %9.4f

// Display results
di _n "Impact Analysis Results:"
di "{hline 80}"
list variable n_pairs mean_diff p_value significance cohens_d effect_size_label, ///
    clean noobs separator(0)

// Export to Excel
export excel using "${tables}/impact_analysis_results.xlsx", ///
    firstrow(variables) replace

// Export to CSV
export delimited using "${tables}/impact_analysis_results.csv", ///
    delimiter(",") replace

di _n "Results exported to:"
di "  - ${tables}/impact_analysis_results.xlsx"
di "  - ${tables}/impact_analysis_results.csv"

/*==============================================================================
                    6. SUMMARY STATISTICS
==============================================================================*/

di _n(2) ">>> SECTION 6: SUMMARY STATISTICS <<<"

di _n "Impact Analysis Summary:"
di "{hline 80}"

// Total analyzed
quietly count
di "Total outcome variables analyzed: " r(N)

// Statistically significant changes
quietly count if p_value < 0.05
di "Statistically significant changes (p < 0.05): " r(N) " (" %4.1f (r(N)/_N*100) "%)"

quietly count if p_value < 0.01
di "  Highly significant (p < 0.01): " r(N)

quietly count if p_value < 0.001
di "  Very highly significant (p < 0.001): " r(N)

// Effect sizes
di _n "Effect Size Distribution:"
quietly count if effect_size_cat == 3
di "  Large effect sizes (|d| >= 0.8): " r(N) " (" %4.1f (r(N)/_N*100) "%)"

quietly count if effect_size_cat == 2
di "  Medium effect sizes (0.5 <= |d| < 0.8): " r(N) " (" %4.1f (r(N)/_N*100) "%)"

quietly count if effect_size_cat == 1
di "  Small effect sizes (0.2 <= |d| < 0.5): " r(N) " (" %4.1f (r(N)/_N*100) "%)"

quietly count if effect_size_cat == 0
di "  Negligible effect sizes (|d| < 0.2): " r(N) " (" %4.1f (r(N)/_N*100) "%)"

// Direction of effects
quietly count if mean_diff > 0 & p_value < 0.05
di _n "Direction of significant effects:"
di "  Positive (improvement): " r(N)

quietly count if mean_diff < 0 & p_value < 0.05
di "  Negative (decline): " r(N)

/*==============================================================================
                    7. CLEANUP AND COMPLETION
==============================================================================*/

di _n(2) "{hline 80}"
di "IMPACT ANALYSIS COMPLETED SUCCESSFULLY"
di "{hline 80}" _n

di "Output files created:"
di "  1. ${tables}/impact_results.dta (raw results)"
di "  2. ${tables}/impact_analysis_results.xlsx (formatted results)"
di "  3. ${tables}/impact_analysis_results.csv (formatted results)"
di "  4. ${figures}/*_beforeafter_boxplot.png (box plots)"
di "  5. ${figures}/*_beforeafter_means.png (mean plots with CI)"
di "  6. ${logs}/03_impact_analysis_`log_date'_`log_time'.log (analysis log)"

di _n "Analysis completed: `c(current_date)' `c(current_time)'"
di "{hline 80}" _n

log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
