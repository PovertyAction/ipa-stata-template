# DIME Analytics Stata Coding Standards

This reference provides the complete DIME Analytics Stata coding guide for writing
clean, maintainable, and reproducible Stata code.

## Code Structure

Good code has three elements:

1. **Structure**: File organization and project layout
2. **Syntax**: Readable mechanics and proper command usage
3. **Style**: Consistent formatting conventions

The overarching rule: the most important recommendation is to ensure that the style
used for code is *consistent* throughout a project.

## File Organization

### Master Do-File Structure

```stata
* ==============================================================================
* MASTER DO-FILE: [Project Name]
* ==============================================================================
* Purpose: Controls all data processing and analysis
* Author: [Author Name]
* Created: [Date]
* Last Modified: [Date]
* ==============================================================================

* ----------------------
* 1. Setup
* ----------------------

clear all
set more off
version 17.0

* Set root directory (user-specific)
if "`c(username)'" == "user1" {
    global root "C:/Users/user1/project"
}
else if "`c(username)'" == "user2" {
    global root "/Users/user2/project"
}
else {
    display as error "Username not recognized. Add your path."
    exit 1
}

* Define global paths
global data     "$root/data"
global raw      "$data/raw"
global clean    "$data/clean"
global output   "$root/output"
global scripts  "$root/scripts"
global logs     "$root/logs"

* Start log file
cap log close
log using "$logs/master_`c(current_date)'.log", replace

* ----------------------
* 2. Run Scripts
* ----------------------

* Import and clean data
run "$scripts/01_import.do"
run "$scripts/02_clean.do"
run "$scripts/03_construct.do"

* Analysis
run "$scripts/04_descriptives.do"
run "$scripts/05_regressions.do"

* Output
run "$scripts/06_tables.do"
run "$scripts/07_figures.do"

* ----------------------
* 3. Wrap Up
* ----------------------

log close
display "Master do-file completed successfully on `c(current_date)' at `c(current_time)'"
```

### Individual Do-File Structure

```stata
* ==============================================================================
* Script: [filename].do
* Purpose: [One sentence description]
* Input: [List input files]
* Output: [List output files]
* Author: [Name]
* Created: [Date]
* ==============================================================================

* ----------------------
* Setup
* ----------------------

* Verify master do-file has been run
capture confirm global root
if _rc != 0 {
    display as error "Run master.do first to set up globals"
    exit 1
}

* ----------------------
* Main Code
* ----------------------

[Code here]

* ----------------------
* Export
* ----------------------

save "$clean/output_file.dta", replace
```

## Command Abbreviations Reference

### Safe to Abbreviate (3+ characters)

| Full Command | Abbreviation | Usage |
| ------------- | -------------- | ------- |
| generate | gen | Create new variables |
| regress | reg | Linear regression |
| label | lab | Variable/value labels |
| summarize | sum | Summary statistics |
| tabulate | tab | Frequency tables |
| bysort | bys | By-group operations |
| quietly | qui | Suppress output |
| noisily | noi | Show output |
| capture | cap | Trap errors |
| forvalues | forv | Numeric loops |
| program | prog | Define programs |
| histogram | hist | Histograms |
| twoway | tw | Two-way graphs |
| display | di | Print to console |

### Never Abbreviate

| Command | Reason |
| --------- | -------- |
| local | Core macro command |
| global | Core macro command |
| save | Data loss risk |
| merge | Complex syntax |
| append | Complex syntax |
| sort | Data order critical |
| drop | Data loss risk |
| keep | Data loss risk |
| rename | Variable management |
| replace | Data modification |
| assert | Defensive programming |

## Whitespace and Formatting

### Indentation Rules

- Use 4 spaces per indentation level (not tabs)
- Indent all code within loops and conditionals
- Align related assignment statements

```stata
* Good: Consistent 4-space indentation
foreach var of varlist income expenditure savings {
    replace `var' = . if `var' < 0
    replace `var' = . if `var' > 1000000

    if ("`var'" == "income") {
        label var `var' "Monthly income (cleaned)"
    }
    else {
        label var `var' "`var' (cleaned)"
    }
}

* Good: Aligned assignments
local sample_size    = 1000
local treatment_rate = 0.5
local control_rate   = 0.5
```

### Spacing Around Operators

```stata
* Good: Spaces around operators
gen log_income = log(income + 1)
gen total = income + expenditure - savings
gen ratio = income / expenditure

* Exception: No space around ^ (exponent)
gen income_sq = income^2
gen income_cu = income^3

* Good: Spaces in expressions
replace status = 1 if (age >= 18) & (age <= 65)
keep if (treatment == 1) | (treatment == 0)
```

## Conditional Expression Standards

### Explicit Conditions

```stata
* Good: Explicit comparisons
if (treatment == 1) {
    gen treated = 1
}

keep if (age >= 18) & (age <= 65)
drop if (status == 0)

* Bad: Implicit truth testing
if treatment {  // Unclear
    ...
}
keep if age >= 18 & age <= 65  // Missing parentheses
```

### Missing Value Handling

```stata
* Good: Use missing() function
drop if missing(respondent_id)
replace income = 0 if missing(income) & employed == 0

* Good: Explicit extended missing checks
keep if !missing(age) | inlist(age, .d, .r)

* Bad: Comparison with .
drop if respondent_id >= .  // Unclear
replace income = 0 if income == .  // Misses extended missing
```

### Negation

```stata
* Good: Use ! for negation
keep if !missing(income)
drop if !(treatment == 1 | treatment == 0)

* Bad: Use ~ for negation
keep if ~missing(income)  // Less common, avoid
```

## Loop Best Practices

### Descriptive Loop Variables

```stata
* Good: Descriptive loop variables
foreach outcome in income expenditure savings {
    reg `outcome' treatment, vce(cluster village)
}

foreach wave in baseline midline endline {
    use "$data/`wave'.dta", clear
    ...
}

forvalues year = 2015/2020 {
    gen growth_`year' = (gdp_`year' - gdp_`=`year'-1') / gdp_`=`year'-1'
}

* Acceptable: i/j for pure iteration
forvalues i = 1/10 {
    gen var`i' = runiform()
}

* Bad: Single letter for meaningful iteration
foreach x in maize rice wheat {  // Use 'crop' instead
    ...
}
```

### Nested Loops

```stata
* Good: Clear nesting with descriptive names
foreach region in north south east west {
    foreach year in 2018 2019 2020 {
        use "$data/`region'_`year'.dta", clear

        * Process data
        gen region_code = "`region'"
        gen survey_year = `year'

        save "$clean/`region'_`year'_clean.dta", replace
    }
}
```

## Line Breaking with ///

### When to Break Lines

Break lines when they exceed ~80 characters:

```stata
* Long regression
regress income ///
    age age_sq ///
    i.education ///
    i.region ///
    household_size ///
    if (sample == 1) & (year == 2020), ///
    vce(cluster village_id)

* Long graph command
graph twoway ///
    (scatter income education, mcolor(blue) msize(small)) ///
    (lfit income education, lcolor(red) lwidth(medium)), ///
    title("Income by Education Level") ///
    subtitle("Survey Year 2020") ///
    xtitle("Years of Education") ///
    ytitle("Monthly Income (USD)") ///
    legend(order(1 "Observed" 2 "Fitted")) ///
    note("Source: Household Survey 2020")
```

### Breaking at Meaningful Points

```stata
* Good: Break at logical boundaries
merge 1:1 hhid ///
    using "$data/treatment.dta", ///
    keepusing(treatment treatment_date) ///
    nogenerate

* Good: Align options
eststo: regress income treatment, ///
    vce(cluster village_id) ///
    absorb(district)
```

## Macro Usage

### Local vs Global

```stata
* Global: Project-wide settings (define in master only)
global data    "$root/data"
global alpha   0.05
global seed    12345

* Local: Script-specific values
local outcomes  income expenditure savings
local controls  age education household_size
local n_bootstrap 1000

* Good: Use locals for temporary values
qui count if treatment == 1
local n_treated = r(N)
display "Number treated: `n_treated'"
```

### Macro Naming

```stata
* Good: Descriptive macro names
local outcome_vars     income expenditure savings
local control_vars     age education hh_size
local sample_restrict  (age >= 18) & (age <= 65)
local cluster_var      village_id

* Use in commands
regress `outcome_vars' treatment `control_vars' ///
    if `sample_restrict', ///
    vce(cluster `cluster_var')
```

## String Functions

### Common String Operations

```stata
* Trim whitespace
replace name = strtrim(name)

* Proper case
replace name = strproper(name)

* Upper/lower case
replace code = strupper(code)
replace email = strlower(email)

* Substring
gen prefix = substr(id, 1, 3)

* String length
gen name_length = strlen(name)

* Find and replace
replace text = subinstr(text, "old", "new", .)

* Regular expressions (Stata 14+)
gen is_email = regexm(email, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
```

## Date Handling

### Date Conversions

```stata
* String to date
gen survey_date = date(date_str, "DMY")
format survey_date %td

* Components
gen year = year(survey_date)
gen month = month(survey_date)
gen day = day(survey_date)

* Date arithmetic
gen days_since = today() - survey_date
gen months_since = mofd(today()) - mofd(survey_date)

* Create date from components
gen date_new = mdy(month, day, year)
```

## Program Definition

### Custom Program Structure

```stata
* Define program with proper structure
capture program drop my_summary
program define my_summary, rclass
    syntax varlist [if] [in]

    marksample touse

    foreach var of local varlist {
        qui summarize `var' if `touse'
        display "`var': mean = " %9.3f r(mean) ", sd = " %9.3f r(sd)
    }

    return scalar n_vars = wordcount("`varlist'")
end

* Usage
my_summary income expenditure if age >= 18
```

## Output and Export

### Table Export with estout

```stata
* Store regression results
eststo clear
eststo m1: reg income treatment
eststo m2: reg income treatment age education
eststo m3: reg income treatment age education i.region

* Export to LaTeX
esttab m1 m2 m3 using "$output/tables/regression.tex", ///
    replace ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Effect of Treatment on Income") ///
    mtitles("Basic" "Controls" "Full") ///
    label ///
    notes("Standard errors in parentheses")
```

### Graph Export

```stata
* Standard graph export
graph export "$output/figures/figure1.png", replace width(1200)
graph export "$output/figures/figure1.pdf", replace

* Multiple formats
local figname "income_distribution"
graph export "$output/figures/`figname'.png", replace width(1200)
graph export "$output/figures/`figname'.pdf", replace
graph export "$output/figures/`figname'.eps", replace
```

## Version Control Considerations

### Avoid in Committed Code

- Hard-coded user paths (use conditional globals)
- Temporary debugging code
- Commented-out alternative approaches (use version control)
- Machine-specific settings

### Include in Committed Code

- Clear header with purpose, author, date
- Explicit version requirements
- All dependencies documented
- Reproducible random seeds

```stata
* Good: Reproducible random operations
set seed 12345
sample 10

* Document dependencies in master
* Required packages: ietoolkit, estout, fre
foreach pkg in ietoolkit estout fre {
    capture which `pkg'
    if _rc {
        ssc install `pkg'
    }
}
```
