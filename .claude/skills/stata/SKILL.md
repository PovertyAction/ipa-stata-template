---
name: stata
description: This skill should be used when users need to write, review, or debug Stata code for data cleaning and analysis. Use this skill for tasks involving data import, variable management, data documentation, merging/appending datasets, creating analysis variables, and following IPA/DIME Analytics coding standards. This skill should be invoked when working with .do files, .dta files, or any Stata-related data processing tasks.
---

# Stata Data Cleaning and Analysis Skill

This skill provides comprehensive guidance for writing high-quality Stata code
following IPA (Innovations for Poverty Action) and DIME Analytics best practices.
It covers the complete data cleaning pipeline from raw data import to analysis-ready
datasets.

## Core Principles

### Reproducibility

All data cleaning code must be:

- **Reproducible**: Code should produce identical outputs when run multiple times
- **Defensive**: Code should alert users if data doesn't meet expected conditions
- **Well-documented**: Code should explain *why* decisions were made, not just *what* the code does

### The Four-Stage Data Flow

Data transitions through sequential stages:

1. **Import**: Combine collected data into Stata format, apply corrections, remove duplicates
2. **Deidentify**: Remove personally identifying information as early as possible
3. **Clean**: Standardize content, formats, and encoding; verify consistency
4. **Create Outcomes**: Build analysis variables through merging and appending

## Stata Coding Standards

### Boilerplate Code

Begin every do-file with proper setup:

```stata
* ==============================================================================
* Project: [Project Name]
* Purpose: [Brief description of what this do-file does]
* Author: [Author Name]
* Created: [Date]
* ==============================================================================

* Clear environment and set version
clear all
set more off
version 17.0  // Use project's minimum Stata version

* Set maxvar conservatively - increase only if genuinely needed
* High defaults can mask inefficient code patterns
set maxvar 5000

* Define global paths (set in master do-file)
* global root     "C:/Users/username/project" (Recommended: set as environmental variable, either .env or PATH)
* global data     "$root/data"
* global output   "$root/output"
```

If using ieboilstart from ietoolkit:

```stata
ieboilstart, version(17.0)
`r(version)'
```

### File Path Conventions

- Always use forward slashes: `"$data/raw/survey.dta"`
- Enclose paths in double quotes
- Use absolute paths via global macros defined in master files
- Include file extensions (`.dta`, `.csv`, `.do`)
- Use lowercase filenames with dashes: `survey-baseline.dta`
- **Never use `cd`** to prevent unintended file overwrites

```stata
* Good - use global paths
use "$data/raw/survey.dta", clear
save "$data/clean/survey_clean.dta", replace

* Bad - using cd
cd "C:/Users/username/project/data"
use survey.dta  // Risky!
```

### Variable Naming Conventions

Variable names should be:

- Lowercase with underscores: `household_income`, `resp_age`
- Descriptive and consistent across datasets
- Prefixed by category when helpful:
    - `hh_*` for household variables
    - `ind_*` for individual variables
    - `bl_*` for baseline, `el_*` for endline
    - `d_*` for dummy/indicator variables
    - `n_*` for count variables

```stata
* Good variable naming
rename income hh_income_monthly
gen d_employed = (employment_status == 1)
gen n_children = number_of_children

* Bad - unclear or inconsistent
rename v1 x
gen emp = (empstat == 1)
```

### Command Abbreviations

Use only standard three-character minimum abbreviations:

**Accepted abbreviations:**

- `gen` (generate), `reg` (regress), `lab` (label)
- `sum` (summarize), `tab` (tabulate), `bys` (bysort)
- `qui` (quietly), `noi` (noisily), `cap` (capture)
- `forv` (forvalues), `prog` (program), `hist` (histogram)
- `tw` (twoway), `di` (display)

**Never abbreviate:**

- `local`, `global`, `save`, `merge`, `append`, `sort`, `drop`, `keep`

```stata
* Good
gen income_log = log(income)
qui sum income, detail
forv i = 1/10 {
    ...
}

* Bad - dangerous abbreviations
g inc = log(inc)  // Too short, unclear
sa mydata         // Never abbreviate save
```

### Commenting Standards

Use three comment types appropriately:

```stata
/* ==============================================================================
   SECTION: Data Import and Initial Cleaning
   This section imports raw survey data and performs initial quality checks.
   ============================================================================== */

* Import raw data
import delimited "$data/raw/survey.csv", clear

// Keep only valid observations
drop if missing(respondent_id)  // Remove incomplete records
```

- `/* */` for multi-line documentation of files or large sections
- `*` for single-line task documentation
- `//` for inline comments on specific lines

Prefer self-documenting code that explains *why* decisions were made.

### Whitespace and Indentation

- Indent loop/conditional blocks by 4 spaces per nesting level
- Use spaces instead of tabs for consistent display
- Align related commands vertically for readability

```stata
* Good indentation
foreach var of varlist income expenditure savings {
    replace `var' = . if `var' < 0
    label var `var' "Cleaned `var' (negative values removed)"
}

if (treatment == 1) {
    gen treated = 1
}
else {
    gen treated = 0
}
```

### Conditional Expressions

- Enclose all conditions in parentheses: `if (gender == 1)`
- Use `!` for negation, not `~`
- Use explicit truth checks: `if (var == 1)` not `if var`
- Use `missing(var)` function instead of `>= .`
- Prefer `if-else` statements to communicate mutual exclusivity

```stata
* Good - explicit and clear
replace status = 1 if (employed == 1) & !missing(income)
keep if (age >= 18) & (age <= 65)
drop if missing(respondent_id)

* Bad - implicit or unclear
replace status = 1 if employed & income
keep if age >= 18 & age <= 65
drop if respondent_id >= .
```

### Line Breaking

Break lines around 80 characters using `///`:

```stata
regress income ///
    age i.education i.region ///
    household_size ///
    if (sample == 1), ///
    vce(cluster village_id)

graph twoway ///
    (scatter income education) ///
    (lfit income education), ///
    title("Income by Education Level") ///
    xtitle("Years of Education") ///
    ytitle("Monthly Income (USD)")
```

Never use `#delimit` in analytical code.

### Loop Indexing

Use descriptive index names beyond single letters:

```stata
* Good - descriptive loop variables
foreach crop in maize rice wheat cassava {
    gen yield_`crop' = production_`crop' / area_`crop'
}

foreach wave in baseline midline endline {
    merge 1:1 hhid using "$data/`wave'.dta"
}

* Reserve i/j only for iteration counters
forvalues i = 1/10 {
    gen var`i' = ...
}
```

## Data Cleaning Workflow

### Stage 1: Data Import

```stata
* ==============================================================================
* Import and Initial Checks
* ==============================================================================

* Import data
import delimited "$data/raw/survey.csv", clear varnames(1)

* Basic data inspection
describe
codebook, compact

* Check for duplicates on key variable
duplicates report respondent_id
duplicates tag respondent_id, gen(dup_flag)
list respondent_id if dup_flag > 0

* Assert uniqueness (defensive programming)
isid respondent_id, missok
```

### Stage 2: Variable Management

```stata
* ==============================================================================
* Variable Cleaning and Standardization
* ==============================================================================

* Rename variables to consistent naming convention
rename (q1 q2 q3) (resp_age resp_gender resp_education)

* Recode missing values using IPA extended missing conventions
* .d = don't know, .r = refused, .n = not applicable, .s = skipped
replace income = .d if income == -99
replace income = .r if income == -98
replace income = .n if income == -97

* Clean string variables
replace name = strtrim(name)
replace name = strproper(name)

* Validate value ranges
assert inrange(age, 0, 120) if !missing(age)
assert inlist(gender, 1, 2) if !missing(gender)

* Create derived variables
gen age_group = .
replace age_group = 1 if inrange(age, 18, 29)
replace age_group = 2 if inrange(age, 30, 44)
replace age_group = 3 if inrange(age, 45, 59)
replace age_group = 4 if (age >= 60) & !missing(age)
```

### Stage 3: Data Documentation

```stata
* ==============================================================================
* Labels and Documentation
* ==============================================================================

* Variable labels
label var resp_age "Respondent age in years"
label var resp_gender "Respondent gender"
label var hh_income "Total household monthly income (USD)"

* Value labels
label define gender_lbl 1 "Male" 2 "Female"
label values resp_gender gender_lbl

label define age_group_lbl ///
    1 "18-29" ///
    2 "30-44" ///
    3 "45-59" ///
    4 "60+"
label values age_group age_group_lbl

* Add notes for complex variables
notes hh_income: "Includes all income sources. Converted from local currency using exchange rate of 1 USD = 100 LCU"
notes _dta: "Survey data cleaned on `c(current_date)'. Original file: survey_raw.csv"
```

### Stage 4: Data Aggregation

#### Merging Datasets

```stata
* ==============================================================================
* Merge household and individual data
* ==============================================================================

use "$data/clean/household.dta", clear

* Document pre-merge observation count
count
local pre_merge = r(N)

* Merge with treatment assignment
merge 1:1 hhid using "$data/admin/treatment.dta"

* Verify merge results
tab _merge
assert _merge != 2  // No unmatched using observations expected

* Keep matched observations
keep if _merge == 3
drop _merge

* Verify post-merge count
count
assert r(N) == `pre_merge'  // No observations should be lost
```

#### Appending Datasets

```stata
* ==============================================================================
* Append multiple survey rounds
* ==============================================================================

use "$data/clean/baseline.dta", clear
gen wave = 1

append using "$data/clean/midline.dta"
replace wave = 2 if missing(wave)

append using "$data/clean/endline.dta"
replace wave = 3 if missing(wave)

* Verify panel structure
label define wave_lbl 1 "Baseline" 2 "Midline" 3 "Endline"
label values wave wave_lbl

* Check for duplicates within waves
duplicates report hhid wave
```

#### Reshaping Data

```stata
* ==============================================================================
* Reshape wide to long
* ==============================================================================

* Original: income_2020 income_2021 income_2022
reshape long income_, i(hhid) j(year)
rename income_ income

* Reshape long to wide
reshape wide income, i(hhid) j(year)
```

## Defensive Programming

### Assert Statements

Use assertions to verify data integrity at critical points:

```stata
* Verify unique identifiers
isid hhid

* Check value ranges
assert inrange(age, 0, 120) if !missing(age)

* Verify no unexpected missing values
assert !missing(treatment) if sample == 1

* Check expected observation counts
count if treatment == 1
assert r(N) == 500

* Verify merge results
merge 1:1 hhid using treatment.dta
assert _merge != 2
```

### Capture and Error Handling

```stata
* Check if file exists before using
capture confirm file "$data/raw/survey.dta"
if _rc != 0 {
    display as error "File not found: $data/raw/survey.dta"
    exit 601
}

* Handle potential errors gracefully
capture drop temp_var
gen temp_var = ...
```

## Missing Value Conventions

### IPA Extended Missing Values

Use extended missing values to preserve information:

| Code | Meaning | Stata |
| ------ | --------- | ------- |
| -99 | Don't know | .d |
| -98 | Refused | .r |
| -97 | Not applicable | .n |
| -96 | Skipped | .s |
| -95 | Other missing | .o |

```stata
* Recode to extended missing values
mvdecode _all, mv(-99=.d \ -98=.r \ -97=.n \ -96=.s)

* Or manually
foreach var of varlist income expenditure {
    replace `var' = .d if `var' == -99
    replace `var' = .r if `var' == -98
    replace `var' = .n if `var' == -97
}
```

## Performance Optimization

### Working with Wide Data Efficiently

Before increasing `maxvar`, consider these alternatives:

1. **Load only needed columns**: Don't load entire surveys with 20k variables
2. **Reshape to long format**: Wide loops are slow; long operations are fast
3. **Modularize**: Clean one survey module at a time, not the entire survey

```stata
* GOOD: Load only the variables you need
use hhid income age education using "$data/raw/survey.dta", clear

* GOOD: Reshape to long before manipulating repeat groups
reshape long crop_yield crop_area, i(hhid) j(crop_id)
replace crop_yield = . if crop_yield < 0  // Fast: operates on single column

* BAD: Looping across wide repeat groups
forvalues i = 1/50 {
    replace crop_yield`i' = . if crop_yield`i' < 0  // Slow: 50 separate operations
}
```

When you truly need more variables (e.g., merging multiple wide datasets):

```stata
* Increase maxvar only in the specific do-file that needs it
set maxvar 10000  // Document why this is needed
```

### General Performance Tips

```stata
* Suppress output for faster execution
qui {
    forvalues i = 1/1000 {
        gen var`i' = ...
    }
}

* Use run instead of do in master files
run "$scripts/01_import.do"
run "$scripts/02_clean.do"

* Compress data to reduce file size
compress
```

## Quality Checks

### Data Quality Report

```stata
* Generate summary statistics
summarize, detail
tabstat income expenditure, stats(n mean sd min p25 p50 p75 max) columns(statistics)

* Check for outliers
egen income_std = std(income)
list hhid income if abs(income_std) > 3

* Missing value patterns
misstable summarize
misstable patterns, frequency
```

### Key Variable Verification

```stata
* Verify unique identifiers
duplicates report hhid
isid hhid

* Check categorical variable distributions
tab1 gender education region, missing

* Cross-tabulations for consistency
tab gender pregnant, missing
assert pregnant == . | pregnant == 0 if gender == 1
```

## Graph Standards

Use the IPA plot scheme when available:

```stata
* Set graph scheme
capture set scheme ipaplots
if _rc != 0 {
    set scheme s2color
}

* Standard graph syntax
graph twoway ///
    (scatter y x) ///
    (lfit y x), ///
    title("Title") ///
    xtitle("X Label") ///
    ytitle("Y Label") ///
    legend(order(1 "Data" 2 "Fitted"))

graph export "$output/figures/scatter_plot.png", replace width(1200)
```

## Common Packages

Install required packages via SSC:

```stata
* Core packages
ssc install ietoolkit    // DIME impact evaluation tools
ssc install iefieldkit   // Field data collection tools
ssc install repkit       // Reproducibility toolkit
ssc install estout       // Regression output tables

* Additional useful packages
ssc install fre          // Frequency tables
ssc install labutil      // Label utilities
ssc install distinct     // Count distinct values
```

## Linting with stata_linter

Run the World Bank DIME Analytics linter to check code quality:

```bash
# Using just command
just lint-stata

# Lint specific file
just lint-stata-file scripts/01_import.do
```

Common linting rules:

- Use proper indentation (4 spaces)
- Avoid deprecated commands
- Use explicit `if` conditions
- Avoid hard-coded file paths
- Use descriptive variable names

## Resources

- **IPA Data Cleaning Guide**: https://data.poverty-action.org/data-cleaning/
- **DIME Analytics Coding Guide**: https://worldbank.github.io/dime-data-handbook/coding.html
- **Stata Linter**: https://github.com/worldbank/stata-linter
- **ietoolkit Documentation**: https://dimewiki.worldbank.org/ietoolkit

## Reference Files

This skill includes detailed reference documentation:

- `references/coding_standards.md` - Complete DIME Analytics Stata coding standards
- `references/data_cleaning_checklist.md` - Step-by-step data cleaning checklist
- `references/missing_values.md` - IPA missing value conventions and handling
