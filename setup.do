/*==============================================================================
SETUP.DO - One-time Project Setup
================================================================================

Purpose:     Bootstrap the project environment
Description: Run this once to install setroot and project packages

Usage:
  - Open Stata from any directory
  - do "path/to/project/setup.do"

==============================================================================*/

version 17
clear all

display as text "{hline 60}"
display as text "PROJECT SETUP"
display as text "{hline 60}"

* Install setroot to user's PLUS directory (one-time)
* setroot is needed to find project root from any directory
capture which setroot
if _rc != 0 {
    display "Installing setroot..."
    ssc install setroot
}
else {
    display as result "setroot already installed"
}

* Find project root using setroot
setroot
global project_path "$root"

display as text "Project root: ${project_path}"

* Install all project packages to local ado/
display _n "Installing project packages..."
do "${project_path}/.config/stata/install_packages.do"

display _n(2) "{hline 60}"
display as result "Setup complete!"
display as text "{hline 60}"
display as text "You can now run the analysis from any directory:"
display as text "  do `"${project_path}/scripts/do/00_run.do`""
display as text ""
display as text "Or run a specific script:"
display as text "  do `"${project_path}/scripts/do/00_run.do`" 01_data_cleaning"
display as text "{hline 60}"
