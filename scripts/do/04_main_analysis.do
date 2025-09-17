/*==============================================================================
MAIN ANALYSIS
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Main regression analysis and hypothesis testing
Input:       data/final/analysis_data.dta
Output:      outputs/tables/main_results.tex

Notes:       - Main regression specifications
             - Follows best practices for econometric analysis
             - Uses reghdfe for fixed effects estimation when appropriate

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
log using "analysis/logs/04_main_analysis.log", replace

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
di "MAIN ANALYSIS"
di "{hline 60}"
di "Analysis sample: " _N " observations"

/*==============================================================================
                            REGRESSION ANALYSIS
==============================================================================*/

// If necessary, install required packages
* ssc install reghdfe, replace
* ssc install estout, replace

/*------------------------------------------------------------------------------
                            Model 1: Basic OLS
------------------------------------------------------------------------------*/

// Manual regression for analyst review and comparison
regress log_income female age, robust
estimates store model1_manual

// Use standardized regression function
standard_regression log_income "female" "age" "model1" "Basic Income Regression"

/*------------------------------------------------------------------------------
                            Model 2: Extended Controls
------------------------------------------------------------------------------*/

// Manual regression for analyst review and comparison
regress log_income female age age_squared education, robust
estimates store model2_manual

// Use standardized regression function with extended controls
standard_regression log_income "female" "age age_squared education" "model2" "Extended Income Regression"

/*------------------------------------------------------------------------------
                            Model 3: With Interactions
------------------------------------------------------------------------------*/

// Manual regression for analyst review and comparison
regress log_income female age education female_x_age, robust
estimates store model3_manual

// Use standardized regression function with interactions
standard_regression log_income "female female_x_age" "age education" "model3" "Income Regression with Interactions"

/*------------------------------------------------------------------------------
                            Model 4: Clustered Standard Errors
------------------------------------------------------------------------------*/

// With clustered standard errors (if clustering variable exists)
capture {
    regress log_income female age education, cluster(cluster_var)
    estimates store model4
}

/*==============================================================================
                    COMPARISON: MANUAL vs STANDARDIZED RESULTS
==============================================================================*/

di _n(2) "{hline 60}"
di "COMPARING MANUAL AND STANDARDIZED REGRESSION RESULTS"
di "{hline 60}"

// Display manual results for comparison
di _n "MANUAL REGRESSION RESULTS:"
estimates table model1_manual model2_manual model3_manual, ///
    b(%9.4f) se(%9.4f) stats(N r2) ///
    title("Manual Regression Results")

// Display standardized results
di _n "STANDARDIZED FUNCTION RESULTS:"
estimates table model1 model2 model3, ///
    b(%9.4f) se(%9.4f) stats(N r2) ///
    title("Standardized Function Results")

di _n "Note: Both sets should be identical - this validates the standard_regression function"
di "{hline 60}" _n

/*==============================================================================
                            HYPOTHESIS TESTING
==============================================================================*/

// Test joint significance of age variables
estimates restore model2
test age age_squared

// Test equality of coefficients across groups
capture {
    // Test if female coefficient differs by education level
    regress log_income female##c.education age, robust
    margins, dydx(female) at(education=(8 12 16))
    marginsplot, title("Effect of Gender by Education Level")
}

/*==============================================================================
                            EXPORT MAIN RESULTS TABLE
==============================================================================*/

// Export main regression results
esttab model1 model2 model3 using "outputs/tables/main_results.tex", ///
    replace ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    booktabs ///
    title("Main Regression Results") ///
    mtitles("Basic" "Extended" "Interactions") ///
    scalars("N Observations" "r2 R-squared") ///
    sfmt(0 3) ///
    note("Robust standard errors in parentheses. *** p<0.01, ** p<0.05, * p<0.10")

/*==============================================================================
                            ROBUSTNESS CHECKS (PREVIEW)
==============================================================================*/

// Quick robustness checks
di _n(2) "{hline 60}"
di "ROBUSTNESS CHECK PREVIEW"
di "{hline 60}"

// Alternative functional forms
capture {
    // Linear model (no log transformation)
    regress income female age education, robust
    estimates store linear_model

    // Quantile regression at median
    qreg log_income female age education, quantile(0.5)
    estimates store qreg_model
}

// Subsample analysis
capture {
    // Young subsample
    regress log_income female age education if young_sample == 1, robust
    estimates store young_sample_model

    // Old subsample
    regress log_income female age education if old_sample == 1, robust
    estimates store old_sample_model
}

/*==============================================================================
                            DIAGNOSTIC TESTS
==============================================================================*/

// Regression diagnostics
estimates restore model2

// Heteroskedasticity test
capture {
    estat hettest
    di "Breusch-Pagan test p-value: " r(p)
}

// Normality of residuals
capture {
    predict residuals, residuals
    sktest residuals
    di "Skewness-Kurtosis test p-value: " r(P_chi2)
}

// Multicollinearity check
capture {
    estat vif
}

/*==============================================================================
                            EFFECT SIZES AND INTERPRETATION
==============================================================================*/

// Calculate effect sizes and practical significance
estimates restore model2

// Marginal effects at means
margins, dydx(female age education) atmeans

// Predicted values for typical individuals
margins, at(female=0 age=30 education=12) ///
         at(female=1 age=30 education=12)

// Calculate percent change interpretation for log-linear model
di _n(2) "{hline 60}"
di "EFFECT SIZE INTERPRETATION"
di "{hline 60}"

local female_coef = _b[female]
local female_pct = (exp(`female_coef') - 1) * 100

di "Female coefficient: " %6.3f `female_coef'
di "Interpreted as: " %5.1f `female_pct' "% difference in income"

/*==============================================================================
                            SUMMARY AND CONCLUSIONS
==============================================================================*/

di _n(2) "{hline 60}"
di "MAIN ANALYSIS SUMMARY"
di "{hline 60}"
di "Number of observations: " _N
di "Number of models estimated: 3"
di "Primary outcome: Log income"
di "Key explanatory variable: Female"
di "Results saved to: outputs/tables/main_results.tex"
di "{hline 60}"

// Close log
log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
