#!/usr/bin/env python3
"""Create a new Quarto document from a template.

Usage:
    uv run python create_quarto.py --output report.qmd --title "My Report" --format html
"""

import argparse
import sys
from pathlib import Path

# Template directory (relative to this script)
SCRIPT_DIR = Path(__file__).parent
TEMPLATE_DIR = SCRIPT_DIR.parent / "assets"

TEMPLATES = {
    "html": "template_html.qmd",
    "typst": "template_typst.qmd",
    "dual": "template_dual.qmd",
    "report": "template_report.qmd",
}


def create_quarto_document(
    output_path: Path,
    template_type: str,
    title: str | None = None,
    author: str | None = None,
    subtitle: str | None = None,
) -> None:
    """Create a Quarto document from a template.

    Args:
        output_path: Path where the new document will be created
        template_type: Type of template to use (html, typst, dual, report)
        title: Document title (optional)
        author: Author name (optional)
        subtitle: Document subtitle (optional)

    """
    # Validate template type
    if template_type not in TEMPLATES:
        print(f"Error: Unknown template type '{template_type}'")
        print(f"Available templates: {', '.join(TEMPLATES.keys())}")
        sys.exit(1)

    # Get template path
    template_path = TEMPLATE_DIR / TEMPLATES[template_type]
    if not template_path.exists():
        print(f"Error: Template file not found: {template_path}")
        sys.exit(1)

    # Read template
    with open(template_path, encoding="utf-8") as f:
        content = f.read()

    # Replace placeholders if provided
    if title:
        # Replace title in YAML front matter
        lines = content.split("\n")
        for i, line in enumerate(lines):
            if line.startswith("title:"):
                lines[i] = f'title: "{title}"'
                break
        content = "\n".join(lines)

    if author:
        # Replace author in YAML front matter
        lines = content.split("\n")
        for i, line in enumerate(lines):
            if line.startswith("author:"):
                lines[i] = f'author: "{author}"'
                break
            # Handle structured author format
            if "  - name:" in line or "    name:" in line:
                lines[i] = f'  - name: "{author}"'
                break
        content = "\n".join(lines)

    if subtitle and template_type == "report":
        # Add subtitle for report template
        lines = content.split("\n")
        for i, line in enumerate(lines):
            if line.startswith("subtitle:"):
                lines[i] = f'subtitle: "{subtitle}"'
                break
        content = "\n".join(lines)

    # Create output directory if needed
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Check if file already exists
    if output_path.exists():
        response = input(f"File {output_path} already exists. Overwrite? (y/N): ")
        if response.lower() != "y":
            print("Cancelled.")
            sys.exit(0)

    # Write the new document
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"[OK] Created Quarto document: {output_path}")
    print(f"  Template: {template_type}")
    if title:
        print(f"  Title: {title}")
    if author:
        print(f"  Author: {author}")
    print("\nTo render this document, run:")
    print(f"  quarto render {output_path}")


def main():
    """Parse arguments and create a Quarto document."""
    parser = argparse.ArgumentParser(
        description="Create a new Quarto document from a template",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Create HTML analysis document
  python create_quarto.py --output analysis.qmd --title "My Analysis" --format html

  # Create Typst report
  python create_quarto.py --output report.qmd --title "Annual Report" --format typst --author "John Doe"

  # Create dual-format document
  python create_quarto.py --output doc.qmd --title "Research Paper" --format dual

  # Create formal report
  python create_quarto.py --output formal.qmd --title "Project Report" --format report
        """,
    )

    parser.add_argument(
        "--output",
        "-o",
        type=Path,
        required=True,
        help="Output file path for the new document",
    )

    parser.add_argument(
        "--format",
        "-f",
        choices=list(TEMPLATES.keys()),
        default="html",
        help="Template format to use (default: html)",
    )

    parser.add_argument(
        "--title",
        "-t",
        help="Document title",
    )

    parser.add_argument(
        "--author",
        "-a",
        help="Author name",
    )

    parser.add_argument(
        "--subtitle",
        "-s",
        help="Document subtitle (only for report template)",
    )

    args = parser.parse_args()

    create_quarto_document(
        output_path=args.output,
        template_type=args.format,
        title=args.title,
        author=args.author,
        subtitle=args.subtitle,
    )


if __name__ == "__main__":
    main()
