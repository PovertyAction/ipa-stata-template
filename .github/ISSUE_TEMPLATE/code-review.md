---
name: Code Review
about: Track code review process following IPA quality standards
title: "[REVIEW] "
labels: ["code-review", "quality"]
assignees: []
---

## Code Review Request

**Author**: [Name of code author]
**Files to review**: [List of files]
**Type of review**: [ ] New feature [ ] Bug fix [ ] Refactoring [ ] Documentation

## Standards Checklist (based on Gentzkow & Shapiro principles)

### 1. Automation

- [ ] Code is part of automated pipeline
- [ ] Can be executed via `just stata-full` or similar command
- [ ] No manual steps required for execution
- [ ] Dependencies clearly defined

### 2. Version Control

- [ ] All generated outputs excluded from git
- [ ] Code has been tested end-to-end
- [ ] Full pipeline runs successfully
- [ ] No broken dependencies

### 3. Directory Structure

- [ ] Files in appropriate directories
- [ ] Inputs and outputs clearly separated
- [ ] Follows project directory conventions
- [ ] Portable paths used (no hardcoded absolute paths)

### 4. Data Keys

- [ ] Uses `verify_keys` function where appropriate
- [ ] Key variables clearly documented
- [ ] Analysis unit properly defined
- [ ] Data normalization maintained

### 5. Abstraction

- [ ] Common operations abstracted into functions
- [ ] Code duplication eliminated
- [ ] Functions improve clarity
- [ ] Abstraction is appropriate (not over-engineered)

### 6. Documentation

- [ ] Variable names are descriptive
- [ ] Function names explain purpose
- [ ] Code structure is logical and readable
- [ ] Comments only where code cannot be self-explanatory

## Code Quality Review

### Stata-Specific Standards

- [ ] **IPA coding standards followed**
  - [ ] Lowercase variable names with underscores
  - [ ] Global macros used for file paths
  - [ ] Proper use of extended missing values
- [ ] **stata_linter passes** (`just lint-stata-file [filename]`)
- [ ] **Defensive programming implemented**
  - [ ] Assert statements for data integrity
  - [ ] Error handling for edge cases
  - [ ] Input validation

### Performance and Efficiency

- [ ] Code runs efficiently
- [ ] No unnecessary loops or operations
- [ ] Memory usage is reasonable
- [ ] Temporary files cleaned up

### Reproducibility

- [ ] Results are completely reproducible
- [ ] Random seeds set where needed
- [ ] Software versions documented
- [ ] Dependencies clearly specified

## Reviewer Notes
<!-- Detailed feedback, suggestions for improvement, praise for good practices -->

## Action Items

- [ ] [List specific changes requested]
- [ ] [Additional items as needed]

## Approval

- [ ] **Code meets IPA standards**
- [ ] **Ready for production use**
- [ ] **Documentation is complete**
- [ ] **Tests pass successfully**

**Reviewer**: [Name]
**Date**: [Date]

---
**Note**: This review ensures code follows IPA principles for reproducible, maintainable research code.
