* docs: https://hugetim.github.io/nbstata/user_guide.html#stata-implementation-details
* "Using vscode-stata"
* requires:
* - Stata 17+
* - nbstata python package
* - VSCode with vscode-stata extension

* %%
* Initialize project paths if not already set
if "${project_path}" == "" {
    clear all
    macro drop _all
    capture log close _all
    set more off

    // Find project root by searching for .here file
    local here_found = 0
    local search_path "`c(pwd)'"
    local orig_dir "`c(pwd)'"

    // Search up the directory tree for .here file (max 10 levels)
    forvalues i = 1/10 {
        capture confirm file "`search_path'/.here"
        if _rc == 0 {
            // Found the .here file, normalize the path
            quietly cd "`search_path'"
            global project_path "`c(pwd)'"
            quietly cd "`orig_dir'"
            local here_found = 1
            continue, break
        }
        // Go up one directory
        local search_path "`search_path'/.."
    }

    if `here_found' == 0 {
        di as error "ERROR: Could not find project root (.here file)"
        di as error "Searched up to 10 directory levels from: `c(pwd)'"
        exit 601
    }

    global logs "${project_path}/logs"
    di as text "Project root: ${project_path}"
}

* %%
* Start logging
local script_name "stata_demo"
capture mkdir "${logs}"
log using "${logs}/`script_name'.log", replace text name(`script_name')

* %%
sysuse auto, clear

* %%
regress price mpg

* %%
sum price mpg weight foreign

* %%
* %set graph_width = 8
* %set graph_height = 5
twoway scatter price mpg, ///
    title("Car Price vs. Fuel Economy") ///
    xtitle("Miles per Gallon") ///
    ytitle("Price (USD)") ///
    note("Data: 1978 Automobile Data")

* %%
regress price mpg weight foreign


* %%
qui regress price mpg weight foreign
estimates store model1

qui regress price mpg weight foreign length
estimates store model2

etable, estimates(model1 model2) ///
    column(estimates) ///
    showstars showstarsnote ///
    title("Regression Results: Car Price Models")

* Close log
log close `script_name'
