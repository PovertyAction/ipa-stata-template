# Ruff Rules Reference

This document provides a comprehensive reference for Ruff lint rules and categories.

## Rule Prefixes

| Prefix | Source | Description |
| -------- | -------- | ------------- |
| **F** | Pyflakes | Errors, undefined names, unused imports |
| **E** | pycodestyle | PEP 8 errors |
| **W** | pycodestyle | PEP 8 warnings |
| **C90** | mccabe | Cyclomatic complexity |
| **I** | isort | Import sorting |
| **N** | pep8-naming | Naming conventions |
| **D** | pydocstyle | Docstring conventions |
| **UP** | pyupgrade | Modernize Python syntax |
| **B** | flake8-bugbear | Likely bugs and design problems |
| **S** | flake8-bandit | Security issues |
| **A** | flake8-builtins | Shadowing builtins |
| **Q** | flake8-quotes | Quote consistency |
| **SIM** | flake8-simplify | Simplification suggestions |
| **RET** | flake8-return | Return statement issues |
| **ARG** | flake8-unused-arguments | Unused function arguments |
| **PTH** | flake8-use-pathlib | Prefer pathlib over os.path |
| **PD** | pandas-vet | Pandas best practices |
| **PL** | Pylint | Various checks from Pylint |
| **T20** | flake8-print | Print statement detection |
| **ERA** | eradicate | Commented-out code detection |
| **RUF** | Ruff-specific | Ruff's own rules |

## Rule Categories by Purpose

### Essential (Start Here)

```toml
select = [
    "F",   # Pyflakes - errors and undefined names
    "E",   # pycodestyle errors - PEP 8 violations
    "I",   # isort - import sorting
]
```

### Recommended (Add Next)

```toml
select = [
    "F", "E", "I",
    "W",   # pycodestyle warnings
    "UP",  # pyupgrade - modernize syntax
    "B",   # bugbear - likely bugs
    "SIM", # simplify - simplification suggestions
]
```

### Advanced (Optional)

```toml
select = [
    "F", "E", "I", "W", "UP", "B", "SIM",
    "S",     # bandit - security issues
    "N",     # pep8-naming - naming conventions
    "C90",   # mccabe - complexity checking
    "A",     # flake8-builtins - shadowing builtins
    "Q",     # flake8-quotes - quote consistency
    "RET",   # flake8-return - return statement issues
    "ARG",   # flake8-unused-arguments
    "PTH",   # flake8-use-pathlib
    "PD",    # pandas-vet
]
```

## Common Rules

### Pyflakes (F)

| Rule | Description |
| ------ | ------------- |
| F401 | Module imported but unused |
| F402 | Import shadowed by loop variable |
| F403 | `from module import *` used |
| F405 | Name may be undefined from star import |
| F501 | Invalid % format string |
| F601 | Dictionary key literal repeated |
| F811 | Redefinition of unused name |
| F821 | Undefined name |
| F841 | Local variable assigned but never used |

### pycodestyle Errors (E)

| Rule | Description |
| ------ | ------------- |
| E101 | Indentation contains mixed spaces and tabs |
| E111 | Indentation is not a multiple of expected |
| E117 | Over-indented |
| E201 | Whitespace after '(' |
| E203 | Whitespace before ':' |
| E225 | Missing whitespace around operator |
| E231 | Missing whitespace after ',' |
| E501 | Line too long |
| E711 | Comparison to None |
| E712 | Comparison to True/False |
| E713 | Test for membership should use 'not in' |
| E721 | Use isinstance() instead of type() |
| E722 | Do not use bare 'except' |
| E731 | Do not assign a lambda expression |
| E741 | Ambiguous variable name |

### Import Sorting (I)

| Rule | Description |
| ------ | ------------- |
| I001 | Import block is unsorted or unformatted |
| I002 | Missing required import |

### Bugbear (B)

| Rule | Description |
| ------ | ------------- |
| B002 | Use of functools.lru_cache on methods |
| B006 | Do not use mutable data structures for default arguments |
| B007 | Loop control variable not used within loop |
| B008 | Do not perform function calls in argument defaults |
| B009 | Do not call getattr with a constant attribute |
| B010 | Do not call setattr with a constant attribute |
| B015 | Pointless comparison |
| B017 | assertRaises(Exception) is too broad |
| B018 | Found useless expression |
| B023 | Function definition does not bind loop variable |
| B028 | No explicit stacklevel keyword argument |

### pyupgrade (UP)

| Rule | Description |
| ------ | ------------- |
| UP001 | Use **all** instead of * imports |
| UP003 | Use {} instead of type("", (), {}) |
| UP004 | Class inherits from object |
| UP006 | Use dict instead of Dict |
| UP007 | Use X \| Y for union types |
| UP008 | Use super() instead of super(**class**, self) |
| UP009 | UTF-8 encoding declaration is unnecessary |
| UP010 | Unnecessary future import |
| UP015 | Unnecessary open mode parameters |
| UP035 | Import from collections.abc |
| UP036 | Version block is outdated |

### Security (S)

| Rule | Description |
| ------ | ------------- |
| S101 | Use of assert detected |
| S102 | Use of exec detected |
| S103 | Permissive file permissions |
| S104 | Binding to all interfaces |
| S105 | Hardcoded password string |
| S106 | Hardcoded password function argument |
| S107 | Hardcoded password default |
| S108 | Hardcoded temp file |
| S110 | Try/except/pass detected |
| S301 | Pickle use detected |
| S303 | Use of insecure MD2/4/5 hash |
| S311 | Pseudo-random generators not for security |
| S324 | Insecure hash function |
| S501 | SSL verification disabled |
| S506 | Unsafe YAML load |
| S602 | subprocess call with shell=True |
| S603 | subprocess call without shell=False |
| S607 | Start process with partial executable path |
| S608 | Possible SQL injection |

### Simplify (SIM)

| Rule | Description |
| ------ | ------------- |
| SIM101 | Multiple isinstance calls for same argument |
| SIM102 | Collapsible if statements |
| SIM103 | Return condition directly |
| SIM105 | Use contextlib.suppress |
| SIM107 | Return in try/except/finally |
| SIM108 | Use ternary operator |
| SIM109 | Use tuple comparison |
| SIM110 | Use any() |
| SIM111 | Use all() |
| SIM115 | Use context handler for file open |
| SIM117 | Combine with statements |
| SIM118 | Use key in dict |
| SIM201 | Negate condition to use else |
| SIM210 | Use bool() |
| SIM212 | Use ternary without negation |
| SIM220 | Use x instead of (x and not x) |
| SIM300 | Yoda condition |

## Inline Rule Configuration

### Disable Rules

```python
# Ignore all rules for this line
import os  # noqa

# Ignore specific rule
import os  # noqa: F401

# Ignore multiple rules
x = 1  # noqa: E701, E702

# Ignore for entire file (at top)
# ruff: noqa

# Disable specific rule for entire file
# ruff: noqa: F401
```

### Per-file Ignores

```toml
[tool.ruff.per-file-ignores]
"tests/*.py" = ["S101", "PLR2004"]  # Allow assert, magic values
"__init__.py" = ["F401"]            # Allow unused imports
"scripts/*.py" = ["T201"]           # Allow print statements
"conftest.py" = ["E501"]            # Allow long lines
```

## Resources

- Full rules documentation: <https://docs.astral.sh/ruff/rules/>
- Rule selection: <https://docs.astral.sh/ruff/linter/#rule-selection>
