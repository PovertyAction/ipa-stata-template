# nbstata Demo Files

This directory contains demo files for testing the [nbstata](https://hugetim.github.io/nbstata/) kernel connection to Stata.
All files contain identical Stata code demonstrating core nbstata features.

## Requirements

- Stata 17+
- Python with nbstata package installed (`pip install nbstata`)
- nbstata kernel registered (`python -m nbstata.install`)

## Demo Files

### `nbstata-demo.do`

Traditional Stata do-file with cell markers for use with the
[vscode-stata](https://marketplace.visualstudio.com/items?itemName=kylebutts.vscode-stata) extension.

**Usage:**

1. Open in VS Code with the vscode-stata extension installed
2. Use `Ctrl+Shift+Enter` to run cells (marked with `* %%`)
3. Results display in the Stata output pane

### `nbstata-demo.qmd`

Quarto markdown document with Stata code blocks using the nbstata kernel.
In VS Code, use the [Quarto](https://marketplace.visualstudio.com/items?itemName=quarto.quarto) extension.

**Usage:**

1. Open in VS Code with the Quarto extension installed
2. Results display in the Quarto output pane

Or render the full Quarto notebook as follows.

```bash
# Render to HTML
quarto render scripts\demo\nbstata-demo.qmd

# Preview with live reload
quarto preview scripts\demo\nbstata-demo.qmd
```

### `nbstata-demo.ipynb`

Jupyter notebook for use in JupyterLab, VS Code, or any Jupyter-compatible environment.

**Usage:**

```bash
# Open in JupyterLab
 uv run jupyter lab scripts\demo\nbstata-demo.ipynb

# Open in VS Code
code scripts\demo\nbstata-demo.ipynb
```

## Features Demonstrated

| Feature | Description |
| --------- | ------------- |
| `%browse` | Interactive data browser widget |
| `%head N` | Display first N observations |
| `%tail N` | Display last N observations |
| `regress` | Regression output display |
| `twoway` | Graph rendering in notebooks |
| `etable` | Formatted estimation tables |

## Troubleshooting

**Kernel not found:**

```bash
# Verify nbstata is installed
python -c "import nbstata; print(nbstata.__version__)"

# Re-register the kernel
python -m nbstata.install
```

**Stata not detected:**

```bash
# Check Stata path configuration
python -c "from nbstata.config import get_config; print(get_config())"
```

**Graph not displaying:**
Ensure your Stata installation supports PNG graph export. Try setting graph dimensions:

```stata
%set graph_width = 8
%set graph_height = 5
```

## Documentation

- [nbstata User Guide](https://hugetim.github.io/nbstata/user_guide.html)
- [Quarto with Jupyter Kernels](https://quarto.org/docs/computations/jupyter-kernels.html)
- [vscode-stata Extension](https://marketplace.visualstudio.com/items?itemName=stata.stata)
