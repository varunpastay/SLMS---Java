<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Dashboard"/>
<%@ include file="/views/base-header.jsp" %>

<div style="min-height:calc(100vh - 64px);background:var(--surface-2);padding:2rem 1.5rem">

<!-- Welcome banner -->
<div class="welcome-banner mb-4">
  <div class="row align-items-center">
    <div class="col">
      <h2>Good day, ${user.firstName}! &#128075;</h2>
      <p>Here's what's happening with your learning journey.</p>
    </div>
    <div class="col-auto d-none d-md-block">
      <i class="bi bi-mortarboard-fill" style="font-size:4rem;opacity:.15;"></i>
    </div>
  </div>
</div>

<!-- Stats -->
<div class="row g-3 mb-4">
  <div class="col-6 col-lg-3">
    <div class="stat-card" style="background:linear-gradient(135deg,#3b82f6,#6366f1)">
      <div class="stat-icon"><i class="bi bi-collection"></i></div>
      <div class="stat-number mt-2">${enrollments.size()}</div>
      <div class="stat-label">Courses Enrolled</div>
    </div>
  </div>
  <div class="col-6 col-lg-3">
    <div class="stat-card" style="background:linear-gradient(135deg,#10b981,#059669)">
      <c:set var="completed" value="0"/>
      <c:forEach var="e" items="${enrollments}">
        <c:if test="${e.completed}"><c:set var="completed" value="${completed + 1}"/></c:if>
      </c:forEach>
      <div class="stat-icon"><i class="bi bi-check2-all"></i></div>
      <div class="stat-number mt-2">${completed}</div>
      <div class="stat-label">Completed</div>
    </div>
  </div>
  <div class="col-6 col-lg-3">
    <div class="stat-card" style="background:linear-gradient(135deg,#f59e0b,#d97706)">
      <div class="stat-icon"><i class="bi bi-bell"></i></div>
      <div class="stat-number mt-2">${unreadNotifications}</div>
      <div class="stat-label">Notifications</div>
    </div>
  </div>
  <div class="col-6 col-lg-3">
    <div class="stat-card" style="background:linear-gradient(135deg,#8b5cf6,#7c3aed)">
      <div class="stat-icon"><i class="bi bi-trophy"></i></div>
      <div class="stat-number mt-2">#${leaderboardRank}</div>
      <div class="stat-label">Leaderboard Rank</div>
    </div>
  </div>
</div>

<div class="row g-4">
  <!-- My Courses with progress -->
  <div class="col-lg-8">
    <div class="card shadow-sm h-100">
      <div class="card-header d-flex justify-content-between align-items-center">
        <span class="section-title mb-0"><i class="bi bi-journals"></i>My Courses</span>
        <a href="${ctx}/courses" class="btn btn-sm btn-outline-primary">Browse More</a>
      </div>
      <div class="card-body p-0">
        <c:choose>
          <c:when test="${empty enrollments}">
            <div class="empty-state">
              <i class="bi bi-book-half"></i>
              <h5>No courses yet</h5>
              <p class="text-muted mb-3">Start learning by enrolling in a course.</p>
              <a href="${ctx}/courses" class="btn btn-primary btn-sm">Browse Courses</a>
            </div>
          </c:when>
          <c:otherwise>
            <div class="p-3 d-flex flex-column gap-3">
              <c:forEach var="e" items="${enrollments}">
                <div class="d-flex align-items-center gap-3 p-3 rounded-xl" style="background:var(--surface-3)">
                  <div class="rounded-xl d-flex align-items-center justify-content-center flex-shrink-0"
                       style="width:48px;height:48px;background:linear-gradient(135deg,#3b82f6,#6366f1);color:#fff;font-size:1.3rem">
                    <i class="bi bi-book"></i>
                  </div>
                  <div class="flex-grow-1 min-w-0">
                    <div class="fw-semibold text-truncate">${e.courseTitle}</div>
                    <div class="d-flex align-items-center gap-2 mt-1">
                      <div class="progress flex-grow-1" style="height:6px">
                        <div class="progress-bar" data-width="${e.completed ? '100%' : '50%'}"
                             style="width:${e.completed ? '100%' : '50%'}"></div>
                      </div>
                      <span style="font-size:.75rem;color:var(--text-muted);white-space:nowrap">
                        ${e.completed ? '100%' : 'In Progress'}
                      </span>
                    </div>
                  </div>
                  <div class="d-flex align-items-center gap-2">
                    <c:choose>
                      <c:when test="${e.completed}">
                        <span class="badge bg-success-subtle text-success">Completed</span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge bg-primary-subtle text-primary">Active</span>
                      </c:otherwise>
                    </c:choose>
                    <a href="${ctx}/course/detail?id=${e.courseId}" class="btn btn-sm btn-primary">Open</a>
                  </div>
                </div>
              </c:forEach>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>

  <!-- Sidebar -->
  <div class="col-lg-4 d-flex flex-column gap-4">
    <!-- Quick actions -->
    <div class="card shadow-sm">
      <div class="card-header">
        <span class="section-title mb-0"><i class="bi bi-lightning"></i>Quick Actions</span>
      </div>
      <div class="card-body d-flex flex-column gap-2">
        <a href="${ctx}/calendar" class="btn btn-outline-primary text-start">
          <i class="bi bi-calendar3 me-2"></i>View Calendar
        </a>
        <a href="${ctx}/gradebook" class="btn btn-outline-primary text-start">
          <i class="bi bi-bar-chart me-2"></i>My Grades
        </a>
        <a href="${ctx}/leaderboard" class="btn btn-outline-primary text-start">
          <i class="bi bi-trophy me-2"></i>Leaderboard
        </a>
        <a href="${ctx}/certificate/my" class="btn btn-outline-primary text-start">
          <i class="bi bi-patch-check me-2"></i>My Certificates
        </a>
      </div>
    </div>

    <!-- Recent Notifications -->
    <div class="card shadow-sm flex-grow-1">
      <div class="card-header d-flex justify-content-between align-items-center">
        <span class="section-title mb-0"><i class="bi bi-bell"></i>Notifications</span>
        <a href="${ctx}/notifications" class="btn btn-sm btn-outline-secondary">All</a>
      </div>
      <div class="list-group list-group-flush">
        <c:choose>
          <c:when test="${empty notifications}">
            <div class="empty-state py-4">
              <i class="bi bi-bell-slash" style="font-size:2rem;opacity:.3"></i>
              <p class="mb-0 mt-2 text-muted small">No notifications</p>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="n" items="${notifications}" varStatus="s">
              <c:if test="${s.index < 5}">
                <div class="list-group-item border-0 py-2 px-3 ${not n.read ? 'fw-semibold' : ''}">
                  <div class="d-flex align-items-start gap-2">
                    <i class="bi bi-dot text-primary fs-5 flex-shrink-0 mt-n1"></i>
                    <div>
                      <div style="font-size:.85rem">${n.message}</div>
                      <div class="text-muted" style="font-size:.75rem">
                        <fmt:formatDate value="${n.createdAt}" pattern="MMM dd, HH:mm"/>
                      </div>
                    </div>
                  </div>
                </div>
              </c:if>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>

</div><!-- end page content -->

<footer class="py-3 border-top text-center text-muted" style="font-size:.8rem;background:var(--surface)">
  &copy; 2025 <strong>SLMS</strong> &mdash; Student Learning Management System
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/static/js/slms.js"></script>
<script>
  (function() {
    fetch('${ctx}/notifications?action=count')
      .then(r => r.json())
      .then(d => {
        const b = document.getElementById('notifCount');
        if (b && d.count > 0) { b.textContent = d.count; b.style.display = ''; }
      }).catch(() => {});
  })();
</script>
</body>
</html>
