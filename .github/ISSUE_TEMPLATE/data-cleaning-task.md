---
name: Data Cleaning Task
about: Track data cleaning tasks with key verification standards
title: "[CLEANING] "
labels: ["data-cleaning", "data"]
assignees: []
---

## Data Source Information

**Dataset name**: [Name of dataset]
**File location**: `data/raw/[filename]`
**Data description**: [Brief description of the data]

## Key Verification

- [ ] **Unique identifiers defined**
  - [ ] Key variables identified: [list key variables]
  - [ ] Analysis unit documented: [what does each row represent?]
  - [ ] Time period specified: [if applicable]
  - [ ] Geographic scope defined: [if applicable]

## Data Cleaning Checklist

- [ ] **Raw data loaded successfully**
  - [ ] File path verified
  - [ ] Import process documented
  - [ ] Basic structure confirmed

- [ ] **Key Verification (REQUIRED)**
  - [ ] `verify_keys [key_vars]` function executed
  - [ ] Key uniqueness confirmed
  - [ ] No missing values in key variables
  - [ ] Data signature created

- [ ] **Variable standardization**
  - [ ] Variable names follow IPA conventions (lowercase, underscores)
  - [ ] Variable labels added
  - [ ] Value labels created where appropriate
  - [ ] Data types verified

- [ ] **Data quality assessment**
  - [ ] `data_quality_report` function executed
  - [ ] Missing data patterns analyzed
  - [ ] Outliers identified and flagged
  - [ ] Data inconsistencies resolved

- [ ] **IPA extended missing values applied**
  - [ ] `.d` - Don't know responses
  - [ ] `.o` - Other/Open-ended responses
  - [ ] `.n` - Not applicable
  - [ ] `.r` - Refused to answer
  - [ ] `.s` - Skipped by design

## Defensive Programming

- [ ] **Assert statements added**
  - [ ] Data structure assertions
  - [ ] Value range checks
  - [ ] Logic consistency checks
- [ ] **Error handling implemented**
  - [ ] Graceful handling of missing files
  - [ ] Clear error messages
  - [ ] Recovery procedures documented

## Output Requirements

- [ ] **Cleaned dataset**: `data/clean/[filename].dta`
- [ ] **Cleaning log**: `analysis/logs/01_data_cleaning.log`
- [ ] **Data documentation**: [Variable descriptions, cleaning decisions]

## Quality Control

- [ ] **Code review completed**
  - [ ] `just lint-stata-file scripts/do/01_data_cleaning.do` passes
  - [ ] Code follows IPA standards (based on Gentzkow & Shapiro principles)
  - [ ] Documentation is complete
- [ ] **Validation completed**
  - [ ] Cleaned data matches expectations
  - [ ] Key verification succeeds
  - [ ] Data quality report reviewed

## Documentation Requirements

- [ ] **Analysis unit clearly documented**
- [ ] **Key variables explained**
- [ ] **Cleaning decisions justified**
- [ ] **Data quality issues noted**

## Notes
<!-- Special considerations, data issues found, cleaning decisions made -->

---
**Compliance:** This task ensures data meets IPA standards for unique, non-missing keys and proper documentation of the analysis unit.
