/*==============================================================================
MASTER DO-FILE FOR STATA ANALYSIS PROJECT
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Master do-file that runs entire analysis pipeline
             Based on Sean Higgins Stata Guide and DIME Analytics best practices

Notes:       - This file should be run from the project root directory
             - All file paths use global macros (best practice)
             - Follows programming principles
             - Uses statacons for dependency management (run 'scons' instead)

References:
- IPA Data Cleaning Guide: https://data.poverty-action.org/data-cleaning/
- IPA Stata Tutorials: https://data.poverty-action.org/software/stata/
- Data Carpentry Stata Economics: https://datacarpentry.github.io/stata-economics/
- statacons: https://bquistorff.github.io/statacons/
- Sean Higgins Stata Guide: https://github.com/skhiggins/Stata_guide
- DIME Analytics Coding Guide: https://worldbank.github.io/dime-data-handbook/coding.html

==============================================================================*/

// Set Stata version for reproducibility
version 17

// Clear memory and close any open files/logs
clear all
macro drop _all
capture log close _all
set more off

// Set random seed for reproducibility (from random.org)
set seed 123456789

// Set maximum variables and memory
set maxvar 32000
set matsize 11000

// Configure Stata settings for reproducibility
set linesize 255
set varabbrev off
set type double

// Define global paths for reproducibility
global project_path "`c(pwd)'"
global data_raw "${project_path}/data/raw"
global data_clean "${project_path}/data/clean"
global data_final "${project_path}/data/final"
global scripts "${project_path}/scripts/do"
global outputs "${project_path}/outputs"
global logs "${project_path}/analysis/logs"

// Set PLUS directory to local ado folder for package reproducibility
adopath + "${project_path}/ado"

// Load standard functions
do "${scripts}/functions.do"

// Validate project structure and dependencies
validate_paths
validate_pipeline

// Display system information
di "Stata version: `c(stata_version)'"
di "Today's date: `c(current_date)'"
di "Working directory: `c(pwd)'"

/*==============================================================================
                            CONTROL SWITCHES
==============================================================================*/

// Use local macros for flexible, reproducible workflows
// Set locals to control which parts of pipeline to run
// Change to 0 to skip that section during development

local data_cleaning         = 1
local data_transformation   = 1  // Advanced transformations
local data_combination      = 0  // Merge/append techniques
local data_preparation      = 1
local descriptive_analysis  = 1
local main_analysis         = 1
local robustness_checks     = 1
local generate_figures      = 1

// Data Carpentry: Display what will be run
di _n(2) "{hline 60}"
di "STATA ANALYSIS PIPELINE CONFIGURATION"
di "{hline 60}"
di "Data cleaning: " cond(`data_cleaning', "YES", "NO")
di "Data transformation: " cond(`data_transformation', "YES", "NO")
di "Data combination: " cond(`data_combination', "YES", "NO")
di "Data preparation: " cond(`data_preparation', "YES", "NO")
di "Descriptive analysis: " cond(`descriptive_analysis', "YES", "NO")
di "Main analysis: " cond(`main_analysis', "YES", "NO")
di "Robustness checks: " cond(`robustness_checks', "YES", "NO")
di "Generate figures: " cond(`generate_figures', "YES", "NO")
di "{hline 60}"

/*==============================================================================
                            DATA PIPELINE
==============================================================================*/

if `data_cleaning' {
    di _n(2) "{hline 80}"
    di "RUNNING: Data Cleaning"
    di "{hline 80}"
    do "scripts/do/01_data_cleaning.do"
}

if `data_transformation' {
    di _n(2) "{hline 80}"
    di "RUNNING: Data Transformation (Data Carpentry Methods)"
    di "{hline 80}"
    do "${scripts}/02a_data_transformation.do"
}

if `data_combination' {
    di _n(2) "{hline 80}"
    di "RUNNING: Data Combination (Data Carpentry Methods)"
    di "{hline 80}"
    do "${scripts}/02b_data_combination.do"
}

if `data_preparation' {
    di _n(2) "{hline 80}"
    di "RUNNING: Data Preparation"
    di "{hline 80}"
    do "${scripts}/02_data_preparation.do"
}

/*==============================================================================
                            ANALYSIS PIPELINE
==============================================================================*/

if `descriptive_analysis' {
    di _n(2) "{hline 80}"
    di "RUNNING: Descriptive Analysis"
    di "{hline 80}"
    do "scripts/do/03_descriptive_analysis.do"
}

if `main_analysis' {
    di _n(2) "{hline 80}"
    di "RUNNING: Main Analysis"
    di "{hline 80}"
    do "scripts/do/04_main_analysis.do"
}

if `robustness_checks' {
    di _n(2) "{hline 80}"
    di "RUNNING: Robustness Checks"
    di "{hline 80}"
    do "scripts/do/05_robustness_checks.do"
}

if `generate_figures' {
    di _n(2) "{hline 80}"
    di "RUNNING: Generate Figures"
    di "{hline 80}"
    do "scripts/do/06_generate_figures.do"
}

/*==============================================================================
                            COMPLETION MESSAGE
==============================================================================*/

di _n(2) "{hline 80}"
di "ANALYSIS PIPELINE COMPLETED SUCCESSFULLY!"
di "Generated files can be found in:"
di "  - outputs/tables/ (regression tables)"
di "  - outputs/figures/ (figures)"
di "  - analysis/logs/ (log files)"
di "{hline 80}"
