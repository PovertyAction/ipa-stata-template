/*==============================================================================
PARTICIPANT TRACKING VALIDATION
================================================================================

Project:     [Project Name - CUSTOMIZE]
Author:      [Author Name - CUSTOMIZE]
Date:        `c(current_date)'
Purpose:     Validate participant tracking across baseline and endline using
             multi-level hierarchical matching: names, age, gender, location,
             GPS coordinates, and household identifiers

Input:       ${data_processed}/merged_analysis_data.dta
             ${caregiver} (optional, for caregiver change information)
Output:      - ${tables}/participant_tracking_validation.xlsx
             - ${tables}/participant_tracking_validation.csv
             - ${tables}/tracking_issues.xlsx
             - ${data_processed}/merged_analysis_data_tracked.dta

Dependencies: Must run 00_setup_config.do and 01_load_explore.do first
             (or run 00_run_all.do)

Notes:       - Uses hierarchical probabilistic linkage approach
             - Creates 0-100 match score based on multiple criteria
             - Identifies potential tracking issues
             - Validates location consistency using GPS coordinates
             - Can be run standalone if prior steps completed

References:
- IPA Data Quality Assurance: https://www.poverty-action.org/
- Record linkage and matching best practices

==============================================================================*/

// Boilerplate code following IPA best practices
version 16
clear all
set more off
set varabbrev off

di _n(2) "{hline 80}"
di "PARTICIPANT TRACKING VALIDATION"
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

// Start log file
local log_date = subinstr("`c(current_date)'", " ", "_", .)
local log_time = subinstr("`c(current_time)'", ":", "_", .)
log using "${logs}/06_participant_tracking_`log_date'_`log_time'.log", replace text

di _n "Log file created: ${logs}/06_participant_tracking_`log_date'_`log_time'.log"

/*==============================================================================
                    2. LOAD DATA AND MERGE CAREGIVER INFO
==============================================================================*/

di _n(2) ">>> SECTION 2: LOAD DATA AND MERGE CAREGIVER INFO <<<"

// Load merged dataset
use "${data_processed}/merged_analysis_data.dta", clear

di "Data loaded successfully"
di "Total observations: " _N

// Try to merge caregiver change information if available
capture confirm file "$caregiver"
if _rc == 0 {
    di _n "Caregiver data file found. Attempting to merge..."

    tempfile caregiver_data
    preserve
        use "$caregiver", clear
        di "  Caregiver data observations: " _N

        // Keep only relevant variables
        capture confirm variable childid care_change
        if _rc == 0 {
            keep childid care_change

            // Ensure care_change is numeric
            capture confirm numeric variable care_change
            if _rc != 0 {
                gen change_cg = (care_change == "Yes" | care_change == "1")
                drop care_change
                rename change_cg care_change
            }

            save `caregiver_data', replace
            di "  Caregiver change information prepared"
        }
        else {
            di "  WARNING: Required variables not found in caregiver data"
            local no_caregiver_data = 1
        }
    restore

    // Merge if data was successfully prepared
    if "`no_caregiver_data'" == "" {
        merge 1:1 childid using `caregiver_data', keep(master match) nogen
        di "  ✓ Caregiver data merged"

        // Display caregiver change statistics
        capture tab care_change, mi
        if _rc == 0 {
            di _n "  Caregiver change distribution:"
            tab care_change, mi
        }
    }
}
else {
    di _n "⚠ NOTE: Caregiver data file not found"
    di "  Tracking validation will proceed without caregiver change information"
    gen care_change = .
}

/*==============================================================================
                    3. CLEAN AND STANDARDIZE NAMES
==============================================================================*/

di _n(2) ">>> SECTION 3: CLEANING AND STANDARDIZING NAMES <<<"

// Function to clean name variables
// Converts to uppercase, removes extra spaces, removes punctuation

// CUSTOMIZE: Add/modify name variables based on your data structure
local name_vars "childname child_name caregiver"

foreach base_var of local name_vars {
    // Clean baseline names
    capture confirm variable `base_var'_bl
    if _rc == 0 {
        gen `base_var'_bl_clean = upper(trim(itrim(`base_var'_bl)))
        replace `base_var'_bl_clean = subinstr(`base_var'_bl_clean, "  ", " ", .)
        replace `base_var'_bl_clean = subinstr(`base_var'_bl_clean, ".", "", .)
        replace `base_var'_bl_clean = subinstr(`base_var'_bl_clean, ",", "", .)
        di "  ✓ Cleaned baseline variable: `base_var'_bl"
    }

    // Clean endline names
    capture confirm variable `base_var'_el
    if _rc == 0 {
        gen `base_var'_el_clean = upper(trim(itrim(`base_var'_el)))
        replace `base_var'_el_clean = subinstr(`base_var'_el_clean, "  ", " ", .)
        replace `base_var'_el_clean = subinstr(`base_var'_el_clean, ".", "", .)
        replace `base_var'_el_clean = subinstr(`base_var'_el_clean, ",", "", .)
        di "  ✓ Cleaned endline variable: `base_var'_el"
    }
}

/*==============================================================================
                    4. CREATE MATCHING SCORES
==============================================================================*/

di _n(2) ">>> SECTION 4: CREATING MULTI-LEVEL MATCHING SCORES <<<"

// Initialize match score and level
gen match_score = 0
gen match_level = ""
label variable match_score "Overall matching confidence score (0-100)"
label variable match_level "Highest matching level achieved"

/*--- LEVEL 1: ADMINISTRATIVE LOCATION MATCH (10 POINTS) ---*/
di _n "LEVEL 1: Administrative Location Matching"

gen admin_match = 0
local admin_vars "region district school schoolid"

// CUSTOMIZE: Adjust based on your administrative hierarchy variables
foreach admin_var of local admin_vars {
    capture confirm variable `admin_var'_bl `admin_var'_el
    if _rc == 0 {
        replace admin_match = 1 if !missing(`admin_var'_bl) & !missing(`admin_var'_el) & ///
                                   `admin_var'_bl == `admin_var'_el
        di "  ✓ Checking `admin_var' match"
    }
}

replace match_score = match_score + 10 if admin_match == 1
label variable admin_match "Administrative location matches"

quietly count if admin_match == 1 & in_baseline == 1 & in_endline == 1
if r(N) > 0 {
    di "  Administrative location match: " r(N) " cases"
}

/*--- LEVEL 2: HOUSEHOLD/SCHOOL ID MATCH (20 POINTS) ---*/
di _n "LEVEL 2: Household/School ID Matching"

gen household_match = 0

// CUSTOMIZE: Adjust based on your household/school identifier variables
capture confirm variable hhid_bl hhid_el
if _rc == 0 {
    replace household_match = 1 if !missing(hhid_bl) & !missing(hhid_el) & hhid_bl == hhid_el
    di "  ✓ Household ID (hhid) match checked"
}

replace match_score = match_score + 20 if household_match == 1
label variable household_match "Household/School ID matches"

quietly count if household_match == 1 & in_baseline == 1 & in_endline == 1
if r(N) > 0 {
    di "  Household ID match: " r(N) " cases"
}

/*--- LEVEL 3: CHILD NAME MATCH (30 POINTS - HIGHEST WEIGHT) ---*/
di _n "LEVEL 3: Child Name Matching"

gen childname_match = 0
gen childname_match_quality = ""

// Try different child name variables
// CUSTOMIZE: Adjust based on your child name variables
local child_name_vars "child_name childname"

foreach name_var of local child_name_vars {
    capture confirm variable `name_var'_bl_clean `name_var'_el_clean
    if _rc == 0 {
        // Exact match
        replace childname_match = 1 if childname_match == 0 & ///
                                       !missing(`name_var'_bl_clean) & ///
                                       !missing(`name_var'_el_clean) & ///
                                       `name_var'_bl_clean == `name_var'_el_clean
        replace childname_match_quality = "Exact match (`name_var')" ///
            if childname_match == 1 & childname_match_quality == ""

        // Partial match (first 5 characters)
        replace childname_match = 0.5 if childname_match == 0 & ///
                                         !missing(`name_var'_bl_clean) & ///
                                         !missing(`name_var'_el_clean) & ///
                                         substr(`name_var'_bl_clean, 1, 5) == substr(`name_var'_el_clean, 1, 5) & ///
                                         strlen(`name_var'_bl_clean) >= 5
        replace childname_match_quality = "Partial match (first 5 chars, `name_var')" ///
            if childname_match == 0.5 & childname_match_quality == ""

        di "  ✓ Checked `name_var' for exact and partial matches"
    }
}

replace match_score = match_score + (30 * childname_match)
label variable childname_match "Child name matches (0=no, 0.5=partial, 1=exact)"
label variable childname_match_quality "Type of name match"

quietly count if childname_match >= 0.5 & in_baseline == 1 & in_endline == 1
if r(N) > 0 {
    di "  Child name match (partial or exact): " r(N) " cases"
}

/*--- LEVEL 4: AGE CONSISTENCY (15 POINTS) ---*/
di _n "LEVEL 4: Age Consistency"

gen age_consistent = 0
gen age_diff = .

capture confirm variable child_age_bl child_age_el
if _rc == 0 {
    replace age_diff = child_age_el - child_age_bl if !missing(child_age_bl) & !missing(child_age_el)

    // Calculate time between surveys
    gen time_gap_years = .
    capture confirm variable subdate_bl subdate_el
    if _rc == 0 {
        replace time_gap_years = (subdate_el - subdate_bl) / 365.25 ///
            if !missing(subdate_bl) & !missing(subdate_el)
    }

    // Age should increase approximately by survey gap (±1 year tolerance)
    replace age_consistent = 1 if !missing(age_diff) & !missing(time_gap_years) & ///
                                  abs(age_diff - time_gap_years) <= 1

    // More lenient: age should at least increase reasonably
    replace age_consistent = 0.5 if age_consistent == 0 & !missing(age_diff) & ///
                                    age_diff >= 0 & age_diff <= 3

    di "  ✓ Age consistency checked against survey timing"
}
else {
    di "  ⚠ WARNING: Child age variables not found"
}

replace match_score = match_score + (15 * age_consistent)
label variable age_consistent "Age progression is consistent (0=no, 0.5=plausible, 1=exact)"
label variable age_diff "Difference in child age (endline - baseline)"

quietly count if age_consistent >= 0.5 & in_baseline == 1 & in_endline == 1
if r(N) > 0 {
    di "  Age consistent: " r(N) " cases"
}

/*--- LEVEL 5: GENDER CONSISTENCY (10 POINTS) ---*/
di _n "LEVEL 5: Gender Consistency"

gen gender_consistent = 0

capture confirm variable gender_bl gender_el
if _rc == 0 {
    replace gender_consistent = 1 if !missing(gender_bl) & !missing(gender_el) & ///
                                     gender_bl == gender_el
    di "  ✓ Gender consistency checked"
}
else {
    di "  ⚠ WARNING: Gender variables not found"
}

replace match_score = match_score + 10 if gender_consistent == 1
label variable gender_consistent "Gender is consistent across waves"

quietly count if gender_consistent == 1 & in_baseline == 1 & in_endline == 1
if r(N) > 0 {
    di "  Gender consistent: " r(N) " cases"
}

/*--- LEVEL 6: CAREGIVER NAME MATCH (15 POINTS) ---*/
di _n "LEVEL 6: Caregiver Name Matching"

gen caregiver_match = 0
gen caregiver_match_quality = ""

// Match on primary caregiver
capture confirm variable caregiver_bl_clean caregiver_el_clean
if _rc == 0 {
    replace caregiver_match = 1 if !missing(caregiver_bl_clean) & ///
                                   !missing(caregiver_el_clean) & ///
                                   caregiver_bl_clean == caregiver_el_clean
    replace caregiver_match_quality = "Primary caregiver name matches" ///
        if caregiver_match == 1

    di "  ✓ Caregiver name match checked"
}

// If caregiver changed (care_change=1), award partial points even if names don't match
capture confirm variable care_change
if _rc == 0 {
    replace caregiver_match = 0.5 if caregiver_match == 0 & care_change == 1
    replace caregiver_match_quality = "Caregiver changed (expected)" ///
        if caregiver_match == 0.5 & caregiver_match_quality == ""

    di "  ✓ Caregiver change information incorporated"
}

replace match_score = match_score + (15 * caregiver_match)
label variable caregiver_match "Caregiver name matches (0=no, 0.5=change, 1=match)"
label variable caregiver_match_quality "Type of caregiver match"

quietly count if caregiver_match >= 0.5 & in_baseline == 1 & in_endline == 1
if r(N) > 0 {
    di "  Caregiver match or expected change: " r(N) " cases"
}

/*==============================================================================
                    5. CREATE TRACKING STATUS CATEGORIES
==============================================================================*/

di _n(2) ">>> SECTION 5: CREATING TRACKING STATUS CATEGORIES <<<"

gen tracking_status = ""
replace tracking_status = "High confidence match (≥80)" if match_score >= 80
replace tracking_status = "Good match (60-79)" if match_score >= 60 & match_score < 80
replace tracking_status = "Moderate match (40-59)" if match_score >= 40 & match_score < 60
replace tracking_status = "Weak match (20-39)" if match_score >= 20 & match_score < 40
replace tracking_status = "Very weak/No match (<20)" if match_score < 20
replace tracking_status = "Baseline only" if in_baseline == 1 & in_endline == 0
replace tracking_status = "Endline only" if in_baseline == 0 & in_endline == 1

label variable tracking_status "Tracking quality category"

// Display distribution
di _n "Tracking Status Distribution:"
tab tracking_status, mi

// Create detailed matching breakdown
gen match_details = ""
replace match_details = "Admin:" + string(admin_match) + " | "
replace match_details = match_details + "HH:" + string(household_match) + " | "
replace match_details = match_details + "Name:" + string(childname_match, "%3.1f") + " | "
replace match_details = match_details + "Age:" + string(age_consistent, "%3.1f") + " | "
replace match_details = match_details + "Gender:" + string(gender_consistent) + " | "
replace match_details = match_details + "CG:" + string(caregiver_match, "%3.1f")
label variable match_details "Detailed matching breakdown"

/*==============================================================================
                    6. GPS LOCATION VALIDATION
==============================================================================*/

di _n(2) ">>> SECTION 6: GPS LOCATION VALIDATION <<<"

// Calculate distance between baseline and endline GPS coordinates
gen distance_meters = .

capture confirm variable latitude_bl longitude_bl latitude_el longitude_el
if _rc == 0 {
    di "GPS coordinates found. Calculating distances using Haversine formula..."

    // Haversine formula to calculate distance
    replace distance_meters = 2 * 6371000 * ///
        asin(sqrt(sin((radians(latitude_el) - radians(latitude_bl)) / 2)^2 + ///
                  cos(radians(latitude_bl)) * cos(radians(latitude_el)) * ///
                  sin((radians(longitude_el) - radians(longitude_bl)) / 2)^2)) ///
        if !missing(latitude_bl) & !missing(longitude_bl) & ///
           !missing(latitude_el) & !missing(longitude_el)

    label variable distance_meters "GPS distance between baseline and endline (meters)"

    // Summary statistics
    quietly summarize distance_meters, detail
    if r(N) > 0 {
        di _n "GPS Distance Summary (meters):"
        di "  Mean: " %9.2f r(mean)
        di "  Median: " %9.2f r(p50)
        di "  SD: " %9.2f r(sd)
        di "  Range: " %9.2f r(min) " to " %9.2f r(max)
    }

    // Create flags for different distance thresholds
    // CUSTOMIZE: Adjust thresholds based on your context
    gen gps_flag_50m = (distance_meters > $gps_threshold_low & !missing(distance_meters))
    gen gps_flag_100m = (distance_meters > $gps_threshold_medium & !missing(distance_meters))
    gen gps_flag_200m = (distance_meters > $gps_threshold_high & !missing(distance_meters))
    gen gps_flag_500m = (distance_meters > $gps_threshold_extreme & !missing(distance_meters))

    label variable gps_flag_50m "GPS location change > 50m"
    label variable gps_flag_100m "GPS location change > 100m"
    label variable gps_flag_200m "GPS location change > 200m"
    label variable gps_flag_500m "GPS location change > 500m"

    // Display flagging statistics
    di _n "GPS Distance Threshold Analysis:"
    foreach threshold in 50 100 200 500 {
        quietly count if gps_flag_`threshold'm == 1
        local n_flagged = r(N)
        quietly count if !missing(distance_meters)
        local n_total = r(N)
        if `n_total' > 0 {
            local pct = (`n_flagged' / `n_total') * 100
            di "  Distance > `threshold'm: " %5.1f `pct' "% (" `n_flagged' "/" `n_total' ")"
        }
    }
}
else {
    di "⚠ WARNING: GPS coordinates not found in data"
    di "  Skipping GPS distance validation"
}

/*==============================================================================
                    7. IDENTIFY TRACKING ISSUES
==============================================================================*/

di _n(2) ">>> SECTION 7: IDENTIFYING POTENTIAL TRACKING ISSUES <<<"

gen tracking_issue = ""
gen tracking_issue_detail = ""

// Issue 1: Low match score but childid exists
replace tracking_issue = "Low confidence despite childid" ///
    if match_score < 60 & !missing(childid) & in_baseline == 1 & in_endline == 1
replace tracking_issue_detail = "Match score " + string(match_score, "%3.0f") + ///
                                " suggests possible mismatch" ///
    if tracking_issue == "Low confidence despite childid"

// Issue 2: Name mismatch
replace tracking_issue = "Child name mismatch" ///
    if tracking_issue == "" & childname_match < 0.5 & in_baseline == 1 & in_endline == 1
replace tracking_issue_detail = "Child name does not match between waves" ///
    if tracking_issue == "Child name mismatch"

// Issue 3: Age inconsistency
replace tracking_issue = "Age inconsistency" ///
    if tracking_issue == "" & age_consistent < 0.5 & !missing(age_diff) & ///
       in_baseline == 1 & in_endline == 1
replace tracking_issue_detail = "Age diff = " + string(age_diff, "%3.1f") + " years" ///
    if tracking_issue == "Age inconsistency"

// Issue 4: Gender mismatch
replace tracking_issue = "Gender mismatch" ///
    if tracking_issue == "" & gender_consistent == 0 & ///
       !missing(gender_bl) & !missing(gender_el) & in_baseline == 1 & in_endline == 1
replace tracking_issue_detail = "Gender changed from baseline to endline" ///
    if tracking_issue == "Gender mismatch"

// Issue 5: Large GPS location change
capture confirm variable gps_flag_200m
if _rc == 0 {
    replace tracking_issue = "Large GPS location change" ///
        if tracking_issue == "" & gps_flag_200m == 1 & in_baseline == 1 & in_endline == 1
    replace tracking_issue_detail = "GPS distance > 200m (distance = " + ///
                                    string(distance_meters, "%6.1f") + "m)" ///
        if tracking_issue == "Large GPS location change"
}

label variable tracking_issue "Primary tracking issue identified"
label variable tracking_issue_detail "Detailed description of tracking issue"

// Summary of tracking issues
quietly count if tracking_issue != "" & tracking_issue != "." & in_baseline == 1 & in_endline == 1
local n_issues = r(N)

di _n "Summary of Identified Tracking Issues:"
di "  Total observations with issues: " `n_issues'

if `n_issues' > 0 {
    di _n "  Breakdown by issue type:"
    tab tracking_issue, mi sort
}
else {
    di _n "  No major tracking issues identified!"
}

/*==============================================================================
                    8. GENERATE TRACKING REPORT
==============================================================================*/

di _n(2) ">>> SECTION 8: GENERATING TRACKING REPORT <<<"

// Display comprehensive tracking summary
quietly count if in_baseline == 1 & in_endline == 1
local n_paired = r(N)

di _n "Tracking Validation Summary:"
di "{hline 80}"
di "Total baseline-endline pairs: " `n_paired'

if `n_paired' > 0 {
    di _n "Match Score Distribution:"
    summarize match_score if in_baseline == 1 & in_endline == 1, detail

    di _n "Component-Level Matching Rates:"

    quietly count if admin_match == 1 & in_baseline == 1 & in_endline == 1
    di "  Administrative location: " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

    quietly count if household_match == 1 & in_baseline == 1 & in_endline == 1
    di "  Household/School ID: " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

    quietly count if childname_match >= 0.5 & in_baseline == 1 & in_endline == 1
    di "  Child name (partial+exact): " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

    quietly count if childname_match == 1 & in_baseline == 1 & in_endline == 1
    di "  Child name (exact only): " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

    quietly count if age_consistent >= 0.5 & in_baseline == 1 & in_endline == 1
    di "  Age consistency: " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

    quietly count if gender_consistent == 1 & in_baseline == 1 & in_endline == 1
    di "  Gender consistency: " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

    quietly count if caregiver_match >= 0.5 & in_baseline == 1 & in_endline == 1
    di "  Caregiver (match or expected change): " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"
}

di "{hline 80}"

/*==============================================================================
                    9. EXPORT RESULTS
==============================================================================*/

di _n(2) ">>> SECTION 9: EXPORTING RESULTS <<<"

// Export main tracking validation results
preserve
    keep if in_baseline == 1 & in_endline == 1

    keep childid tracking_status match_score tracking_issue tracking_issue_detail ///
         admin_match household_match childname_match childname_match_quality ///
         age_consistent age_diff gender_consistent ///
         caregiver_match caregiver_match_quality ///
         distance_meters gps_flag_* match_details ///
         *_bl *_el

    order childid tracking_status match_score tracking_issue tracking_issue_detail

    // Export to Excel
    export excel using "${tables}/participant_tracking_validation.xlsx", ///
        firstrow(variables) replace

    // Export to CSV
    export delimited using "${tables}/participant_tracking_validation.csv", ///
        delimiter(",") replace

    di "✓ Tracking validation results exported"
restore

// Export tracking issues separately
preserve
    keep if tracking_issue != "" & tracking_issue != "." & in_baseline == 1 & in_endline == 1

    if _N > 0 {
        keep childid tracking_status match_score tracking_issue tracking_issue_detail ///
             admin_match household_match childname_match age_diff gender_consistent ///
             distance_meters match_details

        order childid tracking_issue tracking_issue_detail match_score tracking_status

        // Export to Excel
        export excel using "${tables}/tracking_issues.xlsx", ///
            firstrow(variables) replace

        di "✓ Tracking issues exported"
    }
    else {
        di "⚠ No tracking issues to export"
    }
restore

// Save dataset with tracking validation variables
save "${data_processed}/merged_analysis_data_tracked.dta", replace
di "✓ Dataset with tracking variables saved"

di _n "Results exported to:"
di "  - ${tables}/participant_tracking_validation.xlsx"
di "  - ${tables}/participant_tracking_validation.csv"
di "  - ${tables}/tracking_issues.xlsx (if issues found)"
di "  - ${data_processed}/merged_analysis_data_tracked.dta"

/*==============================================================================
                    10. CLEANUP AND COMPLETION
==============================================================================*/

di _n(2) "{hline 80}"
di "PARTICIPANT TRACKING VALIDATION COMPLETED SUCCESSFULLY"
di "{hline 80}" _n

di "Output files created:"
di "  1. ${tables}/participant_tracking_validation.xlsx (full validation)"
di "  2. ${tables}/participant_tracking_validation.csv (full validation)"
di "  3. ${tables}/tracking_issues.xlsx (flagged cases only)"
di "  4. ${data_processed}/merged_analysis_data_tracked.dta (dataset with tracking vars)"
di "  5. ${logs}/06_participant_tracking_`log_date'_`log_time'.log (analysis log)"

di _n "Key Findings:"
di "  - Total baseline-endline pairs: " `n_paired'
di "  - Tracking issues identified: " `n_issues' " (" %4.1f (`n_issues'/`n_paired'*100) "%)"

di _n "Next Steps:"
di "  - Review cases with tracking_status = 'Weak match' or 'Very weak/No match'"
di "  - Investigate all flagged tracking issues in tracking_issues.xlsx"
di "  - Consider excluding low-confidence matches from analysis"
di "  - Document tracking validation decisions"

di _n "Analysis completed: `c(current_date)' `c(current_time)'"
di "{hline 80}" _n

log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
