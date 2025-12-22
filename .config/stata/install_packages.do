* Stata script to install required packages to the project ado folder
* Run this ONCE to populate the ado folder, then commit to git
* docs: https://worldbank.github.io/repkit/reference/repado.html

clear all

// * OPTIONAL: Customize adopath to install packages to project folder if using repado
// * Remove user's package directories from adopath
// * This prevents Stata from finding existing packages and skipping install
// adopath - PLUS
// adopath - PERSONAL
// adopath - SITE
// adopath - OLDPLACE

// * Set the project ado folder as the new PLUS and add to adopath
// sysdir set PLUS "`c(pwd)'/ado"
// adopath + PLUS

* Install required packages (they'll go to ./ado)
* docs: https://github.com/sergiocorreia/stata-require
ssc install require
require using ".config/stata/stata_requirements.txt", install

* Install github package manager and other github packages
require github, install from("https://haghish.github.io/github/")
github install PovertyAction/ipaplots

* Set a consistent scheme for graphs
set scheme ipaplots, permanent

display as text "{hline 60}"
display as text "Packages installed to ./ado folder"
display as text "Commit the ado folder to git for reproducibility"
display as text "{hline 60}"
