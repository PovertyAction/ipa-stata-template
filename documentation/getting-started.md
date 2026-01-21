# Getting Started with the Stata Project Template

This guide helps you set up and use this template at your preferred level of complexity.
Start with **Tier 1** (minimal) and add features as needed.

> [!WARNING]
> NEVER COMMIT DATA FILES TO GITHUB.
>
> NEVER USE AI ASSISTANTS WITH PERSONALLY IDENTIFIABLE DATA.
>
> YOU ARE REQUIRED TO REMOVE IDENTIFYING INFORMATION **BEFORE** CONNECTING AI
> ASSISTANTS OR STORING IN ANY UNENCRYPTED LOCATION.

## Which Tier Should You Use?

| Tier | Time Investment | Best For                            | Key Benefit                          |
|------|-----------------|-------------------------------------|--------------------------------------|
| 1    | 15 min          | Getting started, small projects     | Version control + reproducibility    |
| 2    | +5 min          | Regular use                         | Simple commands (no path typing)     |
| 3    | +10 min         | Projects with long runtimes (>5min) | Only rebuild what changed            |
| 4    | +15 min         | Full-time development               | IDE integration + quality checks     |

## Project File Structure

```text
ipa-stata-template/
├── data/
│   ├── raw/          # Your raw data (never edit!)
│   └── clean/        # Cleaned data (generated)
├── do_files/         # Your Stata scripts
├── outputs/
│   ├── tables/       # Generated tables
│   └── figures/      # Generated figures
├── logs/             # Execution logs
└── ado/              # Local Stata packages
```

---

## Tier 1: Minimal Setup (Git + Stata + Just)

**What you get:** Reproducible analysis with version control

### Installation Checklist (Do these in order)

1. Install Stata 17+: [IPA Box link](https://ipastorage.app.box.com/folder/325607567529?s=ex2qvb00y6lukwo1x3rht0jkuxnbscj8)
2. Install Git

   **Windows:**

   ```bash
   winget install --id Git.Git -e
   ```

   **macOS:**

   ```bash
   brew install git
   ```

   **Linux or manual install:**
   [Download from git-scm.com](https://git-scm.com/downloads)

3. Install Just

   **Windows:**

   ```bash
   winget install --id Casey.Just -e
   ```

   **macOS/Linux:**

   ```bash
   brew install just
   ```

   **Manual install:**
   [Download from GitHub releases](https://github.com/casey/just/releases)

   > **Note:** After installing Git or Just, you may need to **restart your terminal** for the commands to be recognized.

4. (Recommended) Install VS Code

   **Windows:**

   ```bash
   winget install --id Microsoft.VisualStudioCode -e
   ```

   **macOS/Linux:**
   [Download from code.visualstudio.com](https://code.visualstudio.com/download)

5. (Recommended) Install VS Code extensions
   - [Jupyter Extension for VS Code](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)
   - [vscode-stata for running Stata code](https://marketplace.visualstudio.com/items?itemName=kylebutts.vscode-stata)
   - [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) or [Claude Code](https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code) for AI assistance

### Setup Steps

#### 1. Clone the repository

```bash
git clone <your-repo-url>
cd ipa-stata-template
```

#### 2. Configure your Stata path

Copy the example environment file:

**Windows:**

```bash
copy .env-example .env
```

**macOS/Linux:**

```bash
cp .env-example .env
```

Open `.env` in a text editor and set your Stata executable path:

**Windows example:**

```bash
STATA_CMD='C:\Program Files\Stata18\StataSE-64.exe'
STATA_EDITION='se'
```

**macOS example:**

```bash
STATA_CMD='/Applications/Stata/StataSE.app/Contents/MacOS/StataSE'
STATA_EDITION='se'
```

**Linux example:**

```bash
STATA_CMD='/usr/local/stata18/stata-se'
STATA_EDITION='se'
```

> **Tip:** If your Stata path contains spaces, keep the single quotes around the path.

#### 3. Configure your data path (Optional)

If your data is stored separately from your code (e.g., on a secure network drive):

**Windows:**

```bash
copy config.do.template config.do
```

**macOS/Linux:**

```bash
cp config.do.template config.do
```

Then edit `config.do` to set your data location:

```stata
// Example: Network drive
global data_root "X:/SECURE_AREA_12345_project_name_country/data"

// Example: Dropbox
global data_root "D:/Dropbox/ProjectName/data"

// Example: Local documents
global data_root "C:/Users/YourName/Documents/Research/ProjectName/data"
```

**Note:** `config.do` is gitignored and never committed to version control. If you
don't create it, the template defaults to using `data/` in the project root.

#### 4. Set up coding environment

Run this command to set up the Python-Stata bridge:

```bash
just stata-setup
```

**What this does:**

- Creates a Python virtual environment in `.venv/` (takes ~2-3 minutes)
- Installs pystatacons (enables Python to communicate with Stata)
- Installs required Stata packages to `ado/`

**Optional:** Verify the setup was successful:

```bash
just stata-check-installation
```

#### 5. Run the demo pipeline

##### Option A: Batch mode (recommended)

Batch mode runs Stata from the command line and automatically creates log files:

```bash
just stata-do demo/stata-demo
```

> **What is batch mode?** Running Stata from the command line instead of the GUI. This creates automatic log files that are useful for debugging and working with AI assistants.

##### Option B: Interactive mode

Open Stata GUI and run from the project root (`ipa-stata-template/`):

```stata
do do_files/demo/stata-demo.do
```

#### 6. Verify success

**Check for these signs of success:**

- No error messages in the console
- New files created in `outputs/tables/`
- New files created in `outputs/figures/`
- A log file in `logs/` ending with "end of do-file"

**Check outputs:**

- Tables: `outputs/tables/`
- Figures: `outputs/figures/`
- Logs: `logs/`

### Common Setup Issues

**Problem:** `just: command not found` after installation

- **Solution:** Restart your terminal or command prompt

**Problem:** `Stata executable not found`

- **Solution:** Check that the path in `.env` exactly matches your Stata installation location. Use forward slashes (`/`) even on Windows.

**Problem:** Error about spaces in path

- **Solution:** Make sure paths with spaces are wrapped in single quotes in `.env`

**Problem:** Python or virtual environment errors

- **Solution:** Make sure you ran `just stata-setup` from the project root directory

---

## Understanding the Full Template Pipeline

### Understanding `00_run.do`

The master do-file orchestrates your entire pipeline using control switches:

```stata
// Set to 0 to skip during development
local data_cleaning         = 1
local data_preparation      = 1
local descriptive_analysis  = 1
local main_analysis         = 1
local robustness_checks     = 1
local generate_figures      = 1
```

This allows you to quickly iterate on specific parts without re-running everything.

### Why Use Batch Mode?

Running Stata in batch mode (`stata -e` or via `just` commands) is recommended because:

- Creates log files that AI assistants can read
- Captures all output for debugging
- More reproducible than interactive execution

---

## Tier 2: Add Task Runner

**Already completed Tier 1?** Add convenient shortcut commands with these steps.

**What you get:** Simple commands instead of typing full paths

> **Note:** Tier 1 already includes Just installation, so you can skip directly to using the commands.

### Available Commands

```bash
just stata-run      # Run the full pipeline (00_run.do)
just stata-config   # Show Stata configuration
just help           # See all available commands
```

### Common Commands

```bash
# Run individual scripts
just stata-script 01_data_cleaning

# Check your Stata setup
just stata-check-installation

# View system information
just system-info
```

That's it! No additional installation needed.

---

## Tier 3: Add Dependency Tracking

**Already using Just commands?** Add smart rebuilding for large projects.

**What you get:** Incremental builds - only rebuild what changed

> **Incremental builds:** Only re-run scripts whose inputs have changed, saving time on large projects.

### When to Use This Tier

Use dependency tracking if your full pipeline takes **more than 5 minutes** and you're frequently
making changes to individual do-files. For most projects, Tier 1 or 2 is sufficient.

### Setup

Install `uv` (Python package manager):

**Windows:**

```bash
winget install --id astral-sh.uv -e
```

**macOS/Linux:**

```bash
brew install uv
```

**Manual install:**
See [https://docs.astral.sh/uv/](https://docs.astral.sh/uv/)

Then sync the Python environment:

```bash
uv sync
```

### Use It

```bash
just stata-build    # Build with dependency tracking
just stata-data     # Build only data pipeline
just stata-analysis # Build only analysis
just stata-clean    # Clean all outputs
```

### How It Works

scons reads the `SConstruct` file which defines dependencies:

```python
# When 01_data_cleaning.do changes, rebuild cleaned_data.dta
data_clean = env.StataBuild(
    target='data/clean/cleaned_data.dta',
    source='do_files/01_data_cleaning.do'
)
```

If you modify `01_data_cleaning.do`, scons knows to re-run downstream scripts
but not unrelated ones.

---

## Tier 4: Full Development Environment

**Using dependency tracking?** Add IDE integration and automated quality checks.

**What you get:** Interactive Stata in VS Code, automatic linting, pre-commit hooks

### Setup

Run the automated setup command:

```bash
just get-started
```

This installs everything: `uv`, `git`, `quarto`, `markdownlint`, `nbstata`, Stata packages.

### Features

#### VS Code Integration (nbstata)

Run Stata interactively in VS Code, similar to Ctrl+D workflow:

1. Install the [vscode-stata](https://marketplace.visualstudio.com/items?itemName=kylebutts.vscode-stata) extension
2. Test with files in `do_files/demo/`
3. Select the nbstata kernel at `.venv/Scripts/python.exe` (Windows) or `.venv/bin/python` (macOS/Linux)

#### Code Quality

```bash
just lint-stata    # Check Stata code quality
just lint-py       # Check Python code
just fmt-markdown  # Format markdown files
```

#### Report Generation

```bash
just render-report  # Generate analysis report
just preview-report # Preview in browser
```

---

## Customizing for Your Project

### Add Your Data

#### Option 1: Data in project directory (default)

Place raw data in `data/raw/` and update the do-files to reference your files.

**Important:** Do not commit data files (especially large or sensitive ones) to GitHub.

#### Option 2: Data stored separately (recommended for secure/network drives)

1. Copy `config.do.template` to `config.do`
2. Set `global data_root` to your data location
3. Place raw data in `<your-data-path>/raw/`

The template automatically uses your configured path while keeping your code repository
clean and portable. The `config.do` file is gitignored to protect sensitive path information.

### Update Analysis Scripts

- **01_data_cleaning.do**: Modify cleaning steps for your data
- **02_data_preparation.do**: Define your analysis sample
- **03_descriptive_analysis.do**: Customize summary statistics
- **04_main_analysis.do**: Add your regression specifications
- **05_robustness_checks.do**: Define alternative specifications
- **06_generate_figures.do**: Create visualizations

### IPA Visualizations (for IPA Staff)

```stata
net install github, from("https://haghish.github.io/github/")
github install PovertyAction/ipaplots
```

The template automatically uses IPA branding when `ipaplots` is available.

---

## Best Practices

### Data Management

- Never modify files in `data/raw/` (treat as read-only)
- Use global macros for file paths
- Use version control for code, not data files

### Code Organization

- Keep do-files focused on single tasks
- Use descriptive variable names
- Comment extensively
- Include quality checks and validation

### Performance Tips

Before increasing `maxvar`, consider:

1. **Load only needed columns**: `use var1 var2 using "data.dta"`
2. **Reshape to long format**: Wide loops are slow; long operations are fast
3. **Modularize**: Clean one survey module at a time

---

## Troubleshooting

### Stata cannot find do-files

- Ensure you're running from the project root directory
- Check file paths in `.env` match your Stata installation

### "Command just not found" or "Command scons not found"

- Restart your terminal after installation
- Ensure you ran `uv sync` to create the Python environment (for scons)
- Activate the environment manually if needed:
    - Windows: `.venv/Scripts/activate`
    - macOS/Linux: `source .venv/bin/activate`

### Path issues on Windows

- Use forward slashes in file paths (e.g., `C:/Program Files/Stata18/...`)
- Quote paths with spaces in `.env` file

### Python virtual environment errors

- Delete the `.venv/` folder and run `just stata-setup` again
- Make sure you're running commands from the project root directory

### Getting Help

- Check log files in `logs/` for Stata errors
- Review the [statacons documentation](https://bquistorff.github.io/statacons/)
- See the README for additional resources

## Glossary

**Batch mode**: Running Stata from the command line instead of the GUI, which creates automatic log files.

**Dependency tracking**: A system that tracks which files depend on other files, so only necessary scripts are re-run when changes are made.

**Incremental builds**: Only rebuilding outputs that have changed or depend on changed inputs, rather than rebuilding everything from scratch.

**Virtual environment**: An isolated Python environment that keeps project dependencies separate from system-wide Python packages.

**Task runner**: A tool (like `just`) that provides shortcuts for commonly-used command sequences.
