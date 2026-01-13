* Stata script to install required packages
* Run this ONCE to install all required packages
* docs: https://worldbank.github.io/repkit/reference/repado.html

clear all

* Install required packages to default PLUS location
* docs: https://github.com/sergiocorreia/stata-require
ssc install require, replace
require using ".config/stata/stata_requirements.txt", install

* Install github package manager and other github packages
require github, install from("https://haghish.github.io/github/")
capture noisily github install PovertyAction/ipaplots

* Set a consistent scheme for graphs (use ipaplots if available, otherwise s2color)
capture set scheme ipaplots, permanent
if _rc != 0 {
    display as text "Note: ipaplots scheme not available, using default scheme"
}

display as text "{hline 60}"
display as text "Packages installed to default PLUS location"
display as text "{hline 60}"
