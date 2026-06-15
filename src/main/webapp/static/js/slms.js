// SLMS – global JS helpers

// Confirm before deleting
document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('[data-confirm]').forEach(function (el) {
    el.addEventListener('click', function (e) {
      if (!confirm(el.dataset.confirm || 'Are you sure?')) {
        e.preventDefault();
      }
    });
  });

  // Auto-dismiss alerts after 5 seconds
  document.querySelectorAll('.alert:not(.alert-permanent)').forEach(function (alert) {
    setTimeout(function () {
      alert.style.transition = 'opacity 0.5s';
      alert.style.opacity = '0';
      setTimeout(function () { alert.remove(); }, 500);
    }, 5000);
  });

  // Star rating highlight
  document.querySelectorAll('.star-rating input[type=radio]').forEach(function (radio) {
    radio.addEventListener('change', function () {
      const val = parseInt(this.value);
      document.querySelectorAll('.star-rating label').forEach(function (lbl, i) {
        lbl.style.color = i < val ? '#ffc107' : '#ccc';
      });
    });
  });
});
