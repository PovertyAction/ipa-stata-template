/*==============================================================================
COMMON ANALYSIS FUNCTIONS
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Reusable functions implementing IPA best practices
             - Data key verification and validation
             - Standardized regression output
             - Data quality checks and reporting
             - Error handling and defensive programming

Notes:       - Load this file at start of analysis pipeline
             - All functions follow abstraction principles
             - Implements IPA and Data Carpentry best practices

References:
- Gentzkow & Shapiro: "Code and Data for the Social Sciences"
- IPA Data Cleaning Guide: https://data.poverty-action.org/data-cleaning/
- Data Carpentry Stata: https://datacarpentry.github.io/stata-economics/

==============================================================================*/

version 17

/*==============================================================================
                    DATA KEY VERIFICATION
==============================================================================*/

// Function: verify_keys
// Purpose: Verify unique identifiers meet IPA standards
// Usage: verify_keys participant_id survey_round
capture program drop verify_keys
program define verify_keys
    syntax varlist

    di _n(2) "{hline 60}"
    di "UNIQUE KEY VERIFICATION"
    di "{hline 60}"

    // Test 1: Key uniqueness
    di "Testing key uniqueness for: `varlist'"
    capture isid `varlist'
    if _rc != 0 {
        di as error "CRITICAL ERROR: Keys are not unique!"
        di as error "Variables: `varlist'"
        di as error "This violates fundamental data standards"

        // Show duplicate observations for debugging
        duplicates tag `varlist', gen(_dup_flag)
        count if _dup_flag > 0
        if r(N) > 0 {
            di as error "Number of duplicate observations: " r(N)
            list `varlist' if _dup_flag > 0, clean
        }
        drop _dup_flag

        di as error "Analysis cannot proceed with duplicate keys"
        exit 459
    }
    else {
        di as result "✓ Key uniqueness verified"
    }

    // Test 2: No missing values in keys
    foreach var of varlist `varlist' {
        count if missing(`var')
        if r(N) > 0 {
            di as error "CRITICAL ERROR: Missing values in key variable `var'"
            di as error "Count of missing: " r(N)
            di as error "This violates data standards"
            exit 459
        }
        else {
            di as result "✓ No missing values in `var'"
        }
    }

    // Test 3: Document key structure
    di _n "KEY DOCUMENTATION:"
    di "Analysis unit: " _N " observations"
    di "Key variables: `varlist'"
    foreach var of varlist `varlist' {
        summarize `var', meanonly
        di "  `var': min=" r(min) " max=" r(max)
    }

    // Create data signature for reproducibility
    datasignature set, reset saving("${logs}/key_signature_`c(current_date)'.dta", replace)
    di as result "✓ Data signature saved for reproducibility"

    di "{hline 60}" _n
end

/*==============================================================================
                    DATA QUALITY CHECKS
==============================================================================*/

// Function: data_quality_report
// Purpose: Comprehensive data quality assessment
// Usage: data_quality_report "dataset_name"
capture program drop data_quality_report
program define data_quality_report
    syntax anything

    local dataset_name `anything'

    di _n(2) "{hline 60}"
    di "DATA QUALITY REPORT: `dataset_name'"
    di "{hline 60}"

    // Basic dataset information
    di "Observations: " _N
    di "Variables: " c(k)
    di "Memory usage: " c(memory) " bytes"

    // Missing data patterns
    di _n "MISSING DATA ANALYSIS:"
    missings report, minimum(1)

    // Check for completely empty observations
    egen _missing_count = rowmiss(_all)
    count if _missing_count == c(k)
    if r(N) > 0 {
        di as error "WARNING: " r(N) " completely empty observations found"
    }
    drop _missing_count

    // Variable type summary
    di _n "VARIABLE TYPES:"
    describe, simple

    // Flag potential data issues
    di _n "POTENTIAL ISSUES:"
    quietly {
        // Check for variables with no variation
        local no_variation_vars ""
        foreach var of varlist _all {
            capture assert `var' == `var'[1]
            if _rc == 0 {
                local no_variation_vars "`no_variation_vars' `var'"
            }
        }
    }
    if "`no_variation_vars'" != "" {
        di as error "Variables with no variation: `no_variation_vars'"
    }
    else {
        di as result "✓ All variables have variation"
    }

    di "{hline 60}" _n
end

/*==============================================================================
                    STANDARDIZED REGRESSION OUTPUT
==============================================================================*/

// Function: standard_regression
// Purpose: Standardized regression with consistent output format
// Usage: standard_regression depvar "indepvars" "controls" "tablename" "title"
capture program drop standard_regression
program define standard_regression
    syntax anything

    // Parse arguments
    tokenize `anything'
    local depvar `1'
    local indepvars `2'
    local controls `3'
    local tablename `4'
    local title `5'

    di _n(2) "{hline 60}"
    di "STANDARDIZED REGRESSION: `title'"
    di "{hline 60}"

    // Run regression with robust standard errors (IPA standard)
    regress `depvar' `indepvars' `controls', robust

    // Display results
    di _n "Dependent variable: `depvar'"
    di "Key variables: `indepvars'"
    di "Controls: `controls'"
    di "Observations: " e(N)
    di "R-squared: " %9.4f e(r2)

    // Export table with consistent formatting
    capture which outreg2
    if _rc == 0 {
        outreg2 using "${outputs}/tables/`tablename'.tex", ///
            replace tex(pretty) keep(`indepvars') ///
            title("`title'") ///
            addtext("Controls", "`controls'") ///
            ctitle("") ///
            label
        di as result "✓ Table exported to: outputs/tables/`tablename'.tex"
    }
    else {
        di as error "WARNING: outreg2 not installed - table not exported"
        di "Install with: ssc install outreg2"
    }

    // Store estimation for later use
    estimates store `tablename'

    di "{hline 60}" _n
end

/*==============================================================================
                    FILE PATH VALIDATION
==============================================================================*/

// Function: validate_paths
// Purpose: Ensure all required directories exist
// Usage: validate_paths
capture program drop validate_paths
program define validate_paths

    di _n(2) "{hline 60}"
    di "VALIDATING PROJECT STRUCTURE"
    di "{hline 60}"

    // Required directories
    local required_dirs "data/raw data/clean data/final outputs/tables outputs/figures analysis/logs"

    foreach dir in `required_dirs' {
        capture confirm file "${project_path}/`dir'"
        if _rc != 0 {
            di as error "Missing directory: `dir'"
            di "Creating directory..."
            shell mkdir "${project_path}/`dir'"
            di as result "✓ Created: `dir'"
        }
        else {
            di as result "✓ Exists: `dir'"
        }
    }

    di "{hline 60}" _n
end

/*==============================================================================
                    ANALYSIS PIPELINE VALIDATION
==============================================================================*/

// Function: validate_pipeline
// Purpose: Check pipeline dependencies before running analysis
// Usage: validate_pipeline
capture program drop validate_pipeline
program define validate_pipeline

    di _n(2) "{hline 60}"
    di "PIPELINE DEPENDENCY VALIDATION"
    di "{hline 60}"

    // Check for required input files
    local required_files "data/raw/sample_data.csv"

    foreach file in `required_files' {
        capture confirm file "${project_path}/`file'"
        if _rc != 0 {
            di as error "CRITICAL: Missing required file: `file'"
            di as error "Pipeline cannot proceed"
            exit 601
        }
        else {
            di as result "✓ Found: `file'"
        }
    }

    // Check for required packages
    local required_packages "estout outreg2 missings"

    foreach pkg in `required_packages' {
        capture which `pkg'
        if _rc != 0 {
            di as error "WARNING: Package `pkg' not installed"
            di "Consider running: just stata-install-packages"
        }
        else {
            di as result "✓ Package available: `pkg'"
        }
    }

    di "{hline 60}" _n
end

/*==============================================================================
                    INITIALIZATION MESSAGE
==============================================================================*/

di _n(2) "{hline 80}"
di "FUNCTIONS LOADED"
di "{hline 80}"
di "Available functions:"
di "  verify_keys varlist       - Verify unique identifiers"
di "  data_quality_report name  - Comprehensive data quality check"
di "  standard_regression ...   - Standardized regression output"
di "  validate_paths            - Ensure directory structure"
di "  validate_pipeline         - Check pipeline dependencies"
di _n "Usage: Call these functions in your analysis scripts"
di "Example: verify_keys participant_id survey_round"
di "{hline 80}" _n
