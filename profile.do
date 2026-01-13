/*==============================================================================
PROJECT PROFILE - Automatic Initialization
================================================================================

This file is automatically executed by Stata when running in batch mode from
this directory. It sets up the project paths required for statacons builds.

Note: This file should be in the project root directory alongside SConstruct.

==============================================================================*/

// Find project root using setroot (looks for .here or .git marker)
capture setroot
if _rc == 0 {
    global project_path "$root"

    // Define standard project paths
    global data_raw "${project_path}/data/raw"
    global data_clean "${project_path}/data/clean"
    global data_final "${project_path}/data/final"
    global scripts "${project_path}/do_files"
    global outputs "${project_path}/outputs"
    global logs "${project_path}/logs"
    global tables "${project_path}/outputs/tables"
    global figures "${project_path}/outputs/figures"

    // Load project functions
    capture do "${scripts}/functions.do"
}
