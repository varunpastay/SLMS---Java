<%@ page contentType="text/html;charset=UTF-8" language="java" %>
</div><!-- /container-fluid -->

<footer class="bg-light border-top py-3 mt-4 text-center text-muted small">
  &copy; 2024 SLMS &mdash; Student Learning Management System
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/static/js/slms.js"></script>
<script>
  // Poll notification count every 30 seconds
  function refreshNotifCount() {
    fetch('${pageContext.request.contextPath}/notifications?action=count')
      .then(r => r.json())
      .then(data => {
        const badge = document.getElementById('notifCount');
        if (badge) {
          if (data.count > 0) {
            badge.textContent = data.count;
            badge.style.display = '';
          } else {
            badge.style.display = 'none';
          }
        }
      }).catch(() => {});
  }
  refreshNotifCount();
  setInterval(refreshNotifCount, 30000);
</script>
</body>
</html>
