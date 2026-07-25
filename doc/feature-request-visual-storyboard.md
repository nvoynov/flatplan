# FEATURE REQUEST: Flatplan Visual Storyboard Editor (Interactive Layout Organizer)

## 1. Objective / Постановка задачи

Create a lightweight, zero-dependency local visual editor (Storyboard) for the `flatplan` editorial framework. The system must allow an art editor to visually distribute a raw bundle of photographic assets into curated layout blocks (Text & Media, Editorial Hero, Visual Pause), manage their sorting order, and edit image-specific metadata (`alt`, `caption`, `title`) without touching the raw text files.

Система должна работать по принципу интерактивного монтажного стола: на входе получается сырой пул фотографий, сгенерированный Ruby-компонентом, а на выходе редактор получает готовый Markdown-манифест публикации, визуально повторяющий дизайн боевого сайта.

---

## 2. Core Functional Requirements / Ключевые требования

### A. The Sidebar Asset Pool (Боковая панель нераспределенного остатка)

- Displays all newly scanned photographic assets that haven't been assigned to an editorial block yet.
- Keeps tracks of total unused image counts.

### B. Contextual Block Operations (Управление блоками "без фанатизма")

Instead of heavy and glitchy cross-grid Drag-and-Drop, the UI should leverage precise contextual actions upon clicking or hovering an image card:
- **"Move to New Hero Block"**: Extracts the image (and optionally subsequent ones) into a standalone 3-column `.flatplan_editorial_hero` container.
- **"Insert Visual Pause"**: Spawns a spacing boundary section between blocks.
- **"Flip Alignment"**: Instantly toggles a Text-and-Media section between `.flatplan_layout_left_text` and `.flatplan_layout_right_text` layout formats.
- **Block Reordering**: Global "Move Up" / "Move Down" controls for layout sections.

### C. Live Metadata Editing (Редактирование атрибутов на лету)

- Inline text fields or a compact modal sheet attached to each image item.
- Supports instant modifications for:
  - `alt` (with visual access to Ruby-generated Kairos tracking hints)
  - `caption`
  - `title`

---

## 3. Proposed Architecture & Implementation Strategy / Архитектурные предположения

### A. The Backend: Lightweight Ruby API Server (`app.rb`)

A minimal local Rack/Sinatra instance operating as a proxy between the file system and the Web UI. It eliminates complex parsing tasks on the frontend by reusing already implemented core domain models:
- **`GET /api/publication`**:
  - Triggers the existing Flatplan parser to read the target `.md` manifest.
  - Serializes the domain structure (`Model::SeriesPublication`) into a pure JSON payload for the frontend.
- **`POST /api/publication`**:
  - Receives the modified JSON configuration payload from the browser.
  - Re-instantiates domain section objects (`Model::TextAndMediaSection`, etc.).
  - Pipes data into `ManifestSerializer.new.call(publication)` to overwrite the localized `.md` manifest file natively with correct `::: fenced_divs` spacing blocks.

### B. The Frontend: Single-File Vue.js Interactive Desk (`editor.html`)
A standalone reactive document embedded right into the local website project tree:
- **Style Injection**: Directly loads the production `publication.css` framework ensuring the editing workspace mimics the final deployed article aesthetics with absolute fidelity.
- **State Management**: Simple Vue/Vanilla reactivity holding the current layout JSON array in memory.
- **Local Asset Resolution**: Runs on the same port as the Sinatra backend, effortlessly resolving physical local image source paths (e.g., `/assets/series/...`) without hitting browser CORS file system blocks.

---

## 4. Expected Benefits / Ценность решения
1. **Dramatic Speedup**: Eliminates manual text-block shuffling inside Markdown files.
2. **Visual Rhythm Guarantee**: The director views real-world scaling, constraints, and gaps during the composition workflow.
3. **Data Integrity**: Zero risks of broken Pandoc blocks or unclosed `::: fenced_div` tags during manual writing.
