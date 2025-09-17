/*==============================================================================
ROBUSTNESS CHECKS
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Robustness checks and sensitivity analysis
Input:       data/final/analysis_data.dta
Output:      outputs/tables/robustness_results.tex

Notes:       - Alternative specifications and estimation methods
             - Subsample analysis and sensitivity tests
             - Addresses potential concerns about main results

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
log using "analysis/logs/05_robustness_checks.log", replace

/*==============================================================================
                            LOAD ANALYSIS DATA
==============================================================================*/

use "data/final/analysis_data.dta", clear

// Verify data integrity and key structure
datasignature confirm
verify_keys id  // Adjust key variables as needed for your data

// Restrict to analysis sample
keep if analysis_sample == 1

di _n(2) "{hline 60}"
di "ROBUSTNESS CHECKS"
di "{hline 60}"
di "Analysis sample: " _N " observations"

/*==============================================================================
                            ALTERNATIVE FUNCTIONAL FORMS
==============================================================================*/

/*------------------------------------------------------------------------------
                            Linear vs Log Specification
------------------------------------------------------------------------------*/

// Linear model (levels instead of logs)
regress income female age education, robust
estimates store linear_income

// Semi-log model (log on left side only)
regress log_income female age education, robust
estimates store semilog_income

// Log-log model (if applicable)
capture {
    regress log_income female log_age log_education, robust
    estimates store loglog_income
}

/*------------------------------------------------------------------------------
                            Alternative Functional Forms for Age
------------------------------------------------------------------------------*/

// Quadratic age specification
capture generate age_squared = age^2
regress log_income female age age_squared education, robust
estimates store quadratic_age

// Cubic age specification
generate age_cubed = age^3
regress log_income female age age_squared age_cubed education, robust
estimates store cubic_age

// Spline specification (age breakpoint at 40)
generate age_spline = max(0, age - 40)
regress log_income female age age_spline education, robust
estimates store spline_age

/*==============================================================================
                            ALTERNATIVE ESTIMATION METHODS
==============================================================================*/

/*------------------------------------------------------------------------------
                            Quantile Regression
------------------------------------------------------------------------------*/

// Quantile regression at different quantiles
qreg log_income female age education, quantile(0.25)
estimates store qreg_25

qreg log_income female age education, quantile(0.50)
estimates store qreg_50

qreg log_income female age education, quantile(0.75)
estimates store qreg_75

/*------------------------------------------------------------------------------
                            Robust Regression Methods
------------------------------------------------------------------------------*/

// Robust regression (less sensitive to outliers)
capture {
    rreg log_income female age education
    estimates store robust_reg
}

// Tobit model (if outcome is censored)
capture {
    tobit log_income female age education, ll(0)
    estimates store tobit_model
}

/*==============================================================================
                            SUBSAMPLE ANALYSIS
==============================================================================*/

/*------------------------------------------------------------------------------
                            Gender Subsamples
------------------------------------------------------------------------------*/

// Male subsample only
regress log_income age education if female == 0, robust
estimates store male_only

// Female subsample only
regress log_income age education if female == 1, robust
estimates store female_only

/*------------------------------------------------------------------------------
                            Age-based Subsamples
------------------------------------------------------------------------------*/

// Young workers (age < 40)
regress log_income female age education if age < 40, robust
estimates store young_workers

// Older workers (age >= 40)
regress log_income female age education if age >= 40, robust
estimates store older_workers

/*------------------------------------------------------------------------------
                            Education-based Subsamples
------------------------------------------------------------------------------*/

// High education subsample
capture {
    regress log_income female age if education >= 12, robust
    estimates store high_education

    // Low education subsample
    regress log_income female age if education < 12, robust
    estimates store low_education
}

/*==============================================================================
                            OUTLIER SENSITIVITY
==============================================================================*/

/*------------------------------------------------------------------------------
                            Exclude Extreme Values
------------------------------------------------------------------------------*/

// Exclude top and bottom 1% of income distribution
_pctile income if analysis_sample == 1, p(1 99)
local p1 = r(r1)
local p99 = r(r2)

regress log_income female age education if income >= `p1' & income <= `p99', robust
estimates store exclude_outliers_1pct

// Exclude top and bottom 5% of income distribution
_pctile income if analysis_sample == 1, p(5 95)
local p5 = r(r1)
local p95 = r(r2)

regress log_income female age education if income >= `p5' & income <= `p95', robust
estimates store exclude_outliers_5pct

/*==============================================================================
                            ALTERNATIVE SAMPLE DEFINITIONS
==============================================================================*/

/*------------------------------------------------------------------------------
                            Expanded Sample
------------------------------------------------------------------------------*/

// Include observations previously excluded (less restrictive)
use "data/final/analysis_data.dta", clear

// Relax some sample restrictions
generate expanded_sample = 1
replace expanded_sample = 0 if missing(age, income, female)
// Keep more age range
replace expanded_sample = 0 if age < 16 | age > 85

regress log_income female age education if expanded_sample == 1, robust
estimates store expanded_sample_model

/*==============================================================================
                            EXPORT ROBUSTNESS RESULTS
==============================================================================*/

// Export alternative functional forms
esttab linear_income semilog_income quadratic_age spline_age ///
    using "outputs/tables/robustness_functional_forms.tex", ///
    replace ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    booktabs ///
    title("Alternative Functional Forms") ///
    mtitles("Linear" "Semi-log" "Quadratic Age" "Age Spline") ///
    scalars("N Observations" "r2 R-squared") ///
    sfmt(0 3) ///
    note("Robust standard errors in parentheses.")

// Export quantile regression results
esttab qreg_25 qreg_50 qreg_75 ///
    using "outputs/tables/robustness_quantile.tex", ///
    replace ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    booktabs ///
    title("Quantile Regression Results") ///
    mtitles("25th percentile" "Median" "75th percentile") ///
    scalars("N Observations") ///
    sfmt(0) ///
    note("Standard errors in parentheses.")

// Export subsample analysis
esttab male_only female_only young_workers older_workers ///
    using "outputs/tables/robustness_subsamples.tex", ///
    replace ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    booktabs ///
    title("Subsample Analysis") ///
    mtitles("Male only" "Female only" "Age<40" "Age≥40") ///
    scalars("N Observations" "r2 R-squared") ///
    sfmt(0 3) ///
    note("Robust standard errors in parentheses.")

/*==============================================================================
                            SENSITIVITY ANALYSIS SUMMARY
==============================================================================*/

di _n(2) "{hline 60}"
di "ROBUSTNESS CHECK SUMMARY"
di "{hline 60}"

// Compare key coefficient across specifications
local main_coef = _b[female] // From last model
di "Female coefficient in main specification: " %6.3f `main_coef'

estimates restore linear_income
local linear_coef = _b[female]
di "Female coefficient in linear model: " %6.3f `linear_coef'

estimates restore qreg_50
local median_coef = _b[female]
di "Female coefficient at median (qreg): " %6.3f `median_coef'

estimates restore exclude_outliers_1pct
local no_outlier_coef = _b[female]
di "Female coefficient excluding outliers: " %6.3f `no_outlier_coef'

di _n(1) "Range of female coefficients: " ///
    %6.3f min(`main_coef', `linear_coef', `median_coef', `no_outlier_coef') ///
    " to " ///
    %6.3f max(`main_coef', `linear_coef', `median_coef', `no_outlier_coef')

/*==============================================================================
                            CONCLUSION
==============================================================================*/

di _n(2) "{hline 60}"
di "ROBUSTNESS ANALYSIS COMPLETED"
di "Specifications tested:"
di "  - Alternative functional forms: 4"
di "  - Quantile regression: 3 quantiles"
di "  - Subsample analysis: 4 subsamples"
di "  - Outlier sensitivity: 2 tests"
di "Results saved to outputs/tables/robustness_*.tex"
di "{hline 60}"

// Close log
log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
