/*==============================================================================
GENERATE FIGURES
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Generate publication-ready figures and visualizations
Input:       data/final/analysis_data.dta
Output:      outputs/figures/ (PDF format)

Notes:       - Creates high-quality figures for publication using IPA theme
             - Uses ipaplots scheme for IPA-branded visualizations
             - Follows IPA data visualization best practices
             - Exports in PDF format for LaTeX integration

==============================================================================*/

// Boilerplate code following IPA guidelines
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
global outputs_figures "${project_path}/outputs/figures"
global logs "${project_path}/analysis/logs"

// Load standard functions
do "${project_path}/scripts/do/functions.do"

// Start log file
capture log close
log using "${logs}/06_generate_figures.log", replace

/*==============================================================================
                            LOAD ANALYSIS DATA
==============================================================================*/

use "${data_final}/analysis_data.dta", clear

// Verify data integrity
datasignature confirm

// Restrict to analysis sample
keep if analysis_sample == 1

di _n(2) "{hline 60}"
di "GENERATING FIGURES"
di "{hline 60}"
di "Analysis sample: " _N " observations"

/*==============================================================================
                            FIGURE SETTINGS
==============================================================================*/

// Set IPA graph scheme for branded visualizations
// NOTE: Requires ipaplots package installation
// Run: net install github, from("https://haghish.github.io/github/")
//      github install PovertyAction/ipaplots
capture set scheme ipaplots
if _rc != 0 {
    di as text "Note: ipaplots scheme not installed, using default s2color"
    di as text "For IPA staff: Install ipaplots for branded visualizations"
    di as text "Commands: net install github, from(\"https://haghish.github.io/github/\")"
    di as text "          github install PovertyAction/ipaplots"
    set scheme s2color
}

// Configure fonts for professional appearance (recommended for IPA graphics)
capture {
    graph set window fontface "Georgia"
    graph set print fontface "Georgia"
}

// Define IPA-compatible colors (works with both schemes)
local color_primary "navy"          // IPA primary color
local color_secondary "maroon"      // IPA secondary color
local color_accent "dknavy"         // IPA accent color
local color_neutral "gs8"           // Neutral gray

/*==============================================================================
                            FIGURE 1: DESCRIPTIVE VISUALIZATIONS
==============================================================================*/

/*------------------------------------------------------------------------------
                            Income Distribution by Gender
------------------------------------------------------------------------------*/

// Histogram with overlaid distributions using IPA color scheme
twoway (histogram log_income if female == 0, ///
            color(`color_primary'%30) ///
            frequency ///
            bin(30)) ///
       (histogram log_income if female == 1, ///
            color(`color_secondary'%30) ///
            frequency ///
            bin(30)), ///
    title("Distribution of Log Income by Gender", size(medlarge)) ///
    subtitle("Analysis Sample", size(medium)) ///
    xtitle("Log Income", size(medium)) ///
    ytitle("Frequency", size(medium)) ///
    legend(label(1 "Male") label(2 "Female") ///
           pos(1) ring(0) cols(1) size(medium)) ///
    note("Sample size: N = " _N ". Generated using IPA theme.", size(small)) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "${outputs_figures}/figure1_income_distribution.pdf", replace

/*------------------------------------------------------------------------------
                            Box Plot by Education Level
------------------------------------------------------------------------------*/

capture {
    graph box log_income, ///
        over(educ_level, label(labsize(medium))) ///
        by(female, title("Income Distribution by Education and Gender", ///
                        size(medlarge)) ///
               subtitle("", size(zero)) ///
               note("Analysis sample. Boxes show median, IQR, and outliers. Generated using IPA theme.", ///
                   size(small))) ///
        ytitle("Log Income", size(medium)) ///
        graphregion(color(white)) ///
        plotregion(color(white))

    graph export "${outputs_figures}/figure1_income_by_education.pdf", replace
}

/*==============================================================================
                            FIGURE 2: REGRESSION RESULTS VISUALIZATION
==============================================================================*/

/*------------------------------------------------------------------------------
                            Coefficient Plot
------------------------------------------------------------------------------*/

// Run main regression and store results using IPA variable names
regress log_income female age education, robust

// Create coefficient plot using coefplot (install if needed)
* ssc install coefplot, replace

capture {
    coefplot, ///
        drop(_cons) ///
        xline(0, lcolor(red) lpattern(dash)) ///
        xlabel(, format(%9.2f)) ///
        xtitle("Coefficient Estimate", size(medium)) ///
        title("Regression Coefficients with 95% Confidence Intervals", ///
              size(medlarge)) ///
        subtitle("Dependent Variable: Log Income", size(medium)) ///
        note("Robust standard errors. Analysis sample N = " e(N) ". Generated using IPA theme.", ///
             size(small)) ///
        graphregion(color(white)) ///
        plotregion(color(white)) ///
        ciopts(color(`color_accent')) ///
        msymbol(circle) ///
        mcolor(`color_accent')

    graph export "${outputs_figures}/figure2_coefficients.pdf", replace
}

/*------------------------------------------------------------------------------
                            Marginal Effects Plot
------------------------------------------------------------------------------*/

// Marginal effects of age across education levels
capture {
    regress log_income c.age##c.education female, robust

    margins, dydx(age) at(education=(8(2)18))

    marginsplot, ///
        title("Marginal Effect of Age on Log Income", ///
              "by Education Level", size(medlarge)) ///
        xtitle("Years of Education", size(medium)) ///
        ytitle("Marginal Effect of Age", size(medium)) ///
        note("Based on interaction model. 95% confidence intervals shown.", ///
             size(small)) ///
        graphregion(color(white)) ///
        plotregion(color(white)) ///
        plot1opts(color(`color_main') lwidth(thick)) ///
        ci1opts(color(`color_main'%30))

    graph export "outputs/figures/figure2_marginal_effects.pdf", replace
}

/*==============================================================================
                            FIGURE 3: RESIDUAL DIAGNOSTICS
==============================================================================*/

/*------------------------------------------------------------------------------
                            Residual vs Fitted Plot
------------------------------------------------------------------------------*/

// Run main regression and generate predictions
regress log_income female age education, robust
predict fitted_values
predict residuals, residuals

// Residual vs fitted plot
twoway (scatter residuals fitted_values, ///
            mcolor(`color_main'%60) ///
            msymbol(circle_hollow) ///
            msize(vsmall)) ///
       (lowess residuals fitted_values, ///
            lcolor(red) ///
            lwidth(thick)), ///
    title("Residuals vs Fitted Values", size(medlarge)) ///
    subtitle("Diagnostic Plot for Main Regression", size(medium)) ///
    xtitle("Fitted Values", size(medium)) ///
    ytitle("Residuals", size(medium)) ///
    legend(off) ///
    note("Red line shows lowess smoother. Ideally should be flat around zero.", ///
         size(small)) ///
    graphregion(color(white)) ///
    plotregion(color(white))

graph export "outputs/figures/figure3_residuals_fitted.pdf", replace

/*------------------------------------------------------------------------------
                            Q-Q Plot for Normality
------------------------------------------------------------------------------*/

// Q-Q plot of residuals
capture {
    qnorm residuals, ///
        title("Q-Q Plot of Residuals", size(medlarge)) ///
        subtitle("Test for Normality of Residuals", size(medium)) ///
        note("Points should lie on diagonal line if residuals are normal.", ///
             size(small)) ///
        graphregion(color(white)) ///
        plotregion(color(white)) ///
        mcolor(`color_main') ///
        msymbol(circle_hollow)

    graph export "outputs/figures/figure3_qq_plot.pdf", replace
}

/*==============================================================================
                            FIGURE 4: ROBUSTNESS VISUALIZATION
==============================================================================*/

/*------------------------------------------------------------------------------
                            Coefficient Stability Plot
------------------------------------------------------------------------------*/

// Show how key coefficient changes across specifications
capture {
    // Store coefficients from different models
    regress log_income female age, robust
    local coef1 = _b[female]
    local se1 = _se[female]

    regress log_income female age education, robust
    local coef2 = _b[female]
    local se2 = _se[female]

    regress log_income female age education age_squared, robust
    local coef3 = _b[female]
    local se3 = _se[female]

    // Create dataset for plotting
    clear
    set obs 3
    generate spec = _n
    generate coef = .
    generate se = .
    generate lb = .
    generate ub = .

    replace coef = `coef1' if spec == 1
    replace se = `se1' if spec == 1
    replace coef = `coef2' if spec == 2
    replace se = `se2' if spec == 2
    replace coef = `coef3' if spec == 3
    replace se = `se3' if spec == 3

    replace lb = coef - 1.96*se
    replace ub = coef + 1.96*se

    label define spec_lbl 1 "Basic" 2 "+ Education" 3 "+ Age²"
    label values spec spec_lbl

    // Plot coefficient stability
    twoway (rcap lb ub spec, ///
                lcolor(`color_main') ///
                lwidth(medium)) ///
           (scatter coef spec, ///
                mcolor(`color_main') ///
                msymbol(circle) ///
                msize(medium)), ///
        title("Coefficient Stability Across Specifications", size(medlarge)) ///
        subtitle("Female Coefficient with 95% Confidence Intervals", ///
                size(medium)) ///
        xtitle("Model Specification", size(medium)) ///
        ytitle("Coefficient Estimate", size(medium)) ///
        xlabel(1 2 3, valuelabel) ///
        legend(off) ///
        note("Shows stability of key coefficient across model specifications.", ///
             size(small)) ///
        graphregion(color(white)) ///
        plotregion(color(white))

    graph export "outputs/figures/figure4_coefficient_stability.pdf", replace
}

/*==============================================================================
                            COMBINED FIGURES
==============================================================================*/

// Reload data for any additional combined plots
use "data/final/analysis_data.dta", clear
keep if analysis_sample == 1

/*------------------------------------------------------------------------------
                            Multi-panel Figure
------------------------------------------------------------------------------*/

capture {
    // Create 2x2 panel figure

    // Panel A: Histogram
    histogram log_income, ///
        title("A. Income Distribution", size(medium)) ///
        xtitle("Log Income", size(small)) ///
        ytitle("Density", size(small)) ///
        note("") ///
        name(panelA, replace) ///
        graphregion(color(white))

    // Panel B: Scatter plot
    twoway scatter log_income age, ///
        title("B. Income vs Age", size(medium)) ///
        xtitle("Age", size(small)) ///
        ytitle("Log Income", size(small)) ///
        mcolor(`color_main'%60) ///
        msymbol(circle_hollow) ///
        msize(vsmall) ///
        name(panelB, replace) ///
        graphregion(color(white))

    // Panel C: Box plot by gender
    graph box log_income, ///
        over(female, relabel(1 "Male" 2 "Female")) ///
        title("C. Income by Gender", size(medium)) ///
        ytitle("Log Income", size(small)) ///
        note("") ///
        name(panelC, replace) ///
        graphregion(color(white))

    // Panel D: Regression line
    twoway (scatter log_income education, ///
                mcolor(`color_main'%40) ///
                msymbol(circle_hollow) ///
                msize(vsmall)) ///
           (lfit log_income education, ///
                lcolor(red) ///
                lwidth(thick)), ///
        title("D. Income vs Education", size(medium)) ///
        xtitle("Years of Education", size(small)) ///
        ytitle("Log Income", size(small)) ///
        legend(off) ///
        name(panelD, replace) ///
        graphregion(color(white))

    // Combine panels
    graph combine panelA panelB panelC panelD, ///
        title("Summary of Key Relationships", size(large)) ///
        note("Analysis sample. All figures based on cleaned data.", ///
             size(small)) ///
        graphregion(color(white)) ///
        plotregion(color(white))

    graph export "outputs/figures/combined_summary.pdf", replace
}

/*==============================================================================
                            FIGURE SUMMARY
==============================================================================*/

di _n(2) "{hline 60}"
di "FIGURE GENERATION COMPLETED"
di "{hline 60}"
di "Figures created:"
di "  - figure1_income_distribution.pdf"
di "  - figure1_income_by_education.pdf"
di "  - figure2_coefficients.pdf"
di "  - figure2_marginal_effects.pdf"
di "  - figure3_residuals_fitted.pdf"
di "  - figure3_qq_plot.pdf"
di "  - figure4_coefficient_stability.pdf"
di "  - combined_summary.pdf"
di "All figures saved to: outputs/figures/"
di "{hline 60}"

// Close log
log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
