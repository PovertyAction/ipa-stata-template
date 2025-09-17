/*==============================================================================
DESCRIPTIVE ANALYSIS
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Generate descriptive statistics and summary tables
Input:       data/final/analysis_data.dta
Output:      outputs/tables/descriptive_stats.tex

Notes:       - Creates publication-ready descriptive statistics tables
             - Follows best practices for table formatting
             - Uses estout/esttab for LaTeX output

==============================================================================*/

// Boilerplate code
version 17
clear all
macro drop _all
set more off
set varabbrev off

// Define global paths for reproducibility (IPA best practice)
global project_path "`c(pwd)'"
global data_raw "${project_path}/data/raw"
global data_clean "${project_path}/data/clean"
global data_final "${project_path}/data/final"
global outputs "${project_path}/outputs"
global logs "${project_path}/analysis/logs"

// Load standard functions
do "${project_path}/scripts/do/functions.do"

// Start log file
capture log close
log using "analysis/logs/03_descriptive_analysis.log", replace

/*==============================================================================
                            LOAD ANALYSIS DATA
==============================================================================*/

use "data/final/analysis_data.dta", clear

// Verify data integrity and key structure
datasignature confirm
verify_keys id  // Adjust key variables as needed for your data

// Generate data quality report for analysis dataset
data_quality_report "Analysis Dataset for Descriptive Statistics"

// Restrict to analysis sample
keep if analysis_sample == 1

di _n(2) "{hline 60}"
di "DESCRIPTIVE ANALYSIS"
di "{hline 60}"
di "Analysis sample: " _N " observations"

/*==============================================================================
                            BASIC DESCRIPTIVE STATISTICS
==============================================================================*/

// Display summary statistics
summarize age income female education_level, detail

// Frequency tables for categorical variables
tab female, missing
tab age_cat, missing
tab education_level, missing

/*==============================================================================
                            SUMMARY STATISTICS TABLE
==============================================================================*/

// Install required packages (would normally be in ado folder)
* ssc install estout, replace

// Summary statistics for full sample
estpost summarize age income log_income female education ///
    if analysis_sample == 1, detail

// Store results for full sample
estimates store summary_all

// Summary statistics by gender (if applicable)
capture {
    estpost summarize age income log_income education ///
        if analysis_sample == 1 & female == 0, detail
    estimates store summary_male

    estpost summarize age income log_income education ///
        if analysis_sample == 1 & female == 1, detail
    estimates store summary_female
}

/*==============================================================================
                            CORRELATION TABLE
==============================================================================*/

// Correlation matrix for key variables
capture {
    estpost correlate age income log_income female education ///
        if analysis_sample == 1, matrix listwise
    estimates store correlations
}

/*==============================================================================
                            BALANCE/COMPARISON TABLES
==============================================================================*/

// T-tests comparing groups (example: by gender)
capture {
    foreach var in age income education {
        ttest `var' if analysis_sample == 1, by(female)
    }
}

// Chi-square tests for categorical variables
capture {
    tab education_level female if analysis_sample == 1, chi2
    tab age_cat female if analysis_sample == 1, chi2
}

/*==============================================================================
                            EXPORT TABLES
==============================================================================*/

// Export summary statistics table
esttab summary_all using "outputs/tables/descriptive_stats.tex", ///
    replace ///
    cells("mean(fmt(2)) sd(fmt(2)) min(fmt(0)) max(fmt(0)) count(fmt(0))") ///
    label ///
    booktabs ///
    title("Descriptive Statistics") ///
    mtitles("Full Sample") ///
    note("Sample restricted to analysis sample. See data preparation log for details.")

// Export summary by gender (if applicable)
capture {
    esttab summary_male summary_female using "outputs/tables/descriptive_by_gender.tex", ///
        replace ///
        cells("mean(fmt(2)) sd(fmt(2)) count(fmt(0))") ///
        label ///
        booktabs ///
        title("Descriptive Statistics by Gender") ///
        mtitles("Male" "Female") ///
        note("Sample restricted to analysis sample.")
}

// Export correlation table
capture {
    esttab correlations using "outputs/tables/correlations.tex", ///
        replace ///
        not ///
        unstack ///
        compress ///
        booktabs ///
        title("Correlation Matrix") ///
        note("Sample restricted to analysis sample.")
}

/*==============================================================================
                            ADDITIONAL DESCRIPTIVE ANALYSIS
==============================================================================*/

// Distribution analysis
capture {
    // Histogram of key variables
    histogram age if analysis_sample == 1, ///
        title("Distribution of Age") ///
        note("Analysis sample only") ///
        saving("outputs/figures/hist_age.gph", replace)

    histogram log_income if analysis_sample == 1, ///
        title("Distribution of Log Income") ///
        note("Analysis sample only") ///
        saving("outputs/figures/hist_income.gph", replace)
}

// Quantile analysis
capture {
    _pctile income if analysis_sample == 1, p(10 25 50 75 90)
    di "Income percentiles:"
    di "10th: " r(r1)
    di "25th: " r(r2)
    di "50th: " r(r3)
    di "75th: " r(r4)
    di "90th: " r(r5)
}

/*==============================================================================
                            SAMPLE REPRESENTATIVENESS
==============================================================================*/

// Compare analysis sample to full sample
di _n(2) "{hline 60}"
di "SAMPLE REPRESENTATIVENESS CHECK"
di "{hline 60}"

// Reload full dataset for comparison
preserve
use "data/clean/cleaned_data.dta", clear

capture {
    ttest age, by(analysis_sample)
    ttest income, by(analysis_sample)
    tab female analysis_sample, chi2
}

restore

di _n(2) "{hline 60}"
di "DESCRIPTIVE ANALYSIS COMPLETED"
di "Tables saved to outputs/tables/"
di "Number of observations: " _N
di "{hline 60}"

// Close log
log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
