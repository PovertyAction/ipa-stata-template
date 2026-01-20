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

---

## Tier 1: Minimal Setup (Git + Stata Only)

**What you need:** Git, Stata 17+

**What you get:** Reproducible analysis with version control

### Steps

1. **Clone the repository**

   ```bash
   git clone <your-repo-url>
   cd ipa-stata-template
   ```

2. **Configure your Stata path**

   Copy `.env-example` to `.env` and set your Stata executable:

   ```bash
   # Windows
   STATA_CMD='C:\Program Files\Stata18\StataSE-64.exe'
   STATA_EDITION='se'

   # macOS
   # STATA_CMD='/Applications/Stata/StataSE.app/Contents/MacOS/StataSE'

   # Linux
   # STATA_CMD='/usr/local/stata18/stata-se'
   ```

3. **Configure your data path** (Optional)

   If your data is stored separately from your code (e.g., on a secure network drive):

   ```bash
   # Windows
   copy config.do.template config.do

   # macOS/Linux
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

4. **Run the pipeline**

   ```bash
   # Batch mode (recommended - creates log files)
   stata -e do do_files/00_run.do

   # Or interactively in Stata
   do do_files/00_run.do
   ```

5. **Check outputs**

   - Tables: `outputs/tables/`
   - Figures: `outputs/figures/`
   - Logs: `logs/`

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

### Batch Mode for AI Assistants

Running Stata in batch mode (`stata -e`) is recommended because:

- Creates log files that AI assistants can read
- Captures all output for debugging
- More reproducible than interactive execution

---

## Tier 2: Add Task Runner (+just)

**What you need:** Everything from Tier 1, plus `just`

**What you get:** Simple commands instead of typing full paths

### Install just

```bash
# Windows
winget install --id Casey.Just -e

# macOS/Linux
brew install just
```

### Use it

```bash
just stata-run      # Run the full pipeline
just stata-config   # Show Stata configuration
just help           # See all commands
```

That's it! No Python or complex setup needed.

---

## Tier 3: Add Dependency Tracking (+scons)

**What you need:** Everything from Tier 2, plus Python via `uv`

**What you get:** Incremental builds - only rebuild what changed

### When to use scons

Use scons if your full pipeline takes **more than 5 minutes** and you're frequently
making changes to individual do-files. For most projects, Tier 1 or 2 is sufficient.

### Setup

```bash
# Install uv first (see https://docs.astral.sh/uv/)
# Windows
winget install --id astral-sh.uv -e

# macOS/Linux
brew install uv

# Then sync the Python environment
uv sync
```

### Use it

```bash
just stata-build    # Build with dependency tracking
just stata-data     # Build only data pipeline
just stata-analysis # Build only analysis
just stata-clean    # Clean all outputs
```

### How it works

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

**What you need:** Everything from Tier 3, plus Node.js

**What you get:** Interactive Stata in VS Code, automatic linting, pre-commit hooks

### Setup

```bash
just get-started
```

This installs everything: `uv`, `git`, `quarto`, `markdownlint`, `nbstata`, Stata packages.

### Features

#### VS Code Integration (nbstata)

Run Stata interactively in VS Code, similar to Ctrl+D workflow:

1. Install the [vscode-stata](https://marketplace.visualstudio.com/items?itemName=kylebutts.vscode-stata) extension
2. Test with files in `do_files/demo/`
3. Select the nbstata kernel at `.venv/Scripts/python.exe`

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

If using this option, do not commit data files (especially large or sensitive ones) to GitHub.

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

### "Command scons not found"

- Ensure you ran `uv sync` to create the Python environment
- Activate the environment: `.venv/Scripts/activate` (Windows) or `source .venv/bin/activate` (Unix)

### Path issues on Windows

- Use forward slashes in file paths
- Quote paths with spaces

### Getting Help

- Check log files in `logs/` for Stata errors
- Review the [statacons documentation](https://bquistorff.github.io/statacons/)
- See the README for additional resources
