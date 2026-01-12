# Markdownlint Rules Reference

This document provides a comprehensive reference for markdownlint rules.

## Common Rules

Common markdownlint rules (prefix with MD):

| Rule | Description |
|------|-------------|
| **MD001** | Heading levels should increment by one |
| **MD003** | Heading style (consistent, atx, setext) |
| **MD004** | Unordered list style |
| **MD007** | Unordered list indentation |
| **MD009** | Trailing spaces |
| **MD010** | Hard tabs |
| **MD012** | Multiple consecutive blank lines |
| **MD013** | Line length (often disabled for flexibility) |
| **MD022** | Headings should be surrounded by blank lines |
| **MD024** | Multiple headings with the same content |
| **MD025** | Multiple top-level headings |
| **MD031** | Fenced code blocks should be surrounded by blank lines |
| **MD032** | Lists should be surrounded by blank lines |
| **MD033** | Inline HTML (often disabled when HTML is needed) |
| **MD034** | Bare URLs |
| **MD036** | Emphasis used instead of a heading |
| **MD038** | Spaces inside code span elements |
| **MD040** | Fenced code blocks should have a language specified |
| **MD041** | First line should be a top-level heading |

## Disabling Rules Inline

Disable rules for specific sections using HTML comments:

```markdown
<!-- markdownlint-disable MD013 -->
This is a very long line that would normally trigger MD013 but won't because the rule is disabled.
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD033 -->
<div>This HTML is allowed</div>

<!-- markdownlint-disable-file MD013 -->
Disable a rule for the entire file
```

## Rule Categories

### Heading Rules

- **MD001**: Heading increment - ensures headings increase by one level at a time
- **MD003**: Heading style - enforces consistent heading format (atx `#` vs setext underlines)
- **MD022**: Blank lines around headings
- **MD024**: No duplicate headings (configurable for siblings only)
- **MD025**: Single top-level heading per document
- **MD041**: First line should be H1

### List Rules

- **MD004**: Consistent unordered list markers (`-`, `*`, or `+`)
- **MD007**: List indentation (default 2 spaces)
- **MD032**: Blank lines around lists

### Whitespace Rules

- **MD009**: No trailing spaces
- **MD010**: No hard tabs
- **MD012**: No multiple consecutive blank lines
- **MD013**: Line length limit

### Code Block Rules

- **MD031**: Blank lines around fenced code blocks
- **MD040**: Language specification for fenced code blocks

### HTML and Special Content

- **MD033**: Inline HTML restrictions
- **MD034**: Bare URL detection

## Resources

- Full rules documentation: <https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md>
