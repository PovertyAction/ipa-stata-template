* Stata script to install required packages for the project
clear all

* Install required packages
ssc install require
require using "scripts/setup/stata_requirements.txt", install
require github, install from("https://haghish.github.io/github/")
github install PovertyAction/ipaplots

* Set a consistent scheme for graphs
set scheme ipaplots, permanent
display as text "Stata package installation complete!"
