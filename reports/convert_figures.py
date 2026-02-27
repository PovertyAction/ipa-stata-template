#!/usr/bin/env python3
"""Convert PDF figures to PNG for DOCX compatibility.

Usage:
    python reports/convert_figures.py
"""

import sys
from pathlib import Path


def convert_pdf_to_png(pdf_path, dpi=300):
    """Convert a PDF file to PNG."""
    pdf_path = Path(pdf_path)
    png_path = pdf_path.with_suffix(".png")

    # Skip if PNG is newer than PDF
    if png_path.exists() and png_path.stat().st_mtime > pdf_path.stat().st_mtime:
        print(f"⏭️  Skipping {pdf_path.name} (PNG is up to date)")
        return True

    print(f"🔄 Converting {pdf_path.name}...", end=" ")

    # Try PyMuPDF first (no external dependencies needed)
    try:
        import fitz  # PyMuPDF

        doc = fitz.open(str(pdf_path))
        page = doc[0]  # Get first page

        # Calculate zoom factor for desired DPI (72 is default PDF DPI)
        zoom = dpi / 72
        mat = fitz.Matrix(zoom, zoom)

        # Render page to pixmap
        pix = page.get_pixmap(matrix=mat)
        pix.save(str(png_path))
        doc.close()

        print(f"✓ Created {png_path.name}")
        return True

    except ImportError:
        pass  # Try next method
    except Exception as e:
        print(f"❌ PyMuPDF failed: {e}")

    # Fallback to pdf2image (requires poppler)
    try:
        from pdf2image import convert_from_path

        images = convert_from_path(str(pdf_path), dpi=dpi, first_page=1, last_page=1)

        if images:
            images[0].save(str(png_path), "PNG")
            print(f"✓ Created {png_path.name}")
            return True
        else:
            print("❌ Failed (no images generated)")
            return False

    except ImportError:
        print("❌ Error: Neither pymupdf nor pdf2image installed")
        print("   Install with: uv add pymupdf")
        return False
    except Exception as e:
        print(f"❌ Failed: {e}")
        if "Unable to get page count" in str(e) or "poppler" in str(e).lower():
            print("   Poppler not found. Use PyMuPDF instead: uv add pymupdf")
        return False


def main():
    """Convert all PDF figures in outputs/figures/ to PNG."""
    # Get the project root (parent of reports/)
    project_root = Path(__file__).parent.parent
    figures_path = project_root / "outputs" / "figures"

    if not figures_path.exists():
        print(f"❌ Error: Figures directory not found: {figures_path}")
        sys.exit(1)

    # Find all PDF files
    pdf_files = list(figures_path.glob("*.pdf"))

    if not pdf_files:
        print(f"⚠️  No PDF files found in {figures_path}")
        sys.exit(0)

    print(f"\n📊 Found {len(pdf_files)} PDF figure(s) to convert\n")

    success_count = 0
    fail_count = 0

    for pdf_file in sorted(pdf_files):
        if convert_pdf_to_png(pdf_file):
            success_count += 1
        else:
            fail_count += 1

    print(f"\n{'=' * 60}")
    print(f"✓ Successfully converted: {success_count}")
    print(f"❌ Failed: {fail_count}")
    print(f"{'=' * 60}\n")

    if success_count > 0:
        print("✅ PNG figures are ready for DOCX rendering!")

    if fail_count > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
