#!/usr/bin/env python

"""SConstruct file for reproducible Stata analysis.
Based on statacons tutorial: https://bquistorff.github.io/statacons/.

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
    "scripts": "do_files",
    "analysis": "analysis",
    "logs": "logs",
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
env.AppendENVPath(name="STATA_PLUS", newpath=os.path.abspath(PATHS["ado"]))

# =============================================================================
# DATA PREPARATION PIPELINE
# =============================================================================

# Step 1: Data cleaning
data_clean = env.StataBuild(
    target="data/clean/cleaned_data.dta", source="do_files/01_data_cleaning.do"
)
Depends(
    data_clean,
    [
        "data/raw/sample_data.csv",
        "do_files/functions.do",  # functions dependency
        "ado",  # Ensure ado files are available
    ],
)

# Step 2: Data preparation for analysis
data_final = env.StataBuild(
    target="data/final/analysis_data.dta", source="do_files/02_data_preparation.do"
)
Depends(data_final, ["data/clean/cleaned_data.dta", "do_files/functions.do", "ado"])

# =============================================================================
# ANALYSIS PIPELINE
# =============================================================================

# Step 3: Descriptive analysis
descriptive_analysis = env.StataBuild(
    target="outputs/tables/descriptive_stats.tex",
    source="do_files/03_descriptive_analysis.do",
)
Depends(
    descriptive_analysis,
    ["data/final/analysis_data.dta", "do_files/functions.do", "ado"],
)

# Step 4: Main analysis
main_analysis = env.StataBuild(
    target=[
        "outputs/tables/main_results.tex",
        "outputs/tables/model1.tex",  # Updated targets from standard_regression function
        "outputs/tables/model2.tex",
        "outputs/tables/model3.tex",
    ],
    source="do_files/04_main_analysis.do",
)
Depends(main_analysis, ["data/final/analysis_data.dta", "do_files/functions.do", "ado"])

# Step 5: Robustness checks
robustness_analysis = env.StataBuild(
    target=[
        "outputs/tables/robustness_functional_forms.tex",
        "outputs/tables/robustness_quantile.tex",
        "outputs/tables/robustness_subsamples.tex",
    ],
    source="do_files/05_robustness_checks.do",
)
Depends(
    robustness_analysis,
    ["data/final/analysis_data.dta", "do_files/functions.do", "ado"],
)

# =============================================================================
# FIGURE GENERATION
# =============================================================================

# Step 6: Generate figures
figures = env.StataBuild(
    target=[
        "outputs/figures/figure1_income_distribution.pdf",
        "outputs/figures/figure1_income_by_education.pdf",
        "outputs/figures/figure2_coefficients.pdf",
        "outputs/figures/figure3_residuals_fitted.pdf",
        "outputs/figures/figure3_qq_plot.pdf",
        "outputs/figures/figure4_coefficient_stability.pdf",
        "outputs/figures/combined_summary.pdf",
    ],
    source="do_files/06_generate_figures.do",
)
Depends(figures, ["data/final/analysis_data.dta", "do_files/functions.do", "ado"])

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

# Clean target to remove all generated files while preserving .gitkeep
if GetOption("clean"):
    import glob

    dirs_to_clean = [
        "data/clean",
        "data/final",
        "outputs/tables",
        "outputs/figures",
        "logs",
    ]
    for d in dirs_to_clean:
        if os.path.exists(d):
            # Remove all files except .gitkeep
            for item in glob.glob(os.path.join(d, "*")):
                if os.path.isfile(item) and not item.endswith(".gitkeep"):
                    os.remove(item)
