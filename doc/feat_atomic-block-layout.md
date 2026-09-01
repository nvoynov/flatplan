
# Architectural RFC: Atomic Block Layout System for Flatplan (Web Series & Zine Roots)

## 1. Structural Concept: Atomic Components
Instead of hardcoding layouts for a single output format, the core design engine treats content as a collection of decoupled structural blocks. Content blocks (text, photos, metadata) exist independently of their presentation layer and can be fluidly mapped to multiple rendering targets (roots).

---

## 2. Core Primitive Blocks (The Bricks)

Every manifestation of a photographic project is constructed using four fundamental layout atoms:

*   **`text`**: Handles typography entities such as narrative essays, short poems, metadata captions, or philosophical quotes.
*   **`media`**: Manages visual content. It can represent a single isolated photograph, a balanced diptych, or a sequential triptych.
*   **`text-and-media`**: A unified compound component handling asymmetrical side-by-side or contextual image-and-caption compositions.
*   **`media-hero`**: A high-impact structural anchor designed for full-bleed showcase imagery or opening title sequences.

---

## 3. Root Mapping: Series vs. Zine (The Outputs)

By combining overlapping sequences of the primitive blocks defined above, the orchestrator generates distinct architectural outcomes from the same raw assets:

┌──────────────┐
│ Primitive    │
│ Blocks Pool  │
└──────┬───────┘
       │
┌───────────────┴───────────────┐
▼                               ▼
┌───────────────┐               ┌───────────────┐
│  SERIES ROOT  │               │   ZINE ROOT   │
├───────────────┤               ├───────────────┤
│ Web Output    │               │ Print Output  │
│ Continuous    │               │ Page-Budgeted │
│ Fluid Layout  │               │ Fixed Spreads │
└───────────────┘               └───────────────┘


### A. The `series` Root (Web Presentation)
*   **Target:** Desktop and mobile screens via continuous browser scrolling.
*   **Rendering Behavior:** Blocks flow vertically down a responsive viewport. 
*   **Pacing & Pauses:** Translated into CSS margins, paddings, or dynamic empty space (`vh` / viewport height) between images to build structural tension.
*   **Compilation:** Handled via regular templates or the Pandoc Server micro-service instantly.

### B. The `zine` Root (Physical Print/PDF Presentation)
*   **Target:** Page-budgeted physical publications (e.g., a 24-page saddle-stitched booklet).
*   **Rendering Behavior:** Blocks are mapped to rigid page boundaries, strictly honoring physical left-hand (verso) and right-hand (recto) document spreads.
*   **Pacing & Pauses:** Translated into deliberate blank pages, forcing physical page turns to isolate key photographs.
*   **Compilation:** Handled by specialized print layouts via Pandoc (e.g., routing through Typst or WeasyPrint) using high-resolution assets and proper print margins.

---

## 4. Conceptual Manifest Realization
Because the definitions are component-driven, the developer or curator can maintain a single asset index while defining two independent presentation flow sheets in their layout system. The asset arrays intersect perfectly, eliminating double-data entry for texts or media descriptors.
