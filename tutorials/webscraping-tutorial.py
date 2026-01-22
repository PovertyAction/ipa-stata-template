# %% [markdown]
# # Web Scraping Tutorial: From Basics to IPA Peace & Recovery Projects
#
# **Instructor Guide for IPA Research & Data Science Hub**
#
# This notebook provides a complete hands-on tutorial for web scraping using gazpacho,
# progressing from fundamentals to scraping real IPA research projects.
#
# ## Learning Objectives
#
# By the end of this tutorial, participants will be able to:
#
# - Make HTTP requests and fetch web page content
# - Parse HTML structure using gazpacho's Soup objects
# - Extract data using tags, classes, and attributes
# - Handle Drupal's multi-class field structure
# - Scrape IPA research project metadata
# - Build DataFrames from scraped data
# - Convert data to multiple output formats (CSV, Markdown)
# - Apply ethical scraping practices
#
# ## Prerequisites
#
# - Basic Python knowledge (variables, functions, lists, dictionaries)
# - Familiarity with pandas is helpful but not required
#
# ---

# %% [markdown]
# ## Setup and Installation
#
# First, let's install the required packages and import what we need.

# %%
# Install required packages
# uv add gazpacho pandas pyyaml

# Import libraries
import re
import time

import pandas as pd
import yaml
from gazpacho import Soup, get

print("✓ All libraries imported successfully!")

# %% [markdown]
# ---
#
# ## Part 1: Making HTTP Requests
#
# Web scraping starts with fetching web pages. The `get()` function from gazpacho makes this simple.
#
# ### Basic Example: Fetching a Simple Webpage

# %%
# Fetch a simple test page
url = "https://example.com"
html = get(url)

print(f"Fetched {len(html)} characters of HTML")
print("\nFirst 500 characters:")
print(html[:500])

# %% [markdown]
# ### Fetch Different Pages
#
# Try fetching these URLs and observe the content:

# %%
# Fetch and compare different pages
test_urls = ["https://httpbin.org/html", "https://httpbin.org/json"]

for url in test_urls:
    html = get(url)
    print(f"\n{url}:")

    # Check if response is a dictionary (JSON) or string (HTML)
    if isinstance(html, dict):
        print("  Type: JSON (dictionary)")
        print(f"  Keys: {list(html.keys())}")
        print(f"  Content preview: {str(html)[:100]}...")
    else:
        print("  Type: HTML (string)")
        print(f"  Length: {len(html)} characters")
        print(f"  Starts with: {html[:100]}...")

# %% [markdown]
# ### Checking robots.txt
#
# Before scraping any website, we should check their robots.txt file:

# %%
# Check IPA's robots.txt
robots_url = "https://poverty-action.org/robots.txt"
robots_content = get(robots_url)

print("IPA robots.txt:")
print(robots_content[:500])

# %% [markdown]
# ---
#
# ## Part 2: Parsing HTML with Soup Objects
#
# Once we have HTML, we need to parse it to extract specific data. Gazpacho's `Soup` class makes this easy.
#
# ### Creating a Soup Object

# %%
# Create a Soup object from HTML
html = """
<html>
<head><title>Example Page</title></head>
<body>
    <h1 class="main-title">Welcome to Web Scraping</h1>
    <p class="intro">This is an introduction to HTML parsing.</p>
    <div class="content">
        <p>First paragraph of content.</p>
        <p>Second paragraph of content.</p>
    </div>
</body>
</html>
"""

soup = Soup(html)
print("✓ Soup object created successfully!")

# %% [markdown]
# ### Finding Elements by Tag

# %%
# Find elements by tag name
title = soup.find("title")
h1 = soup.find("h1")
first_p = soup.find("p")

print("Title:", title.text if title else None)
print("H1:", h1.text if h1 else None)

# Safely handle first_p - check if it's a list or a single element
if first_p:
    if isinstance(first_p, list):
        print("First paragraph:", first_p[0].text if len(first_p) > 0 else None)
    else:
        print("First paragraph:", first_p.text)
else:
    print("First paragraph:", None)

# %% [markdown]
# ### Finding Elements by Class

# %%
# Find elements by class name
main_title = soup.find("h1", {"class": "main-title"})
intro = soup.find("p", {"class": "intro"})

print("Main title:", main_title.text if main_title else None)
print("Intro:", intro.text if intro else None)

# %% [markdown]
# ### Exercise 2: Extract Data from HTML
#
# Parse this article structure and extract the title, author, and date:

# %%
# Exercise: Parse article data
article_html = """
<article>
    <h2 class="article-title">Research Methods in Development Economics</h2>
    <div class="meta">
        <span class="author">Jane Researcher</span>
        <time datetime="2024-01-15">January 15, 2024</time>
    </div>
    <div class="content">
        <p>This article discusses randomized controlled trials in development economics.</p>
    </div>
</article>
"""

# Your code here:
# 1. Create a Soup object from article_html
# 2. Find the h2 element with class "article-title" and extract its text
# 3. Find the span element with class "author" and extract its text
# 4. Find the time element and extract both its text and the 'datetime' attribute

# Hint: Use soup.find(tag, {'class': 'classname'})
# Hint: Use element.text to get text content
# Hint: Use element.attrs.get('attribute_name') to get attributes

# %% [markdown]
# ---
#
# ## Part 3: Working with Attributes and Partial Matching
#
# Modern websites use complex CSS classes. Gazpacho's `partial` parameter helps us match them.
#
# ### Strict vs. Partial Matching

# %%
# HTML with complex class names (like Bootstrap, Tailwind, or Drupal)
complex_html = """
<div class="card shadow-lg rounded-lg p-4">
    <h3 class="card-title text-xl font-bold">Project Title</h3>
    <p class="card-text text-gray-700">Project description</p>
    <a href="#" class="btn btn-primary btn-lg">Read More</a>
</div>
"""

soup = Soup(complex_html)

# Strict matching (won't find it because class has multiple values)
button_strict = soup.find("a", {"class": "btn"}, partial=False)
print("Button (strict):", button_strict.text if button_strict else "Not found")

# Partial matching (will find it)
button_partial = soup.find("a", {"class": "btn"}, partial=True)
print("Button (partial):", button_partial.text if button_partial else "Not found")

# %% [markdown]
# ### Extracting Attributes

# %%
# Extract attributes like href, src, etc.
link_html = """
<a href="https://poverty-action.org/analyzing-effects-venezuelan-migration-colombias-education-system"
   class="project-link"
   data-project-id="123">
    Example Project
</a>
"""

soup = Soup(link_html)
link = soup.find("a")

print("Link text:", link.text)
print("URL:", link.attrs.get("href"))
print("Project ID:", link.attrs.get("data-project-id"))
print("All attributes:", link.attrs)

# %% [markdown]
# ---
#
# ## Part 4: Scraping Real IPA Project Pages
#
# Now let's apply what we've learned to scrape actual IPA research projects!
#
# ### Understanding Drupal Field Structure
#
# IPA's website uses Drupal, which adds classes like `field--name-field-researchers`.

# %%
# Example Drupal field structure
drupal_html = """
<div class="field field--name-field-program-areas field--type-entity-reference">
    <div class="field__label">Program areas</div>
    <div class="field__items">
        <div class="field__item">
            <a href="/taxonomy/term/181">Peace &amp; Recovery</a>
        </div>
    </div>
</div>
"""

soup = Soup(drupal_html)

# Use partial matching to find the field
program_area = soup.find(
    "div", {"class": "field--name-field-program-areas"}, partial=True
)

if program_area:
    link = soup.find("a")
    print("Program Area:", link.text if link else None)
    print("Term ID:", link.attrs.get("href") if link else None)

# %% [markdown]
# ### Helper Functions for Safe Extraction


# %%
def safe_extract_text(element):
    """Safely extract and clean text from element."""
    if element is None:
        return None

    # Handle if element is a list (sometimes soup.find() returns a list)
    if isinstance(element, list):
        if len(element) == 0:
            return None
        element = element[0]  # Take the first element

    text = element.text.strip() if element.text else None

    if not text:
        return None

    # Clean text
    text = re.sub(r"\s+", " ", text)
    text = text.replace("&amp;", "&")
    text = text.replace("&lt;", "<")
    text = text.replace("&gt;", ">")

    return text.strip()


# Test the function
test_html = "<p>   Too   much    whitespace &amp; entities   </p>"
soup = Soup(test_html)
elem = soup.find("p")
print("Cleaned text:", safe_extract_text(elem))

# %% [markdown]
# ### Scraping a Single IPA Project
#
# Let's scrape a real IPA project page!


# %%
def scrape_ipa_project_basic(url):
    """Extract basic information from IPA project page."""
    try:
        print(f"Fetching {url}...")
        html = get(url)
        soup = Soup(html)

        # Extract title
        title_elem = soup.find("h1")
        title = safe_extract_text(title_elem)

        # Extract status
        status_elem = soup.find(
            "div", {"class": "field--name-field-status"}, partial=True
        )
        status = safe_extract_text(status_elem)

        # Extract timeline
        timeline_elem = soup.find(
            "div", {"class": "field--name-field-timeline"}, partial=True
        )
        timeline = safe_extract_text(timeline_elem)

        # Extract countries
        countries_elem = soup.find(
            "div", {"class": "field--name-field-countries"}, partial=True
        )
        countries = safe_extract_text(countries_elem)

        return {
            "title": title,
            "status": status,
            "timeline": timeline,
            "countries": countries,
            "url": url,
        }

    except Exception as e:
        print(f"Error: {e}")
        return None


# Test with a real IPA project
project_url = "https://poverty-action.org/analyzing-effects-venezuelan-migration-colombias-education-system"
project_data = scrape_ipa_project_basic(project_url)

if project_data:
    print("\n" + "=" * 60)
    print("PROJECT DATA")
    print("=" * 60)
    for key, value in project_data.items():
        print(f"{key}: {value}")


# %%
def extract_researchers_from_links(soup):
    """Extract researcher names from links within the researchers field.

    IPA often stores researchers as links to profile pages rather than plain text.

    Args:
        soup: Soup object to search in

    Returns:
        Comma-separated string of researcher names or None

    """
    html_text = soup.html

    # Look for the researchers field (try multiple patterns)
    researcher_patterns = [
        "field--name-field-researchers",
        "field-details-researchers",
        "field-researchers",
        "field-staff",
    ]

    for pattern in researcher_patterns:
        # Find where the researchers field starts (opening tag only)
        # Better approach: extract chunk after opening tag to handle nested divs
        pattern_regex = rf'<div[^>]*class="[^"]*{re.escape(pattern)}[^"]*"[^>]*>'
        match = re.search(pattern_regex, html_text)

        if match:
            # Extract 3000 chars after opening tag (handles nested divs)
            start_pos = match.end()
            chunk = html_text[start_pos : start_pos + 3000]

            # Extract names from nested div structure
            # Pattern: <div class="name notranslate">NAME</div>
            name_pattern = (
                r'<div[^>]*class="[^"]*name notranslate[^"]*"[^>]*>\s*([^<]+)\s*</div>'
            )
            researcher_names = re.findall(name_pattern, chunk)

            if researcher_names:
                # Clean up names
                cleaned_names = []
                for name in researcher_names:
                    name = name.strip()
                    if name and len(name) > 2:
                        cleaned_names.append(name)

                if cleaned_names:
                    return ", ".join(cleaned_names[:10])  # Limit to 10 names

    return None


def extract_staff_from_links(soup):
    """Extract staff names from links within the staff field.

    IPA often stores staff as links to profile pages rather than plain text.

    Args:
        soup: Soup object to search in

    Returns:
        Comma-separated string of staff names or None

    """
    html_text = soup.html

    # Look for the staff field (try multiple patterns)
    staff_patterns = [
        "field--name-field-staff",
        "field-staff",
    ]

    for pattern in staff_patterns:
        # Find where the staff field starts (opening tag only)
        # Better approach: extract chunk after opening tag to handle nested divs
        pattern_regex = rf'<div[^>]*class="[^"]*{re.escape(pattern)}[^"]*"[^>]*>'
        match = re.search(pattern_regex, html_text)

        if match:
            # Extract 3000 chars after opening tag (handles nested divs)
            start_pos = match.end()
            chunk = html_text[start_pos : start_pos + 3000]

            # Extract names from nested div structure
            # Pattern: <div class="name notranslate">NAME</div>
            name_pattern = (
                r'<div[^>]*class="[^"]*name notranslate[^"]*"[^>]*>\s*([^<]+)\s*</div>'
            )
            staff_names = re.findall(name_pattern, chunk)

            if staff_names:
                # Clean up names
                cleaned_names = []
                for name in staff_names:
                    name = name.strip()
                    if name and len(name) > 2:
                        cleaned_names.append(name)

                if cleaned_names:
                    return ", ".join(cleaned_names[:10])  # Limit to 10 names

    return None


def extract_countries_from_taxonomy(soup):
    """Extract country names from taxonomy term links.

    IPA often stores countries as taxonomy term links rather than in Drupal fields.

    Args:
        soup: Soup object to search in

    Returns:
        Comma-separated string of country names or None

    """
    # Common country names to look for in taxonomy links
    country_names = [
        "Colombia",
        "Uganda",
        "Kenya",
        "India",
        "Ghana",
        "Mexico",
        "Peru",
        "Philippines",
        "Rwanda",
        "Tanzania",
        "Zambia",
        "Bangladesh",
        "Malawi",
        "Sierra Leone",
        "Liberia",
        "Nigeria",
        "Pakistan",
        "Haiti",
        "Honduras",
        "Guatemala",
        "El Salvador",
        "Nicaragua",
        "Costa Rica",
        "Panama",
        "Brazil",
        "Argentina",
        "Chile",
        "Ecuador",
        "Bolivia",
        "Paraguay",
        "Uruguay",
        "Venezuela",
        "Dominican Republic",
        "Jamaica",
        "Trinidad and Tobago",
        "Indonesia",
        "Vietnam",
        "Cambodia",
        "Laos",
        "Myanmar",
        "Thailand",
        "Nepal",
        "Sri Lanka",
        "Afghanistan",
        "Ethiopia",
        "Mozambique",
        "Burkina Faso",
        "Mali",
        "Niger",
        "Senegal",
        "Benin",
        "Togo",
        "Cameroon",
        "Democratic Republic of Congo",
        "South Africa",
        "Botswana",
        "Morocco",
        "Egypt",
        "Jordan",
        "Lebanon",
    ]

    # Search for taxonomy term links in the HTML
    html_text = soup.html
    found_countries = []

    # Look for links with /taxonomy/term/ that contain country names
    link_pattern = r'<a[^>]*href="[^"]*\/taxonomy\/term\/[^"]*"[^>]*>([^<]+)<\/a>'
    links = re.findall(link_pattern, html_text)

    for link_text in links:
        # Check if this link text is a country name
        for country in country_names:
            if country.lower() == link_text.strip().lower():
                if country not in found_countries:
                    found_countries.append(country)
                break

    return ", ".join(found_countries) if found_countries else None


def extract_drupal_field(soup, field_class_names):
    """Extract text from a Drupal field, handling nested field__items structure.
    IPA pages use different field naming conventions, so we try multiple patterns.

    Args:
        soup: Soup object to search in
        field_class_names: Single field class name or list of names to try
                          (e.g., ["field--name-field-status", "field-details-study-status"])

    Returns:
        Extracted text or None

    """
    # Convert single string to list for uniform processing
    if isinstance(field_class_names, str):
        field_class_names = [field_class_names]

    # Gazpacho doesn't recursively find nested divs, so search the raw HTML
    html_text = soup.html

    # Try each field class name pattern
    for field_class_name in field_class_names:
        # Build regex pattern for this specific field
        # Look for div with the field class, then try to extract field__item content
        field_regex = rf'<div[^>]*class="[^"]*{re.escape(field_class_name)}[^"]*"[^>]*>(.*?)</div>'

        matches = re.findall(field_regex, html_text, re.DOTALL)

        if matches:
            # Get the content of the first matching div
            content = matches[0]

            # Try to extract from field__item if present
            item_match = re.search(
                r'<div[^>]*class="[^"]*field__item[^"]*"[^>]*>(.*?)</div>',
                content,
                re.DOTALL,
            )
            if item_match:
                content = item_match.group(1)

            # Clean up HTML tags and whitespace
            text = re.sub(r"<[^>]+>", " ", content)
            text = re.sub(r"\s+", " ", text).strip()

            # Decode HTML entities
            text = text.replace("&amp;", "&")
            text = text.replace("&lt;", "<")
            text = text.replace("&gt;", ">")

            return text if text else None

    # None of the patterns matched
    return None


# Exercise: Add extraction for researchers and study type
def scrape_ipa_project_complete(url):
    """Extract comprehensive project information including researchers, study type, and more."""
    html = get(url)
    soup = Soup(html)

    # Extract title
    title_elem = soup.find("h1")
    title = safe_extract_text(title_elem)

    # Extract researchers - try multiple field name patterns
    researchers = extract_drupal_field(
        soup,
        [
            "field--name-field-researchers",
            "field-details-researchers",
            "field-researchers",
            "field-staff",
        ],
    )
    # If no text found (field might contain only links), extract from links
    if not researchers:
        researchers = extract_researchers_from_links(soup)

    # Extract staff - similar to researchers
    staff = extract_drupal_field(
        soup,
        [
            "field--name-field-staff",
            "field-staff",
        ],
    )
    # If no text found (field might contain only links), extract from links
    if not staff:
        staff = extract_staff_from_links(soup)

    # Extract study type
    study_type = extract_drupal_field(
        soup,
        [
            "field--name-field-study-type",
            "field-details-study-type",
            "field-study-type",
        ],
    )

    # Extract implemented by IPA (yes/no)
    implemented_by_ipa = extract_drupal_field(
        soup,
        ["field--name-field-research-implemented-by-ipa", "field-implemented-by-ipa"],
    )

    # Extract countries - try field first, then taxonomy links
    countries = extract_drupal_field(
        soup, ["field--name-field-countries", "field-countries"]
    )
    # If no field found, try extracting from taxonomy links
    if not countries:
        countries = extract_countries_from_taxonomy(soup)

    # Extract timeline/years
    timeline = extract_drupal_field(
        soup, ["field--name-field-timeline", "field-timeline"]
    )

    # Extract status
    status = extract_drupal_field(
        soup, ["field--name-field-status", "field-details-study-status", "field-status"]
    )

    # Extract project summary (try sub-editor field first, then body)
    summary = extract_drupal_field(
        soup,
        [
            "field--name-field-sub-editor",
            "field-sub-editor",
            "field--name-body",
            "field-body",
        ],
    )
    # Limit summary to first 500 characters for display
    summary = summary[:500] + "..." if summary and len(summary) > 500 else summary

    # Extract sample size
    sample_size = extract_drupal_field(
        soup, ["field--name-field-sample-size", "field-sample-size"]
    )

    return {
        "title": title,
        "researchers": researchers,
        "staff": staff,
        "study_type": study_type,
        "implemented_by_ipa": implemented_by_ipa,
        "countries": countries,
        "timeline": timeline,
        "status": status,
        "sample_size": sample_size,
        "summary": summary,
        "url": url,
    }


# Test your solution
print("\n" + "=" * 60)
print("COMPLETE PROJECT DATA EXTRACTION")
print("=" * 60)
additional_data = scrape_ipa_project_complete(project_url)
for key, value in additional_data.items():
    print(f"\n{key.upper()}:")
    print(f"  {value}")

# %% [markdown]
# ---
#
# ## Part 5: Building DataFrames from Multiple Projects
#
# Now let's scrape multiple projects and organize them in a pandas DataFrame.


# %%
def scrape_multiple_projects(urls, delay=2):
    """Scrape multiple IPA projects with comprehensive data extraction."""
    all_projects = []

    for i, url in enumerate(urls):
        print(f"\nScraping project {i + 1}/{len(urls)}...")

        try:
            # Use the complete scraper for comprehensive data
            project_data = scrape_ipa_project_complete(url)
            if project_data:
                all_projects.append(project_data)
                print(f"  ✓ {project_data.get('title', 'Untitled')[:50]}...")
        except Exception as e:
            print(f"  ✗ Error: {e}")

        # Rate limiting - be respectful!
        if i < len(urls):
            print(f"  Waiting {delay} seconds...")
            time.sleep(delay)

    return pd.DataFrame(all_projects)


# Example: Scrape a few projects
# Note: Start with just one or two projects to test
sample_urls = [
    "https://poverty-action.org/analyzing-effects-venezuelan-migration-colombias-education-system",
    "https://poverty-action.org/impacts-ingreso-solidario-program-confront-covid-19-crisis-colombia-0",
    "https://poverty-action.org/binging-gap-promoting-cohesion-through-edutainment-web-series-venezuelan-migrants",
    "https://poverty-action.org/impact-military-policing-program-colombia",
    "https://poverty-action.org/does-training-banking-representatives-reduce-barriers-migrants-access-financial-sector-colombia",
    "https://poverty-action.org/financial-inclusion-venezuelan-migrants-colombia",
    "https://poverty-action.org/improving-mental-health-early-childhood-development-workers-evaluating-sanar-para-crecer-program",
    "https://poverty-action.org/improving-caregiving-practices-reduce-household-violence-evaluating-apapacho-program-colombia",
    # Add more URLs here if desired
]

# %%
# Scrape the projects
projects_df = scrape_multiple_projects(sample_urls, delay=2)

# Display the DataFrame
print("\n" + "=" * 60)
print("SCRAPED PROJECTS DATAFRAME")
print("=" * 60)
print(projects_df)

# %%
# Review the dataframe structure
projects_df.describe(include="all").T

# %%
# Print the summary column of projects_df
if "summary" in projects_df.columns:
    print(projects_df["summary"])

# %% [markdown]
# ### Data Cleaning and Analysis

# %%
# Check for missing data
print("Missing values:")
print(projects_df.isnull().sum())

# %%
# View project count by status
if "status" in projects_df.columns and not projects_df.empty:
    print("\nProjects by status:")
    print(projects_df["status"].value_counts())

# %% [markdown]
# ### Exporting Data

# %%
# Save to CSV
if not projects_df.empty:
    output_file = "outputs/scraped_projects.csv"
    projects_df.to_csv(output_file, index=False)
    print(f"✓ Saved {len(projects_df)} projects to {output_file}")
else:
    print("No data to save")

# %% [markdown]
# ---
#
# ## Part 6: Converting to Markdown
#
# Let's convert project data to markdown format with YAML frontmatter.


# %%
def project_to_markdown(project_data):
    """Convert project data to markdown with YAML frontmatter."""
    # Build frontmatter
    frontmatter = {
        "title": project_data.get("title", "Untitled Project"),
        "status": project_data.get("status"),
        "timeline": project_data.get("timeline"),
        "countries": project_data.get("countries"),
        "url": project_data.get("url"),
    }

    # Remove None values
    frontmatter = {k: v for k, v in frontmatter.items() if v is not None}

    # Build markdown
    md = "---\n"
    md += yaml.dump(frontmatter, default_flow_style=False, allow_unicode=True)
    md += "---\n\n"
    md += "## Project Details\n\n"
    md += f"This project is focused on {project_data.get('countries', 'research')}.\n"

    return md


# Test markdown conversion
if not projects_df.empty:
    first_project = projects_df.iloc[0].to_dict()
    markdown = project_to_markdown(first_project)

    print("Generated Markdown:")
    print("=" * 60)
    print(markdown)


# %%
# Export all projects to markdown file
if not projects_df.empty:
    output_file = "outputs/scraped_projects.md"

    with open(output_file, "w", encoding="utf-8") as f:
        f.write("# IPA Projects\n\n")
        f.write(f"Scraped on: {time.strftime('%Y-%m-%d')}\n\n")
        f.write("---\n\n")

        for idx, project in projects_df.iterrows():
            project_dict = project.to_dict()
            markdown = project_to_markdown(project_dict)
            f.write(markdown)
            f.write("\n---\n\n")

    print(f"✓ Exported {len(projects_df)} projects to {output_file}")
else:
    print("No data to export")


# %% [markdown]
# ---
#
# ## Summary and Best Practices
#
# ### Key Takeaways
#
# 1. **Always check robots.txt** before scraping
# 2. **Use rate limiting** (2-4 second delays) to be respectful
# 3. **Handle errors gracefully** with try-except blocks
# 4. **Use partial matching** for complex CSS classes
# 5. **Extract safely** - check if elements exist before accessing
# 6. **Clean your data** - remove whitespace, decode HTML entities
# 7. **Save incrementally** - don't lose work if scraping fails
#
# ### Ethical Scraping Checklist
#
# - [ ] Checked robots.txt
# - [ ] Implemented rate limiting (2-4 seconds)
# - [ ] Used appropriate user agent
# - [ ] Only scraping public data
# - [ ] Respecting server resources
# - [ ] Handling errors without hammering server
# - [ ] Caching results to avoid re-scraping
#
# ### Next Steps
#
# 1. **Complete the challenges** above
# 2. **Build a full scraper** for Peace & Recovery projects
# 3. **Create visualizations** from scraped data
# 4. **Automate scraping** with scheduled tasks
# 5. **Share your work** with the team
#
# ---
#
# ## Additional Resources
#
# - [Gazpacho Documentation](https://github.com/maxhumber/gazpacho)
# - [IPA Research & Data Science Hub - Web Scraping Tutorial](https://ipa-research-data-science-hub/data-science/webscraping/)
# - [Pandas Documentation](https://pandas.pydata.org/docs/)
# - [HTML Basics (MDN)](https://developer.mozilla.org/en-US/docs/Learn/HTML)
#
# ---
#
# **Happy Scraping! 🚀**
