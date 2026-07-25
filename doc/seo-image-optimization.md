---
title: "Image Optimization Guide: Alt vs Title in Art & Photography"
author: "Gallery SEO Best Practices"
date: "2026-07-25"
---

# Image Optimization Guide: Alt vs Title

This guide outlines the critical differences between `alt` and `title` attributes and provides actionable examples for photography and art gallery websites.

## Core Differences

| Feature | `alt` Attribute (Alternative Text) | `title` Attribute (Tooltip) |
| :--- | :--- | :--- |
| **Primary Target** | Search engines (SEO) & Screen readers. | Human users (UI/UX enhancement). |
| **SEO Impact** | **Critical**. Directly ranks images in search results. | **Minimal**. Mostly ignored by search engines. |
| **Visibility** | Shows only if the image fails to load. | Shows as a tooltip on mouse hover. |

---

## Photography & Art LSI Keyword Examples

Latent Semantic Indexing (LSI) keywords help search engines understand the context, medium, and quality of your artwork. Do not stuff keywords; integrate them naturally into the descriptive text.

### Key LSI Categories for Galleries:

* **Medium/Materials:** *oil on canvas, archival pigment print, 35mm film, giclée print, mixed media, watercolor*.
* **Artistic Style:** *minimalist, abstract expressionism, surrealism, street photography, fine art photography, monochrome*.
* **Technical Specs:** *high-contrast, long exposure, analog, chiaroscuro, macro photography, golden hour light*.

---

## Code Examples with Visual Anchors

### Example 1: Fine Art Photography (Landscape)

* **Alt (Focus on visual content + LSI):** Minimalist long exposure photography of a lonely pier on a misty lake at dawn.
* **Title (Focus on context):** Series 'Silent Waters', 35mm film print, 2026.

```html
<figure>
  <img src="pier.jpg" 
       alt="Minimalist long exposure photography of a lonely pier on a misty lake at dawn" 
       title="Series 'Silent Waters', 35mm film print, 2026">
  <figcaption>The Lonely Pier, Mist Series, 2026.</figcaption>
</figure>
```

### Example 2: Contemporary Painting (Hero Section)

* **Alt (Focus on medium, style, colors):** Abstract expressionist oil painting with vibrant blue and textured gold palette knife strokes.
* **Title (Focus on meta info):** Curated by Studio Art, 120x120cm Canvas.

```html
<div class="hero-section">
  <figure>
    <img src="abstract-gold.jpg" 
         alt="Abstract expressionist oil painting with vibrant blue and textured gold palette knife strokes" 
         title="Curated by Studio Art, 120x120cm Canvas">
    <figcaption>Composition No. 5 by Modern Master.</figcaption>
  </figure>
</div>
```

---

## Quick Checklist for the Project

1. **Never duplicate:** Do not copy `alt` text into `title`.
2. **Describe, don't name:** Avoid generic names like `alt="Photo 1"` or `alt="Artwork"`.
3. **Keep it under 125 characters:** Screen readers often stop reading after this limit.
4. **Use `<figcaption>`:** Wrap your future hero layout text in structural HTML elements for maximum semantic SEO.
