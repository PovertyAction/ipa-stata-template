/*==============================================================================
DATA LOADING AND EXPLORATION
================================================================================

Project:     [Project Name - CUSTOMIZE]
Author:      [Author Name - CUSTOMIZE]
Date:        `c(current_date)'
Purpose:     Load and explore baseline, endline, and backcheck datasets

Input:       - Baseline data: $baseline
             - Endline data: $endline
             - Backcheck data: $backcheck

Output:      - Temporary files with cleaned variable names
             - ${data_processed}/baseline_clean.dta
             - ${data_processed}/endline_clean.dta
             - ${data_processed}/backcheck_clean.dta

Notes:       - Run 00_setup_config.do first
             - Checks data quality and variable availability
             - Standardizes variable names with suffixes (_bl, _el, _bc)
             - Identifies key variables and handles missing IDs

==============================================================================*/

// Boilerplate
version 16
clear all
set more off

// Start log file
capture log close
log using "${logs}/01_load_explore.log", replace

di _n(2) "{hline 80}"
di "DATA LOADING AND EXPLORATION"
di "{hline 80}" _n
di "Run date: `c(current_date)' `c(current_time)'"

/*==============================================================================
                    1. LOAD AND EXPLORE BASELINE DATA
==============================================================================*/

di _n(2) "{hline 80}"
di "SECTION 1: BASELINE DATA"
di "{hline 80}" _n

use "$baseline", clear

di "Number of observations: " _N
di "Number of variables: " c(k)

// Standardize variable names - CUSTOMIZE THIS SECTION
// Rename key ID variables if needed
capture rename childage_yrs child_age
capture rename childid childid_new
capture rename old_childid childid

// Check for childid variable
capture confirm variable childid
if _rc == 0 {
    di _n "✓ childid variable exists"

    // Check uniqueness
    duplicates report childid
    quietly count if missing(childid)
    if r(N) > 0 {
        di "! WARNING: " r(N) " observations have missing childid"
    }
    else {
        di "✓ No missing childid values"
    }
}
else {
    di as error _n "! CRITICAL: childid variable NOT FOUND"
    di "Available ID variables:"
    lookfor id
    di as error "Update variable renaming in this script"
}

// Check which outcome variables exist
di _n "Checking outcome variables availability:"
di _n "Anthropometric outcomes:"
foreach var of global anthro_outcomes {
    capture confirm variable `var'
    if _rc == 0 {
        di "  ✓ `var' exists"
    }
    else {
        di "  ✗ `var' missing"
    }
}

di _n "IDELA outcomes:"
local count_idela = 0
foreach var of global idela_outcomes {
    capture confirm variable `var'
    if _rc == 0 {
        local count_idela = `count_idela' + 1
    }
}
di "  " `count_idela' "/" `: word count $idela_outcomes' " IDELA variables found"

// Check for treatment variable
di _n "Checking for treatment variable:"
capture confirm variable treatment
if _rc == 0 {
    di "  ✓ treatment variable found"
    tab treatment, mi
}
else {
    di "  ⚠ WARNING: treatment variable not found"
    di "  Consider creating treatment indicator if applicable"
}

// Keep only relevant variables
local keep_vars "childid"
local all_vars "$anthro_outcomes $demographics $idela_outcomes"
foreach var of local all_vars {
    capture confirm variable `var'
    if _rc == 0 {
        local keep_vars "`keep_vars' `var'"
    }
}

// Add treatment if found
capture confirm variable treatment
if _rc == 0 {
    local keep_vars "`keep_vars' treatment"
}

di _n "Keeping " `: word count `keep_vars'' " variables"
keep `keep_vars'

// Rename variables with _bl suffix for baseline
foreach var of varlist * {
    if "`var'" != "childid" {
        rename `var' `var'_bl
    }
}

// Display final variable list
di _n "Variables in baseline dataset:"
quietly ds
local n_vars : word count `r(varlist)'
di "`n_vars' variables retained"

// Save baseline clean
save "${data_processed}/baseline_clean.dta", replace
di _n "✓ Baseline data saved: ${data_processed}/baseline_clean.dta"

tempfile baseline_clean
save `baseline_clean', replace

/*==============================================================================
                    2. LOAD AND EXPLORE ENDLINE DATA
==============================================================================*/

di _n(2) "{hline 80}"
di "SECTION 2: ENDLINE DATA"
di "{hline 80}" _n

use "$endline", clear

di "Number of observations: " _N
di "Number of variables: " c(k)

// Standardize variable names - CUSTOMIZE THIS SECTION
capture rename childage child_age
capture rename childid childid_new
capture rename old_childid childid
capture destring child_age, replace

// Check for childid variable
capture confirm variable childid
if _rc == 0 {
    di _n "✓ childid variable exists"

    // Check uniqueness
    duplicates report childid
    quietly count if missing(childid)
    if r(N) > 0 {
        di "! WARNING: " r(N) " observations have missing childid"
    }
    else {
        di "✓ No missing childid values"
    }
}
else {
    di as error _n "! CRITICAL: childid variable NOT FOUND"
    di "Available ID variables:"
    lookfor id
    di as error "Update variable renaming in this script"
}

// Check which outcome variables exist
di _n "Checking outcome variables availability:"
di _n "Anthropometric outcomes:"
foreach var of global anthro_outcomes {
    capture confirm variable `var'
    if _rc == 0 {
        di "  ✓ `var' exists"
    }
    else {
        di "  ✗ `var' missing"
    }
}

di _n "IDELA outcomes:"
local count_idela = 0
foreach var of global idela_outcomes {
    capture confirm variable `var'
    if _rc == 0 {
        local count_idela = `count_idela' + 1
    }
}
di "  " `count_idela' "/" `: word count $idela_outcomes' " IDELA variables found"

di _n "Spelke outcomes (endline only):"
local count_spelke = 0
foreach var of global spelke_outcomes {
    capture confirm variable `var'
    if _rc == 0 {
        local count_spelke = `count_spelke' + 1
    }
}
di "  " `count_spelke' "/" `: word count $spelke_outcomes' " Spelke variables found"

// Check for treatment variable
di _n "Checking for treatment variable:"
capture confirm variable treatment
if _rc == 0 {
    di "  ✓ treatment variable found"
    tab treatment, mi
}
else {
    di "  ⚠ WARNING: treatment variable not found"
}

// Keep only relevant variables
local keep_vars "childid"
local all_vars "$anthro_outcomes $demographics $idela_outcomes $spelke_outcomes"
foreach var of local all_vars {
    capture confirm variable `var'
    if _rc == 0 {
        local keep_vars "`keep_vars' `var'"
    }
}

// Add treatment if found
capture confirm variable treatment
if _rc == 0 {
    local keep_vars "`keep_vars' treatment"
}

di _n "Keeping " `: word count `keep_vars'' " variables"
keep `keep_vars'

// Rename variables with _el suffix for endline
foreach var of varlist * {
    if "`var'" != "childid" {
        rename `var' `var'_el
    }
}

// Display final variable list
di _n "Variables in endline dataset:"
quietly ds
local n_vars : word count `r(varlist)'
di "`n_vars' variables retained"

// Save endline clean
save "${data_processed}/endline_clean.dta", replace
di _n "✓ Endline data saved: ${data_processed}/endline_clean.dta"

tempfile endline_clean
save `endline_clean', replace

/*==============================================================================
                    3. LOAD AND EXPLORE BACKCHECK DATA
==============================================================================*/

di _n(2) "{hline 80}"
di "SECTION 3: BACKCHECK DATA"
di "{hline 80}" _n

use "$backcheck", clear

di "Number of observations: " _N
di "Number of variables: " c(k)

// Standardize variable names - CUSTOMIZE THIS SECTION
capture rename child_name childname

// Check for childid variable
capture confirm variable childid
if _rc == 0 {
    di _n "✓ childid variable exists"

    // Check uniqueness
    duplicates report childid
    quietly count if missing(childid)
    if r(N) > 0 {
        di "! WARNING: " r(N) " observations have missing childid"
    }

    // Drop duplicates if any (backchecks may have re-surveys)
    duplicates tag childid, gen(_dup_tag)
    quietly count if _dup_tag > 0
    if r(N) > 0 {
        di "! WARNING: " r(N) " duplicate observations found - keeping most recent"
        duplicates drop childid, force
        di "  After dropping duplicates: " _N " observations"
    }
    capture drop _dup_tag
}
else {
    di as error _n "! CRITICAL: childid variable NOT FOUND"
    di "Available ID variables:"
    lookfor id
    di as error "Update variable renaming in this script"
}

// Transform submission date if needed
capture confirm variable submissiondate
if _rc == 0 {
    gen subdate = dofc(submissiondate)
    format subdate %tdDDmonCCYY
    drop submissiondate
    di "✓ Converted submissiondate to subdate"
}

// Check which outcome variables exist
di _n "Checking outcome variables availability:"
di _n "Anthropometric outcomes:"
foreach var of global anthro_outcomes {
    capture confirm variable `var'
    if _rc == 0 {
        di "  ✓ `var' exists"
    }
    else {
        di "  ✗ `var' missing"
    }
}

// Keep only relevant variables
local keep_vars "childid"
local all_vars "$anthro_outcomes $demographics"
foreach var of local all_vars {
    capture confirm variable `var'
    if _rc == 0 {
        local keep_vars "`keep_vars' `var'"
    }
}

di _n "Keeping " `: word count `keep_vars'' " variables"
keep `keep_vars'

// Rename variables with _bc suffix for backcheck
foreach var of varlist * {
    if "`var'" != "childid" {
        rename `var' `var'_bc
    }
}

// Display final variable list
di _n "Variables in backcheck dataset:"
quietly ds
local n_vars : word count `r(varlist)'
di "`n_vars' variables retained"

// Save backcheck clean
save "${data_processed}/backcheck_clean.dta", replace
di _n "✓ Backcheck data saved: ${data_processed}/backcheck_clean.dta"

tempfile backcheck_clean
save `backcheck_clean', replace

/*==============================================================================
                    4. DATA EXPLORATION SUMMARY
==============================================================================*/

di _n(2) "{hline 80}"
di "DATA LOADING SUMMARY"
di "{hline 80}" _n

// Load each dataset and count observations
use `baseline_clean', clear
local n_bl = _N

use `endline_clean', clear
local n_el = _N

use `backcheck_clean', clear
local n_bc = _N

di "Dataset sizes:"
di "  Baseline:  " %8.0fc `n_bl' " observations"
di "  Endline:   " %8.0fc `n_el' " observations"
di "  Backcheck: " %8.0fc `n_bc' " observations"

/*==============================================================================
                    5. COMPLETION MESSAGE
==============================================================================*/

di _n(2) "{hline 80}"
di "DATA LOADING COMPLETED SUCCESSFULLY"
di "{hline 80}" _n

di "Output files created:"
di "  1. ${data_processed}/baseline_clean.dta"
di "  2. ${data_processed}/endline_clean.dta"
di "  3. ${data_processed}/backcheck_clean.dta"

di _n "Next steps:"
di "  Run: do scripts/do/impact/02_merge_datasets.do"

di _n "Completion time: `c(current_date)' `c(current_time)'"

// Close log
log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
