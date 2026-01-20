* Stata script to install required packages
* Run this ONCE to install all required packages


local full_adopath = c(adopath)

* Replace semicolons with spaces to make tokenization easier
local full_adopath = subinstr("`full_adopath'", ";", " ", .)

* Count words and loop through each adopath name
local count_paths: word count `full_adopath'
forvalues i=1(1)`count_paths'{
	local ado_word: word `i' of `full_adopath'

	* Strip all types of quotes from the path name
	local ado_word = subinstr("`ado_word'", `"""', "", .)
	local ado_word = subinstr("`ado_word'", "`", "", .)
	local ado_word = subinstr("`ado_word'", "'", "", .)

	* Keep BASE and PLUS, remove everything else
	if "`ado_word'"=="BASE" | "`ado_word'"=="PLUS" {
		display as text "  Keeping `ado_word' in adopath"
    }
	else if "`ado_word'" != "" {
		display as text "  Removing `ado_word' from adopath"
		adopath - `ado_word'
	}
}
* remove all other ado paths
* Install required packages to the project ado folder
* Set PLUS to project ado folder
sysdir set PLUS "${root}/ado"

* docs: https://github.com/sergiocorreia/stata-require
ssc install require, replace
require using "${root}/.config/stata/stata_requirements.txt", install

* Install github package manager and other github packages
require github, install from("https://haghish.github.io/github/")
capture noisily github install PovertyAction/ipaplots

* Set a consistent scheme for graphs (use ipaplots if available, otherwise s2color)
capture set scheme ipaplots, permanent
if _rc != 0 {
    display as text "Note: ipaplots scheme not available, using default scheme"
}

display as text "{hline 60}"
display as text "Packages installed to project ado folder"
display as text "{hline 60}"
