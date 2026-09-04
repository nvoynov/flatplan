---
title: "SEO Image Integration Guide"
author: "Gemini AI"
date: "2026-07-08"
geometry: margin=1in
output: pdf_document
---

# Core Image SEO Rules

Modern search engines (Google, Yandex) have moved beyond simple keyword stuffing. They look for **LSI (Latent Semantic Indexing) phrases**—words that are topically and contextually connected to a main subject. 

> `lib/kairos.rb` provides the automatic, organic **chronological and environmental baseline** (e.g., *morning on Thursday*, *during the spring blossom season*). Your manual input should provide the **subject and spatial baseline** (e.g., *stone tomb*, *ancient ruins*). Combined, they form a highly natural LSI description.

## Rule A: The Separation of Roles (Alt vs. Title)

Never duplicate the same text string across `alt` and `title` attributes. This is recognized as spam by search crawlers and harms user accessibility.

*   **The `alt` Attribute (Alternative Text) — Objective Fact Engine**
    *   *SEO Role*: The single most critical vector for Google Images ranking. It tells the robot precisely **what** is on the image.
    *   *Formula*: `[Manual Physical Subject] + [Automated Chronolens Context]`
    *   *Example*: `"Ancient stone tomb near the cliff edge, afternoon on Thursday, in late spring"`
*   **The `title` Attribute (Tooltip Cover) — Atmosphere & Engagement**
    *   *SEO Role*: Enhances user behavioral metrics. Appears when hovering over the image. It should be evocative or artistic.
    *   *Formula*: `[Artistic Presentation Name] — [Automated Chronolens Basic Context]`
    *   *Example*: `"Toward the Edge — afternoon on Thursday, in late spring"`

## Rule B: Eliminating Stop Words

When writing manual description overrides within your manifests, strip out dead weight. Search bots ignore stop words, and ideal `alt` strings should stay under 125–150 characters.
*   ❌ **Bad (Spammy/Noisy):** `"This is a beautiful photo of an old stone tomb captured early morning on..."`
*   ▲ **Excellent (Clean LSI):** `"Weathered megalithic stone tomb on a grassy hill, early morning on..."`

