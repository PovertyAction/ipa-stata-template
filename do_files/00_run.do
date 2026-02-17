/*==============================================================================
MASTER DO-FILE FOR STATA ANALYSIS PROJECT
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Master do-file that runs entire analysis pipeline
             Based on Sean Higgins Stata Guide and DIME Analytics best practices

Usage:
  Full pipeline:    do 00_run.do
  Single script:    do 00_run.do "01_data_cleaning"
  Via just:         just stata-run
                    just stata-script 01_data_cleaning

Notes:       - Uses setroot to find project root from any directory
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
* %%
// Clear memory and close any open files/logs
clear all
macro drop _all
capture log close _all
set more off

// Set random seed for reproducibility (from random.org)
set seed 123456789

// Set maximum variables and memory
// Conservative maxvar - increase only if needed for genuinely wide datasets.
// If you hit the limit, consider: (1) loading only needed columns with
// `use var1 var2 using "data.dta"`, or (2) reshaping to long format first.
* %%
/*==============================================================================
                            FIND PROJECT ROOT
==============================================================================*/

// Uses setroot to find .here or .git marker from any directory
// Install setroot first: ssc install setroot (or run setup.do)
// Install setroot first: ssc install setroot (or run setup.do)
capture setroot, verbose
if _rc != 0 {
    di as error _n(2) "{hline 80}"
    di as error "ERROR: Could not find project root directory"
    di as error "{hline 80}"
    di as text _n "Current directory: " c(pwd)
    di as text _n "Possible solutions:"
    di as text "  1. In Stata, change to project directory first:"
    di as text "     cd ~/code/ipa-stata-template"
    di as text "     do do_files/00_run.do"
    di as text _n "  2. Use the recommended workflow with just:"
    di as text "     just stata-run              (from terminal in project directory)"
    di as text "     just stata-script 01_data_cleaning"
    di as text _n "  3. Ensure setroot package is installed:"
    di as text "     ssc install setroot"
    di as error _n "{hline 80}"
    exit 601
}
global project_path "${root}"

// Use ieboilstart strict to only allow commands being run from selected adopath
ieboilstart, versionnumber(17.0) adopath("${project_path}/ado", strict)
// ieboilstart modifies a lot of the settings below, might need to adjust settings individually
//set maxvar 5000
//set matsize 11000
//set linesize 255
//set varabbrev off
//set type double

* %%
/*==============================================================================
                            DEFINE PATHS
==============================================================================*/

// Code and output paths always relative to project root
// Check for user-specific config file (gitignored)
// This allows users to override data paths without modifying tracked files
capture confirm file "${project_path}/config.do"
if _rc == 0 {
    di as text "Loading user-specific configuration from config.do"
    do "${project_path}/config.do"
}
else {
    di as text "No config.do found - using default paths"
    di as text "To customize data paths, copy config.do.template to config.do"
}

// Set default data root if not defined in config.do
// This allows code and data to be stored separately
if "${data_root}" == "" {
    global data_root "${project_path}/data"
    di as text "Using default data location: ${data_root}"
}
else {
    di as text "Using custom data location: ${data_root}"
}

// Define standard paths (use config.do values if set, otherwise use defaults)
if "${data_raw}" == "" global data_raw "${data_root}/raw"
if "${data_clean}" == "" global data_clean "${data_root}/clean"
if "${data_final}" == "" global data_final "${data_root}/final"

// Code and output paths always relative to project root
global scripts "${project_path}/do_files"
global outputs "${project_path}/outputs"
global logs "${project_path}/logs"
global tables "${outputs}/tables"
global figures "${outputs}/figures"

* %%
/*==============================================================================
                            START LOG FILE
==============================================================================*/

// Open log file now that paths are defined
capture log close
log using "${logs}/00_run.log", replace name(master)

* %%
/*==============================================================================
                            LOAD FUNCTIONS
==============================================================================*/

do "${scripts}/functions.do"

// Validate project structure and dependencies
validate_paths
validate_pipeline, ///
    files("data/raw/sample_data.csv") ///
    packages("estout outreg2 missings reghdfe coefplot")

// Display system information
di "Stata version: `c(stata_version)'"
di "Today's date: `c(current_date)'"
di "Project root: ${project_path}"

* %%
/*==============================================================================
                            RUNNER PATTERN
==============================================================================*/

// Accept optional argument for single-script execution
// Usage: do 00_run.do "01_data_cleaning"
args script_to_run

if "`script_to_run'" != "" {
    di _n(2) "{hline 60}"
    di "RUNNING SINGLE SCRIPT: `script_to_run'.do"
    di "{hline 60}"
    do "${scripts}/`script_to_run'.do"
    exit
}

* %%
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

* %%
/*==============================================================================
                            DATA PIPELINE
==============================================================================*/

if `data_cleaning' {
    di _n(2) "{hline 80}"
    di "RUNNING: Data Cleaning"
    di "{hline 80}"
    do "${scripts}/01_data_cleaning.do"
}

* %%
if `data_transformation' {
    di _n(2) "{hline 80}"
    di "RUNNING: Data Transformation (Data Carpentry Methods)"
    di "{hline 80}"
    do "${scripts}/02a_data_transformation.do"
}

* %%
if `data_combination' {
    di _n(2) "{hline 80}"
    di "RUNNING: Data Combination (Data Carpentry Methods)"
    di "{hline 80}"
    do "${scripts}/02b_data_combination.do"
}

* %%
if `data_preparation' {
    di _n(2) "{hline 80}"
    di "RUNNING: Data Preparation"
    di "{hline 80}"
    do "${scripts}/02_data_preparation.do"
}

* %%
/*==============================================================================
                            ANALYSIS PIPELINE
==============================================================================*/

if `descriptive_analysis' {
    di _n(2) "{hline 80}"
    di "RUNNING: Descriptive Analysis"
    di "{hline 80}"
    do "${scripts}/03_descriptive_analysis.do"
}

* %%
if `main_analysis' {
    di _n(2) "{hline 80}"
    di "RUNNING: Main Analysis"
    di "{hline 80}"
    do "${scripts}/04_main_analysis.do"
}

* %%
if `robustness_checks' {
    di _n(2) "{hline 80}"
    di "RUNNING: Robustness Checks"
    di "{hline 80}"
    do "${scripts}/05_robustness_checks.do"
}

* %%
if `generate_figures' {
    di _n(2) "{hline 80}"
    di "RUNNING: Generate Figures"
    di "{hline 80}"
    do "${scripts}/06_generate_figures.do"
}

* %%
/*==============================================================================
                            COMPLETION MESSAGE
==============================================================================*/

di _n(2) "{hline 80}"
di "ANALYSIS PIPELINE COMPLETED SUCCESSFULLY!"
di "Generated files can be found in:"
di "  - outputs/tables/ (regression tables)"
di "  - outputs/figures/ (figures)"
di "  - logs/ (log files)"
di "{hline 80}"

// Close log file
log close master

// Clean up: Remove automatic log file created by Stata batch mode
// This removes the unwanted 00_run.log from the root directory
capture erase "${project_path}/00_run.log"
