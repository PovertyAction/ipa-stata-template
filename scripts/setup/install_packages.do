/*==============================================================================
Title: Install Stata Packages from Requirements
Author: Innovations for Poverty Action
Description: Reads package requirements and installs them reproducibly
==============================================================================*/

// Set up logging
capture log close
log using "analysis/logs/package_install.log", replace text

// Display header
display as text "{hline 60}"
display as text "Installing Stata packages from requirements file"
display as text "{hline 60}"

// First, install github package directly (prerequisite for github-based packages)
display as text "Installing github package (prerequisite)..."
capture net install github, from("https://haghish.github.io/github/") replace
if _rc == 0 {
    display as result "github package installed successfully"
}
else {
    display as error "Failed to install github package (error code: `=_rc')"
}
display ""

// Read the requirements file
tempname req_file
file open `req_file' using "scripts/setup/stata_requirements.txt", read

// Skip header line
file read `req_file' line
display as text "Reading requirements from: scripts/setup/stata_requirements.txt"
display ""

// Initialize counters
local installed = 0
local failed = 0

// Process each package line
file read `req_file' line
while r(eof) == 0 {
    // Skip comment lines and empty lines
    if substr(trim("`line'"), 1, 1) != "#" & trim("`line'") != "" {

        // Parse the line: package_name,source,command
        tokenize "`line'", parse(",")
        local package "`1'"
        local source "`3'"
        local command "`5'"

        display as text "Installing `package' from `source'..."

        // Execute installation command
        capture `command', replace

        if _rc == 0 {
            display as result "  ✓ `package' installed successfully"
            local ++installed
        }
        else {
            display as error "  ✗ Failed to install `package' (error code: `=_rc')"
            local ++failed
        }
        display ""
    }

    // Read next line
    file read `req_file' line
}

file close `req_file'

// Display summary
display as text "{hline 60}"
display as text "Package Installation Summary:"
display as result "  Successfully installed: `installed' packages"
if `failed' > 0 {
    display as error "  Failed installations: `failed' packages"
}
else {
    display as result "  Failed installations: `failed' packages"
}
display as text "{hline 60}"

// Close log
log close

// Return error if any packages failed
if `failed' > 0 {
    display as error "Some packages failed to install. Check analysis/logs/package_install.log for details."
    exit 1
}
else {
    display as result "All packages installed successfully!"
}
