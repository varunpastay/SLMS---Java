<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Admin Dashboard – SLMS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
body{background:#f0f4ff}
.hero{background:linear-gradient(135deg,#1e293b,#334155);color:#fff;border-radius:16px;padding:28px 32px;margin-bottom:24px}
.stat-card{border:none;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,.08);transition:transform .2s}
.stat-card:hover{transform:translateY(-2px)}
.chart-card{border:none;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,.07);padding:20px}
</style>
</head>
<body>
<%@ include file="/views/base-header.jsp" %>
<div class="container-fluid py-4 px-4">
  <div class="hero">
    <h2 class="mb-1"><i class="bi bi-speedometer2 me-2"></i>Admin Analytics Dashboard</h2>
    <p class="mb-0 opacity-75">System-wide stats: users, courses, enrollments, and activity.</p>
  </div>

  <!-- Summary Stats -->
  <div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
      <div class="stat-card card p-3">
        <div class="d-flex justify-content-between align-items-center">
          <div><div class="text-muted small">Total Users</div><div class="fs-2 fw-bold text-primary" id="sUsers">–</div></div>
          <i class="bi bi-people-fill fs-1 text-primary opacity-25"></i>
        </div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="stat-card card p-3">
        <div class="d-flex justify-content-between align-items-center">
          <div><div class="text-muted small">Total Courses</div><div class="fs-2 fw-bold text-success" id="sCourses">–</div></div>
          <i class="bi bi-book-fill fs-1 text-success opacity-25"></i>
        </div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="stat-card card p-3">
        <div class="d-flex justify-content-between align-items-center">
          <div><div class="text-muted small">Enrollments</div><div class="fs-2 fw-bold text-warning" id="sEnroll">–</div></div>
          <i class="bi bi-person-check-fill fs-1 text-warning opacity-25"></i>
        </div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="stat-card card p-3">
        <div class="d-flex justify-content-between align-items-center">
          <div><div class="text-muted small">Pending Teachers</div><div class="fs-2 fw-bold text-danger" id="sPendingT">–</div></div>
          <i class="bi bi-hourglass-split fs-1 text-danger opacity-25"></i>
        </div>
      </div>
    </div>
  </div>

  <div class="row g-4">
    <!-- Users by Role Pie -->
    <div class="col-lg-4">
      <div class="chart-card card">
        <h6 class="fw-semibold mb-3"><i class="bi bi-people me-2 text-primary"></i>Users by Role</h6>
        <canvas id="roleChart" height="220"></canvas>
      </div>
    </div>
    <!-- Registrations Line -->
    <div class="col-lg-8">
      <div class="chart-card card">
        <h6 class="fw-semibold mb-3"><i class="bi bi-person-plus me-2 text-success"></i>New Registrations (Last 7 Days)</h6>
        <canvas id="regChart" height="220"></canvas>
      </div>
    </div>
    <!-- Top Courses Bar -->
    <div class="col-lg-7">
      <div class="chart-card card">
        <h6 class="fw-semibold mb-3"><i class="bi bi-bar-chart me-2 text-warning"></i>Top Courses by Enrollment</h6>
        <canvas id="coursesChart" height="260"></canvas>
      </div>
    </div>
    <!-- Submissions Line -->
    <div class="col-lg-5">
      <div class="chart-card card">
        <h6 class="fw-semibold mb-3"><i class="bi bi-send me-2 text-info"></i>Submissions (Last 7 Days)</h6>
        <canvas id="subsChart" height="260"></canvas>
      </div>
    </div>
  </div>
</div>

<script>
async function loadData() {
  const r = await fetch('/slms/admin/dashboard-charts?action=data');
  const d = await r.json();

  document.getElementById('sUsers').textContent = d.totalUsers || 0;
  document.getElementById('sCourses').textContent = d.totalCourses || 0;
  document.getElementById('sEnroll').textContent = d.totalEnrollments || 0;
  document.getElementById('sPendingT').textContent = d.pendingTeachers || 0;

  // Role pie
  const roles = d.usersByRole || {};
  new Chart(document.getElementById('roleChart'), {
    type: 'doughnut',
    data: {
      labels: Object.keys(roles),
      datasets: [{ data: Object.values(roles), backgroundColor: ['#6366f1','#22c55e','#f59e0b','#ef4444'] }]
    },
    options: { plugins:{ legend:{position:'bottom'} } }
  });

  // Registrations
  const regs = d.registrations || [];
  new Chart(document.getElementById('regChart'), {
    type: 'line',
    data: {
      labels: regs.map(r=>r.date),
      datasets: [{ label:'New Users', data: regs.map(r=>r.count),
        borderColor:'#22c55e', backgroundColor:'rgba(34,197,94,.15)', fill:true, tension:.4 }]
    },
    options: { plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true}} }
  });

  // Top courses
  const courses = d.topCourses || [];
  new Chart(document.getElementById('coursesChart'), {
    type: 'bar',
    data: {
      labels: courses.map(c=>c.title),
      datasets: [{ label:'Enrolled', data: courses.map(c=>c.enrolled), backgroundColor:'rgba(245,158,11,.7)', borderRadius:6 }]
    },
    options: { indexAxis:'y', plugins:{legend:{display:false}}, scales:{x:{beginAtZero:true}} }
  });

  // Submissions
  const subs = d.submissions || [];
  new Chart(document.getElementById('subsChart'), {
    type: 'bar',
    data: {
      labels: subs.length ? subs.map(s=>s.date) : ['No data'],
      datasets: [{ label:'Submissions', data: subs.length ? subs.map(s=>s.count) : [0], backgroundColor:'rgba(99,102,241,.7)', borderRadius:6 }]
    },
    options: { plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true}} }
  });
}
loadData();
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
