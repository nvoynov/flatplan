<script>
  // highlighting
  window.addEventListener('message', (e) => {
    if (e.data.action === 'highlight') {
      document.querySelectorAll('.flatplan_image_cell').forEach(el => {
        el.style.outline = 'none'; el.style.boxShadow = 'none';
      });
      const activeCell = document.getElementById(e.data.id);
      if (activeCell) {
        activeCell.scrollIntoView({ behavior: 'smooth', block: 'center' });
        activeCell.style.outline = '3px solid #ffaa00';
        activeCell.style.outlineOffset = '5px';
        activeCell.style.boxShadow = '0 0 20px rgba(255, 170, 0, 0.4)';
      }
    }
  });

  // live-reloading
  (function() {
    let currentVersion = null;
    setInterval(async () => {
      try {
        // request version, skipping browser cache by adding ?t=
        const res = await fetch(`version.txt?t=${Date.now()}`);
        if (!res.ok) return;
        const text = await res.text();
        
        if (currentVersion === null) {
          currentVersion = text;
        } else if (currentVersion !== text) {
          window.location.reload();
        }
      } catch (e) {
        // ignore net errors while entr buillds preview
      }
    }, 500); // every 500 milliseconds
  })();
</script>
