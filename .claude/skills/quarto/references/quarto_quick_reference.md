# Quarto Quick Reference

## Document Structure

### Basic .qmd File

```markdown
---
title: "Document Title"
format: html
---

# Section 1

Content here...

```{python}
# Code chunk
```text

## Section 2

More content...

```

## YAML Front Matter

### HTML Output

```yaml
---
title: "My Document"
author: "Name"
date: today
format:
  html:
    toc: true
    toc-depth: 3
    toc-location: left
    number-sections: true
    code-fold: show
    code-tools: true
    code-copy: true
    theme: cosmo
    embed-resources: true
---
```

### Typst Output

```yaml
---
title: "My Document"
author: "Name"
date: today
format:
  typst:
    toc: true
    number-sections: true
    papersize: us-letter
    margin:
      x: 1.25in
      y: 1.25in
    fontsize: 11pt
---
```

### Multiple Formats

```yaml
---
title: "My Document"
format:
  html:
    toc: true
  typst:
    toc: true
---
```

## Code Chunks

### Python

```markdown
```{python}
#| label: fig-plot
#| fig-cap: "My figure"
#| echo: false

import matplotlib.pyplot as plt
plt.plot([1, 2, 3], [1, 4, 9])
plt.show()
```text

```

### R

```markdown
```{r}
#| label: tbl-summary
#| tbl-cap: "Summary table"

summary(mtcars)
```text

```

### Bash

```markdown
```{bash}
#| echo: true

ls -la
```text

```

## Cell Options

Common options (use `#|` prefix):

```markdown
```{python}
#| label: my-code
#| echo: false          # Hide code, show output
#| eval: false          # Show code, don't run
#| output: false        # Hide output
#| warning: false       # Suppress warnings
#| message: false       # Suppress messages
#| error: true          # Show errors without failing
#| include: false       # Run but don't show anything
#| fig-cap: "Caption"   # Figure caption
#| fig-width: 8         # Figure width
#| fig-height: 6        # Figure height
#| tbl-cap: "Caption"   # Table caption

# code here
```text

```

## Markdown Syntax

### Headings

```markdown
# Level 1
## Level 2
### Level 3

## Unnumbered Heading {.unnumbered}
## Unlisted Heading {.unlisted}
## Both {.unnumbered .unlisted}

## Heading with ID {#sec-methods}
```

### Text Formatting

```markdown
*italic* or _italic_
**bold** or __bold__
***bold italic***
`code`
~~strikethrough~~

Subscript: H~2~O
Superscript: X^2^
```

### Lists

```markdown
- Unordered item 1
- Unordered item 2
  - Nested item

1. Ordered item 1
2. Ordered item 2
   a. Nested item
```

### Links and Images

```markdown
[Link text](https://example.com)

![Image caption](path/to/image.png)

![Image with ID](image.png){#fig-myimage}
```

### Tables

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
| Data 4   | Data 5   | Data 6   |

: Table caption {#tbl-mytable}
```

### Math

```markdown
Inline: $E = mc^2$

Display:
$$
\frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$
```

## Cross-References

### Creating References

```markdown
See @fig-plot for the figure.
Results in @tbl-results.
Methods described in @sec-methods.

## Methods {#sec-methods}

```{python}
#| label: fig-plot
#| fig-cap: "My plot"
```text

```{python}
#| label: tbl-results
#| tbl-cap: "Results"
```text

```

### Reference Types

- Figures: `@fig-label`
- Tables: `@tbl-label`
- Sections: `@sec-label`
- Equations: `@eq-label`
- Listings: `@lst-label`

## Special Blocks

### Callouts

```markdown
:::{.callout-note}
This is a note.
:::

:::{.callout-warning}
This is a warning.
:::

:::{.callout-important}
This is important.
:::

:::{.callout-tip}
This is a tip.
:::

:::{.callout-caution}
This is a caution.
:::
```

### Conditional Content

```markdown
::: {.content-visible when-format="html"}
This only appears in HTML output.
:::

::: {.content-visible when-format="typst"}
This only appears in Typst output.
:::

::: {.content-hidden when-format="html"}
This is hidden in HTML output.
:::
```

### Columns

```markdown
:::: {.columns}
::: {.column width="50%"}
Left column content
:::

::: {.column width="50%"}
Right column content
:::
::::
```

## Including Files

### Include Another Document

```markdown
{{< include _other.qmd >}}
```

### Include Code from File

```markdown
```{python}
#| file: analysis.py
```text

```

## Parameters

### Define Parameters

```yaml
---
title: "Parameterized Report"
params:
  dataset: "data.csv"
  year: 2024
  alpha: 0.05
---
```

### Use Parameters

```markdown
```{python}
import pandas as pd

data = pd.read_csv(params['dataset'])
year = params['year']
alpha = params['alpha']
```text

```

### Render with Parameters

```bash
quarto render report.qmd -P dataset:other.csv -P year:2025
```

## Quarto Commands

### Rendering

```bash
# Render to default format
quarto render document.qmd

# Render to specific format
quarto render document.qmd --to html
quarto render document.qmd --to typst

# Render all formats
quarto render document.qmd --to all

# Verbose output
quarto render document.qmd --verbose

# Keep intermediate files
quarto render document.qmd --keep-md
```

### Preview

```bash
# Preview with live reload
quarto preview document.qmd

# Preview on specific port
quarto preview document.qmd --port 8080
```

### Project Management

```bash
# Render entire project
quarto render

# Preview project
quarto preview

# Create new project
quarto create project default myproject
```

### Utilities

```bash
# Check Quarto installation
quarto check

# Show version
quarto --version

# Get help
quarto --help
quarto render --help
```

## Project Configuration (_quarto.yml)

```yaml
project:
  type: default
  output-dir: _output

format:
  html:
    theme: cosmo
    toc: true
  typst:
    toc: true

execute:
  echo: true
  warning: false
  cache: false

metadata-files:
  - _metadata.yml
```

## Execution Options

### Document-Level

```yaml
---
execute:
  echo: true
  warning: false
  message: false
  cache: true
  freeze: true
---
```

### Project-Level (_quarto.yml)

```yaml
execute:
  echo: true
  warning: false
  cache: true
```

### Cell-Level

```markdown
```{python}
#| echo: false
#| cache: true
```text

```

## Themes (HTML)

Built-in themes:

- default
- cerulean
- cosmo
- flatly
- journal
- litera
- lumen
- lux
- materia
- minty
- morph
- pulse
- quartz
- sandstone
- simplex
- sketchy
- slate
- solar
- spacelab
- superhero
- united
- vapor
- yeti
- zephyr

```yaml
format:
  html:
    theme: cosmo
```

## Common Workflows

### Create Document

```bash
# Using template script
uv run python .claude/skills/quarto/scripts/create_quarto.py \
  --output report.qmd \
  --title "My Report" \
  --format html
```

### Validate YAML

```bash
uv run python .claude/skills/quarto/scripts/validate_yaml.py document.qmd
```

### Batch Render

```bash
uv run python .claude/skills/quarto/scripts/render_all.py \
  --pattern "reports/*.qmd"
```

## Troubleshooting

### YAML Issues

- Use spaces, not tabs for indentation
- Put colons after keys: `key: value`
- Quote strings with special characters
- Check matching of opening/closing braces

### Code Execution Issues

- Verify kernel is installed (jupyter, R, etc.)
- Check code chunk syntax
- Use `error: true` to continue on errors
- Check file paths are correct

### Rendering Issues

- Run `quarto check` to verify installation
- Check for missing dependencies
- Review error messages carefully
- Use `--verbose` flag for details

## Resources

- Official Docs: <https://quarto.org/docs/>
- Guide: <https://quarto.org/docs/guide/>
- Reference: <https://quarto.org/docs/reference/>
- Gallery: <https://quarto.org/docs/gallery/>
