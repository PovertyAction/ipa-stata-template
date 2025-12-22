# Quarto Document Generation Skill

You are assisting with creating Quarto markdown (.qmd) files for analysis and reporting.
This skill provides templates, references, and workflows for generating professional
documents with HTML or Typst output formats.

## Core Capabilities

When this skill is active, you should:

1. **Generate Quarto Documents**: Create .qmd files from templates with appropriate YAML front matter
2. **Configure Output Formats**: Set up HTML or Typst output with proper formatting options
3. **Integrate Analysis Code**: Embed Python, R, or other code chunks appropriately
4. **Render Documents**: Execute quarto render commands to produce final outputs
5. **Troubleshoot Issues**: Debug YAML syntax, code execution, or rendering errors

## Quarto Document Structure

### Basic .qmd File Layout

```markdown
---
title: "Document Title"
author: "Author Name"
date: "2025-01-05"
format:
  html:
    toc: true
    code-fold: true
---

# Introduction

Document content here...

```{python}
# Code chunk
import pandas as pd
```text

## Analysis

More content...

```

## Output Format Configuration

### HTML Output

Use HTML format for:

- Interactive reports with code folding
- Web-based documentation
- Shareable analysis with embedded resources

Key HTML options:

```yaml
format:
  html:
    toc: true                    # Table of contents
    toc-depth: 3                 # TOC heading depth
    toc-location: left           # TOC position
    number-sections: true        # Number sections
    code-fold: true              # Collapsible code
    code-tools: true             # Code display tools
    embed-resources: true        # Self-contained HTML
    theme: cosmo                 # Visual theme
    html-math-method: katex      # Math rendering
    fig-width: 8                 # Figure width
    fig-height: 6                # Figure height
```

### Typst Output

Use Typst format for:

- PDF-quality typeset documents
- Academic papers and reports
- Print-ready materials

Key Typst options:

```yaml
format:
  typst:
    toc: true                    # Table of contents
    toc-depth: 3                 # TOC heading depth
    number-sections: true        # Section numbering
    papersize: us-letter         # Paper size
    margin:
      x: 1.25in                  # Horizontal margins
      y: 1.25in                  # Vertical margins
    mainfont: "Latin Modern Roman"  # Document font
    fontsize: 11pt               # Base font size
    columns: 1                   # Number of columns
```

## Code Chunk Integration

### Python Chunks

```markdown
```{python}
#| label: fig-plot
#| fig-cap: "My Figure Caption"
#| echo: false

import matplotlib.pyplot as plt
import numpy as np

x = np.linspace(0, 10, 100)
plt.plot(x, np.sin(x))
plt.show()
```text

```

### R Chunks

```markdown
```{r}
#| label: tbl-summary
#| tbl-cap: "Summary Statistics"

library(tidyverse)
mtcars %>%
  summarize(across(everything(), mean)) %>%
  knitr::kable()
```text

```

### Stata Chunks (if using stata kernel)

```markdown
```{stata}
#| label: regression
#| echo: true

sysuse auto, clear
regress price mpg weight
```text

```

### Cell Options

Common cell options (use `#|` prefix):

- `echo: false` - Hide code, show output
- `eval: false` - Show code, don't run
- `output: false` - Hide all output
- `warning: false` - Suppress warnings
- `message: false` - Suppress messages
- `label: fig-name` - Cross-reference label
- `fig-cap: "Caption"` - Figure caption
- `tbl-cap: "Caption"` - Table caption

## Workflow

### Creating a New Document

1. **Choose Template**: Select appropriate template from assets/
2. **Set Metadata**: Configure title, author, date in YAML
3. **Select Format**: Choose HTML or Typst (or both)
4. **Add Content**: Write markdown and code chunks
5. **Render**: Run `quarto render document.qmd`

### Using the Template Script

Generate a new Quarto document:

```bash
uv run python .claude/skills/quarto/scripts/create_quarto.py \
  --output path/to/document.qmd \
  --title "My Analysis" \
  --author "Author Name" \
  --format html \
  --template analysis
```

Template types:

- `analysis` - Data analysis with code chunks
- `report` - Formal report structure
- `presentation` - Slide deck (revealjs)
- `article` - Academic article format

### Rendering Documents

Render to default format:

```bash
quarto render document.qmd
```

Render to specific format:

```bash
quarto render document.qmd --to html
quarto render document.qmd --to typst
```

Render to all formats:

```bash
quarto render document.qmd --to all
```

Preview with live reload:

```bash
quarto preview document.qmd
```

## Common Patterns

### Multiple Output Formats

Create document that renders to both HTML and Typst:

```yaml
format:
  html:
    toc: true
    code-fold: true
    embed-resources: true
  typst:
    toc: true
    number-sections: true
    margin:
      x: 1in
      y: 1in
```

### Parameterized Reports

Add parameters for reusable reports:

```yaml
---
title: "Analysis Report"
params:
  dataset: "data.csv"
  year: 2024
---

```{python}
import pandas as pd
data = pd.read_csv(params['dataset'])
year = params['year']
```text

```

Render with parameters:

```bash
quarto render report.qmd -P dataset:other.csv -P year:2025
```

### Cross-References

Reference figures, tables, and sections:

```markdown
See @fig-plot for the visualization.
Results are shown in @tbl-results.
Details in @sec-methods.

## Methods {#sec-methods}

```{python}
#| label: fig-plot
#| fig-cap: "My plot"
```text

```{python}
#| label: tbl-results
#| tbl-cap: "Results table"
```text

```

### Including External Content

```markdown
Include other files:
{{< include _content.qmd >}}

Include code from file:
```{python}
#| file: analysis.py
```text

Include images:
![Caption](path/to/image.png){#fig-img}

```

## File Organization

Recommended project structure:

```text

project/
├── analysis/
│   ├── 01_import.qmd
│   ├── 02_clean.qmd
│   └── 03_analyze.qmd
├── reports/
│   ├── summary.qmd
│   └── technical.qmd
├──_quarto.yml           # Project config
├── references.bib        # Bibliography
└── data/
    └── *.csv

```

## Project Configuration (_quarto.yml)

Set project-wide defaults:

```yaml
project:
  type: default
  output-dir: _output

format:
  html:
    theme: cosmo
    toc: true
    code-fold: true
  typst:
    toc: true
    margin:
      x: 1in
      y: 1in

execute:
  echo: true
  warning: false
  cache: true
```

## Troubleshooting

### Common Issues

#### YAML Syntax Errors

- Check indentation (use spaces, not tabs)
- Ensure colons have space after them
- Quote strings with special characters

#### Code Execution Errors

- Verify kernel/engine is installed (Python, R, etc.)
- Check code chunk syntax (triple backticks + language)
- Use `#| error: true` to show errors without failing

#### Rendering Failures

- Run `quarto check` to verify installation
- Check for missing dependencies (pandoc, tinytex for PDF)
- Review error messages for missing files or packages

#### Typst Specific

- Ensure Quarto 1.4+ is installed for Typst support
- Use `keep-typ: true` to debug intermediate .typ files
- Check font availability for custom fonts

### Debug Commands

```bash
# Check Quarto installation
quarto check

# Show detailed rendering info
quarto render document.qmd --verbose

# Keep intermediate files
quarto render document.qmd --keep-md

# List available formats
quarto render document.qmd --help
```

## Best Practices

1. **Use Relative Paths**: Keep documents portable with relative file paths
2. **Version Control**: Commit .qmd files, not rendered outputs (unless needed)
3. **Cache Long Computations**: Use `cache: true` for expensive code chunks
4. **Separate Concerns**: Keep data processing separate from presentation
5. **Test Incrementally**: Render frequently during development
6. **Document Dependencies**: List required packages in setup chunk
7. **Use Project Config**: Set common options in _quarto.yml
8. **Cross-Reference Smartly**: Use meaningful labels for figures/tables

## References

- Quarto Documentation: <https://quarto.org/docs/>
- HTML Format Guide: <https://quarto.org/docs/output-formats/html-basics.html>
- Typst Format Guide: <https://quarto.org/docs/output-formats/typst.html>
- Code Cells: <https://quarto.org/docs/computations/execution-options.html>
- Cross-References: <https://quarto.org/docs/authoring/cross-references.html>

## Available Assets

- `assets/template_html.qmd` - Basic HTML analysis template
- `assets/template_typst.qmd` - Basic Typst document template
- `assets/template_dual.qmd` - Template for both formats
- `assets/template_report.qmd` - Formal report structure
- `assets/_quarto.yml` - Example project configuration

## Available Scripts

- `scripts/create_quarto.py` - Generate new Quarto documents from templates
- `scripts/render_all.py` - Batch render multiple documents
- `scripts/validate_yaml.py` - Check YAML front matter syntax

## When to Use This Skill

Invoke this skill when you need to:

- Create new Quarto markdown documents
- Set up HTML or Typst output formats
- Configure document rendering options
- Integrate analysis code (Python, R, Stata, etc.)
- Structure reports or analysis documentation
- Debug Quarto rendering issues
- Set up Quarto projects

## Interaction Guidelines

When helping users:

1. **Ask About Requirements**: Clarify output format (HTML/Typst), content type, and audience
2. **Suggest Appropriate Templates**: Recommend templates based on use case
3. **Explain Options**: Help users understand YAML configuration choices
4. **Show Examples**: Provide concrete code chunk examples
5. **Test Renders**: Verify documents render correctly before finishing
6. **Document Decisions**: Explain why certain options were chosen
