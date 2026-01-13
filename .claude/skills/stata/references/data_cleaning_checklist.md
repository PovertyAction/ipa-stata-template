# Data Cleaning Checklist

This checklist provides a systematic approach to data cleaning following IPA and DIME
Analytics standards. Use this as a reference when cleaning survey or administrative data.

## Pre-Cleaning Setup

### Environment Setup

- [ ] Set up project directory structure
- [ ] Create master do-file with path globals
- [ ] Set appropriate Stata version
- [ ] Initialize log file
- [ ] Document data sources and dates

```stata
* Standard setup
clear all
set more off
version 17.0

* Paths (set in master.do)
global root     "[project_path]"
global data     "$root/data"
global raw      "$data/raw"
global clean    "$data/clean"
global scripts  "$root/scripts"

* Start log
cap log close
log using "$root/logs/cleaning_`c(current_date)'.log", replace
```

### Documentation

- [ ] Record original data source
- [ ] Document data collection dates
- [ ] Note any known data issues from field
- [ ] Create data dictionary or codebook

## Stage 1: Data Import

### File Import

- [ ] Import data in appropriate format (CSV, Excel, DTA)
- [ ] Verify all variables imported correctly
- [ ] Check for import errors or warnings
- [ ] Preserve original variable names initially

```stata
* Import data
import delimited "$raw/survey.csv", clear varnames(1)

* Or from Excel
import excel "$raw/survey.xlsx", sheet("data") firstrow clear

* Initial inspection
describe
list in 1/5
```

### Initial Data Inspection

- [ ] Count total observations
- [ ] List all variables and types
- [ ] Check for obvious import issues
- [ ] Identify key identifier variables

```stata
* Basic inspection
count
describe, short
codebook, compact

* Check data types
describe, fullnames
```

### Identifier Verification

- [ ] Identify unique identifier(s)
- [ ] Check for duplicates
- [ ] Investigate and resolve duplicates
- [ ] Assert uniqueness

```stata
* Check for duplicates
duplicates report respondent_id
duplicates list respondent_id

* Tag duplicates for investigation
duplicates tag respondent_id, gen(dup_flag)
list respondent_id name date if dup_flag > 0

* After resolving duplicates
drop dup_flag
isid respondent_id
```

## Stage 2: Variable Management

### Variable Renaming

- [ ] Rename variables to consistent convention
- [ ] Use lowercase with underscores
- [ ] Add meaningful prefixes
- [ ] Document original names

```stata
* Rename with documentation
* Original: Q1, Q2, Q3 -> resp_age, resp_gender, resp_education
rename (Q1 Q2 Q3) (resp_age resp_gender resp_education)

* Or systematically
rename q* resp_*
rename (resp_1 resp_2 resp_3) (resp_age resp_gender resp_education)
```

### String Variable Cleaning

- [ ] Trim whitespace
- [ ] Standardize case
- [ ] Remove special characters if needed
- [ ] Check for encoding issues

```stata
foreach var of varlist name district village {
    * Trim whitespace
    replace `var' = strtrim(`var')

    * Standardize case
    replace `var' = strproper(`var')

    * Remove extra spaces
    replace `var' = stritrim(`var')
}
```

### Numeric Variable Cleaning

- [ ] Convert string numbers to numeric
- [ ] Handle non-numeric entries
- [ ] Check for out-of-range values
- [ ] Identify outliers

```stata
* Convert string to numeric
destring income, replace force

* Check conversion results
count if missing(income)

* Check ranges
summarize income, detail
assert inrange(income, 0, 1000000) if !missing(income)
```

### Missing Value Recoding

- [ ] Identify missing value codes in raw data
- [ ] Recode to Stata missing values
- [ ] Use extended missing values appropriately
- [ ] Document missing value conventions

```stata
* IPA missing value conventions
* -99 = Don't know (.d)
* -98 = Refused (.r)
* -97 = Not applicable (.n)
* -96 = Skipped (.s)
* -95 = Other missing (.o)

foreach var of varlist income expenditure savings {
    replace `var' = .d if `var' == -99
    replace `var' = .r if `var' == -98
    replace `var' = .n if `var' == -97
    replace `var' = .s if `var' == -96
    replace `var' = .o if `var' == -95
}

* Or using mvdecode
mvdecode _all, mv(-99=.d \ -98=.r \ -97=.n \ -96=.s \ -95=.o)
```

### Categorical Variable Recoding

- [ ] Define value labels
- [ ] Apply labels to variables
- [ ] Verify label accuracy
- [ ] Check for unlabeled values

```stata
* Define labels
label define yesno_lbl 0 "No" 1 "Yes"
label define gender_lbl 1 "Male" 2 "Female" 3 "Other"
label define education_lbl ///
    1 "No formal education" ///
    2 "Primary incomplete" ///
    3 "Primary complete" ///
    4 "Secondary incomplete" ///
    5 "Secondary complete" ///
    6 "Tertiary"

* Apply labels
label values employed yesno_lbl
label values gender gender_lbl
label values education education_lbl

* Verify
tab gender, missing
tab education, missing
```

### Date Variable Processing

- [ ] Identify date variables
- [ ] Convert to Stata date format
- [ ] Apply appropriate display format
- [ ] Calculate derived date variables

```stata
* Convert string dates
gen survey_date = date(date_string, "DMY")
format survey_date %td

* Extract components
gen survey_year = year(survey_date)
gen survey_month = month(survey_date)

* Calculate intervals
gen age_at_survey = (survey_date - birth_date) / 365.25
gen days_since_treatment = survey_date - treatment_date
```

## Stage 3: Data Validation

### Range Checks

- [ ] Define valid ranges for each variable
- [ ] Flag out-of-range values
- [ ] Investigate and correct/set to missing
- [ ] Document corrections made

```stata
* Check ranges
assert inrange(age, 0, 120) if !missing(age)
assert inrange(household_size, 1, 50) if !missing(household_size)

* Flag issues
gen flag_age = (age < 0 | age > 120) & !missing(age)
gen flag_hhsize = (household_size < 1 | household_size > 50) & !missing(household_size)

list respondent_id age if flag_age
list respondent_id household_size if flag_hhsize
```

### Logical Consistency Checks

- [ ] Check skip patterns
- [ ] Verify conditional logic
- [ ] Check cross-variable consistency
- [ ] Flag inconsistencies

```stata
* Skip pattern checks
assert missing(pregnancy_status) if gender == 1  // Males shouldn't answer
assert !missing(spouse_name) if married == 1     // Married should have spouse

* Cross-variable consistency
assert n_children <= household_size
assert income >= 0 | missing(income)

* Age consistency
assert age >= 18 if married == 1  // Minimum marriage age
```

### Outlier Detection

- [ ] Calculate standardized values
- [ ] Identify statistical outliers
- [ ] Investigate outliers
- [ ] Document decisions on outliers

```stata
* Statistical outliers (>3 SD)
egen income_mean = mean(income)
egen income_sd = sd(income)
gen income_std = (income - income_mean) / income_sd

gen outlier_income = abs(income_std) > 3 & !missing(income_std)
list respondent_id income if outlier_income

* Investigate
summarize income if !outlier_income, detail

* Winsorize if appropriate
winsor2 income, cuts(1 99) replace
```

## Stage 4: Documentation

### Variable Labels

- [ ] Add descriptive labels to all variables
- [ ] Include units where applicable
- [ ] Note transformations applied
- [ ] Ensure labels are informative

```stata
* Variable labels
label var resp_age "Respondent age in years"
label var hh_income_monthly "Household monthly income (USD)"
label var log_income "Log of monthly income"
label var d_employed "=1 if currently employed"
label var n_children "Number of children in household"
```

### Variable Notes

- [ ] Add notes for complex variables
- [ ] Document data sources
- [ ] Record cleaning decisions
- [ ] Note known issues

```stata
* Variable notes
notes income: "Self-reported monthly income. Converted from local currency at rate of 1 USD = 100 LCU"
notes age: "Calculated from date of birth. Some respondents reported age directly when DOB unknown"
notes treatment: "Random assignment conducted at village level on 2020-01-15"

* Dataset notes
notes _dta: "Cleaned household survey data"
notes _dta: "Original file: survey_raw_2020.csv"
notes _dta: "Cleaned by [Name] on `c(current_date)'"
notes _dta: "N duplicates removed: 15"
```

### Codebook Generation

- [ ] Generate codebook for cleaned data
- [ ] Export variable documentation
- [ ] Create summary statistics file

```stata
* Generate codebook
codebook, compact

* Detailed codebook
codebook, all

* Export to text file
log using "$output/codebook.txt", text replace
describe
codebook
log close
```

## Stage 5: Final Verification

### Completeness Check

- [ ] Verify expected observation count
- [ ] Check missing value patterns
- [ ] Confirm all variables cleaned
- [ ] Review final data structure

```stata
* Observation count
count
display "Final N = " r(N)

* Missing value summary
misstable summarize
misstable patterns, frequency

* Variable summary
describe
summarize
```

### Reproducibility Check

- [ ] Run cleaning code from scratch
- [ ] Verify identical output
- [ ] Check no external dependencies
- [ ] Test on different machine if possible

```stata
* Clear and re-run
clear all
run "$scripts/master.do"

* Compare output
use "$clean/final_data.dta", clear
cf _all using "$clean/final_data_previous.dta"
```

### Export Clean Data

- [ ] Save cleaned Stata file
- [ ] Compress data
- [ ] Add dataset label
- [ ] Document version

```stata
* Final save
label data "Cleaned Survey Data - Version 1.0"
compress
save "$clean/survey_clean_v1.dta", replace

* Optional: Save as CSV for other software
export delimited "$clean/survey_clean_v1.csv", replace
```

## Post-Cleaning Tasks

### Data Quality Report

- [ ] Generate summary statistics
- [ ] Create frequency tables for categoricals
- [ ] Document remaining data issues
- [ ] Archive cleaning log

```stata
* Summary statistics
estpost summarize income expenditure age household_size, detail
esttab using "$output/summary_stats.csv", cells("count mean sd min p25 p50 p75 max") replace

* Categorical summaries
foreach var in gender education employment_status {
    tab `var', missing
}
```

### Archive and Version Control

- [ ] Archive raw data (read-only)
- [ ] Version clean data appropriately
- [ ] Commit cleaning code
- [ ] Update README/documentation

### Handoff Documentation

- [ ] Document any remaining issues
- [ ] Note variables requiring special handling
- [ ] Provide data dictionary
- [ ] Brief next analyst on data
