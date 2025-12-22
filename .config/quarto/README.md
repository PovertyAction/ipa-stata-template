# Quarto Markdownlint Rules

This directory contains custom markdownlint rules for validating Quarto-flavored Markdown documents.

## Overview

Quarto extends standard Markdown with additional syntax for callouts, cross-references,
code blocks with options, and more. Standard markdownlint rules don't understand
these extensions and may flag valid Quarto syntax as errors. These custom rules
provide proper validation for Quarto-specific features.

## Files

| File | Purpose |
| ------ | --------- |
| `custom-quarto-rules.js` | Callout block validation (note, tip, warning, caution, important) |
| `additional-quarto-rules.js` | Div/span syntax, code blocks, diagrams, cross-references, footnotes |
| `quarto-image-rules.js` | Image accessibility validation (alt text requirements) |

## Integration with Markdownlint

These rules are loaded via the project's `.markdownlint.yaml` configuration:

```yaml
customRules:
  - ".config/quarto/custom-quarto-rules.js"
  - ".config/quarto/additional-quarto-rules.js"
  - ".config/quarto/quarto-image-rules.js"
```

Each rule can be enabled/disabled individually in `.markdownlint.yaml`:

```yaml
# Enable Quarto-specific rules
quarto-callout-blocks: true
quarto-callout-title: true
quarto-collapsible-callout: true
quarto-callout-appearance: true
quarto-callout-crossref: true
quarto-div-span: true
quarto-code-block: true
quarto-diagram: true
quarto-cross-reference: true
quarto-footnote: true
quarto-image-alt-text: true
```

## Rule Descriptions

### Callout Rules (`custom-quarto-rules.js`)

| Rule | Description |
| ------ | ------------- |
| `quarto-callout-blocks` | Validates callout block syntax (`::: {.callout-*}`) and ensures proper closing |
| `quarto-callout-title` | Ensures callouts have a title (via attribute or heading) |
| `quarto-collapsible-callout` | Validates `collapse="true"`, `collapse="false"` attribute values |
| `quarto-callout-appearance` | Validates `appearance` attribute (default, simple, minimal) |
| `quarto-callout-crossref` | Validates cross-references to callout IDs |

### Additional Rules (`additional-quarto-rules.js`)

| Rule | Description |
| ------ | ------------- |
| `quarto-div-span` | Validates fenced div (`::: {}`) and span (`[text]{}`) syntax |
| `quarto-code-block` | Validates executable code blocks with `#\|` options |
| `quarto-diagram` | Validates Mermaid and Graphviz diagram blocks |
| `quarto-cross-reference` | Checks that `@fig-*`, `@tbl-*`, etc. reference existing labels |
| `quarto-footnote` | Validates footnote syntax and checks for undefined references |

### Image Rules (`quarto-image-rules.js`)

| Rule | Description |
| ------ | ------------- |
| `quarto-image-alt-text` | Ensures images have descriptive alt text for accessibility |

## Usage

Run markdownlint on your Quarto documents:

```bash
# Lint all Markdown and Quarto files
just fmt-check-markdown

# Lint and auto-fix
just fmt-markdown

# Lint a specific file
just fmt-md path/to/file.qmd
```

## Examples of Validated Syntax

### Callout Blocks

```markdown
::: {.callout-note}
## Note Title
This is a note callout.
:::

::: {.callout-warning collapse="true"}
## Expandable Warning
This warning is collapsed by default.
:::
```

### Code Blocks with Options

````markdown
```{python}
#| label: fig-plot
#| fig-cap: "A sample plot"
import matplotlib.pyplot as plt
plt.plot([1, 2, 3])
```
````

### Cross-References

```markdown
See @fig-plot for the visualization.
As shown in @tbl-summary, the results are significant.
```

## References

- [Quarto Markdown Basics](https://quarto.org/docs/authoring/markdown-basics.html)
- [Quarto Callouts](https://quarto.org/docs/authoring/callouts.html)
- [Quarto Cross-References](https://quarto.org/docs/authoring/cross-references.html)
- [markdownlint Custom Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/CustomRules.md)
