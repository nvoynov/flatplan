# Feature Request: Interactive Visual Layout Editor for Flatplan

## 1. Executive Summary & Vision

The core purpose of the `flatplan` utility is to choreograph the rhythm, text layout, and structural pauses of photographic series.

This feature request outlines the architecture for an **Interactive Visual Layout Editor**. By moving to a persistent background engine paired with a dual-panel web interface, authors can drag, drop, and edit text or image blocks with instant, real-time feedback.

---

## 2. High-Level Editor Architecture

The visual editor operates as a lightweight local web interface powered by a Ruby micro-backend (e.g., Sinatra or Roda) and an in-memory Pandoc Server instance. The workspace is divided into two distinct logical planes:

1. **The Control Plane (Left Panel):** A user-friendly control canvas representing the manifest structure. Text sequences, image nodes, and whitespace blocks ("pauses") are rendered as discrete UI elements that support drag-and-drop reordering, parameter shifting, and inline editing.
2. **The Preview Plane (Right Panel):** A fully sandboxed `<iframe>` displaying the authentic compiled website theme. This pane updates dynamically without full page reloads.

---

## 3. Real-Time Data Flow (Step-by-Step)

The transition from a slow manual file-compilation loop to a reactive system follows a 5-step life cycle:

### Step 1: Initialization & Loading

* **Action:** The user launches the editor via a terminal command (e.g., `flatplan edit`).
* **Backend Operations:** The Ruby service reads the target manifest layout (YAML/JSON) from the local disk and parses it into memory. Concurrently, it triggers lightweight, low-resolution cached thumbnails of the raw high-resolution portfolio images to maintain low frontend browser overhead.
* **Result:** The web client receives the structural manifest data payload and populates the layout workspace interface.

### Step 2: Client Interaction & Debouncing

* **Action:** The author interacts with the layout—modifying an essay paragraph, dragging a picture element between structural columns, or widening a spatial padding slider ("pause duration").
* **Frontend Control:** As changes occur, the browser delays immediate syncing using a **Debounce** function (typically 300ms to 500ms). This prevents flooding the network stack with hundreds of intermediate server API calls during active typing or dragging.

### Step 3: Fast Memory Rendering (Pandoc Server Layer)

* **Action:** Once the debounce window closes, the frontend transmits the serialized state of the modified document block directly to the Ruby backend via an asynchronous `POST /preview` fetch request.
* **Processing:** The Ruby app intercepts the content, extracts the narrative markdown blocks, and streams them instantly to the persistent **Pandoc Server** via HTTP headers.
* **Output:** Pandoc returns raw compiled HTML elements back to Ruby within single-digit milliseconds. Ruby then wraps this HTML snippet into the site's layout shell, along with its specific typography stylesheets.

### Step 4: Selective DOM Update

* **Action:** The frontend captures the incoming text stream response from the Ruby backend.
* **Injection:** Instead of resetting the browser window state (`window.location.reload`), the editor targeting script dynamically refreshes only the document node container nested inside the preview `<iframe>`.
* **Result:** The author experiences instantaneous rendering of their structural edits with zero visual flicker.

### Step 5: Persistent Disk Flushing (The Commit)

* **Action:** When the creator is satisfied with the pacing of their photographic manifest sequence, they click the `Save Configuration` action element (or trigger an automatic background auto-save event).
* **Finalization:** The Ruby host application securely flushes the optimized internal configuration data array back down onto the file system, safely overwriting the primary prodject manifest configuration file on the disk.

---

## 4. Key Performance Enhancements

* **Latency Reduction:** Shrinks the feedback loop duration from ~4 seconds (CLI re-run + file IO wait + browser cache dump) down to **50-100 milliseconds** total turnaround time.
* **Decoupled Processing:** Edits are rendered safely in system memory cache space, removing unnecessary disk thrashing and preventing repetitive image-write wear on local drives during drafting phases.

