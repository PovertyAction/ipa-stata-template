/*==============================================================================
MERGE DATASETS
================================================================================

Project:     [Project Name - CUSTOMIZE]
Author:      [Author Name - CUSTOMIZE]
Date:        `c(current_date)'
Purpose:     Merge baseline, endline, and backcheck datasets

Input:       - ${data_processed}/baseline_clean.dta
             - ${data_processed}/endline_clean.dta
             - ${data_processed}/backcheck_clean.dta

Output:      - ${data_processed}/merged_analysis_data.dta

Notes:       - Creates merge indicators for each dataset
             - Handles type mismatches between datasets
             - Identifies available outcome pairs for analysis

==============================================================================*/

// Boilerplate
version 16
clear all
set more off

// Start log file
capture log close
log using "${logs}/02_merge_datasets.log", replace

di _n(2) "{hline 80}"
di "MERGE DATASETS"
di "{hline 80}" _n
di "Run date: `c(current_date)' `c(current_time)'"

/*==============================================================================
                    1. MERGE BASELINE AND ENDLINE
==============================================================================*/

di _n ">>> MERGING BASELINE AND ENDLINE <<<"

// Start with baseline
use "${data_processed}/baseline_clean.dta", clear
di "Baseline observations: " _N

// Merge with endline
merge 1:1 childid using "${data_processed}/endline_clean.dta", gen(_merge_bl_el)

di _n "Merge results (baseline-endline):"
tab _merge_bl_el

di _n "Total observations after merge: " _N

/*==============================================================================
                    2. MERGE WITH BACKCHECK
==============================================================================*/

di _n ">>> MERGING WITH BACKCHECK <<<"

// Merge with backcheck
merge 1:1 childid using "${data_processed}/backcheck_clean.dta", gen(_merge_bc)

di _n "Merge results (backcheck):"
tab _merge_bc

di _n "Total observations after merge: " _N

/*==============================================================================
                    3. CREATE MERGE INDICATORS
==============================================================================*/

di _n ">>> CREATING SAMPLE INDICATORS <<<"

gen in_baseline = (_merge_bl_el == 1 | _merge_bl_el == 3)
gen in_endline = (_merge_bl_el == 2 | _merge_bl_el == 3)
gen in_backcheck = (_merge_bc == 2 | _merge_bc == 3)

label variable in_baseline "Observation in baseline dataset"
label variable in_endline "Observation in endline dataset"
label variable in_backcheck "Observation in backcheck dataset"

// Sample composition summary
di _n "Sample Composition:"
quietly count if in_baseline == 1 & in_endline == 0
di "  Baseline only: " %8.0fc r(N)

quietly count if in_baseline == 1 & in_endline == 1
di "  Both baseline & endline: " %8.0fc r(N)

quietly count if in_baseline == 0 & in_endline == 1
di "  Endline only: " %8.0fc r(N)

quietly count if in_backcheck == 1
di "  In backcheck: " %8.0fc r(N)

quietly count if in_endline == 1 & in_backcheck == 1
di "  Both endline & backcheck: " %8.0fc r(N)

/*==============================================================================
                    4. FIX TYPE MISMATCHES
==============================================================================*/

di _n(2) ">>> FIXING TYPE MISMATCHES <<<"

// Function to check and fix type mismatches
program define fix_type_mismatch
    args varname

    local has_bl = 0
    local has_el = 0
    local has_bc = 0

    capture confirm variable `varname'_bl
    if _rc == 0 local has_bl = 1

    capture confirm variable `varname'_el
    if _rc == 0 local has_el = 1

    capture confirm variable `varname'_bc
    if _rc == 0 local has_bc = 1

    // Only process if variable exists in at least 2 datasets
    if (`has_bl' + `has_el' + `has_bc') >= 2 {

        // Check types
        local type_bl ""
        local type_el ""
        local type_bc ""

        if `has_bl' {
            capture confirm numeric variable `varname'_bl
            local type_bl = cond(_rc == 0, "numeric", "string")
        }

        if `has_el' {
            capture confirm numeric variable `varname'_el
            local type_el = cond(_rc == 0, "numeric", "string")
        }

        if `has_bc' {
            capture confirm numeric variable `varname'_bc
            local type_bc = cond(_rc == 0, "numeric", "string")
        }

        // Check for mismatch
        local has_mismatch = 0
        if `has_bl' & `has_el' & "`type_bl'" != "`type_el'" local has_mismatch = 1
        if `has_bl' & `has_bc' & "`type_bl'" != "`type_bc'" local has_mismatch = 1
        if `has_el' & `has_bc' & "`type_el'" != "`type_bc'" local has_mismatch = 1

        if `has_mismatch' {
            di _n "  WARNING: Type mismatch for `varname'"
            if `has_bl' di "    - `varname'_bl: `type_bl'"
            if `has_el' di "    - `varname'_el: `type_el'"
            if `has_bc' di "    - `varname'_bc: `type_bc'"

            // Convert string to numeric
            if `has_bl' & "`type_bl'" == "string" {
                di "    - Converting `varname'_bl to numeric..."
                capture destring `varname'_bl, replace force
                if _rc == 0 {
                    di "      SUCCESS"
                }
                else {
                    di "      FAILED - dropping variable"
                    drop `varname'_bl
                }
            }

            if `has_el' & "`type_el'" == "string" {
                di "    - Converting `varname'_el to numeric..."
                capture destring `varname'_el, replace force
                if _rc == 0 {
                    di "      SUCCESS"
                }
                else {
                    di "      FAILED - dropping variable"
                    drop `varname'_el
                }
            }

            if `has_bc' & "`type_bc'" == "string" {
                di "    - Converting `varname'_bc to numeric..."
                capture destring `varname'_bc, replace force
                if _rc == 0 {
                    di "      SUCCESS"
                }
                else {
                    di "      FAILED - dropping variable"
                    drop `varname'_bc
                }
            }
        }
    }
end

// Check outcome variables
di "Checking outcome variables:"
foreach var of global all_outcomes {
    quietly fix_type_mismatch `var'
}

// Check demographic variables
di _n "Checking demographic variables:"
foreach var of global demographics {
    if "`var'" != "childid" {
        quietly fix_type_mismatch `var'
    }
}

di _n "Type mismatch checking complete"

/*==============================================================================
                    5. IDENTIFY AVAILABLE OUTCOME PAIRS
==============================================================================*/

di _n(2) ">>> IDENTIFYING AVAILABLE OUTCOME PAIRS <<<"

// Baseline-Endline pairs
di _n "Baseline-Endline pairs:"
local bl_el_pairs ""
local numeric_bl_el_pairs ""

foreach var of global all_outcomes {
    capture confirm variable `var'_bl
    local bl_exists = (_rc == 0)

    capture confirm variable `var'_el
    local el_exists = (_rc == 0)

    if `bl_exists' & `el_exists' {
        local bl_el_pairs "`bl_el_pairs' `var'"

        // Check if both are numeric
        capture confirm numeric variable `var'_bl
        local bl_numeric = (_rc == 0)
        capture confirm numeric variable `var'_el
        local el_numeric = (_rc == 0)

        if `bl_numeric' & `el_numeric' {
            local numeric_bl_el_pairs "`numeric_bl_el_pairs' `var'"
            di "  ✓ `var' (numeric)"
        }
        else {
            di "  ✗ `var' (type mismatch)"
        }
    }
}

global bl_el_pairs "`bl_el_pairs'"
global numeric_bl_el_pairs "`numeric_bl_el_pairs'"

di _n "Total baseline-endline pairs: " `: word count $bl_el_pairs'
di "Numeric pairs for analysis: " `: word count $numeric_bl_el_pairs'

// Endline-Backcheck pairs
di _n "Endline-Backcheck pairs:"
local el_bc_pairs ""
local numeric_el_bc_pairs ""

foreach var of global anthro_outcomes {
    capture confirm variable `var'_el
    local el_exists = (_rc == 0)

    capture confirm variable `var'_bc
    local bc_exists = (_rc == 0)

    if `el_exists' & `bc_exists' {
        local el_bc_pairs "`el_bc_pairs' `var'"

        // Check if both are numeric
        capture confirm numeric variable `var'_el
        local el_numeric = (_rc == 0)
        capture confirm numeric variable `var'_bc
        local bc_numeric = (_rc == 0)

        if `el_numeric' & `bc_numeric' {
            local numeric_el_bc_pairs "`numeric_el_bc_pairs' `var'"
            di "  ✓ `var' (numeric)"
        }
        else {
            di "  ✗ `var' (type mismatch)"
        }
    }
}

global el_bc_pairs "`el_bc_pairs'"
global numeric_el_bc_pairs "`numeric_el_bc_pairs'"

di _n "Total endline-backcheck pairs: " `: word count $el_bc_pairs'
di "Numeric pairs for analysis: " `: word count $numeric_el_bc_pairs'

/*==============================================================================
                    6. SAVE MERGED DATASET
==============================================================================*/

// Save merged dataset
save "${data_processed}/merged_analysis_data.dta", replace

di _n(2) "{hline 80}"
di "MERGE COMPLETED SUCCESSFULLY"
di "{hline 80}" _n

di "Output file:"
di "  ${data_processed}/merged_analysis_data.dta"

di _n "Dataset contains:"
di "  Total observations: " %8.0fc _N
di "  Total variables: " c(k)

di _n "Next steps:"
di "  Run impact analysis: do scripts/do/impact/03_impact_analysis.do"
di "  Run reliability analysis: do scripts/do/impact/04_reliability_analysis.do"

di _n "Completion time: `c(current_date)' `c(current_time)'"

// Close log
log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
