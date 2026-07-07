% Exposure. User Stories
% Nikolay Voynov
% 2026-06-30

# Introduction

This document exploers set of User Stories for Flatplan system (further, the system) that serves as an overview of the system features and establishes base for the scope of the system.

**The Spark**

As an amateur photographer, I want to build a simple, personal web gallery for my top photos with near-zero maintenance and hosting costs, so that I can establish a sustainable digital home and a single source of truth without financial overhead.

---

# Actors

## A Layout Editor (Art Editor)

# User Stories

## As a Layout Editor

### Narrative Orchestration Tools

I want to use simple structural text markers (like block divisions and image references) within a clean Markdown file so that I can control the visual layout, direction, and grouping of content without writing HTML tags or CSS styles.

I want my raw text files to remain highly readable and free from technical asset metadata (such as image dimensions or data-attributes) so that I can focus entirely on the pacing, rhythm, and storytelling of the series.

I want to generate a rapid, high-level visual preview of the layout structure directly in my command-line terminal so that I can instantly evaluate the pacing, block distribution, and rhythm of the entire publication before building the full website.

TODO: REWRITE THE FOLLOWING CHAPTER for using our new schema with metadata attributes

### Applying the Layout Controls

I want to wrap a collection of paragraphs and images inside a text-and-media block (using native `::: ` fenced dividers) and apply a positioning token (like `.layout-left-text` or `.layout-right-text`) so that the website engine automatically flows the text and assets into the correct editorial grid.

I want to create a visual transition (using a `.visual-pause` block) containing only image tokens so that I can deliberately interrupt the reading flow and give the viewer a dedicated space of silence to contemplate the photography.

I want to designate a single, high-impact photograph as a centerpiece (using an `.editorial-hero` block) accompanied by a blockquote so that a critical moment in the journey receives maximum full-screen emphasis and contextual weight.
