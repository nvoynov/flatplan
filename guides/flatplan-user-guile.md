# Flatplan: The Fine-Art Photographer’s Layout Guide
> Made by a photographer, for photographers. Designed for absolute visual control.

Flatplan treats a photographic series as a musical composition. It balances imagery, text, and empty space ("visual silence") into a structured, flat publication blueprint.

This guide outlines how to format your `SERIES.md` manifest file to orchestrate your story.

## 1. Global Metadata (The Front Matter)
Every series starts with a standard YAML block. This anchors your series geographically and historically, providing essential keys for search engines (SEO).

```yaml
---
title: 'Your Project Title'
author: 'Your Name'
date: 'Years of Production'
location: 'Specific Location, Country'
keywords: ['art photography', 'monochrome', 'documentary']
description: 'A concise, curatorial summary of the series narrative.'
---
```

## 2. Text Paragraphs & The Introduction
Any raw text block placed immediately below the title front matter serves as the main project introduction. Write naturally. Do not inject HTML tags or inline styles.

## 3. Section Blocks & Editorial Layouts
To group images into semantic layout spreads ("couplets" or chapters), use a single Level 1 header (`#`). Directly beneath the header, define the layout parameters:

### Text and Media Spreads
Flows text paragraphs and an image grid side-by-side.
```markdown
# Chapter Title Here
text: left      # Options: left, right
media: right    # Options: left, right

Your narrative paragraph goes here. It automatically fills the text column.

![Image Alt Text](IMAGE_KEY.webp)
![Another Image Alt Text](ANOTHER_KEY.webp)
```

### The Design of Silence (Visual Pauses)
To deliberately interrupt the reading flow and give the viewer room to breathe, create a standalone visual pause spread using three dashes (`---`).
```markdown
---
# Optional Internal Marker
layout: pause
spacing: large  # Options: medium, large
```

## 4. Fine-Art Asset Metadata (Under-Image Attributes)
To attach specialized curatorial metadata to a specific photograph without cluttering your narrative, list properties directly beneath the Markdown image token using a clean `key: value` syntax:

```markdown
![A traditional wooden draw well inside the village](DP2Q2644.webp)
title: The Echo of Water       # Curated artistic title for this specific frame
captured_at: 2020-10-14 14:20  # Capture timestamp anchor (useful for image selection)
```

## 5. Layout Golden Rules
* **Form follows rhythm:** Use `---` pauses between heavy chapters to separate visual thoughts.
* **Keep files clean:** Technical data (EXIF, camera models) and print availability live in separate registries. Focus entirely on the pacing and storytelling.

