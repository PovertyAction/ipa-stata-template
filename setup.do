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
    capture ssc install setroot
    if _rc != 0 {
        display as error "ERROR: setroot installation failed"
        display as error "Please check your internet connection and try again"
        display as error "Or install manually: ssc install setroot"
        exit 601
    }
}
else {
    display as result "setroot already installed"
}

* Verify setroot installation succeeded
capture which setroot
if _rc != 0 {
    display as error "ERROR: setroot installation failed"
    display as error "Please install manually: ssc install setroot"
    exit 601
}
else {
    display as result "setroot installation verified"
}

* Find project root using setroot
capture setroot
if _rc != 0 {
    display as error "ERROR: setroot failed to find project root"
    display as error "Ensure .here or .git file exists in project root"
    exit 601
}
global project_path "$root"

* Verify setroot found a valid project root
if "$root" == "" {
    display as error "ERROR: setroot failed to find project root"
    display as error "Ensure .here or .git file exists in project root"
    exit 601
}
display as result "Project root verified: $root"

* Verify .here marker exists
capture confirm file "$root/.here"
if _rc != 0 {
    display as error "WARNING: .here marker not found"
    display as error "setroot may have found .git instead"
    display as text "This is OK, but .here is preferred for explicit project marking"
}

* Install all project packages to local ado/
display _n "Installing project packages..."
capture do "${project_path}/.config/stata/install_packages.do"

* Check if installation completed successfully
if _rc != 0 {
    display as error "ERROR: Package installation failed with code " _rc
    display as error "Check the error messages above"
    display as error "You may need to:"
    display as error "  - Check your internet connection"
    display as error "  - Verify stata_requirements.txt is valid"
    display as error "  - Try running setup.do again"
    exit _rc
}
display as result "Package installation completed successfully"

display _n(2) "{hline 60}"
display as result "✓ Setup complete!"
display as text "{hline 60}"
display as text "You can now run the analysis from any directory:"
display as text "  do `"${project_path}/scripts/do/00_run.do`""
display as text ""
display as text "Or run a specific script:"
display as text "  do `"${project_path}/scripts/do/00_run.do`" 01_data_cleaning"
display as text ""
display as text "Or use the just commands:"
display as text "  just stata-run"
display as text "  just stata-script 01_data_cleaning"
display as text "{hline 60}"
