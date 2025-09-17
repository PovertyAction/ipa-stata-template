#!/usr/bin/env python

"""
SConstruct file for reproducible Stata analysis
Based on statacons tutorial: https://bquistorff.github.io/statacons/

This file defines the build targets and dependencies for the analysis pipeline.
It uses statacons to automatically track file dependencies and rebuild only
what's necessary when input files or code changes.

Key Features:
- Implements Gentzkow & Shapiro (G&S) automation principles
- All scripts depend on functions.do for G&S standardized functions
- Automatic dependency tracking and selective rebuilding
- Consistent output paths and naming conventions
- Integration with IPA best practices

Dependencies:
- functions.do: Contains G&S standardized functions (verify_keys, standard_regression, etc.)
- ado/: Local Stata package directory for reproducibility
- All scripts automatically load functions.do and validate data integrity
"""

import os
from pystatacons import init_env

# Initialize Stata environment
env = init_env()

# Define paths
PATHS = {
    "data_raw": "data/raw",
    "data_clean": "data/clean",
    "data_final": "data/final",
    "scripts": "scripts/do",
    "analysis": "analysis",
    "logs": "analysis/logs",
    "outputs": "outputs",
    "tables": "outputs/tables",
    "figures": "outputs/figures",
    "ado": "ado",
}

# Ensure output directories exist
for path in PATHS.values():
    if not os.path.exists(path):
        os.makedirs(path)

# Set Stata PLUS directory to local ado folder for reproducibility
env.AppendENVPath("STATA_PLUS", os.path.abspath(PATHS["ado"]))

# =============================================================================
# DATA PREPARATION PIPELINE
# =============================================================================

# Step 1: Data cleaning
data_clean = env.StataBuild(
    target="data/clean/cleaned_data.dta", source="scripts/do/01_data_cleaning.do"
)
Depends(
    data_clean,
    [
        "data/raw/sample_data.csv",
        "scripts/do/functions.do",  # functions dependency
        "ado",  # Ensure ado files are available
    ],
)

# Step 2: Data preparation for analysis
data_final = env.StataBuild(
    target="data/final/analysis_data.dta", source="scripts/do/02_data_preparation.do"
)
Depends(data_final, ["data/clean/cleaned_data.dta", "scripts/do/functions.do", "ado"])

# =============================================================================
# ANALYSIS PIPELINE
# =============================================================================

# Step 3: Descriptive analysis
descriptive_analysis = env.StataBuild(
    target=[
        "outputs/tables/descriptive_stats.tex",
        "analysis/logs/03_descriptive_analysis.log",
    ],
    source="scripts/do/03_descriptive_analysis.do",
)
Depends(
    descriptive_analysis,
    ["data/final/analysis_data.dta", "scripts/do/functions.do", "ado"],
)

# Step 4: Main analysis
main_analysis = env.StataBuild(
    target=[
        "outputs/tables/main_results.tex",
        "outputs/tables/model1.tex",  # Updated targets from standard_regression function
        "outputs/tables/model2.tex",
        "outputs/tables/model3.tex",
        "analysis/logs/04_main_analysis.log",
    ],
    source="scripts/do/04_main_analysis.do",
)
Depends(
    main_analysis, ["data/final/analysis_data.dta", "scripts/do/functions.do", "ado"]
)

# Step 5: Robustness checks
robustness_analysis = env.StataBuild(
    target=[
        "outputs/tables/robustness_results.tex",
        "analysis/logs/05_robustness_checks.log",
    ],
    source="scripts/do/05_robustness_checks.do",
)
Depends(
    robustness_analysis,
    ["data/final/analysis_data.dta", "scripts/do/functions.do", "ado"],
)

# =============================================================================
# FIGURE GENERATION
# =============================================================================

# Step 6: Generate figures
figures = env.StataBuild(
    target=["outputs/figures/figure1.pdf", "outputs/figures/figure2.pdf"],
    source="scripts/do/06_generate_figures.do",
)
Depends(figures, ["data/final/analysis_data.dta", "scripts/do/functions.do", "ado"])

# =============================================================================
# BUILD ALIASES AND DEPENDENCIES
# =============================================================================

# Create convenient aliases for different stages
Alias("data", [data_clean, data_final])
Alias("analysis", [descriptive_analysis, main_analysis, robustness_analysis])
Alias("figures", figures)
Alias(
    "all",
    [
        data_clean,
        data_final,
        descriptive_analysis,
        main_analysis,
        robustness_analysis,
        figures,
    ],
)

# Default target when running 'scons' without arguments
Default("all")

# Clean target to remove all generated files
if GetOption("clean"):
    import shutil

    dirs_to_clean = [
        "data/clean",
        "data/final",
        "outputs/tables",
        "outputs/figures",
        "analysis/logs",
    ]
    for d in dirs_to_clean:
        if os.path.exists(d):
            shutil.rmtree(d)
            os.makedirs(d)
