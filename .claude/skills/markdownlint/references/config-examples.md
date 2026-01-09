# Markdownlint Configuration Examples

This document provides configuration templates and examples for markdownlint-cli2.

## Configuration File Detection

Markdownlint automatically detects configuration files in the following order:

1. `.markdownlint-cli2.jsonc`
2. `.markdownlint-cli2.yaml`
3. `.markdownlint-cli2.cjs` or `.markdownlint-cli2.mjs`
4. `.markdownlint.jsonc` or `.markdownlint.json`
5. `.markdownlint.yaml` or `.markdownlint.yml`
6. `.markdownlint.cjs` or `.markdownlint.mjs`
7. `package.json` (under `markdownlint-cli2` key)

Specify a custom configuration file:

```bash
markdownlint-cli2 --config .markdownlint-custom.json "**/*.md"
```

## Basic Configuration

### Simple JSON Configuration

Create a `.markdownlint.json` file:

```json
{
  "default": true,
  "MD013": false,
  "MD033": false
}
```

### JSONC with Comments

Create a `.markdownlint-cli2.jsonc` file:

```jsonc
{
  // Use default rules
  "config": {
    "default": true,
    // Disable line length rule
    "MD013": false,
    // Allow inline HTML
    "MD033": false,
    // Customize list indentation
    "MD007": {
      "indent": 2
    }
  },
  // Files to ignore
  "globs": ["**/*.md"],
  "ignores": ["node_modules", "CHANGELOG.md"]
}
```

### YAML Configuration

Create a `.markdownlint.yaml` file:

```yaml
default: true

# Disable line length
MD013: false

# Allow inline HTML
MD033: false

# List indentation
MD007:
  indent: 2

# Duplicate headings allowed under different parents
MD024:
  siblings_only: true
```

## Common Configuration Patterns

### Documentation Projects

Optimized for documentation sites:

```json
{
  "default": true,
  "MD013": false,
  "MD033": false,
  "MD041": false,
  "MD024": {
    "siblings_only": true
  }
}
```

### Strict Mode

Maximum enforcement:

```json
{
  "default": true,
  "MD013": {
    "line_length": 120,
    "code_blocks": false,
    "tables": false
  }
}
```

### Minimal Rules

Catch only critical issues:

```json
{
  "default": false,
  "MD001": true,
  "MD009": true,
  "MD010": true,
  "MD040": true
}
```

## CI/CD Integration Examples

### GitHub Actions

```yaml
name: Lint Markdown
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm install -g markdownlint-cli2
      - run: markdownlint-cli2 "**/*.md" "#node_modules"
```

### Pre-commit Hook

Add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/DavidAnson/markdownlint-cli2
    rev: v0.12.1
    hooks:
      - id: markdownlint-cli2
```

## Ignoring Files

### Via Configuration

In `.markdownlint-cli2.jsonc`:

```jsonc
{
  "ignores": [
    "node_modules/**",
    "vendor/**",
    "CHANGELOG.md",
    "**/generated/**"
  ]
}
```

### Via .markdownlintignore

Create a `.markdownlintignore` file (gitignore syntax):

```text
node_modules/
vendor/
CHANGELOG.md
**/generated/
```

## Resources

- Configuration schema: <https://github.com/DavidAnson/markdownlint-cli2#configuration>
- All configuration options: <https://github.com/DavidAnson/markdownlint#optionsconfig>
