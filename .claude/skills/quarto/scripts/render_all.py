#!/usr/bin/env python3
"""Batch render multiple Quarto documents.

Usage:
    uv run python render_all.py --pattern "reports/*.qmd"
    uv run python render_all.py --files doc1.qmd doc2.qmd doc3.qmd
"""

import argparse
import subprocess
import sys
from pathlib import Path


def find_quarto_files(pattern: str, base_path: Path = Path.cwd()) -> list[Path]:
    """Find Quarto files matching a glob pattern.

    Args:
        pattern: Glob pattern to match (e.g., "*.qmd", "reports/**/*.qmd")
        base_path: Base directory to search from

    Returns:
        List of matching file paths

    """
    return sorted(base_path.glob(pattern))


def render_document(
    file_path: Path, format: str | None = None, verbose: bool = False
) -> bool:
    """Render a single Quarto document.

    Args:
        file_path: Path to the .qmd file
        format: Output format (html, typst, etc.) or None for default
        verbose: Show detailed output

    Returns:
        True if successful, False otherwise

    """
    cmd = ["quarto", "render", str(file_path)]

    if format:
        cmd.extend(["--to", format])

    if verbose:
        print(f"\n{'=' * 60}")
        print(f"Rendering: {file_path}")
        if format:
            print(f"Format: {format}")
        print(f"{'=' * 60}\n")
    else:
        print(f"Rendering: {file_path}...", end=" ", flush=True)

    try:
        subprocess.run(
            cmd,
            check=True,
            capture_output=not verbose,
            text=True,
        )
        if not verbose:
            print("[OK]")
        return True
    except subprocess.CalledProcessError as e:
        if not verbose:
            print("[FAIL]")
        print(f"Error rendering {file_path}:")
        if e.stderr:
            print(e.stderr)
        return False
    except FileNotFoundError:
        print("Error: 'quarto' command not found. Is Quarto installed?")
        print(
            "Visit https://quarto.org/docs/get-started/ for installation instructions."
        )
        sys.exit(1)


def main():
    """Parse arguments and batch render Quarto documents."""
    parser = argparse.ArgumentParser(
        description="Batch render multiple Quarto documents",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Render all .qmd files in current directory
  python render_all.py --pattern "*.qmd"

  # Render all files in a specific directory
  python render_all.py --pattern "reports/*.qmd"

  # Render specific files
  python render_all.py --files doc1.qmd doc2.qmd doc3.qmd

  # Render to specific format
  python render_all.py --pattern "*.qmd" --format html

  # Verbose output
  python render_all.py --pattern "*.qmd" --verbose
        """,
    )

    input_group = parser.add_mutually_exclusive_group(required=True)
    input_group.add_argument(
        "--pattern",
        "-p",
        help="Glob pattern to match Quarto files (e.g., '*.qmd', 'reports/**/*.qmd')",
    )
    input_group.add_argument(
        "--files",
        "-f",
        nargs="+",
        type=Path,
        help="Specific files to render",
    )

    parser.add_argument(
        "--format",
        "-t",
        choices=["html", "typst", "pdf", "docx", "all"],
        help="Output format (default: use document's default)",
    )

    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Show detailed rendering output",
    )

    parser.add_argument(
        "--continue-on-error",
        "-c",
        action="store_true",
        help="Continue rendering even if some documents fail",
    )

    args = parser.parse_args()

    # Get list of files to render
    if args.pattern:
        files = find_quarto_files(args.pattern)
        if not files:
            print(f"No files found matching pattern: {args.pattern}")
            sys.exit(1)
    else:
        files = args.files
        # Verify files exist
        for f in files:
            if not f.exists():
                print(f"Error: File not found: {f}")
                sys.exit(1)

    print(f"Found {len(files)} file(s) to render\n")

    # Render each file
    success_count = 0
    fail_count = 0

    for file_path in files:
        success = render_document(
            file_path,
            format=args.format,
            verbose=args.verbose,
        )

        if success:
            success_count += 1
        else:
            fail_count += 1
            if not args.continue_on_error:
                print("\nStopping due to error. Use --continue-on-error to continue.")
                sys.exit(1)

    # Summary
    print(f"\n{'=' * 60}")
    print("Rendering complete:")
    print(f"  Success: {success_count}")
    print(f"  Failed: {fail_count}")
    print(f"  Total: {len(files)}")
    print(f"{'=' * 60}")

    if fail_count > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
