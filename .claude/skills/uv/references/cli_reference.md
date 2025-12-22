# uv CLI Command Reference

This reference provides detailed information about uv command-line interface options and advanced usage patterns.

## Core Commands

### uv run

Execute a command or script in a project environment.

**Syntax:**

```bash
uv run [OPTIONS] <COMMAND> [ARGS]...
```

**Common Options:**

- `--with <PACKAGE>` - Add a package for this invocation only
- `--python <VERSION>` - Use a specific Python version
- `--no-sync` - Skip environment synchronization
- `--frozen` - Run without updating the lockfile
- `--isolated` - Run in an isolated environment ignoring project
- `--no-project` - Ignore project configuration
- `--package <PACKAGE>` - Run a command from a specific package in a workspace

**Examples:**

```bash
# Run with temporary dependency
uv run --with httpx python script.py

# Run with specific Python version
uv run --python 3.11 pytest

# Run without syncing environment
uv run --no-sync python app.py

# Run isolated from project
uv run --isolated python script.py
```

**Special Behaviors:**

- Automatically installs project into `.venv` if needed
- Updates environment if `pyproject.toml` or lockfile changed
- Forwards signals to child processes (Unix)
- Supports Windows scripts (.ps1, .cmd, .bat)
- Can execute HTTP(S) URLs containing Python code
- Handles Python modules with `-m` flag

### uv add

Add dependencies to the project.

**Syntax:**

```bash
uv add [OPTIONS] <PACKAGE>...
```

**Common Options:**

- `--dev` - Add as development dependency
- `--optional <GROUP>` - Add to optional dependency group
- `--editable` - Install in editable mode (for local packages)
- `--script <FILE>` - Add dependency to a script's inline metadata
- `--no-sync` - Add to pyproject.toml without syncing environment
- `--frozen` - Add without updating lockfile
- `--rev <REV>` - Git revision for VCS dependencies
- `--tag <TAG>` - Git tag for VCS dependencies
- `--branch <BRANCH>` - Git branch for VCS dependencies

**Examples:**

```bash
# Add regular dependency
uv add requests

# Add with version constraint
uv add 'httpx>=0.25,<0.27'

# Add development dependency
uv add --dev pytest pytest-cov

# Add to optional group
uv add --optional docs sphinx

# Add from git repository
uv add --git https://github.com/user/repo.git package-name

# Add with specific git branch
uv add --git https://github.com/user/repo.git --branch main package-name

# Add editable local package
uv add --editable ./local-package

# Add to script inline metadata
uv add --script analyze.py pandas numpy
```

### uv remove

Remove dependencies from the project.

**Syntax:**

```bash
uv remove [OPTIONS] <PACKAGE>...
```

**Common Options:**

- `--dev` - Remove from development dependencies
- `--optional <GROUP>` - Remove from optional dependency group
- `--script <FILE>` - Remove from script's inline metadata
- `--no-sync` - Remove from pyproject.toml without syncing environment

**Examples:**

```bash
# Remove dependency
uv remove requests

# Remove dev dependency
uv remove --dev pytest

# Remove from optional group
uv remove --optional docs sphinx

# Remove from script
uv remove --script analyze.py pandas
```

### uv sync

Synchronize the project environment with the lockfile.

**Syntax:**

```bash
uv sync [OPTIONS]
```

**Common Options:**

- `--frozen` - Sync without updating the lockfile
- `--no-dev` - Exclude development dependencies
- `--only-dev` - Include only development dependencies
- `--no-install-project` - Don't install the project itself
- `--no-install-workspace` - Don't install workspace members
- `--no-install-package <PACKAGE>` - Skip specific packages

**Examples:**

```bash
# Standard sync
uv sync

# Sync without updating lockfile
uv sync --frozen

# Sync without dev dependencies (for production)
uv sync --no-dev

# Sync only dev dependencies
uv sync --only-dev
```

### uv lock

Update the project lockfile without syncing the environment.

**Syntax:**

```bash
uv lock [OPTIONS]
```

**Common Options:**

- `--upgrade` - Upgrade all dependencies to latest compatible versions
- `--upgrade-package <PACKAGE>` - Upgrade specific package only
- `--frozen` - Assert lockfile is up-to-date without updating
- `--script <FILE>` - Lock dependencies for a script

**Examples:**

```bash
# Update lockfile
uv lock

# Upgrade all dependencies
uv lock --upgrade

# Upgrade specific package
uv lock --upgrade-package httpx

# Lock script dependencies
uv lock --script analyze.py
```

## Project Management

### uv init

Create a new project or initialize the current directory.

**Syntax:**

```bash
uv init [OPTIONS] [PATH]
```

**Common Options:**

- `--name <NAME>` - Project name (defaults to directory name)
- `--lib` - Create a library project
- `--app` - Create an application project (default)
- `--script` - Initialize a Python script with inline metadata
- `--python <VERSION>` - Specify Python version requirement
- `--no-readme` - Don't create README.md
- `--no-pin-python` - Don't create .python-version file

**Examples:**

```bash
# Create new project
uv init my-project

# Create library
uv init --lib my-library

# Initialize current directory
uv init

# Create with specific Python version
uv init --python 3.12 my-project

# Create standalone script
uv init --script analyze.py
```

### uv build

Build source distributions and wheels.

**Syntax:**

```bash
uv build [OPTIONS] [SRC]
```

**Common Options:**

- `--sdist` - Build source distribution only
- `--wheel` - Build wheel only
- `--out-dir <DIR>` - Output directory (default: `dist/`)
- `--package <PACKAGE>` - Build specific package in workspace

**Examples:**

```bash
# Build both sdist and wheel
uv build

# Build wheel only
uv build --wheel

# Build to specific directory
uv build --out-dir ./build
```

### uv publish

Upload distributions to a package index.

**Syntax:**

```bash
uv publish [OPTIONS] [FILES]...
```

**Common Options:**

- `--index-url <URL>` - Package index URL
- `--token <TOKEN>` - Authentication token
- `--username <USER>` - Username for authentication
- `--password <PASS>` - Password for authentication
- `--publish-url <URL>` - Override upload URL

**Examples:**

```bash
# Publish to PyPI (requires authentication)
uv publish

# Publish to Test PyPI
uv publish --index-url https://test.pypi.org/legacy/

# Publish with token
uv publish --token $PYPI_TOKEN

# Publish specific files
uv publish dist/*
```

## Python Version Management

### uv python install

Install Python versions.

**Syntax:**

```bash
uv python install [OPTIONS] [VERSION]...
```

**Examples:**

```bash
# Install specific version
uv python install 3.12

# Install multiple versions
uv python install 3.11 3.12 3.13

# Install latest patch version
uv python install 3.12.x
```

### uv python list

List available or installed Python versions.

**Syntax:**

```bash
uv python list [OPTIONS]
```

**Common Options:**

- `--all-versions` - Show all available versions
- `--only-installed` - Show only installed versions

**Examples:**

```bash
# List installed versions
uv python list

# List all available versions
uv python list --all-versions
```

### uv python find

Find a Python installation.

**Syntax:**

```bash
uv python find [OPTIONS] [VERSION]
```

**Examples:**

```bash
# Find any Python
uv python find

# Find specific version
uv python find 3.12

# Find with version constraint
uv python find ">=3.11"
```

### uv python pin

Pin the project to a specific Python version.

**Syntax:**

```bash
uv python pin [OPTIONS] <VERSION>
```

**Examples:**

```bash
# Pin to specific version
uv python pin 3.12

# Pin with version constraint
uv python pin ">=3.11,<3.13"
```

## Tool Management

### uv tool run / uvx

Run a tool without installing it.

**Syntax:**

```bash
uvx [OPTIONS] <COMMAND> [ARGS]...
# or
uv tool run [OPTIONS] <COMMAND> [ARGS]...
```

**Common Options:**

- `--from <PACKAGE>` - Install tool from specific package
- `--with <PACKAGE>` - Include additional packages
- `--python <VERSION>` - Use specific Python version

**Examples:**

```bash
# Run tool ephemerally
uvx ruff check .

# Run from specific package
uvx --from black black --check .

# Run with additional dependencies
uvx --with pandas python -c "import pandas; print(pandas.__version__)"
```

### uv tool install

Install a tool globally.

**Syntax:**

```bash
uv tool install [OPTIONS] <PACKAGE>
```

**Common Options:**

- `--with <PACKAGE>` - Include additional packages
- `--python <VERSION>` - Use specific Python version
- `--force` - Force reinstallation

**Examples:**

```bash
# Install tool
uv tool install ruff

# Install with additional packages
uv tool install jupyter --with ipython

# Force reinstall
uv tool install --force black
```

### uv tool list

List installed tools.

**Syntax:**

```bash
uv tool list
```

### uv tool uninstall

Uninstall a tool.

**Syntax:**

```bash
uv tool uninstall <PACKAGE>
```

## pip-Compatible Commands

### uv pip install

Install packages (pip-compatible interface).

**Syntax:**

```bash
uv pip install [OPTIONS] <PACKAGE>...
```

**Common Options:**

- `-r <FILE>` - Install from requirements file
- `-e <PATH>` - Install in editable mode
- `--upgrade` - Upgrade packages
- `--no-deps` - Don't install dependencies
- `--python <VERSION>` - Target Python version

**Examples:**

```bash
# Install package
uv pip install requests

# Install from requirements.txt
uv pip install -r requirements.txt

# Install editable package
uv pip install -e ./local-package

# Upgrade package
uv pip install --upgrade httpx
```

### uv pip compile

Generate a locked requirements file.

**Syntax:**

```bash
uv pip compile [OPTIONS] <INPUT>
```

**Common Options:**

- `-o <FILE>` - Output file
- `--upgrade` - Upgrade all dependencies
- `--upgrade-package <PACKAGE>` - Upgrade specific package
- `--no-annotate` - Exclude comments in output
- `--no-header` - Exclude header in output

**Examples:**

```bash
# Compile pyproject.toml
uv pip compile pyproject.toml -o requirements.txt

# Compile with upgrades
uv pip compile --upgrade pyproject.toml -o requirements.txt

# Compile from requirements.in
uv pip compile requirements.in -o requirements.txt
```

### uv pip sync

Sync environment to a requirements file.

**Syntax:**

```bash
uv pip sync [OPTIONS] <FILE>...
```

**Examples:**

```bash
# Sync to requirements file
uv pip sync requirements.txt

# Sync to multiple files
uv pip sync requirements.txt dev-requirements.txt
```

### uv pip freeze

List installed packages in requirements format.

**Syntax:**

```bash
uv pip freeze [OPTIONS]
```

**Examples:**

```bash
# List all packages
uv pip freeze

# Save to file
uv pip freeze > requirements.txt
```

### uv pip list

List installed packages in table format.

**Syntax:**

```bash
uv pip list [OPTIONS]
```

**Common Options:**

- `--editable` - List only editable packages
- `--exclude-editable` - Exclude editable packages
- `--format <FORMAT>` - Output format (columns, freeze, json)

**Examples:**

```bash
# List packages
uv pip list

# List in JSON format
uv pip list --format json
```

### uv pip tree

Display dependency tree.

**Syntax:**

```bash
uv pip tree [OPTIONS]
```

**Common Options:**

- `--depth <DEPTH>` - Maximum display depth
- `--prune <PACKAGE>` - Exclude package and dependencies
- `--package <PACKAGE>` - Show tree for specific package

**Examples:**

```bash
# Show full tree
uv pip tree

# Limit depth
uv pip tree --depth 2

# Show tree for specific package
uv pip tree --package httpx
```

## Virtual Environment Management

### uv venv

Create a virtual environment.

**Syntax:**

```bash
uv venv [OPTIONS] [PATH]
```

**Common Options:**

- `--python <VERSION>` - Python version to use
- `--seed` - Install pip, setuptools, and wheel
- `--system-site-packages` - Give access to system packages

**Examples:**

```bash
# Create venv in .venv
uv venv

# Create with specific Python
uv venv --python 3.12

# Create in custom location
uv venv ./my-venv

# Create with system packages access
uv venv --system-site-packages
```

## Cache Management

### uv cache clean

Remove all cached data.

**Syntax:**

```bash
uv cache clean [OPTIONS] [PACKAGE]...
```

**Examples:**

```bash
# Clean all cache
uv cache clean

# Clean specific package
uv cache clean httpx
```

### uv cache prune

Remove unused cached data.

**Syntax:**

```bash
uv cache prune [OPTIONS]
```

**Common Options:**

- `--ci` - Optimize for CI environments

**Examples:**

```bash
# Prune unused cache
uv cache prune
```

### uv cache dir

Show cache directory path.

**Syntax:**

```bash
uv cache dir
```

## Global Options

These options work with most uv commands:

- `--verbose` / `-v` - Increase verbosity (use multiple times for more detail)
- `--quiet` / `-q` - Decrease verbosity
- `--color <WHEN>` - Control color output (auto, always, never)
- `--no-progress` - Disable progress bars
- `--config-file <PATH>` - Use specific config file
- `--no-config` - Ignore configuration files

## Environment Variables

Key environment variables that affect uv behavior:

- `UV_PYTHON` - Default Python version for projects
- `UV_INDEX_URL` - Default package index URL
- `UV_EXTRA_INDEX_URL` - Additional package index URLs
- `UV_CACHE_DIR` - Cache directory location
- `UV_NO_CACHE` - Disable cache when set
- `UV_SYSTEM_PYTHON` - Allow using system Python
- `VIRTUAL_ENV` - Virtual environment location

## Configuration Files

uv reads configuration from:

1. `pyproject.toml` - Project-specific settings under `[tool.uv]`
2. `uv.toml` - Dedicated uv configuration file
3. User-level config: `~/.config/uv/uv.toml` (Unix) or `%APPDATA%\uv\uv.toml` (Windows)

Example `pyproject.toml` configuration:

```toml
[tool.uv]
index-url = "https://pypi.org/simple"
extra-index-url = ["https://download.pytorch.org/whl/cu118"]
no-cache = false

[tool.uv.pip]
no-binary = ["pillow"]
```
