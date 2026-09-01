# Feature Request: Multi-Format Publishing (Web Engine to Print-Ready Photozine PDF)

## 1. Concept & Vision
A photozine demands strict control over page layout, physical dimensions, color spaces, and print margins—parameters that radically differ from a fluid, responsive web layout. 

This extension outlines how the existing `flatplan` architecture can reuse the same content manifest to compile both the interactive web catalog and a high-quality, print-ready PDF photozine using Pandoc's document engines.

---

## 2. Manifest Schema Extensions (Conceptual)
To bridge the gap between web screens and physical paper, the existing manifest can be extended with a dedicated `publishing` or `print_target` block:

```yaml
title: "Silent Spaces"
author: "Alex Developer"
theme: "minimalist"

# Global print settings ignored by the web router, used only by the PDF generator
print_target:
  page_size: "a5"             # Standard zine format (A5, B6, or custom inches)
  orientation: "portrait"
  margins:
    top: "20mm"
    bottom: "20mm"
    inner: "25mm"             # Extra padding for the physical book binding/gutter
    outer: "15mm"
  color_profile: "CMYK"       # For professional printing alignment
  bleed: "3mm"                # Edge trimming allowance for full-bleed images

timeline:
  - type: text
    content: "Chapter 1: The Isolation"
  - type: image
    source: "photos/img_01.jpg"
    layout: "full-page"        # Tells Pandoc to expand this photo across the whole paper bleed
  - type: pause
    duration: "blank-page"     # Translates to a deliberate empty page in the PDF zine
```

---

## 3. PDF Generation Pipelines with Pandoc
Pandoc doesn't render PDFs natively; instead, it converts Markdown into an intermediate structural format and orchestrates a backend engine to bake the final PDF document. Depending on the design requirements of the photozine, Ruby can trigger one of two professional pipelines:

### Option A: The Typst Pipeline (Recommended for Modern Speed)
* **How it works:** Pandoc parses the manifest into Markdown and routes it using `--pdf-engine=typst`. 
* **Pros:** Typst is incredibly fast (sub-second rendering), uses clean, modern CSS-like layouts, handles high-res images brilliantly, and supports pixel-perfect block placements natively.
* **Best for:** Rapid on-demand downloads straight from the admin preview screen or by end-users on the live website.

### Option B: The WeasyPrint / Typst-HTML Pipeline (Web-to-Print CSS)
* **How it works:** Pandoc compiles the manifest into a highly structured semantic HTML5 file first. Then, a headless print processor like **WeasyPrint** parses the HTML alongside a dedicated `print.css` stylesheet file using CSS Paged Media standards (`@page`).
* **Pros:** Complete control over typography, layouts, and image scaling using familiar CSS rules (e.g., page-break-before, page counters).
* **Best for:** Complex photo-grids where the zine layout must strictly match the exact stylistic design principles of the web layout.

---

## 4. The User & Production Flow
1. **The Download Request:** A visitor on the static website clicks a button: *“Download Limited Edition Photozine (PDF)”*.
2. **On-the-Fly Generation:** The background Ruby app feeds the project manifest file through the configured Pandoc PDF engine.
3. **Asset Optimization:** The pipeline automatically swaps the lightweight web-optimized thumbnails out for the ultra-sharp, high-resolution original photographs during compilation.
4. **Delivery:** The optimized, print-ready PDF file is instantly streamed to the user's browser, complete with automated page numbers, running headers, and precise visual pacing.

