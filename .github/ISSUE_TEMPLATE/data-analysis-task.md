---
name: Data Analysis Task
about: Track research analysis tasks following project management standards
title: "[ANALYSIS] "
labels: ["analysis", "data"]
assignees: []
---

## Objective

Brief description of the analysis task

## Data Requirements

- [ ] **Raw data files identified**
  - [ ] Data source documented
  - [ ] Data dictionary available
  - [ ] Data access confirmed
- [ ] **Data quality verified**
  - [ ] Unique identifiers confirmed
  - [ ] Missing data patterns assessed
  - [ ] Outliers and data issues flagged

## Analysis Steps

- [ ] **Data cleaning completed**
  - [ ] Key verification passed (`verify_keys` function)
  - [ ] Data quality report generated
  - [ ] Cleaning script documented
- [ ] **Analysis script written**
  - [ ] Uses standardized functions from `functions.do`
  - [ ] Follows IPA coding standards
  - [ ] Includes defensive programming checks
- [ ] **Results generated**
  - [ ] Tables exported to `outputs/tables/`
  - [ ] Figures saved to `outputs/figures/`
  - [ ] All outputs reproducible

## Expected Outputs

- [ ] **Tables generated**:
  - [ ] [Specify table names]
- [ ] **Figures created**:
  - [ ] [Specify figure names]
- [ ] **Results documented**
  - [ ] Analysis interpretation written
  - [ ] Results validated by PI

## Quality Checks

- [ ] **Code quality verified**
  - [ ] `just lint-stata` passes without errors
  - [ ] Code follows style guidelines
  - [ ] Functions abstracted where appropriate
- [ ] **Pipeline testing completed**
  - [ ] `just stata-full` runs successfully
  - [ ] All outputs generated correctly
  - [ ] Results are reproducible
- [ ] **Peer review completed**
  - [ ] Code reviewed by team member
  - [ ] Results validated by PI
  - [ ] Documentation complete

## Deliverables

- [ ] Analysis script(s): `scripts/do/[script_name].do`
- [ ] Output tables: `outputs/tables/[table_files]`
- [ ] Output figures: `outputs/figures/[figure_files]`
- [ ] Documentation: [Brief summary or report section]

## Notes
<!-- Additional context, methodological notes, or special considerations -->

## Dependencies
<!-- List any tasks that must be completed before this one -->

---
**Compliance Checklist:**

- [ ] Task managed through GitHub Issues (not email)
- [ ] All code under version control
- [ ] Full pipeline tested before closing
- [ ] Results are completely reproducible
