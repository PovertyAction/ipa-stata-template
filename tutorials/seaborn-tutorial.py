# %% [markdown]
# # Data Visualization with Seaborn Tutorial
# **1-Hour Workshop for IPA Research & Data Science Hub**
#
# This interactive tutorial condenses the full 7-lesson data visualization workshop
# into a focused 1-hour session. You'll learn to create compelling visualizations
# using Python's seaborn library and its modern `seaborn.objects` interface.
#
# ## Learning Objectives
#
# By the end of this tutorial, you will be able to:
#
# - Understand the grammar of graphics framework
# - Create visualizations using `seaborn.objects`
# - Map data variables to visual properties (position, color, size, shape)
# - Choose appropriate marks (dots, lines, bars) for different data types
# - Customize plots with labels, scales, and colorblind-friendly palettes
# - Create multi-panel figures with faceting
# - Add statistical summaries (means, regression lines, confidence intervals)
# - Produce publication-ready figures for research reports
#
# ## Prerequisites
#
# - Basic Python knowledge (variables, functions, importing libraries)
# - Familiarity with pandas DataFrames (helpful but not required)
# - Python environment with required packages installed:
#   ```bash
#   uv pip install pandas seaborn matplotlib
#   ```
#
# ## Time Expectation
#
# This tutorial is designed for a 1-hour live instruction session with hands-on
# exercises. Work through the sections sequentially, running code as you go.
#
# ---

# %% [markdown]
# ## Section 1: Setup and Introduction
#
# Data visualization helps us discover patterns, communicate findings, and quality-check
# our data. The `seaborn.objects` interface uses a **grammar of graphics** approach -
# the same principled framework behind R's ggplot2.
#
# Instead of thinking about "chart types," we think about **components**:
# - **Data**: What we want to visualize
# - **Aesthetic mappings**: How variables map to visual properties (x, y, color, size)
# - **Marks**: The shapes representing data (dots, lines, bars)
# - **Scales**: How data values translate to visual values
# - **Facets**: Small multiples for comparing subsets

# %%
# If using a uv virtual environment, ensure it's synced (`uv sync`) and activated
# (`.venv\Scripts\activate` on Windows or `source .venv/bin/activate` on Mac/Linux)
# before running this code.
# Import libraries
import numpy as np
import pandas as pd
import seaborn as sns
import seaborn.objects as so

# Set random seed for reproducibility
np.random.seed(42)

print("✓ Libraries imported successfully!")
print(f"Seaborn version: {sns.__version__}")

# %% [markdown]
# ### Load the Penguins Dataset
#
# We'll use the Palmer Penguins dataset - measurements of penguin species from Antarctica.
# It's perfect for learning because it has:
# - Multiple species (categorical)
# - Continuous measurements (body mass, flipper length, bill dimensions)
# - Clear relationships to explore

# %%
# Load penguins dataset (built into seaborn)
penguins = sns.load_dataset("penguins")

# Display first few rows
print("Dataset shape:", penguins.shape)
print("\nFirst 5 rows:")
print(penguins.head())

# Check for missing values
print("\nMissing values per column:")
print(penguins.isnull().sum())

# Create clean version without missing values
penguins_clean = penguins.dropna()
print(f"\nClean dataset: {len(penguins_clean)} rows")

# %%
# Review the dataset structure
penguins_clean.describe(include="all").T


# %% [markdown]
# ---
# ## Section 2: Your First Plot & Grammar of Graphics Basics
#
# Let's create our first visualization! The basic pattern in seaborn.objects is:
#
# ```python
# (
#     so.Plot(data, x="variable1", y="variable2")  # Data and mappings
#     .add(so.Dot())                                # Mark (what to draw)
# )
# ```

# %%
# Create a simple scatter plot
(so.Plot(penguins_clean, x="flipper_length_mm", y="body_mass_g").add(so.Dot()))

# %% [markdown]
# **What we see**: Penguins with longer flippers tend to have greater body mass!
#
# ### Adding Color to Show Groups
#
# Let's add color to distinguish penguin species:

# %%
# Enhanced plot with color by species
(
    so.Plot(
        penguins_clean, x="flipper_length_mm", y="body_mass_g", color="species"
    ).add(so.Dot())
)

# %% [markdown]
# **Key insight**: Different species cluster in different parts of the plot.
# The `color="species"` automatically:
# - Assigns distinct colors to each species
# - Creates a legend
# - Makes patterns visible
#
# ### Exercise 1: Create Your First Plot
#
# Create a scatter plot showing the relationship between `bill_length_mm` (x-axis)
# and `bill_depth_mm` (y-axis), colored by `species`.

# %%
# Exercise 1: Your code here
# Hint: Copy the structure above and change the x and y variables

# Solution (uncomment to see):
# (
#     so.Plot(
#         penguins_clean,
#         x="bill_length_mm",
#         y="bill_depth_mm",
#         color="species"
#     )
#     .add(so.Dot())
# )

# %% [markdown]
# ---
# ## Section 3: Visual Properties (Aesthetics) (10 minutes)
#
# We can map data to multiple visual properties simultaneously:
#
# | Aesthetic | Controls | Best For |
# |-----------|----------|----------|
# | `x`, `y` | Position | Any data type |
# | `color` | Color | Categorical groups or continuous gradients |
# | `pointsize` | Size | Continuous magnitude |
# | `marker` | Shape | Categorical (≤6 categories) |
# | `alpha` | Transparency | Showing density/overlap |
#
# ### Mapping Size

# %%
# Size by body mass creates a "bubble plot"
(
    so.Plot(
        penguins_clean, x="bill_length_mm", y="bill_depth_mm", pointsize="body_mass_g"
    ).add(so.Dot())
)

# %% [markdown]
# ### Combining Multiple Aesthetics
#
# Let's show **four variables at once**: bill length (x), bill depth (y),
# species (color), and body mass (size)!

# %%
# Multi-dimensional visualization
(
    so.Plot(
        penguins_clean,
        x="bill_length_mm",
        y="bill_depth_mm",
        color="species",
        pointsize="body_mass_g",
    ).add(so.Dot(alpha=0.6))  # alpha=0.6 adds transparency
)

# %% [markdown]
# ### Using Shape for Accessibility
#
# Combining color AND shape makes plots accessible to colorblind viewers:

# %%
# Both color and shape for species (accessibility best practice)
(
    so.Plot(
        penguins_clean,
        x="flipper_length_mm",
        y="body_mass_g",
        color="species",
        marker="species",
    ).add(so.Dot())
)

# %% [markdown]
# ### Exercise 2: Multi-Aesthetic Plot
#
# Create a plot showing:
# - x: `flipper_length_mm`
# - y: `body_mass_g`
# - color: `island`
# - marker: `sex`
#
# (Note: Filter out missing sex values first)

# %%
# Exercise 2: Your code here
penguins_complete = penguins_clean.dropna(subset=["sex"])

# Your plot code here:


# Solution (uncomment to see):
# (
#     so.Plot(
#         penguins_complete,
#         x="flipper_length_mm",
#         y="body_mass_g",
#         color="island",
#         marker="sex"
#     )
#     .add(so.Dot(alpha=0.7))
# )

# %% [markdown]
# ---
# ## Section 4: Marks (Geometric Objects)
#
# **Marks** are the visual elements that represent data. Choose marks based on your data:
#
# - **`so.Dot()`**: Scatter plots (individual observations, relationships)
# - **`so.Line()`**: Time series, trends, continuous functions
# - **`so.Bar()`**: Categorical comparisons, counts, aggregated values
# - **`so.Band()`**: Confidence intervals, ranges
# - **`so.Area()`**: Cumulative values, composition over time
#
# ### Lines: Showing Trends Over Time

# %%
# Create time series data (monthly program enrollment)
months = pd.date_range("2023-01-01", periods=12, freq="ME")
enrollment_data = pd.DataFrame(
    {
        "month": months,
        "enrolled": [120, 145, 162, 180, 195, 210, 235, 248, 265, 282, 295, 310],
        "program": "Microfinance Training",
    }
)

# Line plot for time series
(so.Plot(enrollment_data, x="month", y="enrolled").add(so.Line()))

# %% [markdown]
# ### Combining Lines and Dots

# %%
# Show both trend and individual data points
(so.Plot(enrollment_data, x="month", y="enrolled").add(so.Line()).add(so.Dot()))

# %% [markdown]
# ### Bars: Comparing Categories

# %%
# Average body mass by species
# IMPORTANT: Bars automatically compute the MEAN for each group!
# Even though we have hundreds of penguins, so.Bar() shows the average body mass
# per species, not individual values. This is different from so.Dot() which shows every point.
(so.Plot(penguins_clean, x="species", y="body_mass_g", color="species").add(so.Bar()))

# %% [markdown]
# ### Multiple Lines for Comparison

# %%
# Create multi-program data
multi_program_data = pd.DataFrame(
    {
        "month": list(months) * 3,
        "enrolled": [
            120,
            145,
            162,
            180,
            195,
            210,
            235,
            248,
            265,
            282,
            295,
            310,
        ]  # Microfinance
        + [80, 95, 102, 118, 135, 155, 168, 185, 198, 215, 228, 242]  # Agriculture
        + [200, 198, 205, 210, 218, 222, 235, 242, 255, 265, 278, 290],  # Education
        "program": ["Microfinance"] * 12 + ["Agriculture"] * 12 + ["Education"] * 12,
    }
)

# Compare multiple programs
(so.Plot(multi_program_data, x="month", y="enrolled", color="program").add(so.Line()))

# %% [markdown]
# ### Exercise 3: Create a Time Series with Dots and Lines
#
# Using the `multi_program_data`, create a plot with both lines and dots.
# Use color to distinguish programs.

# %%
# Exercise 3: Your code here
# Hint: Use two .add() calls - one for Line(), one for Dot()


# Solution (uncomment):
# (
#     so.Plot(multi_program_data, x="month", y="enrolled", color="program")
#     .add(so.Line())
#     .add(so.Dot())
# )

# %% [markdown]
# ---
# ## Section 5: Labels, Scales & Customization
#
# Professional visualizations need clear labels and appropriate scales.
# Use `.label()` to add titles and axis labels.
#
# ### Adding Labels

# %%
# Plot without labels - NOT ready to share
(
    so.Plot(
        penguins_clean, x="flipper_length_mm", y="body_mass_g", color="species"
    ).add(so.Dot())
)

# Same plot WITH labels - ready for presentation!
(
    so.Plot(penguins_clean, x="flipper_length_mm", y="body_mass_g", color="species")
    .add(so.Dot())
    .label(
        title="Relationship Between Flipper Length and Body Mass in Penguins",
        x="Flipper Length (mm)",
        y="Body Mass (g)",
        color="Penguin Species",
    )
)

# %% [markdown]
# ### Colorblind-Friendly Palettes
#
# Use the "colorblind" palette to ensure accessibility:

# %%
# Default colors
(
    so.Plot(penguins_clean, x="bill_length_mm", y="bill_depth_mm", color="species")
    .add(so.Dot(pointsize=5))
    .label(title="Default Colors")
)

# %%
# Colorblind-friendly palette
(
    so.Plot(penguins_clean, x="bill_length_mm", y="bill_depth_mm", color="species")
    .add(so.Dot(pointsize=5))
    .scale(color="colorblind")
    .label(title="Colorblind-Friendly Palette")
)

# %% [markdown]
# ### Controlling Axis Limits and Scales

# %%
# Zoom in on a specific region with limits
(
    so.Plot(penguins_clean, x="flipper_length_mm", y="body_mass_g", color="species")
    .add(so.Dot())
    .scale(
        x=so.Continuous().tick(every=10),  # Tick marks every 10mm
        y=so.Continuous().label(like="${x:.0f}"),  # Format as whole numbers
    )
    .label(
        title="Penguin Body Measurements (Customized Scales)",
        x="Flipper Length (mm)",
        y="Body Mass (g)",
        color="Species",
    )
)

# %% [markdown]
# ### Exercise 4: Label a Complex Plot
#
# Take the multi-aesthetic plot from Exercise 2 and add:
# - A clear title
# - Axis labels with units
# - A colorblind-friendly palette

# %%
# Exercise 4: Your code here
# Start with your Exercise 2 solution and add .label() and .scale()


# Solution (uncomment):
# (
#     so.Plot(
#         penguins_complete,
#         x="flipper_length_mm",
#         y="body_mass_g",
#         color="island",
#         marker="sex"
#     )
#     .add(so.Dot(alpha=0.7, pointsize=5))
#     .scale(color="colorblind")
#     .label(
#         title="Penguin Body Measurements by Island and Sex",
#         x="Flipper Length (mm)",
#         y="Body Mass (g)",
#         color="Island",
#         marker="Sex"
#     )
# )

# %% [markdown]
# ---
# ## Section 6: Faceting & Statistical Transformations
#
# ### Part A: Faceting (Small Multiples)
#
# **Faceting** creates small multiples - the same plot repeated for different subsets.
# Use `.facet()` to split by categories.
#
# ### When to use **color** vs **facets**:
# - **Color**: 2-5 categories, want to see overlap
# - **Facets**: Many categories (>5), clearer separation, comparing distributions

# %%
# Compare with color (overlap visible)
(
    so.Plot(penguins_clean, x="bill_length_mm", y="bill_depth_mm", color="species")
    .add(so.Dot())
    .label(title="Using Color")
)

# %%
# Compare with facets (clearer for each group)
(
    so.Plot(penguins_clean, x="bill_length_mm", y="bill_depth_mm")
    .add(so.Dot())
    .facet(col="species")
    .label(
        x="Bill Length (mm)",
        y="Bill Depth (mm)",
    )
)

# %% [markdown]
# ### Understanding Facet Titles
#
# **Important**: Notice that seaborn.objects **automatically displays facet values
# as panel titles** above each plot. The `.facet(col="species")` created three panels
# labeled "Adelie", "Chinstrap", and "Gentoo" without any extra code!
#
# **Customization options:**
# - **Default behavior**: Omit `title` from `.label()` - facet values appear automatically
# - **Add a prefix**: `.label(col="Species: ")` creates titles like "Species: Adelie"
# - **Custom function**: `.label(title=lambda col_name, row_name: f"{col_name}")` for logic
# - **Overall figure title**: Use `.label(title="Main Title")` for a suptitle above all panels

# %% [markdown]
# ### Combining Faceting and Color
#
# Facet by one variable, color by another for even more dimensions!

# %%
# Facet by island, color by species
# Note: Island names automatically appear as panel titles ("Biscoe", "Dream", "Torgersen")
(
    so.Plot(penguins_clean, x="flipper_length_mm", y="body_mass_g", color="species")
    .add(so.Dot(alpha=0.6))
    .facet(col="island")
    .scale(color="colorblind")
    .label(
        x="Flipper Length (mm)",
        y="Body Mass (g)",
        color="Species",
    )
)

# %% [markdown]
# ### Part B: Statistical Transformations
#
# **Why add statistical layers?** Raw data shows all the variation, but statistical
# summaries reveal patterns like central tendencies, trends, and uncertainty. Combining
# raw data with summaries gives viewers both detail and big-picture insights.
#
# Add statistical summaries by combining marks with **stats**:
# - `so.Agg()`: Compute means or other aggregations
# - `so.Est()`: Add confidence intervals
# - `so.PolyFit()`: Fit regression lines
#
# Pattern: `.add(so.Mark(), so.Stat())`

# %%
# Show both raw data and means
(
    so.Plot(penguins_clean, x="species", y="body_mass_g", color="species")
    .add(so.Dot(alpha=0.3, pointsize=3))  # Raw data
    .add(so.Dot(pointsize=10), so.Agg())  # Mean as larger dots
    .label(
        title="Penguin Body Mass: Individual Values and Means",
        x="Species",
        y="Body Mass (g)",
        color="Species",
    )
)

# %% [markdown]
# ### Confidence Intervals

# %%
# Means with confidence intervals
(
    so.Plot(penguins_clean, x="species", y="body_mass_g", color="species")
    .add(so.Dot(pointsize=10), so.Agg())  # Mean
    .add(so.Range(), so.Est())  # 95% confidence interval
    .scale(color="colorblind")
    .label(
        title="Mean Body Mass with 95% Confidence Intervals",
        x="Species",
        y="Body Mass (g)",
        color="Species",
    )
)

# %% [markdown]
# ### Regression Lines

# %%
# Scatter plot with linear regression
(
    so.Plot(penguins_clean, x="flipper_length_mm", y="body_mass_g", color="species")
    .add(so.Dot(alpha=0.5))  # Raw data
    .add(so.Line(), so.PolyFit(order=1))  # Linear regression (order=1)
    .scale(color="colorblind")
    .label(
        title="Flipper Length vs Body Mass with Linear Fits",
        x="Flipper Length (mm)",
        y="Body Mass (g)",
        color="Species",
    )
)

# %% [markdown]
# ### Combining Everything: Faceted Plot with Statistical Layer

# %%
# Comprehensive visualization: facets + regression lines + confidence bands
# Note: Species names automatically appear as panel titles ("Adelie", "Chinstrap", "Gentoo")
(
    so.Plot(penguins_clean, x="bill_length_mm", y="bill_depth_mm")
    .add(so.Dot(alpha=0.4, color="gray"))  # Raw data
    # IMPORTANT: color="red" is a FIXED color (applies red to all data)
    # This is different from color="species" which MAPS data values to colors
    .add(so.Line(color="red"), so.PolyFit(order=1))  # Regression line
    .add(so.Band(alpha=0.2, color="red"), so.PolyFit(order=1))  # Confidence band
    .facet(col="species")
    .label(
        x="Bill Length (mm)",
        y="Bill Depth (mm)",
    )
)

# %% [markdown]
# ### Exercise 5: Create a Faceted Visualization with Statistics
#
# Create a plot that:
# 1. Shows `flipper_length_mm` (x) vs `body_mass_g` (y)
# 2. Facets by `sex` (columns)
# 3. Colors by `species`
# 4. Adds linear regression lines for each species
# 5. Includes proper labels

# %%
# Exercise 5: Your code here
# Hint: Use .facet(col="sex"), color="species", and .add(so.Line(), so.PolyFit(order=1))


# Solution (uncomment):
# (
#     so.Plot(
#         penguins_complete,
#         x="flipper_length_mm",
#         y="body_mass_g",
#         color="species"
#     )
#     .add(so.Dot(alpha=0.5))
#     .add(so.Line(), so.PolyFit(order=1))
#     .facet(col="sex")  # Sex values automatically appear as panel titles ("Male", "Female")
#     .scale(color="colorblind")
#     .label(
#         x="Flipper Length (mm)",
#         y="Body Mass (g)",
#         color="Species"
#     )
# )

# %% [markdown]
# ---
# ## Section 7: Themes & Wrap-up (5 minutes)
#
# ### Applying Themes
#
# Themes control the overall appearance of your plots. Seaborn provides several
# professional themes.

# %%
# Default theme
(
    so.Plot(penguins_clean, x="species", y="body_mass_g", color="species")
    .add(so.Bar())
    .label(title="Default Theme")
)

# %%
# Apply whitegrid theme using axes_style
(
    so.Plot(penguins_clean, x="species", y="body_mass_g", color="species")
    .add(so.Bar())
    .theme(sns.axes_style("whitegrid"))
    .scale(color="colorblind")
    .label(title="Whitegrid Theme with Colorblind Palette")
)

# %%

# Reset to default
sns.set_theme()

# %% [markdown]
# ### Available Themes
#
# For `seaborn.objects` plots, apply themes using `sns.axes_style()` with the `.theme()` method:
#
# ```python
# .theme(sns.axes_style("whitegrid"))
# ```
#
# **Available styles:**
# - `"darkgrid"` (default): Gray background with white grid
# - `"whitegrid"`: White background with gray grid
# - `"dark"`: Gray background, no grid
# - `"white"`: White background, no grid
# - `"ticks"`: White background with tick marks
#
# **For presentations**: Use `"whitegrid"` or `"white"`
# **For papers**: Use `"white"` or `"ticks"`
# **For exploratory analysis**: Use `"darkgrid"` (default)
#
# ### Comparing Different Themes
#
# Let's see how different themes look:

# %%
# White theme (clean, minimal)
(
    so.Plot(penguins_clean, x="species", y="body_mass_g", color="species")
    .add(so.Bar())
    .theme(sns.axes_style("white"))
    .scale(color="colorblind")
    .label(title="White Theme (Minimal)")
)

# %%
# Ticks theme (white background with axis ticks)
(
    so.Plot(penguins_clean, x="species", y="body_mass_g", color="species")
    .add(so.Bar())
    .theme(sns.axes_style("ticks"))
    .scale(color="colorblind")
    .label(title="Ticks Theme (For Publications)")
)

# %%
# Dark theme (dark background, no grid)
(
    so.Plot(penguins_clean, x="species", y="body_mass_g", color="species")
    .add(so.Bar())
    .theme(sns.axes_style("dark"))
    .scale(color="colorblind")
    .label(title="Dark Theme")
)

# %% [markdown]
# ### Saving Plots
#
# Save your visualizations for reports and presentations:

# %%
# Create a publication-ready plot
plot = (
    so.Plot(penguins_clean, x="flipper_length_mm", y="body_mass_g", color="species")
    .add(so.Dot(alpha=0.6))
    .add(so.Line(), so.PolyFit(order=1))
    .scale(color="colorblind")
    .label(
        title="Penguin Body Mass vs Flipper Length by Species",
        x="Flipper Length (mm)",
        y="Body Mass (g)",
        color="Species",
    )
    .theme({"axes.labelsize": 12, "axes.titlesize": 14, "legend.fontsize": 10})
)

# Display the plot
plot

# Save as PNG (high resolution for publications)
# plot.save("penguin_analysis.png", dpi=300, bbox_inches="tight")

# Save as PDF (vector format, best for papers)
# plot.save("penguin_analysis.pdf", bbox_inches="tight")

# %% [markdown]
# ### Best Practices Summary
#
# - **Always use clear labels** with units (mm, g, USD, etc.)
# - **Choose colorblind-friendly palettes** for accessibility
# - **Match mark types to data types**:
#    - Dots for scatter plots and individual observations
#    - Lines for time series and trends
#    - Bars for categorical comparisons
# - **Use faceting** for comparing many categories (>5)
# - **Combine raw data with summaries** (dots + means, scatter + regression)
# - **Add statistical context** (confidence intervals, regression lines)
# - **Save at appropriate resolution** (300 DPI for publications)
# - **Think about your audience** (colleagues, policymakers, community members)
#
# - **Don't** use pie charts (hard to compare angles)
# - **Don't** use 3D plots (perspective distorts perception)
# - **Don't** use red-green color schemes (colorblind unfriendly)
# - **Don't** over-complicate (simplicity aids understanding)

# %% [markdown]
# ---
# ## Workshop Summary
#
# ### What You Learned
#
#
# 1. **Create basic plots** with `so.Plot()` and `.add()`
# 2. **Map variables to aesthetics** (x, y, color, size, shape)
# 3. **Choose appropriate marks** (Dot, Line, Bar, Band)
# 4. **Customize with labels** and colorblind-friendly palettes
# 5. **Create small multiples** with `.facet()`
# 6. **Add statistical layers** (aggregations, regression lines, confidence intervals)
# 7. **Apply professional themes** and save publication-ready figures
#
# ### The Power of Grammar of Graphics
#
# By thinking in terms of **components** rather than "chart types," you can:
# - Build complex visualizations step-by-step
# - Customize every aspect of your plots
# - Create visualizations you haven't seen before
# - Understand how any visualization is constructed
#
# ### Next Steps
#
# #### Practice with Your Own Data
#
# The best way to learn is by doing! Try:
# 1. Apply these techniques to your research data
# 2. Recreate visualizations from papers you admire
# 3. Experiment with different combinations of marks and aesthetics
# 4. Get feedback from colleagues on clarity
#
# #### Explore the Full Tutorial Series
#
# This 1-hour workshop is condensed from a comprehensive 7-lesson series.
# For deeper exploration, visit the IPA Research & Data Science Hub:
#
# - **Lesson 1**: Introduction to Seaborn
# - **Lesson 2**: Grammar of Graphics
# - **Lesson 3**: Marks and Geometric Objects
# - **Lesson 4**: Labels and Customization
# - **Lesson 5**: Faceting and Layering
# - **Lesson 6**: Statistical Transformations
# - **Lesson 7**: Themes and Final Polish
#
# Visit: [IPA Research & Data Science Hub](https://poverty-action.github.io/ipa-data-tech-hub/) for full tutorials
#
# #### Additional Resources
#
# - **Seaborn Documentation**: [seaborn.pydata.org](https://seaborn.pydata.org/)
# - **Seaborn Objects Guide**: [seaborn.pydata.org/tutorial/objects_interface.html](https://seaborn.pydata.org/tutorial/objects_interface.html)
# - **Python Graph Gallery**: [python-graph-gallery.com](https://python-graph-gallery.com/)
# - **Data Viz Books**:
#   - "Fundamentals of Data Visualization" by Claus O. Wilke
#   - "The Visual Display of Quantitative Information" by Edward Tufte
#
#
# ---
#
# ## Bonus: Quick Reference Cheat Sheet
#
# ### Basic Plot Structure
# ```python
# (
#     so.Plot(data, x="var1", y="var2", color="var3")
#     .add(so.Dot())
#     .label(title="Title", x="X Label", y="Y Label")
# )
# ```
#
# ### Common Marks
# - `so.Dot()` - Scatter plots
# - `so.Line()` - Time series, trends
# - `so.Bar()` - Categorical comparisons
# - `so.Band()` - Confidence intervals
# - `so.Area()` - Cumulative/stacked areas
#
# ### Common Stats
# - `so.Agg()` - Compute means
# - `so.Est()` - Add confidence intervals
# - `so.PolyFit(order=1)` - Linear regression
# - `so.PolyFit(order=2)` - Quadratic fit
#
# ### Aesthetics
# - `x`, `y` - Position
# - `color` - Color encoding
# - `pointsize` - Size encoding
# - `marker` - Shape encoding
# - `alpha` - Transparency (0-1)
#
# ### Customization
# ```python
# .scale(color="colorblind")  # Colorblind-friendly palette
# .facet(col="variable")       # Small multiples
# .label(title="...", x="...", y="...")  # Labels
# .theme({"axes.labelsize": 12})  # Fine-tune appearance
# ```
#
# ### Saving
# ```python
# plot.save("figure.png", dpi=300, bbox_inches="tight")  # High-res PNG
# plot.save("figure.pdf", bbox_inches="tight")           # Vector PDF
# ```
#
# ---
#
# **Thank you for participating in this workshop!**
#
# 🚀 **Now go create amazing visualizations for your research!**
#
# *Questions? Visit: [IPA Research & Data Science Hub](https://poverty-action.github.io/ipa-data-tech-hub/)*

# %%
