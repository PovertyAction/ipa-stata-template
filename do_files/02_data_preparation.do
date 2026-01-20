/*==============================================================================
DATA PREPARATION FOR ANALYSIS
================================================================================

Project:     [Project Name]
Author:      [Author Name]
Date:        `c(current_date)'
Description: Prepare cleaned data for analysis by creating variables and samples
Input:       data/clean/cleaned_data.dta
Output:      data/final/analysis_data.dta

Notes:       - Assumes globals are set by 00_run.do
             - Can be run standalone via: do 00_run.do "02_data_preparation"
             - Creates analysis variables and sample restrictions
             - Follows best practices for variable creation and labeling

==============================================================================*/

/*==============================================================================
                    STANDALONE INITIALIZATION
==============================================================================*/
* %%
// Check if already initialized by 00_run.do
if "${project_path}" == "" {

    di _n(2) "{hline 60}"
    di "STANDALONE EXECUTION DETECTED"
    di "{hline 60}"

    // 1. Clear and setup environment
    clear all
    macro drop _all
    capture log close _all
    set more off

    // 2. Find project root with setroot
    capture setroot, verbose
    if _rc != 0 {
        di as error "ERROR: Could not find project root"
        di as error "Ensure setroot is installed: ssc install setroot"
        di as error "Or run from project directory"
        exit 601
    }
    global project_path "${root}"

    // 3. Environment setup with ieboilstart
    ieboilstart, versionnumber(17.0) adopath("${project_path}/ado", strict)

    // 4. Load user configuration (if exists)
    capture confirm file "${project_path}/config.do"
    if _rc == 0 {
        di as text "Loading user configuration from config.do"
        do "${project_path}/config.do"
    }

    // 5. Set default paths
    if "${data_root}" == "" {
        global data_root "${project_path}/data"
    }

    // 6. Define standard paths
    if "${data_raw}" == "" global data_raw "${data_root}/raw"
    if "${data_clean}" == "" global data_clean "${data_root}/clean"
    if "${data_final}" == "" global data_final "${data_root}/final"

    global scripts "${project_path}/do_files"
    global outputs "${project_path}/outputs"
    global logs "${project_path}/logs"
    global tables "${outputs}/tables"
    global figures "${outputs}/figures"

    // 7. Load functions
    do "${scripts}/functions.do"

    // 8. Validate paths
    validate_paths

    di "{hline 60}"
    di "INITIALIZATION COMPLETED"
    di "Project root: ${project_path}"
    di "{hline 60}" _n
}
else {
    di _n "Running via 00_run.do (initialization already complete)" _n
}

* %%
// Start log file
capture log close
log using "${logs}/02_data_preparation.log", replace

* %%
/*==============================================================================
                            LOAD CLEANED DATA
==============================================================================*/

use "${data_clean}/cleaned_data.dta", clear

// Verify data integrity and key structure
datasignature confirm
verify_keys id  // Adjust key variables as needed for your data

* %%
// Generate data quality report for cleaned data
data_quality_report "Cleaned Data for Preparation"

di _n(2) "{hline 60}"
di "PREPARING DATA FOR ANALYSIS"
di "{hline 60}"
di "Starting observations: " _N

* %%
/*==============================================================================
                            CREATE ANALYSIS VARIABLES
==============================================================================*/

// Create standardized variables for analysis
capture {
    // Standardize continuous variables (z-scores)
    foreach var in age income {
        capture {
            egen `var'_std = std(`var')
            label variable `var'_std "Standardized `var'"
        }
    }
}

* %%
// Create interaction terms and polynomial terms if relevant variables exist
capture {
    if _rc == 0 {
        generate female_x_age = female * age
        label variable female_x_age "Female × Age interaction"

        generate female_x_income = female * log_income if !missing(female, log_income)
        label variable female_x_income "Female × Log income interaction"

        // Create polynomial terms for analysis
        generate age_squared = age^2
        label variable age_squared "[Derived] Age squared for quadratic models"
    }
}

* %%
// Create quantile/percentile variables
capture {
    // Income quintiles
    xtile income_quintile = income, nq(5)
    label variable income_quintile "Income quintile (1=lowest, 5=highest)"

    // Education categories (if education variable exists)
    capture {
        generate education_level = .
        replace education_level = 1 if education <= 8
        replace education_level = 2 if education > 8 & education <= 12
        replace education_level = 3 if education > 12 & education <= 16
        replace education_level = 4 if education > 16 & !missing(education)

        label define educ_lbl 1 "Primary" 2 "Secondary" 3 "Tertiary" 4 "Graduate"
        label values education_level educ_lbl
        label variable education_level "Education level categories"
    }
}


/*==============================================================================
                            SAMPLE RESTRICTIONS
==============================================================================*/

// Create analysis sample indicator
generate analysis_sample = 1

// Apply sample restrictions (modify as needed for your analysis)
capture {
    // Restrict to specific age range
    replace analysis_sample = 0 if age < 18 | age > 80

    // Exclude extreme outliers
    replace analysis_sample = 0 if outlier_income == 1

    // Require non-missing key variables
    replace analysis_sample = 0 if missing(age, income)
}

label variable analysis_sample "1 if included in main analysis sample"

// Report sample restrictions
count if analysis_sample == 1
local analysis_n = r(N)
count
local total_n = r(N)
local excluded = `total_n' - `analysis_n'

* %%
di _n(2) "{hline 60}"
di "SAMPLE RESTRICTIONS SUMMARY"
di "{hline 60}"
di "Total observations: " `total_n'
di "Analysis sample: " `analysis_n'
di "Excluded observations: " `excluded'
di "Exclusion rate: " %4.1f (`excluded'/`total_n'*100) "%"
di "{hline 60}"

* %%
/*==============================================================================
                            CREATE ANALYSIS SUBSAMPLES
==============================================================================*/

// Create subsample indicators for robustness checks
capture {
    // Gender-specific subsamples
    generate male_sample = (analysis_sample == 1 & female == 0)
    generate female_sample = (analysis_sample == 1 & female == 1)

    label variable male_sample "1 if in male analysis subsample"
    label variable female_sample "1 if in female analysis subsample"

    // Age-based subsamples
    generate young_sample = (analysis_sample == 1 & age < 40)
    generate old_sample = (analysis_sample == 1 & age >= 40)

    label variable young_sample "1 if in young (age<40) subsample"
    label variable old_sample "1 if in old (age>=40) subsample"
}

* %%
/*==============================================================================
                            FINAL DATA CHECKS
==============================================================================*/

// Describe final dataset
describe

// Summary statistics for key variables
summarize if analysis_sample == 1

// Check for perfect multicollinearity
capture {
    correlate age income female if analysis_sample == 1
}

// Verify no missing values in key variables for analysis sample
foreach var of varlist age income female {
    capture {
        count if missing(`var') & analysis_sample == 1
        if r(N) > 0 {
            di "Warning: `var' has missing values in analysis sample"
        }
    }
}

* %%
/*==============================================================================
                            SAVE ANALYSIS DATA
==============================================================================*/

// Add data signature for integrity checking
datasignature set, reset

// Sort data
sort id

// Save final analysis dataset
save "${data_final}/analysis_data.dta", replace

// Create codebook for documentation
capture {
    codebook, compact
}

* %%
di _n(2) "{hline 60}"
di "DATA PREPARATION COMPLETED"
di "Final analysis sample: " `analysis_n' " observations"
di "Output saved to: ${data_final}/analysis_data.dta"
di "{hline 60}"

* %%
// Close log
log close

/*==============================================================================
                            END OF FILE
==============================================================================*/
