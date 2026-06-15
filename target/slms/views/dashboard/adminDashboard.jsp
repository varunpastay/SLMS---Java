<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Admin Dashboard"/>
<%@ include file="/views/base-header.jsp" %>

<div style="min-height:calc(100vh - 64px);background:var(--surface-2);padding:2rem 1.5rem">

<!-- Welcome -->
<div class="welcome-banner mb-4">
  <div class="row align-items-center">
    <div class="col">
      <h2>Admin Dashboard</h2>
      <p>Manage users, monitor platform activity, and configure the system.</p>
    </div>
    <div class="col-auto d-none d-md-block">
      <i class="bi bi-shield-lock-fill" style="font-size:4rem;opacity:.15"></i>
    </div>
  </div>
</div>

<!-- Stats -->
<div class="row g-3 mb-4">
  <div class="col-6 col-lg-3">
    <div class="stat-card" style="background:linear-gradient(135deg,#3b82f6,#6366f1)">
      <div class="stat-icon"><i class="bi bi-people-fill"></i></div>
      <div class="stat-number mt-2">${totalUsers}</div>
      <div class="stat-label">Total Users</div>
    </div>
  </div>
  <div class="col-6 col-lg-3">
    <div class="stat-card" style="background:linear-gradient(135deg,#10b981,#059669)">
      <div class="stat-icon"><i class="bi bi-collection"></i></div>
      <div class="stat-number mt-2">${totalCourses}</div>
      <div class="stat-label">Total Courses</div>
    </div>
  </div>
  <div class="col-6 col-lg-3">
    <div class="stat-card" style="background:linear-gradient(135deg,#f59e0b,#d97706)">
      <div class="stat-icon"><i class="bi bi-person-check"></i></div>
      <div class="stat-number mt-2">${totalEnrollments}</div>
      <div class="stat-label">Enrollments</div>
    </div>
  </div>
  <div class="col-6 col-lg-3">
    <div class="stat-card" style="background:linear-gradient(135deg,#8b5cf6,#7c3aed)">
      <div class="stat-icon"><i class="bi bi-journal-text"></i></div>
      <div class="stat-number mt-2">
        <a href="${ctx}/admin/activity-log" class="text-white text-decoration-none" style="font-size:1rem">View Log</a>
      </div>
      <div class="stat-label">Activity Log</div>
    </div>
  </div>
</div>

<!-- Charts row -->
<div class="row g-4 mb-4">
  <div class="col-lg-6">
    <div class="card shadow-sm">
      <div class="card-header"><span class="section-title mb-0"><i class="bi bi-pie-chart"></i>Users by Role</span></div>
      <div class="card-body d-flex justify-content-center" style="height:260px">
        <canvas id="roleChart"></canvas>
      </div>
    </div>
  </div>
  <div class="col-lg-6">
    <div class="card shadow-sm">
      <div class="card-header"><span class="section-title mb-0"><i class="bi bi-bar-chart"></i>Platform Overview</span></div>
      <div class="card-body d-flex justify-content-center" style="height:260px">
        <canvas id="overviewChart"></canvas>
      </div>
    </div>
  </div>
</div>

<!-- Users table -->
<div class="card shadow-sm">
  <div class="card-header d-flex justify-content-between align-items-center">
    <span class="section-title mb-0"><i class="bi bi-people"></i>All Users</span>
    <a href="${ctx}/admin/activity-log" class="btn btn-sm btn-outline-primary">
      <i class="bi bi-journal-text me-1"></i>Activity Log
    </a>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover align-middle mb-0">
        <thead class="table-dark">
          <tr>
            <th>#</th>
            <th>Name</th>
            <th>Email</th>
            <th>Role</th>
            <th>Joined</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
        <c:forEach var="u" items="${allUsers}" varStatus="s">
          <tr>
            <td class="text-muted">${s.count}</td>
            <td>
              <div class="d-flex align-items-center gap-2">
                <span class="avatar-placeholder" style="width:32px;height:32px;font-size:.8rem">
                  ${u.firstName.substring(0,1)}
                </span>
                <span class="fw-semibold">${u.firstName} ${u.lastName}</span>
              </div>
            </td>
            <td class="text-muted small">${u.email}</td>
            <td>
              <c:choose>
                <c:when test="${u.role == 'ADMIN'}"><span class="badge bg-danger">Admin</span></c:when>
                <c:when test="${u.role == 'TEACHER'}"><span class="badge bg-info text-dark">Teacher</span></c:when>
                <c:otherwise><span class="badge bg-primary">Student</span></c:otherwise>
              </c:choose>
            </td>
            <td class="text-muted small">
              <fmt:formatDate value="${u.dateJoined}" pattern="MMM dd, yyyy"/>
            </td>
            <td>
              <c:choose>
                <c:when test="${u.active}">
                  <span class="badge bg-success-subtle text-success"><i class="bi bi-circle-fill me-1" style="font-size:.5rem"></i>Active</span>
                </c:when>
                <c:otherwise>
                  <span class="badge bg-secondary-subtle text-secondary">Inactive</span>
                </c:otherwise>
              </c:choose>
            </td>
            <td>
              <div class="d-flex gap-1">
                <!-- Toggle active -->
                <form action="${ctx}/admin/user/toggle" method="post" class="d-inline">
                  <input type="hidden" name="id" value="${u.id}"/>
                  <button class="btn btn-sm ${u.active ? 'btn-outline-warning' : 'btn-outline-success'}" type="submit"
                          title="${u.active ? 'Deactivate' : 'Activate'}">
                    <i class="bi bi-${u.active ? 'person-dash' : 'person-check'}"></i>
                  </button>
                </form>
                <!-- Change role -->
                <div class="dropdown">
                  <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                    Role
                  </button>
                  <ul class="dropdown-menu dropdown-menu-end">
                    <c:forEach var="role" items="${['STUDENT','TEACHER','ADMIN']}">
                      <li>
                        <form action="${ctx}/admin/user/role" method="post">
                          <input type="hidden" name="userId" value="${u.id}"/>
                          <input type="hidden" name="role" value="${role}"/>
                          <button type="submit" class="dropdown-item ${u.role == role ? 'fw-bold text-primary' : ''}">
                            ${role == 'ADMIN' ? 'Admin' : role == 'TEACHER' ? 'Teacher' : 'Student'}
                            <c:if test="${u.role == role}"><i class="bi bi-check ms-1"></i></c:if>
                          </button>
                        </form>
                      </li>
                    </c:forEach>
                  </ul>
                </div>
              </div>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

</div>

<footer class="py-3 border-top text-center text-muted" style="font-size:.8rem;background:var(--surface)">
  &copy; 2025 <strong>SLMS</strong>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
<script src="${pageContext.request.contextPath}/static/js/slms.js"></script>
<script>
  // Role distribution pie chart
  new Chart(document.getElementById('roleChart'), {
    type: 'doughnut',
    data: {
      labels: ['Students', 'Teachers', 'Admins'],
      datasets: [{
        data: [${totalStudents}, ${totalTeachers}, ${totalAdmins}],
        backgroundColor: ['#3b82f6','#10b981','#ef4444'],
        borderWidth: 0,
        hoverOffset: 8
      }]
    },
    options: {
      cutout: '65%',
      plugins: { legend: { position: 'bottom' } },
      animation: { duration: 1000 }
    }
  });

  // Platform overview bar chart
  new Chart(document.getElementById('overviewChart'), {
    type: 'bar',
    data: {
      labels: ['Users', 'Courses', 'Enrollments'],
      datasets: [{
        label: 'Count',
        data: [${totalUsers}, ${totalCourses}, ${totalEnrollments}],
        backgroundColor: ['#3b82f6','#10b981','#f59e0b'],
        borderRadius: 8,
        borderSkipped: false
      }]
    },
    options: {
      scales: { y: { beginAtZero: true, grid: { color: '#f1f5f9' } }, x: { grid: { display: false } } },
      plugins: { legend: { display: false } },
      animation: { duration: 1000 }
    }
  });

  // Show toast for role update
  const params = new URLSearchParams(window.location.search);
  if (params.get('roleUpdated') === '1') SLMS.toast('User role updated successfully.', 'success');
</script>
</body>
</html>
