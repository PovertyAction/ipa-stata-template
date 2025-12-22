#!/usr/bin/env python3
"""Validate YAML front matter in Quarto documents.

Usage:
    uv run python validate_yaml.py document.qmd
    uv run python validate_yaml.py --pattern "*.qmd"
"""

import argparse
import re
import sys
from pathlib import Path

import yaml


def extract_yaml_frontmatter(content: str) -> tuple[str | None, int, int]:
    """Extract YAML front matter from Quarto document.

    Args:
        content: Full document content

    Returns:
        Tuple of (yaml_string, start_line, end_line) or (None, 0, 0) if not found

    """
    # Match YAML front matter between --- delimiters
    pattern = r"^---\s*\n(.*?)\n---\s*\n"
    match = re.match(pattern, content, re.DOTALL)

    if match:
        yaml_content = match.group(1)
        start_line = 1
        end_line = content[: match.end()].count("\n")
        return yaml_content, start_line, end_line

    return None, 0, 0


def validate_yaml(yaml_string: str) -> tuple[bool, str | None]:
    """Validate YAML syntax.

    Args:
        yaml_string: YAML content to validate

    Returns:
        Tuple of (is_valid, error_message)

    """
    try:
        yaml.safe_load(yaml_string)
        return True, None
    except yaml.YAMLError as e:
        return False, str(e)


def check_required_fields(yaml_content: dict, required: list[str]) -> list[str]:
    """Check if required fields are present in YAML.

    Args:
        yaml_content: Parsed YAML dictionary
        required: List of required field names

    Returns:
        List of missing field names

    """
    missing = []
    for field in required:
        if field not in yaml_content:
            missing.append(field)
    return missing


def validate_quarto_document(file_path: Path, verbose: bool = False) -> bool:
    """Validate a Quarto document's YAML front matter.

    Args:
        file_path: Path to the .qmd file
        verbose: Show detailed validation info

    Returns:
        True if valid, False otherwise

    """
    if not file_path.exists():
        print(f"[FAIL] {file_path}: File not found")
        return False

    # Read file
    try:
        with open(file_path, encoding="utf-8") as f:
            content = f.read()
    except Exception as e:
        print(f"[FAIL] {file_path}: Error reading file: {e}")
        return False

    # Extract YAML front matter
    yaml_string, start_line, end_line = extract_yaml_frontmatter(content)

    if yaml_string is None:
        print(f"[FAIL] {file_path}: No YAML front matter found")
        if verbose:
            print("  Expected front matter between --- delimiters at start of file")
        return False

    if verbose:
        print(f"\n{file_path}:")
        print(f"  YAML front matter found (lines {start_line}-{end_line})")

    # Validate YAML syntax
    is_valid, error_msg = validate_yaml(yaml_string)

    if not is_valid:
        print(f"[FAIL] {file_path}: Invalid YAML syntax")
        if verbose:
            print(f"  Error: {error_msg}")
        return False

    # Parse YAML
    try:
        yaml_content = yaml.safe_load(yaml_string)
    except Exception as e:
        print(f"[FAIL] {file_path}: Error parsing YAML: {e}")
        return False

    # Check common fields
    if verbose:
        print(f"  Fields found: {', '.join(yaml_content.keys())}")

        if "title" in yaml_content:
            print(f"  Title: {yaml_content['title']}")
        if "author" in yaml_content:
            print(f"  Author: {yaml_content['author']}")
        if "format" in yaml_content:
            formats = (
                list(yaml_content["format"].keys())
                if isinstance(yaml_content["format"], dict)
                else [yaml_content["format"]]
            )
            print(f"  Formats: {', '.join(formats)}")

    # Check for recommended fields
    recommended = ["title", "format"]
    missing = check_required_fields(yaml_content, recommended)

    if missing and verbose:
        print(f"  [WARN] Recommended fields missing: {', '.join(missing)}")

    if verbose:
        print("  [OK] YAML is valid")
    else:
        print(f"[OK] {file_path}")

    return True


def find_quarto_files(pattern: str, base_path: Path = Path.cwd()) -> list[Path]:
    """Find Quarto files matching a glob pattern."""
    return sorted(base_path.glob(pattern))


def main():
    """Parse arguments and validate Quarto document YAML."""
    parser = argparse.ArgumentParser(
        description="Validate YAML front matter in Quarto documents",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Validate a single file
  python validate_yaml.py document.qmd

  # Validate all .qmd files in current directory
  python validate_yaml.py --pattern "*.qmd"

  # Validate with detailed output
  python validate_yaml.py document.qmd --verbose

  # Validate all files in a directory
  python validate_yaml.py --pattern "reports/*.qmd"
        """,
    )

    input_group = parser.add_mutually_exclusive_group(required=True)
    input_group.add_argument(
        "file",
        nargs="?",
        type=Path,
        help="Quarto document to validate",
    )
    input_group.add_argument(
        "--pattern",
        "-p",
        help="Glob pattern to match Quarto files",
    )

    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Show detailed validation information",
    )

    args = parser.parse_args()

    # Get list of files
    if args.pattern:
        files = find_quarto_files(args.pattern)
        if not files:
            print(f"No files found matching pattern: {args.pattern}")
            sys.exit(1)
    else:
        files = [args.file]

    # Validate each file
    all_valid = True
    for file_path in files:
        is_valid = validate_quarto_document(file_path, verbose=args.verbose)
        if not is_valid:
            all_valid = False

    # Summary for multiple files
    if len(files) > 1:
        print(f"\nValidated {len(files)} file(s)")

    sys.exit(0 if all_valid else 1)


if __name__ == "__main__":
    main()
