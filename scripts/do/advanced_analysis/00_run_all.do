/*==============================================================================
MASTER SCRIPT: RUN ALL IMPACT AND RELIABILITY ANALYSES
================================================================================

Project:     [Project Name - CUSTOMIZE]
Author:      [Author Name - CUSTOMIZE]
Date:        `c(current_date)'
Purpose:     Master script to run all impact and reliability analysis scripts
             in sequence with control switches for each section

Scripts:     1. 00_setup_config.do - Configure paths and parameters
             2. 01_load_explore.do - Load and merge datasets
             3. 03_impact_analysis.do - Baseline vs endline impact
             4. 04_reliability_analysis.do - Endline vs backcheck reliability
             5. 05_enumerator_effects.do - Enumerator and time effects
             6. 06_participant_tracking.do - Multi-level tracking validation

Input:       Raw data files specified in 00_setup_config.do
Output:      All outputs from individual scripts (tables, figures, logs)

Notes:       - Turn control switches ON (1) or OFF (0) to run/skip sections
             - Each script can also be run independently
             - Review logs if any section fails
             - All scripts follow IPA best practices

Usage:       Simply run: do scripts/do/impact/00_run_all.do
             Or customize switches below before running

==============================================================================*/

// Boilerplate code following IPA best practices
version 16
clear all
set more off
set varabbrev off

di _n(3) "{hline 80}"
di "{bf:MASTER SCRIPT: IMPACT AND RELIABILITY ANALYSIS}"
di "{hline 80}" _n

/*==============================================================================
                    CONTROL SWITCHES - CUSTOMIZE THESE
==============================================================================*/

di ">>> SETTING CONTROL SWITCHES <<<"

// Set to 1 to run, 0 to skip
global run_setup         1    // Always run unless globals already defined
global run_load_explore  1    // Load and merge datasets
global run_impact        1    // Baseline vs endline impact analysis
global run_reliability   1    // Endline vs backcheck reliability
global run_enumerator    1    // Enumerator and time effects
global run_tracking      1    // Participant tracking validation

di _n "Control switches set:"
di "  Setup & Configuration: " %2.0f $run_setup
di "  Load & Explore Data: " %2.0f $run_load_explore
di "  Impact Analysis: " %2.0f $run_impact
di "  Reliability Analysis: " %2.0f $run_reliability
di "  Enumerator Effects: " %2.0f $run_enumerator
di "  Participant Tracking: " %2.0f $run_tracking

/*==============================================================================
                    START MASTER LOG FILE
==============================================================================*/

// Create timestamp for master log
local log_date = subinstr("`c(current_date)'", " ", "_", .)
local log_time = subinstr("`c(current_time)'", ":", "_", .)

// Temporarily change to project directory to create log
// (Will be set properly in config script)
capture cd "C:\Users\IPACOLPC105\scratch\ipa-stata-template"
capture mkdir "analysis/logs"

log using "analysis/logs/00_run_all_master_`log_date'_`log_time'.log", replace text

di _n "Master log file created"
di "Start time: `c(current_date)' `c(current_time)'"

/*==============================================================================
                    TRACK EXECUTION TIME AND STATUS
==============================================================================*/

// Initialize tracking variables
local total_sections = 6
local completed_sections = 0
local failed_sections = 0
local skipped_sections = 0

local start_time = clock("`c(current_time)'", "hms")

/*==============================================================================
                    SECTION 0: SETUP AND CONFIGURATION
==============================================================================*/

if $run_setup == 1 {
    di _n(3) "{hline 80}"
    di "{bf:SECTION 0: SETUP AND CONFIGURATION}"
    di "{hline 80}" _n

    local section_start = clock("`c(current_time)'", "hms")

    capture noisily do "scripts/do/impact/00_setup_config.do"

    if _rc == 0 {
        di _n "{green}✓ Configuration completed successfully{reset}"
        local completed_sections = `completed_sections' + 1

        local section_end = clock("`c(current_time)'", "hms")
        local section_duration = (`section_end' - `section_start') / 1000
        di "Duration: " %9.2f `section_duration' " seconds"
    }
    else {
        di _n "{red}✗ Configuration FAILED with error code: " _rc "{reset}"
        di "Please check the log file for details"
        local failed_sections = `failed_sections' + 1
        log close
        exit _rc
    }
}
else {
    di _n(3) "{hline 80}"
    di "{bf:SECTION 0: SETUP AND CONFIGURATION} - {yellow}SKIPPED{reset}"
    di "{hline 80}" _n
    local skipped_sections = `skipped_sections' + 1

    // Check if globals are defined
    capture confirm existence $project_path
    if _rc != 0 {
        di _n "{red}ERROR: Globals not defined and run_setup = 0{reset}"
        di "Either set run_setup = 1 or run 00_setup_config.do manually first"
        log close
        exit 198
    }
}

/*==============================================================================
                    SECTION 1: LOAD AND EXPLORE DATA
==============================================================================*/

if $run_load_explore == 1 {
    di _n(3) "{hline 80}"
    di "{bf:SECTION 1: LOAD AND EXPLORE DATA}"
    di "{hline 80}" _n

    local section_start = clock("`c(current_time)'", "hms")

    // Check if script exists
    capture confirm file "scripts/do/impact/01_load_explore.do"
    if _rc == 0 {
        capture noisily do "scripts/do/impact/01_load_explore.do"

        if _rc == 0 {
            di _n "{green}✓ Data loading completed successfully{reset}"
            local completed_sections = `completed_sections' + 1

            local section_end = clock("`c(current_time)'", "hms")
            local section_duration = (`section_end' - `section_start') / 1000
            di "Duration: " %9.2f `section_duration' " seconds"
        }
        else {
            di _n "{red}✗ Data loading FAILED with error code: " _rc "{reset}"
            di "Please check the log file for details"
            local failed_sections = `failed_sections' + 1

            di _n "{yellow}WARNING: Subsequent sections may fail without loaded data{reset}"
            di "Continue anyway? (This will likely cause errors)"
        }
    }
    else {
        di _n "{yellow}NOTE: 01_load_explore.do not found - SKIPPED{reset}"
        di "This script is optional if data is already merged"
        local skipped_sections = `skipped_sections' + 1
    }
}
else {
    di _n(3) "{hline 80}"
    di "{bf:SECTION 1: LOAD AND EXPLORE DATA} - {yellow}SKIPPED{reset}"
    di "{hline 80}" _n
    local skipped_sections = `skipped_sections' + 1
}

/*==============================================================================
                    SECTION 2: IMPACT ANALYSIS
==============================================================================*/

if $run_impact == 1 {
    di _n(3) "{hline 80}"
    di "{bf:SECTION 2: IMPACT ANALYSIS (BASELINE VS ENDLINE)}"
    di "{hline 80}" _n

    local section_start = clock("`c(current_time)'", "hms")

    capture noisily do "scripts/do/impact/03_impact_analysis.do"

    if _rc == 0 {
        di _n "{green}✓ Impact analysis completed successfully{reset}"
        local completed_sections = `completed_sections' + 1

        local section_end = clock("`c(current_time)'", "hms")
        local section_duration = (`section_end' - `section_start') / 1000
        di "Duration: " %9.2f `section_duration' " seconds"
    }
    else {
        di _n "{red}✗ Impact analysis FAILED with error code: " _rc "{reset}"
        di "Please check the log file for details"
        local failed_sections = `failed_sections' + 1
    }
}
else {
    di _n(3) "{hline 80}"
    di "{bf:SECTION 2: IMPACT ANALYSIS} - {yellow}SKIPPED{reset}"
    di "{hline 80}" _n
    local skipped_sections = `skipped_sections' + 1
}

/*==============================================================================
                    SECTION 3: RELIABILITY ANALYSIS
==============================================================================*/

if $run_reliability == 1 {
    di _n(3) "{hline 80}"
    di "{bf:SECTION 3: RELIABILITY ANALYSIS (ENDLINE VS BACKCHECK)}"
    di "{hline 80}" _n

    local section_start = clock("`c(current_time)'", "hms")

    capture noisily do "scripts/do/impact/04_reliability_analysis.do"

    if _rc == 0 {
        di _n "{green}✓ Reliability analysis completed successfully{reset}"
        local completed_sections = `completed_sections' + 1

        local section_end = clock("`c(current_time)'", "hms")
        local section_duration = (`section_end' - `section_start') / 1000
        di "Duration: " %9.2f `section_duration' " seconds"
    }
    else {
        di _n "{red}✗ Reliability analysis FAILED with error code: " _rc "{reset}"
        di "Please check the log file for details"
        local failed_sections = `failed_sections' + 1

        // Warn about enumerator effects dependency
        di _n "{yellow}WARNING: Enumerator effects analysis requires reliability analysis{reset}"
    }
}
else {
    di _n(3) "{hline 80}"
    di "{bf:SECTION 3: RELIABILITY ANALYSIS} - {yellow}SKIPPED{reset}"
    di "{hline 80}" _n
    local skipped_sections = `skipped_sections' + 1
}

/*==============================================================================
                    SECTION 4: ENUMERATOR EFFECTS
==============================================================================*/

if $run_enumerator == 1 {
    di _n(3) "{hline 80}"
    di "{bf:SECTION 4: ENUMERATOR AND TIME EFFECTS}"
    di "{hline 80}" _n

    local section_start = clock("`c(current_time)'", "hms")

    capture noisily do "scripts/do/impact/05_enumerator_effects.do"

    if _rc == 0 {
        di _n "{green}✓ Enumerator effects analysis completed successfully{reset}"
        local completed_sections = `completed_sections' + 1

        local section_end = clock("`c(current_time)'", "hms")
        local section_duration = (`section_end' - `section_start') / 1000
        di "Duration: " %9.2f `section_duration' " seconds"
    }
    else {
        di _n "{red}✗ Enumerator effects analysis FAILED with error code: " _rc "{reset}"
        di "Please check the log file for details"
        di "Note: This requires 04_reliability_analysis.do to run first"
        local failed_sections = `failed_sections' + 1
    }
}
else {
    di _n(3) "{hline 80}"
    di "{bf:SECTION 4: ENUMERATOR EFFECTS} - {yellow}SKIPPED{reset}"
    di "{hline 80}" _n
    local skipped_sections = `skipped_sections' + 1
}

/*==============================================================================
                    SECTION 5: PARTICIPANT TRACKING
==============================================================================*/

if $run_tracking == 1 {
    di _n(3) "{hline 80}"
    di "{bf:SECTION 5: PARTICIPANT TRACKING VALIDATION}"
    di "{hline 80}" _n

    local section_start = clock("`c(current_time)'", "hms")

    capture noisily do "scripts/do/impact/06_participant_tracking.do"

    if _rc == 0 {
        di _n "{green}✓ Participant tracking completed successfully{reset}"
        local completed_sections = `completed_sections' + 1

        local section_end = clock("`c(current_time)'", "hms")
        local section_duration = (`section_end' - `section_start') / 1000
        di "Duration: " %9.2f `section_duration' " seconds"
    }
    else {
        di _n "{red}✗ Participant tracking FAILED with error code: " _rc "{reset}"
        di "Please check the log file for details"
        local failed_sections = `failed_sections' + 1
    }
}
else {
    di _n(3) "{hline 80}"
    di "{bf:SECTION 5: PARTICIPANT TRACKING} - {yellow}SKIPPED{reset}"
    di "{hline 80}" _n
    local skipped_sections = `skipped_sections' + 1
}

/*==============================================================================
                    EXECUTION SUMMARY
==============================================================================*/

local end_time = clock("`c(current_time)'", "hms")
local total_duration = (`end_time' - `start_time') / 1000
local total_minutes = floor(`total_duration' / 60)
local total_seconds = mod(`total_duration', 60)

di _n(3) "{hline 80}"
di "{bf:EXECUTION SUMMARY}"
di "{hline 80}" _n

di "Completion Statistics:"
di "  Total sections: " `total_sections'
di "  Completed successfully: {green}" `completed_sections' "{reset}"
di "  Failed: {red}" `failed_sections' "{reset}"
di "  Skipped: {yellow}" `skipped_sections' "{reset}"

di _n "Timing:"
di "  Total duration: " `total_minutes' " minutes " %4.1f `total_seconds' " seconds"
di "  Start time: " c(current_date) " " c(current_time)

di _n "Output Locations:"
di "  Tables: ${tables}/"
di "  Figures: ${figures}/"
di "  Processed data: ${data_processed}/"
di "  Logs: ${logs}/"

// List key output files
di _n "Key Output Files Created:"
if $run_impact == 1 {
    di "  Impact Analysis:"
    di "    - ${tables}/impact_analysis_results.xlsx"
    di "    - ${tables}/impact_analysis_results.csv"
    di "    - ${figures}/*_beforeafter_*.png"
}

if $run_reliability == 1 {
    di "  Reliability Analysis:"
    di "    - ${tables}/reliability_analysis_results.xlsx"
    di "    - ${tables}/reliability_analysis_results.csv"
    di "    - ${tables}/flagged_observations.xlsx"
    di "    - ${figures}/*_bland_altman.png"
    di "    - ${figures}/*_scatter_agreement.png"
}

if $run_enumerator == 1 {
    di "  Enumerator Effects:"
    di "    - ${tables}/enumerator_effects_regression.xlsx"
    di "    - ${tables}/enumerator_effects_summary.xlsx"
}

if $run_tracking == 1 {
    di "  Participant Tracking:"
    di "    - ${tables}/participant_tracking_validation.xlsx"
    di "    - ${tables}/tracking_issues.xlsx"
}

// Overall status
di _n(2) "{hline 80}"
if `failed_sections' == 0 {
    di "{green}{bf:ALL ANALYSES COMPLETED SUCCESSFULLY!}{reset}"
    di "{hline 80}" _n

    di "Next Steps:"
    di "  1. Review output tables and figures"
    di "  2. Check individual log files in ${logs}/ for details"
    di "  3. Address any flagged observations or tracking issues"
    di "  4. Document key findings and decisions"
    di "  5. Proceed with report generation or further analysis"
}
else {
    di "{red}{bf:SOME ANALYSES FAILED - PLEASE REVIEW}{reset}"
    di "{hline 80}" _n

    di "Troubleshooting Steps:"
    di "  1. Check the master log file: analysis/logs/00_run_all_master_`log_date'_`log_time'.log"
    di "  2. Review individual section log files in ${logs}/"
    di "  3. Verify input data files exist and are accessible"
    di "  4. Check that all required variables exist in datasets"
    di "  5. Run failed sections individually for detailed error messages"
    di "  6. Contact data team or technical support if issues persist"
}

di _n "Master log saved: analysis/logs/00_run_all_master_`log_date'_`log_time'.log"
di "Execution completed: " c(current_date) " " c(current_time)
di "{hline 80}" _n

log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
