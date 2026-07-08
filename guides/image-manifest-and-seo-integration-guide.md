---
title: "Image Manifest & SEO Integration Guide"
author: "Chronolens Project"
date: "2026-07-08"
geometry: margin=1in
output: pdf_document
---

# Chronolens Integration Standards

This document establishes the architectural standards for integrating **Chronolens** automated metadata into thematic photo-gallery manifests (such as Jekyll, Hugo, or custom static generators). It outlines core Image SEO rules, the strict separation of `alt`/`title` attributes, and provides a structural blueprint for multi-layered manifests.

## 1. Core Image SEO Rules

Modern search engines (Google, Yandex) have moved beyond simple keyword stuffing. They look for **LSI (Latent Semantic Indexing) phrases**—words that are topically and contextually connected to a main subject. 

Chronolens provides the automatic, organic **chronological and environmental baseline** (e.g., *morning on Thursday*, *during the spring blossom season*). Your manual input should provide the **subject and spatial baseline** (e.g., *stone tomb*, *ancient ruins*). Combined, they form a highly natural LSI description.

### Rule A: The Separation of Roles (Alt vs. Title)
Never duplicate the same text string across `alt` and `title` attributes. This is recognized as spam by search crawlers and harms user accessibility.

*   **The `alt` Attribute (Alternative Text) — Objective Fact Engine**
    *   *SEO Role*: The single most critical vector for Google Images ranking. It tells the robot precisely **what** is on the image.
    *   *Formula*: `[Manual Physical Subject] + [Automated Chronolens Context]`
    *   *Example*: `"Ancient stone tomb near the cliff edge, afternoon on Thursday, in late spring"`
*   **The `title` Attribute (Tooltip Cover) — Atmosphere & Engagement**
    *   *SEO Role*: Enhances user behavioral metrics. Appears when hovering over the image. It should be evocative or artistic.
    *   *Formula*: `[Artistic Presentation Name] — [Automated Chronolens Basic Context]`
    *   *Example*: `"Toward the Edge — afternoon on Thursday, in late spring"`

### Rule B: Eliminating Stop Words
When writing manual description overrides within your manifests, strip out dead weight. Search bots ignore stop words, and ideal `alt` strings should stay under 125–150 characters.
*   ❌ **Bad (Spammy/Noisy):** `"This is a beautiful photo of an old stone tomb captured early morning on..."`
*   ▲ **Excellent (Clean LSI):** `"Weathered megalithic stone tomb on a grassy hill, early morning on..."`

---

## 2. Manifest Architecture with Chronolens

In your static site architecture, a **Series (Album)** represents a curated publication with a distinct layout, narrative text, and an array of target photographs. 

To prevent rewriting identical descriptions manually, the data pipeline should process metadata in three cascading layers:
1.  **Series Global Settings Layer**: Holds common contexts (`:sea`, `:rural`) shared by the album.
2.  **Chronolens Automated Layer**: Evaluates raw EXIF timestamps into a fallback string hash map.
3.  **Author Override Layer**: Individual fields inside the Markdown block where you specify the artistic values.

### Thematic Album Manifest Specification (Pandoc Markdown + YAML Front Matter)

Below is the optimized layout blueprint matching your multi-media section setup. The static site generator reads this file, runs `Chronolens.call(captured_at, series_contexts)`, and compiles the HTML output programmatically.

```yaml
---
title: 'Stonetomb — Toward the Edge'
author: 'N. Voynov'
date: '2026-07-07'
# Global series context passed dynamically to Chronolens for every asset in this file
series_contexts: 
  - :rural
  - :basic
---

# Section Layout Block
text: left
media: right

There will be some descriptive narrative text about the journey here...

![Fallback caption](DP2Q2200.tif)
captured_at: 2019:05:30 14:47:53
# Author Overrides (Your manual polishing layer)
user_title: "Toward the Edge"
user_subject: "Megalithic stonetomb overlooking the valley"
chosen_context: :rural
```

---

## 3. Data Pipeline & HTML Compilation Logic

When your build command runs, the pipeline extracts the layout and compiles the final production HTML components. The compilation engine handles fallbacks gracefully using this programmatic pseudocode logic:

```ruby
# How your builder translates the manifest into HTML variables
time = Time.strptime(photo[:captured_at], "%Y:%m:%d %H:%M:%S")
active_contexts = manifest[:series_contexts]

# 1. Fetch all potential variations from Chronolens
suggestions = Chronolens.call(time, active_contexts)
# => { 
#      basic: "afternoon on Thursday, in late spring",
#      rural: "afternoon on Thursday, during the spring plowing season"
#    }

# 2. Extract selected context based on author preference
context_key = photo[:chosen_context] || :basic
time_string = suggestions[context_key]

# 3. Construct clean, human-readable SEO strings
final_alt   = [photo[:user_subject], time_string].compact.join(", ")
final_title = photo[:user_title] ? "#{photo[:user_title]} — #{suggestions[:basic]}" : final_alt
```

### Resulting Production HTML Output
```html
<img src="/assets/media/DP2Q2200.jpg" 
     alt="Megalithic stonetomb overlooking the valley, afternoon on Thursday, during the spring plowing season" 
     title="Toward the Edge — afternoon on Thursday, in late spring" />
```

---

## 4. Key Benefits of This Strategy
*   **Zero Cold Starts**: If you leave `user_title` and `user_subject` empty during a fast export, the template logic automatically falls back directly to the `basic` Chronolens string. Your layout will never be published without functional image SEO metadata.
*   **Decoupled Assets**: Keeps your source images clean. All editorial, presentation, and seasonal shifts live strictly inside your high-level text manifests.

