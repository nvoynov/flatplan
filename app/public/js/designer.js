let storyName = ""; 
let localStoryData = null;

// Target the sandbox compiler immediately via the preview frame
document.getElementById('preview_plane').src = '/preview.html';

// === 1. DATA RESTORATION FROM REST API ===
async function loadData() {
  try {
    const res = await fetch('/api/design');
    localStoryData = await res.json();
    
    storyName = localStoryData.slug || "story";
    document.getElementById('title_display').textContent = `Design: ${localStoryData.title || storyName}`;
    
    // Inject runtime analytical layout tokens needed for JS Sortable maps identification
    localStoryData.blocks.forEach((block, index) => {
      block.id = `block_${Date.now()}_${index}_${Math.random().toString(36).substr(2, 5)}`;
      block.media_assets.forEach((asset, aIndex) => {
        asset.id = `img_${block.id}_${aIndex}`;
      });
    });

    renderTree();
  } catch (e) {
    console.error("Failed to load layout blueprint from Flatplan core API:", e);
  }
}

// === 2. INTERACTIVE COMPONENT TREE RENDERING ===
function renderTree() {
  const treeContainer = document.getElementById('blocks_tree');
  treeContainer.innerHTML = '';

  localStoryData.blocks.forEach(block => {
    const blockEl = document.createElement('div');
    blockEl.className = 'root-block';
    blockEl.setAttribute('data-block-id', block.id);

    const meta = block.metadata || {};
    const isTextAndMedia = block.type.endsWith('TextAndMedia');
    const cleanTypeName = block.type.split('::').pop();

    blockEl.innerHTML = `
      <div class="block-header">
        <div style="display: flex; align-items: center; gap: 10px;">
          <div class="drag-handle root-handle">☰</div>
          <span class="block-title">${cleanTypeName}</span>
        </div>
        <div class="settings-btn" onclick="toggleInspector('${block.id}')">⚙️</div>
      </div>
      
      <!-- Properties Inspector (medium_spec layout constraints panel) -->
      <div class="inspector-panel" id="inspector_${block.id}">
        <div class="inspector-row">
          <label>columns</label>
          <input type="number" min="1" max="6" value="${meta.columns || 2}" onchange="updateMetadata('${block.id}', 'columns', this.value)">
        </div>
        <div class="inspector-row">
          <label>aspect_mode</label>
          <select onchange="updateMetadata('${block.id}', 'aspect_mode', this.value)">
            <option value="natural" ${meta.aspect_mode === 'natural' ? 'selected' : ''}>natural</option>
            <option value="square" ${meta.aspect_mode === 'square' ? 'selected' : ''}>square</option>
            <option value="portrait" ${meta.aspect_mode === 'portrait' ? 'selected' : ''}>portrait</option>
          </select>
        </div>
        ${isTextAndMedia ? `
          <div class="inspector-row">
            <label>text_position</label>
            <select onchange="updateMetadata('${block.id}', 'text_position', this.value)">
              <option value="left" ${meta.text_position === 'left' ? 'selected' : ''}>left</option>
              <option value="right" ${meta.text_position === 'right' ? 'selected' : ''}>right</option>
            </select>
          </div>
          <div class="inspector-row">
            <label>flow</label>
            <select onchange="updateMetadata('${block.id}', 'flow', this.value === 'true')">
              <option value="false" ${meta.flow !== true ? 'selected' : ''}>false</option>
              <option value="true" ${meta.flow === true ? 'selected' : ''}>true</option>
            </select>
          </div>
        ` : ''}
      </div>

      <!-- Nested structural sub-node dropped images target container -->
      <div class="media-dropzone" data-block-id="${block.id}">
        ${block.media_assets.map(asset => `
          <div class="image-card" data-asset-id="${asset.id}" title="${asset.filename}">
            <img src="${asset.thumb_url}">
          </div>
        `).join('')}
      </div>
    `;

    treeContainer.appendChild(blockEl);
  });

  initSortables();
}

// === 3. NESTED DRAG-AND-DROP (SORTABLE) WIREFRAME ===
function initSortables() {
  new Sortable(document.getElementById('blocks_tree'), {
    animation: 150,
    handle: '.root-handle',
    ghostClass: 'sortable-ghost',
    onEnd: function () {
      reorderRootBlocks();
      syncPreview();
    }
  });

  document.querySelectorAll('.media-dropzone').forEach(zone => {
    new Sortable(zone, {
      animation: 150,
      group: 'shared_media_pool',
      ghostClass: 'sortable-ghost',
      onEnd: function (evt) {
        const sourceBlockId = evt.from.getAttribute('data-block-id');
        const targetBlockId = evt.to.getAttribute('data-block-id');
        const assetId = evt.item.getAttribute('data-asset-id');

        moveAssetInMemory(sourceBlockId, targetBlockId, assetId, evt.newIndex);
        syncPreview();
      }
    });
  });
}

// === 4. IN-MEMORY RUNTIME LOCALCACHE MUTATORS ===
function reorderRootBlocks() {
  const currentOrderIds = Array.from(document.querySelectorAll('.root-block')).map(el => el.getAttribute('data-block-id'));
  localStoryData.blocks.sort((a, b) => currentOrderIds.indexOf(a.id) - currentOrderIds.indexOf(b.id));
}

function moveAssetInMemory(sourceId, targetId, assetId, newIndex) {
  const sourceBlock = localStoryData.blocks.find(b => b.id === sourceId);
  const targetBlock = localStoryData.blocks.find(b => b.id === targetId);
  
  const assetIndex = sourceBlock.media_assets.findIndex(a => a.id === assetId);
  const [movedAsset] = sourceBlock.media_assets.splice(assetIndex, 1);

  targetBlock.media_assets.splice(newIndex, 0, movedAsset);
}

function toggleInspector(blockId) {
  const el = document.getElementById(`inspector_${blockId}`);
  el.style.display = el.style.display === 'block' ? 'none' : 'block';
}

function updateMetadata(blockId, key, value) {
  const block = localStoryData.blocks.find(b => b.id === blockId);
  if (key === 'columns') value = parseInt(value, 10) || 2;
  block.metadata[key] = value;
  syncPreview();
}

// === 5. EXTERNAL API ROUTING COMMITS ===
function syncPreview() {
  fetch('/api/preview', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(localStoryData)
  }).then(() => {
    document.getElementById('preview_plane').contentWindow.location.reload();
  });
}

function saveLayout() {
  const saveBtn = document.getElementById('save_btn');
  fetch('/api/save', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(localStoryData)
  }).then(res => { 
    if (res.ok) {
      saveBtn.textContent = 'Saved!';
      saveBtn.style.background = '#1b5e20';
      setTimeout(() => { 
        saveBtn.textContent = 'Save (Ctrl+S)'; 
        saveBtn.style.background = '#2e7d32';
      }, 1200);
    } 
  });
}

document.getElementById('save_btn').addEventListener('click', saveLayout);
window.addEventListener('keydown', (e) => {
  if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 's') {
    e.preventDefault();
    saveLayout();
  }
});

loadData();
