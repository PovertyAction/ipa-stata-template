# Missing Value Conventions and Handling

This reference documents IPA's extended missing value system and best practices
for handling missing data in Stata.

## Stata Missing Value System

### Standard Missing Value

Stata uses `.` (period) as the standard missing value for numeric variables.

```stata
* Standard missing
replace income = . if income < 0

* Check for missing
count if missing(income)
list id if income == .
```

### Extended Missing Values

Stata supports 26 extended missing values: `.a` through `.z`

These are ordered: `. < .a < .b < ... < .z`

```stata
* Extended missing values are greater than any number
display 999999999 < .    // Returns 1 (true)
display . < .a           // Returns 1 (true)
display .a < .z          // Returns 1 (true)
```

## IPA Missing Value Conventions

### Standard Codes

IPA uses the following standardized coding system:

| Raw Code | Stata Missing | Meaning | Description |
| ---------- | -------------- | --------- | ------------- |
| -99 | .d | Don't know | Respondent doesn't know the answer |
| -98 | .r | Refused | Respondent refused to answer |
| -97 | .n | Not applicable | Question not applicable to respondent |
| -96 | .s | Skipped | Question was skipped (programming error or skip pattern) |
| -95 | .o | Other | Other type of missing (specify in notes) |

### Rationale for Extended Missing

Using extended missing values instead of a single `.` preserves information about
*why* data is missing, which can be important for:

1. **Data quality assessment**: High refusal rates may indicate sensitive questions
2. **Analysis decisions**: "Don't know" vs "Refused" may warrant different treatment
3. **Survey improvement**: Patterns of skipped questions reveal survey issues
4. **Transparency**: Distinguishes true missing from structural missing

## Converting Raw Data to Extended Missing

### Basic Conversion

```stata
* Individual variable
replace income = .d if income == -99
replace income = .r if income == -98
replace income = .n if income == -97
replace income = .s if income == -96
replace income = .o if income == -95

* Multiple variables
foreach var of varlist income expenditure savings {
    replace `var' = .d if `var' == -99
    replace `var' = .r if `var' == -98
    replace `var' = .n if `var' == -97
    replace `var' = .s if `var' == -96
    replace `var' = .o if `var' == -95
}
```

### Using mvdecode

The `mvdecode` command provides a more efficient approach:

```stata
* Single variable
mvdecode income, mv(-99=.d \ -98=.r \ -97=.n \ -96=.s \ -95=.o)

* All variables
mvdecode _all, mv(-99=.d \ -98=.r \ -97=.n \ -96=.s \ -95=.o)

* Specific variables
mvdecode income expenditure savings, mv(-99=.d \ -98=.r \ -97=.n)
```

## Checking for Missing Values

### Using the missing() Function

```stata
* Check for any missing (standard or extended)
count if missing(income)
list id if missing(income)

* Keep only non-missing
keep if !missing(income)
```

### Checking Specific Missing Types

```stata
* Check for specific extended missing
count if income == .d
count if income == .r

* Check for any extended missing
count if income >= .a & income <= .z

* Check for standard missing only
count if income == .
```

### Missing Value Patterns

```stata
* Summary of missing values
misstable summarize

* Detailed patterns
misstable patterns, frequency

* Missing by variable
foreach var of varlist income expenditure savings {
    display "`var':"
    count if `var' == .
    count if `var' == .d
    count if `var' == .r
    count if `var' == .n
}
```

## Creating Missing Value Summary Tables

### Basic Summary

```stata
* Count by missing type
gen byte mv_type = .
replace mv_type = 0 if !missing(income)
replace mv_type = 1 if income == .
replace mv_type = 2 if income == .d
replace mv_type = 3 if income == .r
replace mv_type = 4 if income == .n
replace mv_type = 5 if income == .s

label define mv_type_lbl ///
    0 "Non-missing" ///
    1 "Missing (standard)" ///
    2 "Don't know" ///
    3 "Refused" ///
    4 "Not applicable" ///
    5 "Skipped"
label values mv_type mv_type_lbl

tab mv_type
```

### Comprehensive Missing Report

```stata
* Program to summarize missing values
capture program drop missing_report
program define missing_report
    syntax varlist

    display _n "Missing Value Report"
    display "{hline 60}"
    display %20s "Variable" %10s "N" %10s "Don't Know" %10s "Refused" %10s "N/A"
    display "{hline 60}"

    foreach var of local varlist {
        qui count if !missing(`var')
        local n = r(N)
        qui count if `var' == .d
        local dk = r(N)
        qui count if `var' == .r
        local ref = r(N)
        qui count if `var' == .n
        local na = r(N)

        display %20s "`var'" %10.0f `n' %10.0f `dk' %10.0f `ref' %10.0f `na'
    }
    display "{hline 60}"
end

missing_report income expenditure savings
```

## Handling Missing Values in Analysis

### Listwise Deletion

Stata automatically excludes observations with missing values:

```stata
* Regression excludes missing observations
regress income age education
display "N used: " e(N)

* Force explicit handling
regress income age education if !missing(income, age, education)
```

### Indicator Variable Approach

Create indicators for missing values when missingness may be informative:

```stata
* Create missing indicator
gen income_missing = missing(income)

* Impute for estimation (e.g., mean imputation)
egen income_mean = mean(income)
gen income_imputed = cond(missing(income), income_mean, income)

* Include in regression
regress outcome income_imputed income_missing other_controls
```

### Conditional Analysis by Missing Type

```stata
* Analyze only "true" missing (excluding N/A)
regress income age education if income != .n

* Separate analysis excluding refusals
regress income age education if income != .r
```

## Common Pitfalls

### Comparison Operators

Missing values are greater than any number:

```stata
* WRONG: This keeps missing values!
keep if income > 0

* CORRECT: Explicitly handle missing
keep if income > 0 & !missing(income)
```

### Arithmetic with Missing

Missing values propagate through calculations:

```stata
* If income is missing, total will be missing
gen total = income + expenditure

* To treat missing as zero (use with caution)
gen total = cond(missing(income), 0, income) + cond(missing(expenditure), 0, expenditure)
```

### Counting Non-Missing

```stata
* Count non-missing values
egen n_nonmiss = rownonmiss(income expenditure savings)

* Count specific values across variables
egen n_refused = anycount(income expenditure savings), values(.r)
```

## Extended Missing in Categorical Variables

### Labeling Extended Missing

```stata
* Include extended missing in value labels
label define income_cat_lbl ///
    1 "Low (<$100)" ///
    2 "Medium ($100-500)" ///
    3 "High (>$500)" ///
    .d "Don't know" ///
    .r "Refused"

label values income_cat income_cat_lbl

* Tabulate including extended missing
tab income_cat, missing
```

### Skip Pattern Documentation

```stata
* Document skip patterns with .n
* Q5 only asked if Q4 == 1
replace q5 = .n if q4 != 1

notes q5: "Not applicable (.n) when Q4 != 1 (not employed)"
```

## Best Practices

### Documentation

1. Always document missing value conventions in codebook
2. Note which variables use extended missing values
3. Explain when .n (not applicable) is used
4. Record patterns of high missingness

### Analysis Decisions

1. Report missing value rates in descriptive statistics
2. Consider whether missing data mechanism is MCAR, MAR, or MNAR
3. Perform sensitivity analyses with different missing data handling
4. Be transparent about how missing data affects sample size

### Data Quality

1. Investigate variables with high "don't know" rates
2. Check if refusal patterns are systematic
3. Verify skip patterns produce expected .n values
4. Flag unusual missing value patterns

## Converting Back for Export

When exporting to other software that doesn't support extended missing:

```stata
* Convert extended missing to numeric codes for export
foreach var of varlist income expenditure savings {
    replace `var' = -99 if `var' == .d
    replace `var' = -98 if `var' == .r
    replace `var' = -97 if `var' == .n
    replace `var' = -96 if `var' == .s
    replace `var' = -95 if `var' == .o
}

export delimited using "$output/data_export.csv", replace
```

Or using `mvencode`:

```stata
mvencode _all, mv(.d=-99 \ .r=-98 \ .n=-97 \ .s=-96 \ .o=-95)
```
