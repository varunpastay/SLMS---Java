/* SLMS – global JS helpers */

/* ── Toast system ── */
const SLMS = {
  toast(message, type = 'info', title = '') {
    const container = document.getElementById('toast-container');
    if (!container) return;
    const icons = { success: 'bi-check-circle-fill', error: 'bi-x-circle-fill', warning: 'bi-exclamation-triangle-fill', info: 'bi-info-circle-fill' };
    const titles = { success: 'Success', error: 'Error', warning: 'Warning', info: 'Info' };
    const el = document.createElement('div');
    el.className = `slms-toast ${type}`;
    el.innerHTML = `
      <i class="bi ${icons[type] || icons.info} toast-icon"></i>
      <div class="toast-body">
        <div class="toast-title">${title || titles[type]}</div>
        <div class="toast-msg">${message}</div>
      </div>
      <button class="toast-close" onclick="SLMS.dismissToast(this.closest('.slms-toast'))">&times;</button>`;
    container.appendChild(el);
    setTimeout(() => SLMS.dismissToast(el), 5000);
  },
  dismissToast(el) {
    if (!el) return;
    el.classList.add('hiding');
    setTimeout(() => el.remove(), 300);
  }
};

document.addEventListener('DOMContentLoaded', function () {

  /* ── Confirm dialogs ── */
  document.querySelectorAll('[data-confirm]').forEach(el => {
    el.addEventListener('click', e => {
      if (!confirm(el.dataset.confirm || 'Are you sure?')) e.preventDefault();
    });
  });

  /* ── Auto-dismiss alerts ── */
  document.querySelectorAll('.alert:not(.alert-permanent)').forEach(alert => {
    setTimeout(() => {
      alert.style.transition = 'opacity 0.5s, transform 0.5s';
      alert.style.opacity = '0';
      alert.style.transform = 'translateY(-8px)';
      setTimeout(() => alert.remove(), 500);
    }, 5000);
  });

  /* ── Animate progress bars on load ── */
  document.querySelectorAll('.progress-bar[data-width]').forEach(bar => {
    const target = bar.dataset.width;
    bar.style.width = '0%';
    requestAnimationFrame(() => {
      setTimeout(() => { bar.style.width = target; }, 100);
    });
  });

  /* ── Active nav link highlighting ── */
  const path = window.location.pathname;
  document.querySelectorAll('.nav-link').forEach(link => {
    const href = link.getAttribute('href');
    if (href && path.includes(href.split('?')[0]) && href !== '#') {
      link.classList.add('active');
    }
  });

  /* ── Star rating highlight ── */
  document.querySelectorAll('.star-rating input[type=radio]').forEach(radio => {
    radio.addEventListener('change', function () {
      const val = parseInt(this.value);
      document.querySelectorAll('.star-rating label').forEach((lbl, i) => {
        lbl.style.color = i < val ? '#ffc107' : '#ccc';
      });
    });
  });

  /* ── Table row loading animation ── */
  document.querySelectorAll('table tbody tr').forEach((tr, i) => {
    tr.style.animationDelay = `${i * 0.03}s`;
    tr.classList.add('animate-fade-in');
  });

  /* ── Card hover ripple ── */
  document.querySelectorAll('.course-card').forEach(card => {
    card.addEventListener('mouseenter', function () {
      this.style.willChange = 'transform';
    });
    card.addEventListener('mouseleave', function () {
      this.style.willChange = '';
    });
  });

  /* ── Flash toast from query param ── */
  const params = new URLSearchParams(window.location.search);
  if (params.get('announced') === '1')   SLMS.toast('Announcement posted to all students.', 'success');
  if (params.get('completed') === '1')   SLMS.toast('Course marked complete! Certificate issued.', 'success', 'Congratulations!');
  if (params.get('enrolled') === '1')    SLMS.toast('Successfully enrolled in course.', 'success');
  if (params.get('roleUpdated') === '1') SLMS.toast('User role updated successfully.', 'success');

});
