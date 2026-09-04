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

// === 4. IN-MEMORY RUNTIME LOCALCACHE MUTATORS ===
function reorderRootBlocks() {
  console.log("LOG: Reordering root blocks based on DOM...");
  
  const currentOrderIds = Array.from(document.querySelectorAll('.root-block'))
                               .map(el => el.getAttribute('data-block-id'));
  
  // Собираем новый массив строго по физическому порядку на экране
  const reorderedBlocks = currentOrderIds.map(id => {
    return localStoryData.blocks.find(block => block.id === id);
  }).filter(Boolean);

  localStoryData.blocks = reorderedBlocks;
  console.log("LOG: New order saved in memory.");
}

// 2. СИНХРОНИЗАЦИЯ ПРЕВЬЮ С ПОЛНОЙ ПЕРЕРИСОВКОЙ ТРЕТА
function syncPreview() {
  console.log("LOG: Syncing modified JSON layout with server...");
  
  fetch('/api/preview', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(localStoryData)
  }).then(res => {
    if (res.ok) {
      console.log("LOG: Server compiled preview successfully. Refreshing viewports...");
      
      // Перезагружаем правый фрейм, чтобы увидеть новую верстку
      document.getElementById('preview_plane').contentWindow.location.reload();
      
      // КРИТИЧНО ДЛЯ СОРТИРОВКИ: Принудительно перерисовываем левое дерево, 
      // чтобы SortableJS инициализировал новые чистые контейнеры для блоков и картинок!
      renderTree();
    }
  });
}

// ИСПРАВЛЕННАЯ ФУНКЦИЯ: Универсальное перемещение картинок
function moveAssetInMemory(sourceId, targetId, assetId, newIndex) {
  const sourceBlock = localStoryData.blocks.find(b => b.id === sourceId);
  
  // Находим саму картинку в исходном блоке
  const assetIndex = sourceBlock.media_assets.findIndex(a => a.id === assetId);
  if (assetIndex === -1) return; // Страховка от сбоев
  
  // Вырезаем картинку из старого места
  const [movedAsset] = sourceBlock.media_assets.splice(assetIndex, 1);

  if (sourceId === targetId) {
    console.log(`LOG: Internal sorting inside block ${sourceId} from index ${assetIndex} to ${newIndex}`);
    // Если сортируем внутри одного блока, вставляем в этот же массив
    sourceBlock.media_assets.splice(newIndex, 0, movedAsset);
  } else {
    console.log(`LOG: Cross-block sorting from ${sourceId} to ${targetId}`);
    // Если картинка уехала в другой блок, ищем целевой блок и вставляем туда
    const targetBlock = localStoryData.blocks.find(b => b.id === targetId);
    targetBlock.media_assets.splice(newIndex, 0, movedAsset);
  }
}

// ОБНОВЛЕННАЯ НАСТРОЙКА SORTABLEJS (Добавляем явное событие для внутренней сортировки)
function initSortables() {
  // Родительские блоки
  new Sortable(document.getElementById('blocks_tree'), {
    animation: 150,
    handle: '.root-handle',
    ghostClass: 'sortable-ghost',
    onEnd: function () {
      reorderRootBlocks();
      syncPreview();
    }
  });

  // Картинки внутри блоков
  document.querySelectorAll('.media-dropzone').forEach(zone => {
    new Sortable(zone, {
      animation: 150,
      group: 'shared_media_pool',
      ghostClass: 'sortable-ghost',
      
      // onEnd ловит абсолютно любые окончания перетаскиваний (и внутренние, и внешние)
      onEnd: function (evt) {
        const sourceBlockId = evt.from.getAttribute('data-block-id');
        const targetBlockId = evt.to.getAttribute('data-block-id');
        const assetId = evt.item.getAttribute('data-asset-id');

        // Вызываем нашу обновленную функцию, которая теперь умеет работать внутри одного блока
        moveAssetInMemory(sourceBlockId, targetBlockId, assetId, evt.newIndex);
        syncPreview();
      }
    });
  });
}

function updateMetadata(blockId, key, value) {
  const block = localStoryData.blocks.find(b => b.id === blockId);
  if (key === 'columns') value = parseInt(value, 10) || 2;
  block.metadata[key] = value;
  syncPreview();
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
