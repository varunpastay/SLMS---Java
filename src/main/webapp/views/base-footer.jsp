<%@ page contentType="text/html;charset=UTF-8" language="java" %>
</div><!-- end page content -->

<footer class="mt-auto py-3 border-top" style="background:var(--surface);border-color:var(--border)!important">
  <div class="container-fluid text-center text-muted" style="font-size:.8rem">
    &copy; 2025 <strong>SLMS</strong> &mdash; Student Learning Management System
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/static/js/slms.js"></script>
<script>
  // Notification count polling
  (function pollNotif() {
    fetch('${pageContext.request.contextPath}/notifications?action=count')
      .then(r => r.json())
      .then(d => {
        const b = document.getElementById('notifCount');
        if (!b) return;
        if (d.count > 0) { b.textContent = d.count > 99 ? '99+' : d.count; b.style.display = ''; }
        else b.style.display = 'none';
      }).catch(() => {});
  })();
  setInterval(function() {
    fetch('${pageContext.request.contextPath}/notifications?action=count')
      .then(r => r.json())
      .then(d => {
        const b = document.getElementById('notifCount');
        if (!b) return;
        if (d.count > 0) { b.textContent = d.count > 99 ? '99+' : d.count; b.style.display = ''; }
        else b.style.display = 'none';
      }).catch(() => {});
  }, 30000);
</script>
</body>
</html>
