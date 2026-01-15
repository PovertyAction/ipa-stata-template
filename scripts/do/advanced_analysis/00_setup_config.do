/*==============================================================================
PROJECT SETUP AND CONFIGURATION
================================================================================

Project:     [Project Name - CUSTOMIZE]
Author:      [Author Name - CUSTOMIZE]
Date:        `c(current_date)'
Purpose:     Configure global paths, directories, and analysis parameters

Input:       None (configuration only)
Output:      Global macros for file paths and analysis settings

Notes:       - Run this file first before any analysis
             - Customize all paths marked with "CUSTOMIZE"
             - This file creates necessary output directories
             - Defines outcome variables and labels used across all scripts

References:
- IPA Data Management Guide: https://www.poverty-action.org/

==============================================================================*/

// Boilerplate code following IPA best practices
version 16
clear all
set more off
set varabbrev off
macro drop _all

di _n(2) "{hline 80}"
di "PROJECT SETUP AND CONFIGURATION"
di "{hline 80}" _n

/*==============================================================================
                    1. GLOBAL PATHS SETUP
==============================================================================*/

di ">>> SETTING UP GLOBAL PATHS <<<"

// Set working directory - CUSTOMIZE THIS
cd "C:\Users\IPACOLPC105\scratch\ipa-stata-template"
global project_path "`c(pwd)'"

di "Project directory: $project_path"

// Define input data paths - CUSTOMIZE THESE
global baseline "${project_path}/data/raw/baseline_data.dta"
global endline "${project_path}/data/raw/endline_data.dta"
global backcheck "${project_path}/data/raw/backcheck_data.dta"
global caregiver "${project_path}/data/raw/caregiver_data.dta"

// Define output directories
global data_processed "${project_path}/data/processed"
global outputs "${project_path}/outputs"
global tables "${outputs}/tables"
global figures "${outputs}/figures"
global logs "${project_path}/analysis/logs"

/*==============================================================================
                    2. CREATE OUTPUT DIRECTORIES
==============================================================================*/

di _n ">>> CREATING OUTPUT DIRECTORIES <<<"

// List of required directories
local directories "data/processed outputs outputs/tables outputs/figures analysis/logs"

foreach dir of local directories {
    capture mkdir "${project_path}/`dir'"
    capture confirm file "${project_path}/`dir'"
    if _rc == 0 {
        di "  ✓ Directory exists: `dir'"
    }
    else {
        di "  ! WARNING: Failed to create: `dir'"
    }
}

/*==============================================================================
                    3. DEFINE OUTCOME VARIABLES
==============================================================================*/

di _n ">>> DEFINING OUTCOME VARIABLES <<<"

// Anthropometric outcomes - CUSTOMIZE THESE BASED ON YOUR DATA
global anthro_outcomes "c1_1 c1_3 c1_4 c1_5 c1_6 c2_1 c2_2 c2_3 c2_4 c3_1 c3_2 c3_3 c4_4"

// IDELA assessment outcomes - CUSTOMIZE THESE BASED ON YOUR DATA
global idela_outcomes "sizepct sortpct shapepct numidpct onetoonepct addsubpct puzzlepct numeracy expvocpct papct ltridpct wordpairpct writlevpct oralcomppct literacy friendspct emotionpct empathypct conflictpct personalpct socialemotional memorypct headtoespct execfunction humanpct foldpct copysqpct grossmotorpct motor schoolready"

// Spelke assessment outcomes (endline only) - CUSTOMIZE THESE
global spelke_outcomes "ptn_pct extranum_pct pm_pct geointr_pct sp_numeracy attsw_pct mentalst_pct sp_execfunction vocabulary_pct spelke fnumeracy fliteracy fef fse fmotor fschoolready"

// Demographic and ID variables - CUSTOMIZE THESE
global demographics "enum_id subdate region_id region district schooil_id school community caregiver a08a old_childid childid child_age child_name latitude longitude altitude gender schoolid childname caregiverid childcode carecode hhid hh_replace"

// All outcomes combined
global all_outcomes "$anthro_outcomes $idela_outcomes"

di "Anthropometric outcomes defined: `: word count $anthro_outcomes' variables"
di "IDELA outcomes defined: `: word count $idela_outcomes' variables"
di "Spelke outcomes defined: `: word count $spelke_outcomes' variables"
di "Demographic variables defined: `: word count $demographics' variables"

/*==============================================================================
                    4. DEFINE VARIABLE LABELS
==============================================================================*/

di _n ">>> DEFINING VARIABLE LABELS <<<"

// Anthropometric variable labels - CUSTOMIZE THESE
local label_c1_1 "Child weight in kgs (measurement 1)"
local label_c1_3 "Child weight in kgs (measurement 2)"
local label_c1_4 "Child weight in kgs (measurement 3)"
local label_c1_5 "Did respondent wear heavy materials during measurement"
local label_c1_6 "Was flat surface available for weighing scale"
local label_c2_1 "Height of child (measurement 1)"
local label_c2_2 "Height of child (measurement 2)"
local label_c2_3 "Height of child (measurement 3)"
local label_c2_4 "Height of child (measurement 4)"
local label_c3_1 "Mid-upper arm circumference (measurement 1)"
local label_c3_2 "Mid-upper arm circumference (measurement 2)"
local label_c3_3 "Mid-upper arm circumference (measurement 3)"
local label_c4_4 "Mid-upper arm circumference (measurement 4)"

// IDELA variable labels - CUSTOMIZE THESE
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

// Demographic variable labels - CUSTOMIZE THESE
local label_enum_id "Enumerator ID"
local label_subdate "Submission date"
local label_region_id "Region ID"
local label_region "Region"
local label_district "District"
local label_school "School"
local label_community "Community"
local label_caregiver "Caregiver name"
local label_childid "Child ID"
local label_child_age "Child age in years"
local label_child_name "Child name"

// Save labels as globals for use in other scripts
// (Alternative: use label define commands in data files)

di "Variable labels defined for all outcome variables"

/*==============================================================================
                    5. ANALYSIS PARAMETERS
==============================================================================*/

di _n ">>> SETTING ANALYSIS PARAMETERS <<<"

// Reliability thresholds (WHO/IPA standards) - CUSTOMIZE IF NEEDED
global threshold_weight 0.1    // ±0.1 kg for weight measurements
global threshold_height 0.5    // ±0.5 cm for height measurements
global threshold_muac 0.5      // ±0.5 cm for arm circumference

// GPS distance thresholds (meters) - CUSTOMIZE IF NEEDED
global gps_threshold_low 50
global gps_threshold_medium 100
global gps_threshold_high 200
global gps_threshold_extreme 500

// ICC interpretation thresholds - CUSTOMIZE IF NEEDED
global icc_excellent 0.90
global icc_good 0.75
global icc_moderate 0.50

// Effect size interpretation (Cohen's d) - CUSTOMIZE IF NEEDED
global effect_large 0.8
global effect_medium 0.5
global effect_small 0.2

// Missing data tolerance - CUSTOMIZE IF NEEDED
global min_obs_analysis 10      // Minimum observations for analysis
global missing_threshold 0.90   // Drop variables with >90% missing

di "Analysis parameters configured:"
di "  Weight threshold: $threshold_weight kg"
di "  Height threshold: $threshold_height cm"
di "  MUAC threshold: $threshold_muac cm"
di "  GPS thresholds: $gps_threshold_low, $gps_threshold_medium, $gps_threshold_high, $gps_threshold_extreme meters"
di "  ICC thresholds: Excellent>=$icc_excellent, Good>=$icc_good, Moderate>=$icc_moderate"
di "  Effect size thresholds: Large>=$effect_large, Medium>=$effect_medium, Small>=$effect_small"
di "  Minimum observations: $min_obs_analysis"

/*==============================================================================
                    6. VERIFY INPUT FILES EXIST
==============================================================================*/

di _n ">>> VERIFYING INPUT FILES <<<"

// Check if baseline file exists
capture confirm file "$baseline"
if _rc == 0 {
    di "  ✓ Baseline data found: $baseline"
}
else {
    di "  ! WARNING: Baseline data NOT FOUND: $baseline"
    di "    Update the path in Section 1 of this file"
}

// Check if endline file exists
capture confirm file "$endline"
if _rc == 0 {
    di "  ✓ Endline data found: $endline"
}
else {
    di "  ! WARNING: Endline data NOT FOUND: $endline"
    di "    Update the path in Section 1 of this file"
}

// Check if backcheck file exists
capture confirm file "$backcheck"
if _rc == 0 {
    di "  ✓ Backcheck data found: $backcheck"
}
else {
    di "  ! WARNING: Backcheck data NOT FOUND: $backcheck"
    di "    Update the path in Section 1 of this file"
}

// Check if caregiver file exists
capture confirm file "$caregiver"
if _rc == 0 {
    di "  ✓ Caregiver data found: $caregiver"
}
else {
    di "  ⚠ NOTE: Caregiver data NOT FOUND: $caregiver"
    di "    This file is optional but useful for tracking validation"
}

/*==============================================================================
                    7. CONFIGURATION SUMMARY
==============================================================================*/

di _n(2) "{hline 80}"
di "CONFIGURATION COMPLETED SUCCESSFULLY"
di "{hline 80}" _n

di "Next steps:"
di "  1. Verify all paths and parameters above are correct"
di "  2. Customize outcome variables and labels for your project"
di "  3. Run data loading script: do scripts/do/impact/01_load_explore.do"
di "  4. Or run master script: do scripts/do/impact/00_run_all.do"

di _n "Configuration date: `c(current_date)' `c(current_time)'"
di "{hline 80}" _n

/*==============================================================================
                            END OF FILE
==============================================================================*/
