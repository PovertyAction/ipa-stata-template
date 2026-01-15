/*==============================================================================
PROJECT: Impact Evaluation and Measurement Reliability Analysis
PURPOSE: Analyze baseline vs endline impact and endline vs backcheck reliability
AUTHOR:  Claude Code
DATE:    2025-11-14
==============================================================================*/
*%%
clear all
set more off
version 16

/*------------------------------------------------------------------------------
SECTION 0: SETUP AND DIRECTORIES
------------------------------------------------------------------------------*/

// Set working directory
cd "C:\Users\IPACOLPC105\scratch\ipa-stata-template"

// Define file paths
*idela file
global baseline "D:\Review\EC5\01_baseline\02_outputs\LMEE_Baseline_EC5_ChildSurvey_pii_idela.dta"
*idela file
global endline "D:\Review\EC5\02_endline\02_outputs\Child_Survey_EC5_Endline_LMEE_idela.dta"
global backcheck "D:\04_Endline\02_Data Management\05 EC 5\04 ChildSurvey\4_data\2_survey\Child_Survey_EC5_Endline_Backcheck.dta"
global caregiver "D:\04_Endline\02_Data Management\05 EC 5\03 CaregiverSurvey\4_data\5_clean\LMEE_EC5_Endline_PrimaryCaregiver_pii.dta"

// Create output directories
capture mkdir "output/tables"
capture mkdir "output/figures"
capture mkdir "data/processed"

// Start log file
*log using "output/impact_reliability_analysis_log.txt", replace text

/*------------------------------------------------------------------------------
SECTION 1: LOAD AND EXPLORE DATASETS
------------------------------------------------------------------------------*/
*%%
di _n(2) "{hline 80}"
di "SECTION 1: DATA EXPLORATION"
di "{hline 80}" _n

// Define outcome variables of interest
global outcomes "c1_1 c1_3 c1_4 c1_5 c1_6 c2_1 c2_2 c2_3 c2_4 c3_1 c3_2 c3_3 c4_4"
*removed: a05 a05_pl child_name
global demographics "enum_id subdate region_id region district schooil_id school community  caregiver a08a old_childid  childid child_age child_name latitude longitude altitude gender schoolid childname caregiverid childcode carecode hhid hh_replace"
global idela "sizepct sortpct shapepct numidpct onetoonepct addsubpct puzzlepct numeracy expvocpct papct ltridpct wordpairpct writlevpct oralcomppct literacy friendspct emotionpct empathypct conflictpct personalpct socialemotional memorypct headtoespct execfunction humanpct foldpct copysqpct grossmotorpct motor schoolready"
global spelke_el "ptn_pct extranum_pct pm_pct geointr_pct sp_numeracy attsw_pct mentalst_pct sp_execfunction vocabulary_pct spelke fnumeracy fliteracy fef fse fmotor fschoolready"

// Define descriptive labels for outcomes
local label_c1_1 "Child weight in kgs"
local label_c1_3 "Child weight in kgs"
local label_c1_4 "Child weight in kgs"
local label_c1_5 "Did respondent wear heavy materials during measurement"
local label_c1_6 "Was flat surface available for weighing scale"
local label_c2_1 "Height of child"
local label_c2_2 "Height of child"
local label_c2_3 "Height of child"
local label_c2_4 "Height of child"
local label_c3_1 "Mid-upper arm circumference"
local label_c3_2 "Mid-upper arm circumference"
local label_c3_3 "Mid-upper arm circumference"
local label_c4_4 "Mid-upper arm circumference"
local label_enum_id "Enumerator ID"
local label_subdate "Submission date"
local label_region_id "Region ID"
local label_region "Region"
local label_district "District"
local label_school "School"
local label_community "Community"
*local label_caregivera "Name of Biological Mother"
local label_caregiver "Caregiver name"
*local label_a05 "Child name"
*local label_a05_pl "Child name (place)"
local label_childid "Child ID"
local label_child_age "Child age in years"
local label_child_name "Child name"

local label_sizepct "IDELA: Size Percentile"
local label_sortpct "IDELA: Sort Percentile"
local label_shapepct "IDELA: Shape Percentile"
local label_numidpct "IDELA: Number Identification Percentile"
local label_onetoonepct "IDELA: One-to-One Correspondence Percentile"
local label_addsubpct "IDELA: Addition and Subtraction Percentile"
local label_puzzlepct "IDELA: Puzzle Percentile"
local label_numeracy "IDELA: Numeracy Percentile"
local label_expvocpct "IDELA: Expressive Vocabulary Percentile"
local label_papct "IDELA: Print Awareness Percentile"
local label_ltridpct "IDELA: Letter Identification Percentile"
local label_wordpairpct "IDELA: Word Pair Percentile"
local label_writlevpct "IDELA: Writing Level Percentile"
local label_oralcomppct "IDELA: Oral Comprehension Percentile"
local label_literacy "IDELA: Literacy Percentile"
local label_friendspct "IDELA: Social - Friends Percentile"
local label_emotionpct "IDELA: Social - Emotion Percentile"
local label_empathypct "IDELA: Social - Empathy Percentile"
local label_conflictpct "IDELA: Social - Conflict Percentile"
local label_personalpct "IDELA: Social - Personal Percentile"
local label_socialemotional "IDELA: Social-Emotional Percentile"
local label_memorypct "IDELA: Memory Percentile"
local label_headtoespct "IDELA: Head-to-Toes Percentile"
local label_execfunction "IDELA: Executive Function Percentile"
local label_humanpct "IDELA: Human Figure Drawing Percentile"
local label_foldpct "IDELA: Paper Folding Percentile"
local label_copysqpct "IDELA: Copying a Square Percentile"
local label_grossmotorpct "IDELA: Gross Motor Percentile"
local label_motor "IDELA: Motor Percentile"
local label_schoolready "IDELA: School Readiness Percentile"


/*--- 1.1: BASELINE DATA ---*/
di _n ">>> BASELINE DATA EXPLORATION <<<"
use "$baseline", clear

di _n "Number of observations: " _N
di "Number of variables: " c(k)

*child age
rename childage_yrs child_age
rename childid childid_new
rename old_childid childid

// Check for childid
capture confirm variable childid
if _rc == 0 {
    di _n "childid variable: EXISTS"

    // Check uniqueness
    duplicates report childid
    quietly count if missing(childid)
    di "Missing childid: " r(N)

    // Check which outcome variables exist
    di _n "Outcome variables present in BASELINE:"
    global outcomeses1 "$outcomes $idela $demographics"
    foreach var of global outcomeses1 {
        capture confirm variable `var'
        if _rc == 0 {
            di "  - `var': EXISTS (`label_`var'')" 
        }
    }
}
else {
    di _n "WARNING: childid variable NOT FOUND in baseline"
    di "Available ID variables:"
    lookfor id
}

// Check for treatment variable
di _n "Searching for treatment variable:"
capture confirm variable treatment
if _rc == 0 {
    di "  treatment variable found"
    capture confirm numeric variable treatment
    if _rc == 0 {
        quietly tab treatment, mi
        di "  Type: numeric"
    }
    else {
        quietly tab treatment, mi
        di "  Type: string"
    }
}
else {
    di "  WARNING: treatment variable not found"
}

// Save variable list for baseline
quietly ds
global baseline_vars `r(varlist)'

// Keep only childid and outcome variables that exist

local keep_vars "childid"
local all_vars "$outcomes $demographics $idela"
foreach var of local all_vars {
    capture confirm variable `var'
    if _rc == 0 {
        local keep_vars "`keep_vars' `var'"
    }
}

// Add treatment variable if found
capture confirm variable treatment
if _rc == 0 {
    local keep_vars "`keep_vars' treatment"
}

keep `keep_vars'

// Rename variables with _bl suffix
foreach var of varlist * {
    if "`var'" != "childid" {
        rename `var' `var'_bl
    }
}

// Display variables in this dataset
di _n "Variables in baseline dataset:"
quietly ds
di "`r(varlist)'"

tempfile baseline_clean
save `baseline_clean'.dta, replace

/*--- 1.2: ENDLINE DATA ---*/
*%%
di _n(2) ">>> ENDLINE DATA EXPLORATION <<<"
use "$endline", clear

di _n "Number of observations: " _N
di "Number of variables: " c(k)

rename childage child_age
rename childid childid_new
rename old_childid childid

// Check for childid
*rename child_id_main childid
capture confirm variable childid
if _rc == 0 {
    di _n "childid variable: EXISTS"

    // Check uniqueness
    duplicates report childid
    quietly count if missing(childid)
    di "Missing childid: " r(N)

    // Check which outcome variables exist
    di _n "Outcome variables present in ENDLINE:"
    foreach var of global outcomes {
        capture confirm variable `var'
        if _rc == 0 {
            di "  - `var': EXISTS (`label_`var'')" 
        }
    }
}
else {
    di _n "WARNING: childid variable NOT FOUND in endline"
    di "Available ID variables:"
    lookfor id
}

// Check for treatment variable
di _n "Searching for treatment variable:"
capture confirm variable treatment
if _rc == 0 {
    di "  treatment variable found"
    capture confirm numeric variable treatment
    if _rc == 0 {
        quietly tab treatment, mi
        di "  Type: numeric"
    }
    else {
        quietly tab treatment, mi
        di "  Type: string"
    }
}
else {
    di "  WARNING: treatment variable not found"
}

// Keep only childid and outcome variables that exist

destring child_age, replace
local keep_vars "childid"
local all_vars "$outcomes $demographics $idela $spelke_el"
foreach var of local all_vars {
    capture confirm variable `var'
    if _rc == 0 {
        local keep_vars "`keep_vars' `var'"
    }
}

// Add treatment variable if found
capture confirm variable treatment
if _rc == 0 {
    local keep_vars "`keep_vars' treatment"
}

keep `keep_vars'

// Rename variables with _el suffix
foreach var of varlist * {
    if "`var'" != "childid" {
        rename `var' `var'_el
    }
}

// Display variables in this dataset
di _n "Variables in endline dataset:"
quietly ds
di "`r(varlist)'"

tempfile endline_clean
save `endline_clean'.dta, replace

/*--- 1.3: BACKCHECK DATA ---*/
*%%
di _n(2) ">>> BACKCHECK DATA EXPLORATION <<<"
use "$backcheck", clear

di _n "Number of observations: " _N
di "Number of variables: " c(k)

rename child_name childname
// Check for childid

capture confirm variable childid
if _rc == 0 {
    di _n "childid variable: EXISTS"

    // Check uniqueness
    duplicates report childid
    quietly count if missing(childid)
    di "Missing childid: " r(N)
    **delete duplicates if any**
    duplicates drop childid, force


    // Check which outcome variables exist
    di _n "Outcome variables present in BACKCHECK:"
    foreach var of global outcomes {
        capture confirm variable `var'
        if _rc == 0 {
            di "  - `var': EXISTS (`label_`var'')" 
        }
    }
}
else {
    di _n "WARNING: childid variable NOT FOUND in backcheck"
    di "Available ID variables:"
    lookfor id
}

// Keep only childid and outcome variables that exist
  
*transform subdate from %tc to %td
gen subdate = dofc(submissiondate)
format subdate %tdDDmonCCYY
drop submissiondate

local keep_vars "childid"
local all_vars "$outcomes $demographics"
foreach var of local all_vars {
    capture confirm variable `var'
    if _rc == 0 {
        local keep_vars "`keep_vars' `var'"
    }
}

keep `keep_vars'

// Rename variables with _bc suffix
foreach var of varlist * {
    if "`var'" != "childid" {
        rename `var' `var'_bc
    }
}

// Display variables in this dataset
di _n "Variables in backcheck dataset:"
quietly ds
di "`r(varlist)'"

tempfile backcheck_clean
save `backcheck_clean'.dta, replace

/*------------------------------------------------------------------------------
SECTION 2: MERGE DATASETS
------------------------------------------------------------------------------*/
*%%
di _n(2) "{hline 80}"
di "SECTION 2: MERGING DATASETS"
di "{hline 80}" _n

// Start with baseline
use `baseline_clean'.dta, clear
di "Baseline observations: " _N

// Merge with endline
merge 1:1 childid using `endline_clean'.dta, gen(_merge_bl_el)
di _n "After merging with endline:"
tab _merge_bl_el
di "Total observations: " _N

// Merge with backcheck
merge 1:1 childid using `backcheck_clean'.dta, gen(_merge_bc)
di _n "After merging with backcheck:"
tab _merge_bc
di "Total observations: " _N

// Create merge indicators
*%%
gen in_baseline = (_merge_bl_el == 1 | _merge_bl_el == 3)
gen in_endline = (_merge_bl_el == 2 | _merge_bl_el == 3)
gen in_backcheck = (_merge_bc == 2 | _merge_bc == 3)

// Summary of sample composition
di _n "Sample Composition:"
di "  In baseline only: "
count if in_baseline == 1 & in_endline == 0
di "  In baseline AND endline: "
count if in_baseline == 1 & in_endline == 1
di "  In endline only: "
count if in_baseline == 0 & in_endline == 1
di "  In backcheck: "
count if in_backcheck == 1
di "  In endline AND backcheck: "
count if in_endline == 1 & in_backcheck == 1

/*--- 2.1: FIX TYPE MISMATCHES ---*/
di _n(2) ">>> FIXING TYPE MISMATCHES ACROSS DATASETS <<<"

// Check and fix type mismatches for outcome variables
di _n "Checking OUTCOME variables for type mismatches:"
global outcomeses "$outcomes $idela"
foreach var of global outcomeses {
    // Check if variable exists in any dataset
    local has_bl = 0
    local has_el = 0
    local has_bc = 0
    
    capture confirm variable `var'_bl
    if _rc == 0 local has_bl = 1
    
    capture confirm variable `var'_el
    if _rc == 0 local has_el = 1
    
    capture confirm variable `var'_bc
    if _rc == 0 local has_bc = 1
    
    // If variable exists in at least 2 datasets, check types
    if (`has_bl' + `has_el' + `has_bc') >= 2 {
        
        local type_bl ""
        local type_el ""
        local type_bc ""
        
        if `has_bl' {
            capture confirm numeric variable `var'_bl
            if _rc == 0 {
                local type_bl "numeric"
            }
            else {
                local type_bl "string"
            }
        }
        
        if `has_el' {
            capture confirm numeric variable `var'_el
            if _rc == 0 {
                local type_el "numeric"
            }
            else {
                local type_el "string"
            }
        }
        
        if `has_bc' {
            capture confirm numeric variable `var'_bc
            if _rc == 0 {
                local type_bc "numeric"
            }
            else {
                local type_bc "string"
            }
        }
        
        // Check for type mismatch
        local has_mismatch = 0
        if `has_bl' & `has_el' & "`type_bl'" != "`type_el'" local has_mismatch = 1
        if `has_bl' & `has_bc' & "`type_bl'" != "`type_bc'" local has_mismatch = 1
        if `has_el' & `has_bc' & "`type_el'" != "`type_bc'" local has_mismatch = 1
        
        if `has_mismatch' {
            di _n "  WARNING: Type mismatch detected for `var'"
            if `has_bl' di "    - `var'_bl: `type_bl'"
            if `has_el' di "    - `var'_el: `type_el'"
            if `has_bc' di "    - `var'_bc: `type_bc'"
            
            // Try to convert string variables to numeric
            if `has_bl' & "`type_bl'" == "string" {
                di "    - Attempting to convert `var'_bl to numeric..."
                capture destring `var'_bl, replace force
                if _rc == 0 {
                    di "      SUCCESS"
                }
                else {
                    di "      FAILED - dropping `var'_bl"
                    drop `var'_bl
                }
            }
            
            if `has_el' & "`type_el'" == "string" {
                di "    - Attempting to convert `var'_el to numeric..."
                capture destring `var'_el, replace force
                if _rc == 0 {
                    di "      SUCCESS"
                }
                else {
                    di "      FAILED - dropping `var'_el"
                    drop `var'_el
                }
            }
            
            if `has_bc' & "`type_bc'" == "string" {
                di "    - Attempting to convert `var'_bc to numeric..."
                capture destring `var'_bc, replace force
                if _rc == 0 {
                    di "      SUCCESS"
                }
                else {
                    di "      FAILED - dropping `var'_bc"
                    drop `var'_bc
                }
            }
        }
    }
}

di _n "Outcome variable type mismatch checking complete."

// Check and fix type mismatches for demographic variables
di _n(2) "Checking DEMOGRAPHIC variables for type mismatches:"
foreach var of global demographics {
    // Skip childid as it shouldn't have suffixes
    if "`var'" == "childid" continue
    
    // Check if variable exists in any dataset
    local has_bl = 0
    local has_el = 0
    local has_bc = 0
    
    capture confirm variable `var'_bl
    if _rc == 0 local has_bl = 1
    
    capture confirm variable `var'_el
    if _rc == 0 local has_el = 1
    
    capture confirm variable `var'_bc
    if _rc == 0 local has_bc = 1
    
    // If variable exists in at least 2 datasets, check types
    if (`has_bl' + `has_el' + `has_bc') >= 2 {
        
        local type_bl ""
        local type_el ""
        local type_bc ""
        
        if `has_bl' {
            capture confirm numeric variable `var'_bl
            if _rc == 0 {
                local type_bl "numeric"
            }
            else {
                local type_bl "string"
            }
        }
        
        if `has_el' {
            capture confirm numeric variable `var'_el
            if _rc == 0 {
                local type_el "numeric"
            }
            else {
                local type_el "string"
            }
        }
        
        if `has_bc' {
            capture confirm variable `var'_bc
            if _rc == 0 {
                capture confirm numeric variable `var'_bc
                if _rc == 0 {
                    local type_bc "numeric"
                }
                else {
                    local type_bc "string"
                }
            }
        }
        
        // Check for type mismatch
        local has_mismatch = 0
        if `has_bl' & `has_el' & "`type_bl'" != "`type_el'" local has_mismatch = 1
        if `has_bl' & `has_bc' & "`type_bl'" != "`type_bc'" local has_mismatch = 1
        if `has_el' & `has_bc' & "`type_el'" != "`type_bc'" local has_mismatch = 1
        
        if `has_mismatch' {
            di _n "  WARNING: Type mismatch detected for demographic variable `var'"
            if `has_bl' di "    - `var'_bl: `type_bl'"
            if `has_el' di "    - `var'_el: `type_el'"
            if `has_bc' di "    - `var'_bc: `type_bc'"
            di "    - Keeping as-is (demographic variables may have different types)"
        }
    }
}

di _n "All type mismatch checking complete."

// Save merged dataset
save "data/processed/merged_analysis_data.dta", replace

/*------------------------------------------------------------------------------
SECTION 3: IDENTIFY AVAILABLE OUTCOME PAIRS
------------------------------------------------------------------------------*/
*%%
di _n(2) "{hline 80}"
di "SECTION 3: IDENTIFYING AVAILABLE OUTCOME PAIRS"
di "{hline 80}" _n

// Identify which outcome pairs exist for baseline-endline comparison
di ">>> BASELINE-ENDLINE PAIRS <<<"
local bl_el_pairs ""
global all_outcomes "$outcomes $idela"
foreach var of global all_outcomes {
    capture confirm variable `var'_bl
    local bl_exists = (_rc == 0)

    capture confirm variable `var'_el
    local el_exists = (_rc == 0)

    if `bl_exists' & `el_exists' {
        di "  `var': Both baseline and endline exist (`label_`var'')"
        local bl_el_pairs "`bl_el_pairs' `var'"
    }
}
global bl_el_pairs "`bl_el_pairs'"
di "Baseline-Endline pairs: $bl_el_pairs"
// Identify which outcome pairs exist for endline-backcheck comparison
di _n ">>> ENDLINE-BACKCHECK PAIRS <<<"
local el_bc_pairs ""
foreach var of global outcomes {
    capture confirm variable `var'_el
    local el_exists = (_rc == 0)

    capture confirm variable `var'_bc
    local bc_exists = (_rc == 0)

    if `el_exists' & `bc_exists' {
        di "  `var': Both endline and backcheck exist (`label_`var'')"
        local el_bc_pairs "`el_bc_pairs' `var'"
    }
}
global el_bc_pairs "`el_bc_pairs'"
di "Endline-Backcheck pairs: $el_bc_pairs"


/*------------------------------------------------------------------------------
SECTION 4: IMPACT ANALYSIS (BASELINE VS ENDLINE)
------------------------------------------------------------------------------*/
*%%
di _n(2) "{hline 80}"
di "SECTION 4: IMPACT ANALYSIS (BASELINE VS ENDLINE)"
di "{hline 80}" _n

// Ensure output directory exists
capture mkdir "output"
capture mkdir "output/tables"
capture mkdir "output/figures"

// Create file for impact results
tempname impact_results
postfile `impact_results' str30 variable n_pairs ///
    mean_bl sd_bl mean_el sd_el ///
    mean_diff se_diff t_stat p_value ///
    cohens_d lower_ci upper_ci ///
    using "output/tables/impact_results.dta", replace

// Filter bl_el_pairs to include only numeric variable pairs
di _n ">>> FILTERING FOR NUMERIC VARIABLE PAIRS <<<"
local numeric_bl_el_pairs ""
foreach var of global bl_el_pairs {
    // Check if both baseline and endline versions are numeric
    capture confirm numeric variable `var'_bl
    local bl_numeric = (_rc == 0)
    
    capture confirm numeric variable `var'_el
    local el_numeric = (_rc == 0)
    
    if `bl_numeric' & `el_numeric' {
        di "  `var': Both versions are numeric - INCLUDED (`label_`var'')"
        local numeric_bl_el_pairs "`numeric_bl_el_pairs' `var'"
    }
    else {
        di "  `var': Type mismatch or non-numeric - EXCLUDED (`label_`var'')"
        if !`bl_numeric' {
            di "    - `var'_bl is string"
        }
        if !`el_numeric' {
            di "    - `var'_el is string"
        }
    }
}
global numeric_bl_el_pairs "`numeric_bl_el_pairs'"
di _n "Total numeric pairs for analysis: `: word count $numeric_bl_el_pairs'"

// Loop through each available numeric baseline-endline pair
foreach var of global numeric_bl_el_pairs {

    di _n(2) ">>> Analyzing: `var' (`label_`var'') <<<"

    // Count non-missing pairs
    quietly count if !missing(`var'_bl) & !missing(`var'_el)
    local n_pairs = r(N)

    if `n_pairs' > 0 {

        // Descriptive statistics
        quietly summarize `var'_bl
        local mean_bl = r(mean)
        local sd_bl = r(sd)

        quietly summarize `var'_el
        local mean_el = r(mean)
        local sd_el = r(sd)

        // Calculate difference
        quietly gen diff_`var' = `var'_el - `var'_bl if !missing(`var'_bl) & !missing(`var'_el)

        quietly summarize diff_`var'
        local mean_diff = r(mean)
        local sd_diff = r(sd)
        local se_diff = r(sd) / sqrt(r(N))

        // Paired t-test
        quietly ttest `var'_el == `var'_bl
        local t_stat = r(t)
        local p_value = r(p)

        // Cohen's d effect size
        local cohens_d = `mean_diff' / `sd_bl'

        // 95% CI for mean difference
        local lower_ci = `mean_diff' - 1.96 * `se_diff'
        local upper_ci = `mean_diff' + 1.96 * `se_diff'

        // Display results
        di "  N pairs: " `n_pairs'
        di "  Baseline:  Mean = " %9.3f `mean_bl' ", SD = " %9.3f `sd_bl'
        di "  Endline:   Mean = " %9.3f `mean_el' ", SD = " %9.3f `sd_el'
        di "  Difference: Mean = " %9.3f `mean_diff' ", SE = " %9.3f `se_diff'
        di "  t-statistic = " %9.3f `t_stat' ", p-value = " %9.4f `p_value'
        di "  Cohen's d = " %9.3f `cohens_d'
        di "  95% CI: [" %9.3f `lower_ci' ", " %9.3f `upper_ci' "]"

        // Post results
        post `impact_results' ("`var'") (`n_pairs') ///
            (`mean_bl') (`sd_bl') (`mean_el') (`sd_el') ///
            (`mean_diff') (`se_diff') (`t_stat') (`p_value') ///
            (`cohens_d') (`lower_ci') (`upper_ci')

        // Create before-after plot
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
                title("`label_`var''") ///
                subtitle("Baseline vs Endline") ///
                ytitle("`var'") ///
                note("N = `n_pairs' matched pairs") ///
                scheme(s2color)
            graph export "output/figures/`var'_beforeafter_boxplot.png", replace width(1200)

            // Mean plot with error bars
            collapse (mean) mean=`var'_ (sd) sd=`var'_ (count) n=`var'_, by(time)
            gen se = sd / sqrt(n)
            gen ci_lower = mean - 1.96*se
            gen ci_upper = mean + 1.96*se

            twoway (rcap ci_lower ci_upper time, lcolor(navy)) ///
                   (scatter mean time, mcolor(navy) msize(large)), ///
                title("`label_`var''") ///
                subtitle("Baseline to Endline") ///
                ytitle("Mean `var'") ///
                xlabel(1 "Baseline" 2 "Endline") ///
                legend(off) ///
                note("Error bars show 95% CI") ///
                scheme(s2color)
            graph export "output/figures/`var'_beforeafter_means.png", replace width(1200)
        restore

    }
    else {
        di "  WARNING: No matched pairs available for `var'"
    }
}

postclose `impact_results'
*%%
// Load and display impact results table
use "output/tables/impact_results.dta", clear

// Add descriptive labels to the results
gen label = ""
replace label = "Child weight in kgs" if variable == "c1_1"
replace label = "Child weight in kgs" if variable == "c1_3" 
replace label = "Child weight in kgs" if variable == "c1_4"
replace label = "Did respondent wear heavy materials during measurement" if variable == "c1_5"
replace label = "Was flat surface available for weighing scale" if variable == "c1_6"
replace label = "Height of child" if variable == "c2_1"
replace label = "Height of child" if variable == "c2_2"
replace label = "Height of child" if variable == "c2_3"
replace label = "Height of child" if variable == "c2_4"
replace label = "Mid-upper arm circumference" if variable == "c3_1"
replace label = "Mid-upper arm circumference" if variable == "c3_2"
replace label = "Mid-upper arm circumference" if variable == "c3_3"
replace label = "Mid-upper arm circumference" if variable == "c4_4"
**add labels of idela variables**
replace label = "IDELA: Size Percentile" if variable == "sizepct"
replace label = "IDELA: Sort Percentile" if variable == "sortpct"
replace label = "IDELA: Shape Percentile" if variable == "shapepct"
replace label = "IDELA: Number Identification Percentile" if variable == "numidpct"
replace label = "IDELA: One-to-One Correspondence Percentile" if variable == "onetoonepct"
replace label = "IDELA: Addition and Subtraction Percentile" if variable == "addsubpct"
replace label = "IDELA: Puzzle Percentile" if variable == "puzzlepct"
replace label = "IDELA: Numeracy Percentile" if variable == "numeracy"
replace label = "IDELA: Expressive Vocabulary Percentile" if variable == "expvocpct"
replace label = "IDELA: Print Awareness Percentile" if variable == "papct"
replace label = "IDELA: Letter Identification Percentile" if variable == "ltridpct"
replace label = "IDELA: Word Pair Percentile" if variable == "wordpairpct"
replace label = "IDELA: Writing Level Percentile" if variable == "writlevpct"
replace label = "IDELA: Oral Comprehension Percentile" if variable == "oralcomppct"
replace label = "IDELA: Literacy Percentile" if variable == "literacy"
replace label = "IDELA: Social - Friends Percentile" if variable == "friendspct"
replace label = "IDELA: Social - Emotion Percentile" if variable == "emotionpct"
replace label = "IDELA: Social - Empathy Percentile" if variable == "empathypct"
replace label = "IDELA: Social - Conflict Percentile" if variable == "conflictpct"
replace label = "IDELA: Social - Personal Percentile" if variable == "personalpct"
replace label = "IDELA: Social-Emotional Percentile" if variable == "socialemotional"
replace label = "IDELA: Memory Percentile" if variable == "memorypct"
replace label = "IDELA: Head-to-Toes Percentile" if variable == "headtoespct"
replace label = "IDELA: Executive Function Percentile" if variable == "execfunction"
replace label = "IDELA: Human Figure Drawing Percentile" if variable == "humanpct"
replace label = "IDELA: Paper Folding Percentile" if variable == "foldpct"
replace label = "IDELA: Copying a Square Percentile" if variable == "copysqpct"
replace label = "IDELA: Gross Motor Percentile" if variable == "grossmotorpct"
replace label = "IDELA: Motor Percentile" if variable == "motor"
replace label = "IDELA: School Readiness Percentile" if variable == "schoolready"


// Reorder variables to show label first
order variable label n_pairs mean_bl sd_bl mean_el sd_el mean_diff se_diff t_stat p_value cohens_d lower_ci upper_ci

list, clean noobs

// Export to Excel
export excel using "output/tables/impact_analysis_results.xlsx", ///
    firstrow(variables) replace

// Export to CSV
export delimited using "output/tables/impact_analysis_results.csv", ///
    delimiter(",") replace

/*------------------------------------------------------------------------------
SECTION 5: RELIABILITY ANALYSIS (ENDLINE VS BACKCHECK)
------------------------------------------------------------------------------*/
*%%
use "data/processed/merged_analysis_data.dta", clear

di _n(2) "{hline 80}"
di "SECTION 5: RELIABILITY ANALYSIS (ENDLINE VS BACKCHECK)"
di "{hline 80}" _n

// Re-identify which outcome pairs exist for endline-backcheck comparison
// (in case global was lost or data structure changed)
di _n ">>> RE-CHECKING ENDLINE-BACKCHECK PAIRS <<<"
local el_bc_pairs ""
foreach var of global outcomes {
    capture confirm variable `var'_el
    local el_exists = (_rc == 0)

    capture confirm variable `var'_bc
    local bc_exists = (_rc == 0)

    if `el_exists' & `bc_exists' {
        di "  `var': Both endline and backcheck exist (`label_`var'')"
        local el_bc_pairs "`el_bc_pairs' `var'"
    }
}
global el_bc_pairs "`el_bc_pairs'"
di "Endline-Backcheck pairs found: $el_bc_pairs"
di "Total pairs: `: word count $el_bc_pairs'"

// Create file for reliability results
tempname reliability_results
postfile `reliability_results' str30 variable n_pairs ///
    mean_el sd_el mean_bc sd_bc ///
    mean_diff mad mean_abs_pct_diff ///
    bias sd_diff loa_lower loa_upper ///
    icc icc_lb icc_ub ///
    n_flagged pct_flagged ///
    using "output/tables/reliability_results.dta", replace

// Filter el_bc_pairs to include only numeric variable pairs
di _n ">>> FILTERING FOR NUMERIC VARIABLE PAIRS (RELIABILITY) <<<"
local numeric_el_bc_pairs ""
foreach var of global el_bc_pairs {
    // Check if both endline and backcheck versions are numeric
    capture confirm numeric variable `var'_el
    local el_numeric = (_rc == 0)
    
    capture confirm numeric variable `var'_bc
    local bc_numeric = (_rc == 0)
    
    if `el_numeric' & `bc_numeric' {
        di "  `var': Both versions are numeric - INCLUDED (`label_`var'')"
        local numeric_el_bc_pairs "`numeric_el_bc_pairs' `var'"
    }
    else {
        di "  `var': Type mismatch or non-numeric - EXCLUDED (`label_`var'')"
        if !`el_numeric' {
            di "    - `var'_el is string"
        }
        if !`bc_numeric' {
            di "    - `var'_bc is string"
        }
    }
}
global numeric_el_bc_pairs "`numeric_el_bc_pairs'"
di _n "Total numeric pairs for reliability analysis: `: word count $numeric_el_bc_pairs'"

// Define WHO/standard thresholds for acceptable differences
// Weight: ±0.1 kg, Height: ±0.5 cm, Arm circumference: ±0.5 cm
local thresholds ""
foreach var of global numeric_el_bc_pairs {
    if regexm("`var'", "weight|c1_") {
        local threshold_`var' = 0.1
    }
    else if regexm("`var'", "height|c2_") {
        local threshold_`var' = 0.5
    }
    else if regexm("`var'", "arm|c3_|c4_") {
        local threshold_`var' = 0.5
    }
    else {
        local threshold_`var' = 0.5  // Default
    }
}

// Loop through each available numeric endline-backcheck pair
foreach var of global numeric_el_bc_pairs {

    di _n(2) ">>> Analyzing Reliability: `var' (`label_`var'') <<<"

    // Count non-missing pairs
    quietly count if !missing(`var'_el) & !missing(`var'_bc)
    local n_pairs = r(N)

    if `n_pairs' > 0 {

        /*--- A. DESCRIPTIVE STATISTICS ---*/
        quietly summarize `var'_el
        local mean_el = r(mean)
        local sd_el = r(sd)

        quietly summarize `var'_bc
        local mean_bc = r(mean)
        local sd_bc = r(sd)

        /*--- B. DIFFERENCE STATISTICS ---*/
        // Calculate difference (endline - backcheck)
        quietly gen diff_bc_`var' = `var'_el - `var'_bc if !missing(`var'_el) & !missing(`var'_bc)

        // Mean difference (bias)
        quietly summarize diff_bc_`var'
        local bias = r(mean)
        local sd_diff = r(sd)

        // Mean absolute difference (MAD)
        quietly gen abs_diff_bc_`var' = abs(diff_bc_`var')
        quietly summarize abs_diff_bc_`var'
        local mad = r(mean)

        // Mean absolute percentage difference
        quietly gen pct_diff_bc_`var' = 100 * abs(diff_bc_`var') / ((`var'_el + `var'_bc) / 2)
        quietly summarize pct_diff_bc_`var'
        local mean_abs_pct_diff = r(mean)

        /*--- C. BLAND-ALTMAN ANALYSIS ---*/
        // Limits of agreement
        local loa_lower = `bias' - 1.96 * `sd_diff'
        local loa_upper = `bias' + 1.96 * `sd_diff'

        // Create mean for Bland-Altman plot
        quietly gen mean_bc_`var' = (`var'_el + `var'_bc) / 2

        /*--- D. INTRACLASS CORRELATION (ICC) ---*/
        // Reshape data for ICC calculation
        preserve
            keep if !missing(`var'_el) & !missing(`var'_bc)
            keep childid `var'_el `var'_bc
            gen id = _n
            reshape long `var'_, i(id) j(measurement) string
            
            // Encode measurement as numeric for ANOVA
            encode measurement, gen(measurement_num)

            // Calculate ICC using anova
            quietly anova `var'_ id measurement_num

            // Get mean squares
            matrix results = r(table)

            // Alternative ICC calculation using loneway
            quietly loneway `var'_ id
            local icc = r(rho)

            // For 95% CI, we'll use approximation
            local icc_lb = max(0, `icc' - 1.96 * sqrt((1-`icc')^2 / `n_pairs'))
            local icc_ub = min(1, `icc' + 1.96 * sqrt((1-`icc')^2 / `n_pairs'))
        restore

        /*--- E. FLAG OBSERVATIONS EXCEEDING THRESHOLDS ---*/
        local threshold = `threshold_`var''
        quietly gen flag_`var' = (abs(diff_bc_`var') > `threshold') if !missing(diff_bc_`var')
        quietly count if flag_`var' == 1
        local n_flagged = r(N)
        local pct_flagged = (`n_flagged' / `n_pairs') * 100

        /*--- DISPLAY RESULTS ---*/
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

        di _n "  Intraclass Correlation:"
        di "    ICC = " %9.3f `icc'
        di "    95% CI: [" %9.3f `icc_lb' ", " %9.3f `icc_ub' "]"
        if `icc' > 0.90 di "    Interpretation: EXCELLENT reliability"
        else if `icc' > 0.75 di "    Interpretation: GOOD reliability"
        else if `icc' > 0.50 di "    Interpretation: MODERATE reliability"
        else di "    Interpretation: POOR reliability"

        di _n "  Quality Flags (threshold = " `threshold' "):"
        di "    N flagged = " `n_flagged' " (" %5.2f `pct_flagged' "%)"

        /*--- POST RESULTS ---*/
        post `reliability_results' ("`var'") (`n_pairs') ///
            (`mean_el') (`sd_el') (`mean_bc') (`sd_bc') ///
            (`mean_diff') (`mad') (`mean_abs_pct_diff') ///
            (`bias') (`sd_diff') (`loa_lower') (`loa_upper') ///
            (`icc') (`icc_lb') (`icc_ub') ///
            (`n_flagged') (`pct_flagged')

        /*--- CREATE BLAND-ALTMAN PLOT ---*/
        preserve
            keep if !missing(`var'_el) & !missing(`var'_bc)

            twoway (scatter diff_bc_`var' mean_bc_`var', mcolor(navy%50)) ///
               (function y = `bias', range(mean_bc_`var') lcolor(red) lpattern(solid)) ///
               (function y = `loa_lower', range(mean_bc_`var') lcolor(red) lpattern(dash)) ///
               (function y = `loa_upper', range(mean_bc_`var') lcolor(red) lpattern(dash)), ///
            title("`label_`var''") ///
            subtitle("Bland-Altman: Endline vs Backcheck Agreement") ///
            xtitle("Mean of Endline and Backcheck") ///
            ytitle("Difference (Endline - Backcheck)") ///
            legend(order(1 "Observations" 2 "Mean difference" 3 "Limits of agreement") ///
                   pos(4) ring(0) col(1)) ///
            note("Bias = " %5.3f `bias' ", LoA = [" %5.3f `loa_lower' ", " %5.3f `loa_upper' "]" ///
                 "ICC = " %5.3f `icc' ", N = " `n_pairs') ///
            scheme(s2color)
            graph export "output/figures/`var'_bland_altman.png", replace width(1200)
        restore

        /*--- CREATE SCATTER PLOT WITH IDENTITY LINE ---*/
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

            twoway (scatter `var'_bc `var'_el, mcolor(navy%50)) ///
                   (function y = x, range(`min_val' `max_val') lcolor(red) lpattern(dash)), ///
                title("`label_`var''") ///
                subtitle("Endline vs Backcheck") ///
                xtitle("Endline Measurement") ///
                ytitle("Backcheck Measurement") ///
                legend(order(1 "Observations" 2 "Perfect agreement line") ///
                       ring(0) pos(5)) ///
                note("ICC = " %5.3f `icc' ", N = " `n_pairs') ///
                aspect(1) ///
                scheme(s2color)
            graph export "output/figures/`var'_scatter_agreement.png", replace width(1200)
        restore

    }
    else {
        di "  WARNING: No matched pairs available for `var'"
    }
}

postclose `reliability_results'

save "data/processed/merged_analysis_data_flag.dta", replace

// Load and display reliability results table
*%%
use "output/tables/reliability_results.dta", clear
list, clean noobs

// Export to Excel
export excel using "output/tables/reliability_analysis_results.xlsx", ///
    firstrow(variables) replace

// Export to CSV
export delimited using "output/tables/reliability_analysis_results.csv", ///
    delimiter(",") replace

/*------------------------------------------------------------------------------
SECTION 6: CREATE FLAGGED OBSERVATIONS REPORT
------------------------------------------------------------------------------*/
*%%
use "data/processed/merged_analysis_data_flag.dta", clear

di _n(2) "{hline 80}"
di "SECTION 6: FLAGGED OBSERVATIONS REPORT"
di "{hline 80}" _n

// Keep observations with any flags
egen any_flag = rowmax(flag_*)
keep if any_flag == 1

// Keep relevant variables
keep childid flag_* *_el *_bc diff_bc_*

// Export flagged observations
*%%
if _N > 0 {
    di "Total flagged observations: " _N

    export excel using "output/tables/flagged_observations.xlsx", ///
        firstrow(variables) replace

    di "Flagged observations exported to: output/tables/flagged_observations.xlsx"
}
else {
    di "No observations exceeded quality thresholds"
}

/*------------------------------------------------------------------------------
SECTION 7: SUMMARY REPORT
------------------------------------------------------------------------------*/
*%%
di _n(2) "{hline 80}"
di "SECTION 8: ANALYSIS SUMMARY"
di "{hline 80}" _n

// Impact Analysis Summary
use "output/tables/impact_results.dta", clear
di _n ">>> IMPACT ANALYSIS SUMMARY <<<"
di "Total outcome variables analyzed: " _N

quietly count if p_value < 0.05
di "Statistically significant changes (p<0.05): " r(N)

quietly count if abs(cohens_d) > 0.8
di "Large effect sizes (|d| > 0.8): " r(N)

quietly count if abs(cohens_d) > 0.5 & abs(cohens_d) <= 0.8
di "Medium effect sizes (0.5 < |d| ≤ 0.8): " r(N)

quietly count if abs(cohens_d) > 0.2 & abs(cohens_d) <= 0.5
di "Small effect sizes (0.2 < |d| ≤ 0.5): " r(N)

// Reliability Analysis Summary
use "output/tables/reliability_results.dta", clear
di _n ">>> RELIABILITY ANALYSIS SUMMARY <<<"
di "Total outcome variables analyzed: " _N

quietly count if icc > 0.90
di "Excellent reliability (ICC > 0.90): " r(N)

quietly count if icc > 0.75 & icc <= 0.90
di "Good reliability (0.75 < ICC ≤ 0.90): " r(N)

quietly count if icc > 0.50 & icc <= 0.75
di "Moderate reliability (0.50 < ICC ≤ 0.75): " r(N)

quietly count if icc <= 0.50
di "Poor reliability (ICC ≤ 0.50): " r(N)

quietly summarize pct_flagged
di _n "Percentage of observations flagged (mean across outcomes): " %5.2f r(mean) "%"

/*------------------------------------------------------------------------------
SECTION 8: enumerators and time effects on outcomes measurement
------------------------------------------------------------------------------*/
*%%
use "data/processed/merged_analysis_data_flag.dta", clear
di _n(2) "{hline 80}"
di "SECTION 7: ENUMERATOR AND TIME EFFECTS ANALYSIS"
di "{hline 80}" _n


*gen differences in time between endline and backcheck
gen time_diff_days = subdate_bc - subdate_el
tab time_diff_days,m

// Get list of unique enumerator IDs
quietly levelsof enum_id_el, local(enum_list)
local n_enums : word count `enum_list'


// Count how many variables we'll analyze
local n_vars : word count $numeric_el_bc_pairs
di _n "Number of variables to analyze: `n_vars'"
di "Number of enumerators: `n_enums'"

// Save the original dataset
tempfile original_data
save `original_data', replace

// Run regressions and store coefficients for each variable
foreach var of global numeric_el_bc_pairs {
    use `original_data', clear
    
    // Check if abs_diff variable exists
    capture confirm variable abs_diff_bc_`var'
    if _rc == 0 {
        di _n "Running regression for: `var'"
        
        // Count non-missing observations
        quietly count if !missing(abs_diff_bc_`var') & !missing(enum_id_el) & !missing(time_diff_days)
        local n_obs = r(N)
        
        if `n_obs' < 10 {
            di "  WARNING: Insufficient observations (`n_obs' < 10) - skipping regression"
            continue
        }
        
        // Run regression
        capture quietly regress abs_diff_bc_`var' i.enum_id_el time_diff_days
        if _rc != 0 {
            di "  WARNING: Regression failed (error `=_rc') - skipping"
            continue
        }
        
        // Store degrees of freedom and all coefficients in locals BEFORE clearing
        local df_r = e(df_r)
        
        // Store all enumerator coefficients in locals
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
        }
        capture {
            local coef_cons = _b[_cons]
            local se_cons = _se[_cons]
        }
        
        // Now create the results dataset
        clear
        set obs `=`n_enums' + 2'
        gen str30 parameter = ""
        gen coef_`var' = .
        gen pval_`var' = .
        
        local row = 1
        foreach enum of local enum_list {
            replace parameter = "Enum_`enum'" in `row'
            // Use stored values
            if "`coef_`enum''" != "" & "`se_`enum''" != "" {
                local t = `coef_`enum'' / `se_`enum''
                local pval = 2 * ttail(`df_r', abs(`t'))
                replace coef_`var' = `coef_`enum'' in `row'
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
            replace pval_`var' = `pval' in `row'
        }
        local row = `row' + 1
        
        // Constant
        replace parameter = "Constant" in `row'
        if "`coef_cons'" != "" & "`se_cons'" != "" {
            local t = `coef_cons' / `se_cons'
            local pval = 2 * ttail(`df_r', abs(`t'))
            replace coef_`var' = `coef_cons' in `row'
            replace pval_`var' = `pval' in `row'
        }
        
        tempfile temp_`var'
        save `temp_`var'', replace
    }
    else {
        di "  WARNING: abs_diff_bc_`var' does not exist - skipping"
    }
}

// Merge all coefficient columns together
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

// Merge each variable's coefficients and p-values
foreach var of global numeric_el_bc_pairs {
    capture confirm file `temp_`var''
    if _rc == 0 {
        merge 1:1 parameter using `temp_`var'', nogenerate
    }
}

// Create string versions with stars for display
foreach var of global numeric_el_bc_pairs {
    capture confirm variable coef_`var'
    if _rc == 0 {
        gen str20 `var'_str = ""
        replace `var'_str = string(coef_`var', "%9.4f") if !missing(coef_`var')
        
        // Add stars based on p-value
        replace `var'_str = `var'_str + "***" if pval_`var' < 0.01 & !missing(pval_`var')
        replace `var'_str = `var'_str + "**" if pval_`var' >= 0.01 & pval_`var' < 0.05 & !missing(pval_`var')
        replace `var'_str = `var'_str + "*" if pval_`var' >= 0.05 & pval_`var' < 0.10 & !missing(pval_`var')
        
        // Drop numeric versions for cleaner display
        drop coef_`var' pval_`var'
    }
}



// Display the table
di _n(2) "{hline 80}"
di "ENUMERATOR EFFECTS ON MEASUREMENT RELIABILITY"
di "(* p<0.10, ** p<0.05, *** p<0.01)"
di "{hline 80}" _n
list, clean noobs

// Export to Excel
export excel using "output/tables/enumerator_effects_regression.xlsx", ///
    firstrow(variables) replace

// Export to CSV
export delimited using "output/tables/enumerator_effects_regression.csv", ///
    delimiter(",") replace

di _n "Regression results exported to:"
di "  - output/tables/enumerator_effects_regression.xlsx"
di "  - output/tables/enumerator_effects_regression.csv"

*%%
***regression analysis for idela scores
use "D:\Review\EC5\02_endline\02_outputs\Child_Survey_EC5_Endline_LMEE_idela.dta", clear

// List of IDELA outcome variables
local idela_vars sizepct sortpct shapepct numidpct onetoonepct addsubpct puzzlepct numeracy expvocpct papct ltridpct wordpairpct writlevpct oralcomppct literacy friendspct emotionpct empathypct conflictpct personalpct socialemotional memorypct headtoespct execfunction humanpct foldpct copysqpct grossmotorpct
local n_idela_vars : word count `idela_vars'
destring enum_id, replace 
di _n "Number of IDELA outcome variables to analyze: `n_idela_vars'"
// Run regressions for each IDELA variable
foreach var of local idela_vars {
    di _n "Running regression for: `var'"
    
    // Count non-missing observations
    quietly count if !missing(`var') & !missing(enum_id)
    local n_obs = r(N)
    
    if `n_obs' < 10 {
        di "  WARNING: Insufficient observations (`n_obs' < 10) - skipping regression"
        continue
    }
    
    capture regress `var' i.enum_id
    if _rc == 0 {
        di _n "Coefficients with significance stars (* p<0.10, ** p<0.05, *** p<0.01):"
        estimates table, star(0.10 0.05 0.01)
    }
    else {
        di "  WARNING: Regression failed (error `=_rc') - skipping"
    }
}



*%%
/*------------------------------------------------------------------------------
SECTION 9: Tracking participants
------------------------------------------------------------------------------*/

di _n(2) "{hline 80}"
di "SECTION 9: PARTICIPANT TRACKING SUMMARY"
di "{hline 80}" _n

// Keep only caregiver data if available
capture confirm file "$caregiver"
if _rc == 0 {
    tempfile caregiver_data
    use "$caregiver", clear
    keep childid care_change
    // Ensure care_change is numeric
    gen change_cg=(care_change=="Yes")
    drop care_change
    rename change_cg care_change
    save `caregiver_data', replace
    
    use "data/processed/merged_analysis_data.dta", clear
    merge 1:1 childid using `caregiver_data', keep(master match) nogen
}

//locals for tracking variables
*caregivera 
local childidentification   caregiver childid child_age childname gender schoolid childname caregiverid carecode hhid hh_replace
local admindata region_id region district schooil_id school community latitude longitude altitude

di _n ">>> MULTI-LEVEL PARTICIPANT TRACKING STRATEGY <<<"
di "{hline 80}" _n

/*==============================================================================
TRACKING STRATEGY: HIERARCHICAL PROBABILISTIC LINKAGE
Purpose: Verify participant tracking across baseline-endline without relying 
         solely on childid
Method: Multi-level matching with confidence scoring
==============================================================================*/

// STEP 1: Clean and standardize names for matching
di "Step 1: Standardizing names for matching..." _n

// Clean child names (baseline)
foreach var in childname_bl    {
    capture confirm variable `var'
    if _rc == 0 {
        gen `var'_clean = upper(trim(itrim(`var')))
        replace `var'_clean = subinstr(`var'_clean, "  ", " ", .)
        // Remove common punctuation
        replace `var'_clean = subinstr(`var'_clean, ".", "", .)
        replace `var'_clean = subinstr(`var'_clean, ",", "", .)
    }
}

// Clean child names (endline)
foreach var in childname_el  {
    capture confirm variable `var'
    if _rc == 0 {
        gen `var'_clean = upper(trim(itrim(`var')))
        replace `var'_clean = subinstr(`var'_clean, "  ", " ", .)
        replace `var'_clean = subinstr(`var'_clean, ".", "", .)
        replace `var'_clean = subinstr(`var'_clean, ",", "", .)
    }
}

// Clean caregiver names (baseline)
*caregivera_bl
foreach var in caregiver_bl  {
    capture confirm variable `var'
    if _rc == 0 {
        gen `var'_clean = upper(trim(itrim(`var')))
        replace `var'_clean = subinstr(`var'_clean, "  ", " ", .)
        replace `var'_clean = subinstr(`var'_clean, ".", "", .)
        replace `var'_clean = subinstr(`var'_clean, ",", "", .)
    }
}

// Clean caregiver names (endline)
*caregivera_el
foreach var in caregiver_el  {
    capture confirm variable `var'
    if _rc == 0 {
        gen `var'_clean = upper(trim(itrim(`var')))
        replace `var'_clean = subinstr(`var'_clean, "  ", " ", .)
        replace `var'_clean = subinstr(`var'_clean, ".", "", .)
        replace `var'_clean = subinstr(`var'_clean, ",", "", .)
    }
}

// STEP 2: Create matching scores for each level
di "Step 2: Creating multi-level matching scores..." _n

gen match_score = 0
gen match_level = ""
label variable match_score "Overall matching confidence score (0-100)"
label variable match_level "Highest matching level achieved"

// LEVEL 1: Administrative location match (10 points)
gen admin_match = 0
capture {
    replace admin_match = 1 if !missing(region_bl) & !missing(region_el) & region_bl == region_el
    replace admin_match = 1 if !missing(district_bl) & !missing(district_el) & district_bl == district_el & admin_match == 1
    replace admin_match = 1 if !missing(school_bl) & !missing(school_el) & school_bl == school_el & admin_match == 1
    replace admin_match = 1 if !missing(schoolid_bl) & !missing(schoolid_el) & school_bl == school_el & admin_match == 1
}
replace match_score = match_score + 10 if admin_match == 1
label variable admin_match "Administrative location matches (region/district/school)"

// LEVEL 2: Household/School ID match (20 points)
gen household_match = 0
capture {
    replace household_match = 1 if !missing(hhid_bl) & !missing(hhid_el) & hhid_bl == hhid_el
   }
replace match_score = match_score + 20 if household_match == 1
label variable household_match "Household/School ID matches"

// LEVEL 3: Child name match (30 points - highest weight)
gen childname_match = 0
gen childname_match_quality = ""

// Exact match on primary child name
capture confirm variable child_name_bl_clean child_name_el_clean
if _rc == 0 {
    replace childname_match = 1 if !missing(child_name_bl_clean) & !missing(child_name_el_clean) & ///
                                    child_name_bl_clean == child_name_el_clean
    replace childname_match_quality = "Exact match (child_name)" if childname_match == 1
}

// Fallback: match on childname variable
capture confirm variable childname_bl_clean childname_el_clean
if _rc == 0 {
    replace childname_match = 1 if childname_match == 0 & !missing(childname_bl_clean) & ///
                                    !missing(childname_el_clean) & childname_bl_clean == childname_el_clean
    replace childname_match_quality = "Exact match (childname)" if childname_match == 1 & childname_match_quality == ""
}

/*/ Fallback: match on a05 (original form name) these vars were deleted
capture confirm variable a05_bl_clean a05_el_clean
if _rc == 0 {
    replace childname_match = 1 if childname_match == 0 & !missing(a05_bl_clean) & ///
                                    !missing(a05_el_clean) & a05_bl_clean == a05_el_clean
    replace childname_match_quality = "Exact match (a05)" if childname_match == 1 & childname_match_quality == ""
}
*/

// Partial name match (if first 5 characters match)
capture confirm variable child_name_bl_clean child_name_el_clean
if _rc == 0 {
    replace childname_match = 0.5 if childname_match == 0 & !missing(child_name_bl_clean) & ///
                                      !missing(child_name_el_clean) & ///
                                      substr(child_name_bl_clean, 1, 5) == substr(child_name_el_clean, 1, 5) & ///
                                      strlen(child_name_bl_clean) >= 5
    replace childname_match_quality = "Partial match (first 5 chars)" if childname_match == 0.5 & childname_match_quality == ""
}

replace match_score = match_score + (30 * childname_match)
label variable childname_match "Child name matches (0=no, 0.5=partial, 1=exact)"
label variable childname_match_quality "Type of name match"

// LEVEL 4: Age consistency (15 points)
gen age_consistent = 0
gen age_diff = .
capture {
    replace age_diff = child_age_el - child_age_bl if !missing(child_age_bl) & !missing(child_age_el)
    
    // Calculate time between surveys (assuming ~1-2 years)
    gen time_gap_years = .
    capture replace time_gap_years = (subdate_el - subdate_bl) / 365.25 if !missing(subdate_bl) & !missing(subdate_el)
    
    // Age should increase approximately by survey gap (±1 year tolerance)
    replace age_consistent = 1 if !missing(age_diff) & !missing(time_gap_years) & ///
                                  abs(age_diff - time_gap_years) <= 1
    // More lenient: age should at least increase
    replace age_consistent = 0.5 if age_consistent == 0 & !missing(age_diff) & age_diff >= 0 & age_diff <= 3
}
replace match_score = match_score + (15 * age_consistent)
label variable age_consistent "Age progression is consistent (0=no, 0.5=plausible, 1=exact)"
label variable age_diff "Difference in child age (endline - baseline)"

// LEVEL 5: Gender consistency (10 points)
gen gender_consistent = 0
capture {
    replace gender_consistent = 1 if !missing(gender_bl) & !missing(gender_el) & gender_bl == gender_el
}
replace match_score = match_score + 10 if gender_consistent == 1
label variable gender_consistent "Gender is consistent across waves"

// LEVEL 6: Caregiver name match (15 points)
gen caregiver_match = 0
gen caregiver_match_quality = ""

* Match on biological mother (most stable)
capture confirm variable caregivera_bl_clean caregivera_el_clean
if _rc == 0 {
    replace caregiver_match = 1 if !missing(a08a_bl_clean) & !missing(a08a_el_clean) & ///
                                    a08a_bl_clean == a08a_el_clean
    replace caregiver_match_quality = "Biological mother name matches" if caregiver_match == 1
}

// Match on primary caregiver
capture confirm variable caregiver_bl_clean caregiver_el_clean
if _rc == 0 {
    replace caregiver_match = 1 if caregiver_match == 0 & !missing(caregiver_bl_clean) & ///
                                      !missing(caregiver_el_clean) & caregiver_bl_clean == caregiver_el_clean
    replace caregiver_match_quality = "Primary caregiver name matches" if caregiver_match == 0.7 & caregiver_match_quality == ""
}

// If caregiver changed (care_change=1), award partial points even if names don't match
capture confirm variable care_change
if _rc == 0 {
    replace caregiver_match = 0.5 if caregiver_match == 0 & care_change == 1
    replace caregiver_match_quality = "Caregiver changed (care_change=1)" if caregiver_match == 0.5 & caregiver_match_quality == ""
}

replace match_score = match_score + (15 * caregiver_match)
label variable caregiver_match "Caregiver name matches (0=no, 0.5=change expected, 0.7=caregiver, 1=mother)"
label variable caregiver_match_quality "Type of caregiver match"

// STEP 3: Create tracking status based on match score
di "Step 3: Creating tracking status categories..." _n

gen tracking_status = ""
replace tracking_status = "High confidence match (≥80)" if match_score >= 80
replace tracking_status = "Good match (60-79)" if match_score >= 60 & match_score < 80
replace tracking_status = "Moderate match (40-59)" if match_score >= 40 & match_score < 60
replace tracking_status = "Weak match (20-39)" if match_score >= 20 & match_score < 40
replace tracking_status = "Very weak/No match (<20)" if match_score < 20
replace tracking_status = "Baseline only" if in_baseline == 1 & in_endline == 0
replace tracking_status = "Endline only" if in_baseline == 0 & in_endline == 1

label variable tracking_status "Tracking quality category"

// STEP 4: Create detailed matching flags
gen match_details = ""
replace match_details = "Admin: " + string(admin_match) + " | "
replace match_details = match_details + "HH: " + string(household_match) + " | "
replace match_details = match_details + "Name: " + string(childname_match, "%3.1f") + " | "
replace match_details = match_details + "Age: " + string(age_consistent, "%3.1f") + " | "
replace match_details = match_details + "Gender: " + string(gender_consistent) + " | "
replace match_details = match_details + "Caregiver: " + string(caregiver_match, "%3.1f")
label variable match_details "Detailed matching breakdown"

// STEP 5: Generate tracking report
di "{hline 80}"
di "TRACKING VALIDATION SUMMARY"
di "{hline 80}" _n

tab tracking_status, mi

di _n "Match Score Distribution:"
summarize match_score if in_baseline == 1 & in_endline == 1, detail

di _n "Component-Level Matching Rates (for matched baseline-endline pairs):"
quietly count if in_baseline == 1 & in_endline == 1
local n_paired = r(N)

quietly count if admin_match == 1 & in_baseline == 1 & in_endline == 1
di "  - Administrative location: " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

quietly count if household_match == 1 & in_baseline == 1 & in_endline == 1
di "  - Household/School ID: " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

quietly count if childname_match >= 0.5 & in_baseline == 1 & in_endline == 1
di "  - Child name (partial+exact): " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

quietly count if childname_match == 1 & in_baseline == 1 & in_endline == 1
di "  - Child name (exact only): " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

quietly count if age_consistent >= 0.5 & in_baseline == 1 & in_endline == 1
di "  - Age consistency: " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

quietly count if gender_consistent == 1 & in_baseline == 1 & in_endline == 1
di "  - Gender consistency: " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

quietly count if caregiver_match >= 0.7 & in_baseline == 1 & in_endline == 1
di "  - Caregiver name: " %5.1f (r(N)/`n_paired'*100) "% (" r(N) "/" `n_paired' ")"

// STEP 6: Flag potential tracking issues
di _n(2) ">>> IDENTIFYING POTENTIAL TRACKING ISSUES <<<"

gen tracking_issue = ""
gen tracking_issue_detail = ""

// Issue 1: Low match score but childid exists
replace tracking_issue = "Low confidence despite childid" if match_score < 60 & !missing(childid) & ///
                                                              in_baseline == 1 & in_endline == 1
replace tracking_issue_detail = "Match score " + string(match_score, "%3.0f") + " suggests possible mismatch" ///
                                if tracking_issue == "Low confidence despite childid"

// Issue 2: Name mismatch
replace tracking_issue = "Child name mismatch" if tracking_issue == "" & childname_match < 0.5 & ///
                                                   in_baseline == 1 & in_endline == 1
replace tracking_issue_detail = "Child name does not match between waves" if tracking_issue == "Child name mismatch"

// Issue 3: Age inconsistency
replace tracking_issue = "Age inconsistency" if tracking_issue == "" & age_consistent < 0.5 & ///
                                                 !missing(age_diff) & in_baseline == 1 & in_endline == 1
replace tracking_issue_detail = "Age diff = " + string(age_diff, "%3.1f") + " years (expected ~" + ///
                                string(time_gap_years, "%3.1f") + ")" if tracking_issue == "Age inconsistency"

// Issue 4: Gender mismatch
replace tracking_issue = "Gender mismatch" if tracking_issue == "" & gender_consistent == 0 & ///
                                               !missing(gender_bl) & !missing(gender_el) & ///
                                               in_baseline == 1 & in_endline == 1
replace tracking_issue_detail = "Gender changed from baseline to endline" if tracking_issue == "Gender mismatch"

// Issue 5: Caregiver name mismatch (only flag if care_change != 1)
replace tracking_issue = "Caregiver name mismatch" if tracking_issue == "" & caregiver_match < 0.5 & ///
                                                       in_baseline == 1 & in_endline == 1
// Don't flag if caregiver change was expected
capture confirm variable care_change
if _rc == 0 {
    quietly count if !missing(care_change)
    if r(N) > 0 {
        replace tracking_issue = "" if tracking_issue == "Caregiver name mismatch" & care_change == 1
        replace tracking_issue_detail = "" if tracking_issue == "" & ///
                                             regexm(tracking_issue_detail, "Caregiver")
    }
}
replace tracking_issue_detail = "Caregiver name does not match (unexpected)" if tracking_issue == "Caregiver name mismatch"

// Summary of tracking issues
di _n "Summary of identified tracking issues:"
quietly count if tracking_issue != "" & tracking_issue != "."
local n_issues = r(N)
di _n "Total observations with tracking issues: " `n_issues'

if `n_issues' > 0 {
    di _n "Breakdown of tracking issues:"
    tab tracking_issue, mi
}

// Export tracking validation results
preserve
    keep if in_baseline == 1 & in_endline == 1
    keep childid tracking_status match_score admin_match household_match childname_match ///
         childname_match_quality age_consistent age_diff gender_consistent ///
         caregiver_match caregiver_match_quality tracking_issue tracking_issue_detail ///
         match_details *_bl *_el
    
    order childid tracking_status match_score tracking_issue
    
    export excel using "output/tables/participant_tracking_validation.xlsx", ///
        firstrow(variables) replace
    
    export delimited using "output/tables/participant_tracking_validation.csv", ///
        delimiter(",") replace
    
    di _n "Tracking validation results exported to:"
    di "  - output/tables/participant_tracking_validation.xlsx"
    di "  - output/tables/participant_tracking_validation.csv"
restore

save "data/processed/merged_analysis_data_tracked.dta", replace

di _n "{hline 80}"
di "TRACKING VALIDATION COMPLETE"
di "{hline 80}" _n

*%%
// using gps coordinates to verify location consistency
/*==============================================================================
TRACKING STRATEGY: GPS COORDINATE VERIFICATION
Purpose: Verify participant location consistency across baseline-endline
Method: Calculate distance between baseline and endline GPS coordinates
==============================================================================*/

di _n ">>> GPS COORDINATE VERIFICATION <<<"
di "{hline 80}" _n
// Haversine formula to calculate distance between two lat-long points
gen distance_meters = .
capture {
    replace distance_meters = 2 * 6371000 * ///
        asin( sqrt( sin( (radians(latitude_el) - radians(latitude_bl)) / 2 )^2 + ///
                    cos(radians(latitude_bl)) * cos(radians(latitude_el)) * ///
                    sin( (radians(longitude_el) - radians(longitude_bl)) / 2 )^2 ) )
}
label variable distance_meters "Distance between baseline and endline GPS coordinates (meters)"
summarize distance_meters if !missing(distance_meters), detail
di _n "GPS Distance Summary (meters):"
di "  - Mean: " %6.2f r(mean)
di "  - SD: " %6.2f r(sd)
di "  - Min: " %6.2f r(min)
di "  - Max: " %6.2f r(max)

// Test different distance thresholds from 50m to 500m in 50m increments
di _n(2) "Testing different distance thresholds:"
forvalues dist = 50(50)500 {
    // Create flag variable for this threshold
    gen gps_flag_`dist'm = 0
    replace gps_flag_`dist'm = 1 if distance_meters > `dist' & !missing(distance_meters)
    label variable gps_flag_`dist'm "Flag for GPS location change >`dist' meters"
    
    // Count and display statistics
    quietly count if gps_flag_`dist'm == 1 & !missing(gps_flag_`dist'm)
    local n_flagged = r(N)
    quietly count if !missing(distance_meters)
    local n_total_gps = r(N)
    local pct_flagged = (`n_flagged' / `n_total_gps') * 100
    
    di "  Distance > `dist'm: " %5.1f `pct_flagged' "% (" `n_flagged' "/" `n_total_gps' ") flagged"
}

// Keep the original 200m flag for backward compatibility
gen gps_location_flag = 0
replace gps_location_flag = 1 if distance_meters > 200
label variable gps_location_flag "Flag for large GPS location change (>200 meters)"
quietly count if gps_location_flag == 1 & !missing(gps_location_flag)
local n_gps_flags = r(N)
di _n "Total observations with large GPS location changes (>200 meters): " `n_gps_flags' 
if `n_gps_flags' > 0 {
    di "Consider reviewing these cases for potential tracking issues."
}

// Save updated dataset with GPS distance
save "data/processed/merged_analysis_data_tracked.dta", replace


/*------------------------------------------------------------------------------
SECTION 10: FINAL NOTES
------------------------------------------------------------------------------*/

di _n(2) "{hline 80}"
di "ANALYSIS COMPLETED SUCCESSFULLY"
di "{hline 80}" _n

di "Output files created:"
di "  1. output/tables/impact_analysis_results.xlsx"
di "  2. output/tables/impact_analysis_results.csv"
di "  3. output/tables/reliability_analysis_results.xlsx"
di "  4. output/tables/reliability_analysis_results.csv"
di "  5. output/tables/flagged_observations.xlsx"
di "  6. output/figures/*.png (Bland-Altman plots, before-after plots, scatter plots)"
di "  7. data/processed/merged_analysis_data.dta"
di "  8. output/impact_reliability_analysis_log.txt"

*log close

di _n "Analysis completed: " c(current_date) " " c(current_time)
