"""Generate Fake Dataset for IPA Stata Template Exercise
======================================================

This script generates a synthetic dataset to use with the IPA Stata template
dofiles (00_run.do through 07_advanced_programming.do).

The dataset includes:
- Demographics: ID, age, gender
- Economic variables: income, education
- Realistic distributions and correlations

Author: Claude Code
Date: 2026-01-13
"""

import numpy as np
import pandas as pd

# Set random seed for reproducibility
np.random.seed(123456789)

# Number of observations
n_obs = 1000

print(f"Generating fake dataset with {n_obs} observations...")

# Generate ID variable
ids = [f"ID{str(i).zfill(4)}" for i in range(1, n_obs + 1)]

# Generate demographics
# Age: Normal distribution, mean 40, sd 15, clipped to 18-80
ages = np.random.normal(40, 15, n_obs)
ages = np.clip(ages, 18, 80)

# Gender: Binary, roughly 50/50 split with slight variation
gender = np.random.choice(["Male", "Female"], size=n_obs, p=[0.48, 0.52])

# Education: Years of education (6-20 years)
# Slightly correlated with age (older people might have less education on average)
educ_base = np.random.normal(12, 3, n_obs)
educ_age_effect = -0.05 * (ages - 40)  # Slight negative correlation with age
education = educ_base + educ_age_effect + np.random.normal(0, 1, n_obs)
education = np.clip(education, 6, 20)

# Income: Log-normal distribution with effects from education, age, and gender
# Base log income
log_income_base = np.random.normal(10, 0.8, n_obs)

# Education effect (higher education -> higher income)
educ_effect = 0.08 * education

# Age effect (quadratic - peaks around 50)
age_centered = ages - 50
age_effect = 0.02 * age_centered - 0.0005 * (age_centered**2)

# Gender effect (gender pay gap)
gender_effect = np.where(gender == "Female", -0.15, 0)

# Combine effects
log_income = (
    log_income_base
    + educ_effect
    + age_effect
    + gender_effect
    + np.random.normal(0, 0.3, n_obs)
)
income = np.exp(log_income)

# Add some missing values (realistic data has missingness)
# Randomly set 2% of income values to missing
missing_income_idx = np.random.choice(n_obs, size=int(0.02 * n_obs), replace=False)
income[missing_income_idx] = np.nan

# Randomly set 1% of education values to missing
missing_educ_idx = np.random.choice(n_obs, size=int(0.01 * n_obs), replace=False)
education[missing_educ_idx] = np.nan

# Create a few duplicates (to test duplicate handling)
# Add 3 duplicate IDs
duplicate_indices = np.random.choice(n_obs, size=3, replace=False)
for idx in duplicate_indices:
    ids[idx] = ids[idx - 1]  # Make it a duplicate of the previous ID

# Create the dataset
data = pd.DataFrame(
    {
        "ID": ids,
        "Age": ages.round(0).astype(int),
        "Gender": gender,
        "Income": income.round(2),
        "Education": education.round(0),
    }
)

# Add some outliers (extreme values for testing)
outlier_indices = np.random.choice(n_obs, size=5, replace=False)
data.loc[outlier_indices, "Income"] = data["Income"].mean() + 5 * data["Income"].std()

# Display summary statistics
print("\nDataset Summary:")
print("=" * 60)
print(f"Number of observations: {len(data)}")
print("\nVariable distributions:")
print(data.describe())

print("\nGender distribution:")
print(data["Gender"].value_counts())

print("\nMissing values:")
print(data.isnull().sum())

print(f"\nDuplicate IDs: {data['ID'].duplicated().sum()}")

# Save to CSV
output_path = "data/raw/sample_data.csv"
data.to_csv(output_path, index=False)
print(f"\nDataset saved to: {output_path}")

print("\n" + "=" * 60)
print("Data generation complete!")
print("=" * 60)
print("\nNext steps:")
print("1. Review the generated data at: data/raw/sample_data.csv")
print("2. Run the master dofile: do scripts/do/00_run.do")
print("3. Or run individual dofiles in sequence")
