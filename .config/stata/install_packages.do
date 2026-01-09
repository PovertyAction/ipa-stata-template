* Stata script to install required packages to the project ado folder
* Run this ONCE to populate the ado folder, then commit to git
* docs: https://worldbank.github.io/repkit/reference/repado.html

clear all

* ACTIVATE: Customize adopath to install packages to project folder
* Remove user's package directories from adopath
* This prevents Stata from finding existing packages and skipping install
adopath - PLUS
adopath - PERSONAL
adopath - SITE
adopath - OLDPLACE

* Set the project ado folder as the new PLUS and add to adopath
local project_root "`c(pwd)'"
sysdir set PLUS "`project_root'/ado"
adopath + PLUS

* Install required packages (they'll go to ./ado)
* docs: https://github.com/sergiocorreia/stata-require
ssc install require
require using ".config/stata/stata_requirements.txt", install

* Install github package manager and other github packages
require github, install from("https://haghish.github.io/github/")
github install PovertyAction/ipaplots

* Set a consistent scheme for graphs
set scheme ipaplots, permanent

* Verify key packages were installed successfully
display _n as text "Verifying package installation..."
local key_packages "estout reghdfe missings"
local all_installed = 1
foreach pkg in `key_packages' {
    capture which `pkg'
    if _rc != 0 {
        display as error "ERROR: Package `pkg' failed to install"
        local all_installed = 0
    }
    else {
        display as result "  ✓ `pkg' installed successfully"
    }
}

if `all_installed' == 0 {
    display as error "Some packages failed to install. Please check errors above."
    exit 601
}

display as text "{hline 60}"
display as result "SUCCESS: All packages installed to ./ado folder"
display as text "The ado/ folder is gitignored and will be populated by setup.do"
display as text "{hline 60}"
