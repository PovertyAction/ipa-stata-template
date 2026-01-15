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

    // Check for user-specific config file (gitignored)
    capture confirm file "${project_path}/config.do"
    if _rc == 0 {
        do "${project_path}/config.do"
    }

    // Set default data root if not defined in config.do
    if "${data_root}" == "" {
        global data_root "${project_path}/data"
    }

    // Define standard paths (use config.do values if set, otherwise use defaults)
    if "${data_raw}" == "" global data_raw "${data_root}/raw"
    if "${data_clean}" == "" global data_clean "${data_root}/clean"
    if "${data_final}" == "" global data_final "${data_root}/final"

    // Code and output paths always relative to project root
    global scripts "${project_path}/do_files"
    global outputs "${project_path}/outputs"
    global logs "${project_path}/logs"
    global tables "${outputs}/tables"
    global figures "${outputs}/figures"

    // Load project functions
    capture do "${scripts}/functions.do"
}
