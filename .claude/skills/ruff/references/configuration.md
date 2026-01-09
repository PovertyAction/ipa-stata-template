# Ruff Configuration Reference

This document provides configuration templates and examples for Ruff.

## Configuration File Detection

Ruff looks for configuration in this order:

1. `ruff.toml`
2. `.ruff.toml`
3. `pyproject.toml` (under `[tool.ruff]`)

## Basic Configuration

### Minimal pyproject.toml

```toml
[tool.ruff]
line-length = 88
target-version = "py311"

select = ["E", "F", "I"]
ignore = ["E501"]
```

### Standard pyproject.toml

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # Pyflakes
    "I",    # isort
    "B",    # flake8-bugbear
    "UP",   # pyupgrade
    "SIM",  # flake8-simplify
]

ignore = [
    "E501",  # Line too long (handled by formatter)
]

exclude = [
    ".git",
    ".venv",
    "__pycache__",
    "build",
    "dist",
]

fixable = ["ALL"]
unfixable = []

[tool.ruff.per-file-ignores]
"tests/**/*.py" = ["S101"]
"__init__.py" = ["F401"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
skip-magic-trailing-comma = false
line-ending = "auto"

[tool.ruff.isort]
known-first-party = ["myapp"]
```

### Standalone ruff.toml

```toml
line-length = 100
target-version = "py311"

select = ["E", "F", "I", "B", "UP"]
ignore = ["E501"]

[format]
quote-style = "double"
indent-style = "space"

[isort]
known-first-party = ["myapp"]
```

## Configuration Options

### Global Options

| Option | Type | Description |
|--------|------|-------------|
| `line-length` | int | Maximum line length (default: 88) |
| `target-version` | str | Python version (e.g., "py311") |
| `select` | list | Rules to enable |
| `ignore` | list | Rules to disable |
| `extend-select` | list | Additional rules to enable |
| `extend-ignore` | list | Additional rules to disable |
| `fixable` | list | Rules that can be auto-fixed |
| `unfixable` | list | Rules that cannot be auto-fixed |
| `exclude` | list | Paths to exclude |
| `extend-exclude` | list | Additional paths to exclude |

### Format Options

```toml
[tool.ruff.format]
quote-style = "double"           # "double", "single", "preserve"
indent-style = "space"           # "space", "tab"
skip-magic-trailing-comma = false
line-ending = "auto"             # "auto", "lf", "cr-lf", "native"
docstring-code-format = false
docstring-code-line-length = "dynamic"
```

### isort Options

```toml
[tool.ruff.isort]
known-first-party = ["myapp"]
known-third-party = ["numpy", "pandas"]
force-single-line = false
force-sort-within-sections = false
combine-as-imports = true
split-on-trailing-comma = true
section-order = [
    "future",
    "standard-library",
    "third-party",
    "first-party",
    "local-folder"
]
```

### McCabe Options

```toml
[tool.ruff.mccabe]
max-complexity = 10
```

### Pylint Options

```toml
[tool.ruff.pylint]
max-args = 5
max-branches = 12
max-returns = 6
max-statements = 50
```

## Common Patterns

### Data Science Projects

```toml
[tool.ruff]
line-length = 100
target-version = "py311"

select = [
    "E", "F", "I", "W",
    "UP",   # Modern Python
    "B",    # Bugbear
    "PD",   # Pandas
]

ignore = [
    "E501",  # Line length
    "PD901", # df as variable name
]

[tool.ruff.per-file-ignores]
"notebooks/*.py" = ["T201", "E402"]  # Allow prints, late imports
```

### Web Application

```toml
[tool.ruff]
line-length = 88
target-version = "py311"

select = [
    "E", "F", "I", "W",
    "UP", "B", "SIM",
    "S",     # Security
    "RET",   # Return statements
]

ignore = ["E501"]

[tool.ruff.per-file-ignores]
"tests/**/*.py" = ["S101"]
"migrations/**/*.py" = ["E501"]
```

### Library/Package

```toml
[tool.ruff]
line-length = 88
target-version = "py39"  # Support older Python

select = [
    "E", "F", "I", "W",
    "UP", "B", "SIM",
    "D",     # Docstrings
    "N",     # Naming
]

ignore = [
    "D100",  # Missing docstring in public module
    "D104",  # Missing docstring in public package
]

[tool.ruff.pydocstyle]
convention = "google"

[tool.ruff.per-file-ignores]
"tests/**/*.py" = ["D", "S101"]
```

### Strict Configuration

```toml
[tool.ruff]
line-length = 88
target-version = "py311"

select = ["ALL"]

ignore = [
    "D",       # Docstrings (optional)
    "ANN",     # Type annotations (use mypy)
    "COM812",  # Missing trailing comma
    "ISC001",  # Single-line string concatenation
]

[tool.ruff.per-file-ignores]
"tests/**/*.py" = ["S101", "PLR2004", "D"]
```

## Pre-commit Integration

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.0
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Lint
on: [push, pull_request]

jobs:
  ruff:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/ruff-action@v1
        with:
          args: "check --output-format=github"
      - uses: astral-sh/ruff-action@v1
        with:
          args: "format --check"
```

### GitLab CI

```yaml
lint:
  image: python:3.11
  script:
    - pip install ruff
    - ruff check --output-format=gitlab .
    - ruff format --check .
```

## VS Code Integration

```json
{
  "ruff.enable": true,
  "ruff.organizeImports": true,
  "[python]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": "explicit",
      "source.organizeImports": "explicit"
    },
    "editor.defaultFormatter": "charliermarsh.ruff"
  }
}
```

## Migration from Other Tools

### From Black

```toml
[tool.ruff]
line-length = 88  # Black default

[tool.ruff.format]
quote-style = "double"  # Black default
```

### From isort

```toml
[tool.ruff.isort]
known-first-party = ["myapp"]
force-single-line = false
combine-as-imports = true
```

### From Flake8

```toml
[tool.ruff]
select = ["E", "F", "W", "C90"]
ignore = ["E203", "E501", "W503"]
line-length = 79

[tool.ruff.mccabe]
max-complexity = 10
```

## Resources

- Configuration docs: <https://docs.astral.sh/ruff/configuration/>
- Settings reference: <https://docs.astral.sh/ruff/settings/>
- Formatter docs: <https://docs.astral.sh/ruff/formatter/>
