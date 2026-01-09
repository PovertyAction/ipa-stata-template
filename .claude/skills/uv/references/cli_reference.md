# uv CLI Reference

This document provides a comprehensive reference for uv commands and options.

## Command Overview

| Command | Purpose |
|---------|---------|
| `uv run` | Execute commands in project environment |
| `uv add` | Add dependencies to project |
| `uv remove` | Remove dependencies from project |
| `uv sync` | Sync environment with lockfile |
| `uv lock` | Update lockfile |
| `uv init` | Create new project |
| `uv build` | Build distributions |
| `uv publish` | Publish to PyPI |
| `uv python` | Manage Python installations |
| `uv tool` | Manage CLI tools |
| `uvx` | Run tools without installation |
| `uv pip` | pip-compatible commands |
| `uv venv` | Create virtual environments |

## uv run

Execute commands within the project environment.

### Basic Usage

```bash
uv run <command> [args...]
```

### Options

| Option | Description |
|--------|-------------|
| `--with <pkg>` | Include additional dependency |
| `--with-requirements <file>` | Include dependencies from file |
| `--python <version>` | Use specific Python version |
| `--no-sync` | Skip environment sync |
| `--frozen` | Don't update lockfile |
| `--isolated` | Ignore project dependencies |

### Examples

```bash
# Run Python script
uv run script.py

# Run Python module
uv run python -m pytest

# Run CLI tool
uv run ruff check .

# Add temporary dependency
uv run --with httpx python -c "import httpx"

# Multiple temporary dependencies
uv run --with httpx --with rich script.py

# Use specific Python version
uv run --python 3.11 script.py
```

## uv add

Add dependencies to the project.

### Basic Usage

```bash
uv add <package> [packages...]
```

### Options

| Option | Description |
|--------|-------------|
| `--dev` | Add as development dependency |
| `--optional <group>` | Add to optional dependency group |
| `--script <file>` | Add to script's inline metadata |
| `--requirements <file>` | Add from requirements file |
| `--frozen` | Don't update lockfile |

### Examples

```bash
# Add runtime dependency
uv add requests

# Add with version constraint
uv add 'httpx>=0.25,<0.27'

# Add multiple packages
uv add numpy pandas matplotlib

# Add development dependency
uv add --dev pytest pytest-cov

# Add optional dependency
uv add --optional docs sphinx sphinx-rtd-theme

# Add to script
uv add --script analyze.py pandas
```

## uv remove

Remove dependencies from the project.

### Basic Usage

```bash
uv remove <package> [packages...]
```

### Options

| Option | Description |
|--------|-------------|
| `--dev` | Remove from development dependencies |
| `--optional <group>` | Remove from optional group |
| `--script <file>` | Remove from script metadata |

### Examples

```bash
uv remove requests
uv remove --dev pytest
uv remove --optional docs sphinx
```

## uv sync

Synchronize the environment with the lockfile.

### Basic Usage

```bash
uv sync
```

### Options

| Option | Description |
|--------|-------------|
| `--frozen` | Don't update lockfile |
| `--no-install-project` | Skip project installation |
| `--extra <group>` | Include optional group |
| `--all-extras` | Include all optional groups |
| `--dev` | Include dev dependencies (default) |
| `--no-dev` | Exclude dev dependencies |

### Examples

```bash
# Sync all dependencies
uv sync

# Sync without dev dependencies
uv sync --no-dev

# Sync with optional group
uv sync --extra docs

# Sync all optional groups
uv sync --all-extras
```

## uv lock

Update the lockfile.

### Basic Usage

```bash
uv lock
```

### Options

| Option | Description |
|--------|-------------|
| `--upgrade` | Upgrade all dependencies |
| `--upgrade-package <pkg>` | Upgrade specific package |
| `--script <file>` | Lock script dependencies |

### Examples

```bash
# Update lockfile
uv lock

# Upgrade all dependencies
uv lock --upgrade

# Upgrade specific package
uv lock --upgrade-package requests

# Lock script dependencies
uv lock --script analyze.py
```

## uv init

Create a new project or script.

### Basic Usage

```bash
uv init [name]
```

### Options

| Option | Description |
|--------|-------------|
| `--lib` | Create library project |
| `--app` | Create application project (default) |
| `--script <file>` | Create script with inline metadata |
| `--python <version>` | Specify Python version |
| `--no-readme` | Skip README creation |
| `--no-pin-python` | Don't pin Python version |

### Examples

```bash
# Create application in new directory
uv init my-project

# Create library
uv init --lib my-library

# Create in current directory
uv init

# Create script with metadata
uv init --script analyze.py --python 3.12

# Specify Python version
uv init --python 3.11
```

## uv python

Manage Python installations.

### Subcommands

| Subcommand | Description |
|------------|-------------|
| `install` | Install Python version |
| `list` | List available versions |
| `find` | Find installed Python |
| `pin` | Pin project Python version |
| `uninstall` | Remove Python installation |

### Examples

```bash
# Install Python version
uv python install 3.12
uv python install 3.11 3.10

# List available versions
uv python list

# Find installed Python
uv python find

# Pin project version
uv python pin 3.12

# Uninstall version
uv python uninstall 3.10
```

## uv tool

Manage CLI tools.

### Subcommands

| Subcommand | Description |
|------------|-------------|
| `run` | Run tool (same as uvx) |
| `install` | Install tool globally |
| `uninstall` | Uninstall tool |
| `list` | List installed tools |
| `upgrade` | Upgrade installed tool |

### Examples

```bash
# Run tool without installing
uv tool run ruff check .
uvx ruff check .  # Shorthand

# Install tool globally
uv tool install ruff

# List installed tools
uv tool list

# Upgrade tool
uv tool upgrade ruff

# Uninstall tool
uv tool uninstall ruff
```

## uv pip

pip-compatible commands for legacy workflows.

### Subcommands

| Subcommand | Description |
|------------|-------------|
| `install` | Install packages |
| `uninstall` | Uninstall packages |
| `freeze` | Output installed packages |
| `list` | List installed packages |
| `show` | Show package info |
| `tree` | Show dependency tree |
| `compile` | Compile requirements |
| `sync` | Sync to requirements |

### Examples

```bash
# Install packages
uv pip install requests
uv pip install -r requirements.txt

# Freeze installed packages
uv pip freeze > requirements.txt

# Show dependency tree
uv pip tree

# Compile pyproject.toml to requirements
uv pip compile pyproject.toml -o requirements.txt

# Sync to requirements file
uv pip sync requirements.txt
```

## uv build

Build distributions.

### Basic Usage

```bash
uv build
```

### Options

| Option | Description |
|--------|-------------|
| `--sdist` | Build source distribution only |
| `--wheel` | Build wheel only |
| `--out-dir <dir>` | Output directory |

### Examples

```bash
# Build both sdist and wheel
uv build

# Build wheel only
uv build --wheel

# Specify output directory
uv build --out-dir dist/
```

## uv publish

Publish to package index.

### Basic Usage

```bash
uv publish
```

### Options

| Option | Description |
|--------|-------------|
| `--index-url <url>` | Package index URL |
| `--token <token>` | Authentication token |
| `--username <user>` | Username |
| `--password <pass>` | Password |

### Examples

```bash
# Publish to PyPI
uv publish

# Publish to test PyPI
uv publish --index-url https://test.pypi.org/legacy/

# With token
uv publish --token $PYPI_TOKEN
```

## Script Inline Metadata

Scripts can declare dependencies inline:

```python
# /// script
# dependencies = [
#   "requests<3",
#   "rich",
# ]
# requires-python = ">=3.12"
# ///

import requests
import rich
```

### Managing Script Dependencies

```bash
# Initialize script with metadata
uv init --script script.py --python 3.12

# Add dependencies to script
uv add --script script.py requests rich

# Remove from script
uv remove --script script.py rich

# Lock script dependencies
uv lock --script script.py

# Run script (uses inline dependencies)
uv run script.py
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `UV_PYTHON` | Default Python version |
| `UV_CACHE_DIR` | Cache directory location |
| `UV_NO_CACHE` | Disable caching |
| `UV_LINK_MODE` | Link mode (copy, hardlink, symlink) |
| `UV_INDEX_URL` | Default package index |
| `UV_EXTRA_INDEX_URL` | Additional package indexes |

## Resources

- Official docs: <https://docs.astral.sh/uv/>
- CLI reference: <https://docs.astral.sh/uv/reference/cli/>
- GitHub: <https://github.com/astral-sh/uv>
