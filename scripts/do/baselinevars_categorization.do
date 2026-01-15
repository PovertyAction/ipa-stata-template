
*%%
* ==============================================================================
* BASELINE VARIABLE IDENTIFICATION ALGORITHM
* ==============================================================================
* This code identifies two types of baseline variables:
* Type 1: Variables collected ONLY at baseline (no follow-up rounds)
* Type 2: Variables collected at baseline AND in other rounds
*
* Common suffixes for rounds: _1, _2, _3, _bl, _el, _ml, _0, _b, _f, etc.
* ==============================================================================

* Stata script to load baseline variable codebook for a specific study

clear all
cd ""
use ""
	
	global study_id "10001"  // List of study IDs to process
	*export codebook file
	ipacodebook _all using "ID`study_id'_codebook.xlsx", replace
	


foreach study_id in `study_ids' {
    
    di _n _n "{hline 80}"
    di "{bf:PROCESSING STUDY ID: `study_id'}"
    di "{hline 80}"
    
    * Check if codebook file exists
    cap confirm file "ID`study_id'_codebook.xlsx"
    if _rc != 0 {
        di as error "Codebook file not found for study `study_id', skipping..."
        continue
    }
    
    * Clear and import the codebook
    clear
    cap import excel "03_Data_Harmonization\02_Data\01_clean\01_codebook\ID`study_id'_codebook.xlsx", sheet("codebook") firstrow clear
    if _rc != 0 {
        di as error "Error importing codebook for study `study_id' (error code: " _rc "), skipping..."
        continue
    }
    
    * Check if variable column exists
    cap confirm variable variable
    if _rc != 0 {
        di as error "Variable 'variable' not found in codebook for study `study_id', skipping..."
        continue
    }

* Keep only the variable name column and rename for clarity
keep variable
rename variable varname

* Clean variable names and prepare for analysis
gen varname_lower = lower(varname)

* ==============================================================================
* STEP 1: Identify potential suffix patterns for rounds
* ==============================================================================

* Generate base variable name by removing common round suffixes
gen basevar = varname_lower

* Common suffix patterns (ordered by specificity)
local suffixes "_baseline _bl _el _ml _fl _endline _midline _followup"
local suffixes "`suffixes' _round1 _round2 _round3 _round4 _round5"
local suffixes "`suffixes' _r1 _r2 _r3 _r4 _r5 _wave1 _wave2 _wave3"
local suffixes "`suffixes' _w1 _w2 _w3 _t0 _t1 _t2 _t3 _t4"
local suffixes "`suffixes' _0 _1 _2 _3 _4 _5 _6 _7 _8 _9"
local suffixes "`suffixes' _b _f _m _e"
local suffixes "`suffixes' 0 1 2 3 4 5 6 7 8 9"

* Remove suffixes iteratively (most specific first)
foreach suffix in `suffixes' {
    replace basevar = regexr(basevar, "`suffix'$", "")
}

* Also handle prefix patterns (less common but possible)
local prefixes "bl_ el_ ml_ fl_ baseline_ endline_ midline_"
local prefixes "`prefixes' r1_ r2_ r3_ round1_ round2_ round3_"
local prefixes "`prefixes' w1_ w2_ w3_ wave1_ wave2_ wave3_"
local prefixes "`prefixes' t0_ t1_ t2_ t3_"

foreach prefix in `prefixes' {
    replace basevar = regexr(basevar, "^`prefix'", "")
}

* ==============================================================================
* STEP 2: Count how many versions of each base variable exist
* ==============================================================================

* Count occurrences of each base variable
bysort basevar: gen var_count = _N

* Create a grouping variable for each base variable
egen basevar_group = group(basevar)

* ==============================================================================
* STEP 3: Identify baseline indicators in variable names
* ==============================================================================

* Flag variables that explicitly indicate baseline in their name
gen is_baseline_named = 0

* Check for baseline indicators in variable name
* Include _1 as potential baseline (often represents first/baseline round)
replace is_baseline_named = 1 if regexm(varname_lower, "_bl$|_bl_|^bl_|_baseline|_0$|_t0|_1$|_r1$|_round1|_wave1|_w1$")

* Also check for specific baseline patterns
replace is_baseline_named = 1 if regexm(varname_lower, "_b$") & !regexm(varname_lower, "_fb$|_sb$|_rb$|_1$")

* Check for cases where variable without suffix might be baseline
* and other rounds have suffixes
gen has_any_suffix = regexm(varname_lower, "_[0-9]$|_[a-z]+[0-9]*$")
bysort basevar: egen group_has_suffix = max(has_any_suffix)
* If some in the group have suffixes but this one doesn't, it might be baseline
replace is_baseline_named = 1 if group_has_suffix == 1 & has_any_suffix == 0
drop has_any_suffix group_has_suffix

* ==============================================================================
* STEP 4: Classify variables into Type 1 and Type 2
* ==============================================================================

* Type 1: Variables collected ONLY at baseline (var_count = 1)
* Type 2: Variables collected at baseline AND other rounds (var_count > 1 and has baseline indicator)

gen baseline_type = .

* Type 1: Single occurrence (no other rounds)
replace baseline_type = 1 if var_count == 1

* Type 2: Multiple versions exist and this is the baseline one
replace baseline_type = 2 if var_count > 1 & is_baseline_named == 1

* Mark non-baseline variables
replace baseline_type = 0 if var_count > 1 & is_baseline_named == 0

* ==============================================================================
* STEP 5: Generate summary statistics and reports
* ==============================================================================

* Label the baseline type variable
label define baseline_type_lbl 0 "Non-baseline (follow-up)" 1 "Type 1: Baseline only" 2 "Type 2: Baseline + follow-ups"
label values baseline_type baseline_type_lbl

* Sort for better viewing
sort baseline_type basevar varname

* Display summary
di _n "{hline 80}"
di "{bf:BASELINE VARIABLE CLASSIFICATION SUMMARY}"
di "{hline 80}"
tab baseline_type, missing

* Show examples by type
di _n "{bf:TYPE 1: Variables collected ONLY at baseline (first 20):}"
count if baseline_type == 1
local type1_count = r(N)
if `type1_count' > 0 {
    list varname basevar if baseline_type == 1, clean noobs
}
else {
    di "  No Type 1 variables found"
}

di _n "{bf:TYPE 2: Variables collected at baseline AND other rounds (first 20):}"
count if baseline_type == 2
local type2_count = r(N)
if `type2_count' > 0 {
    list varname basevar var_count if baseline_type == 2, clean noobs
}
else {
    di "  No Type 2 variables found"
}

di _n "{bf:Example of variable groups with multiple rounds:}"
qui sum basevar_group
local max_group = r(max)
local groups_shown = 0
forvalues i = 1/`max_group' {
    qui count if basevar_group == `i'
    if r(N) > 1 & `groups_shown' < 5 {
        qui levelsof basevar if basevar_group == `i', local(base_name) clean
        di _n "Group `i' - Base variable: `base_name'"
        list varname baseline_type if basevar_group == `i', clean noobs sepby(basevar_group)
        local groups_shown = `groups_shown' + 1
    }
}

* ==============================================================================
* STEP 6: Save results
* ==============================================================================

* Keep relevant variables
keep varname basevar var_count is_baseline_named baseline_type basevar_group

* Save the classification
cap save "ID`study_id'_baseline_vars.dta", replace
if _rc != 0 {
    di as error "  Error saving .dta file for study `study_id'"
}

* Export to Excel for easy review
cap export excel using "ID`study_id'_baseline_vars.xlsx", firstrow(variables) replace
if _rc != 0 {
    di as error "  Error saving Excel file for study `study_id' (file may be open)"
}

* Create separate lists for each type
preserve
qui count if baseline_type == 1
if r(N) > 0 {
    keep if baseline_type == 1
    keep varname
    cap export excel using "ID`study_id'_type1_baseline_vars.xlsx", firstrow(variables) replace
    if _rc == 0 {
        di "  - Type 1 variables list saved"
    }
    else {
        di as error "  - Error saving Type 1 variables list (file may be open)"
    }
}
else {
    di "  - No Type 1 variables to export"
}
restore

preserve
qui count if baseline_type == 2
if r(N) > 0 {
    keep if baseline_type == 2
    keep varname basevar
    cap export excel using "ID`study_id'_type2_baseline_vars.xlsx", firstrow(variables) replace
    if _rc == 0 {
        di "  - Type 2 variables list saved"
    }
    else {
        di as error "  - Error saving Type 2 variables list (file may be open)"
    }
}
else {
    di "  - No Type 2 variables to export"
}
restore

di _n "{hline 80}"
di "{bf:RESULTS SAVED FOR STUDY `study_id':}"
di "  - Full classification: ID`study_id'_baseline_vars.xlsx"
di "  - Type 1 variables: ID`study_id'_type1_baseline_vars.xlsx"
di "  - Type 2 variables: ID`study_id'_type2_baseline_vars.xlsx"
di "{hline 80}"

} // End of foreach study_id loop

* ==============================================================================
* END OF BASELINE VARIABLE IDENTIFICATION FOR ALL STUDIES
* ==============================================================================

di _n _n "{hline 80}"
di "{bf:PROCESSING COMPLETE FOR ALL STUDIES}"
di "{hline 80}"
