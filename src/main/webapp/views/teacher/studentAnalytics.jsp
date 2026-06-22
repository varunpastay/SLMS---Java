<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Student Analytics – SLMS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
body{background:#fffbf0}
.hero{background:linear-gradient(135deg,#f59e0b,#d97706);color:#fff;border-radius:16px;padding:28px 32px;margin-bottom:24px}
.chart-card{border:none;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,.07);padding:20px}
</style>
</head>
<body>
<%@ include file="/views/base-header.jsp" %>
<div class="container py-4">
  <div class="hero">
    <h2 class="mb-1"><i class="bi bi-graph-up me-2"></i>Student Analytics</h2>
    <p class="mb-0 opacity-75">Visualize student performance, grade distribution, and attendance for your courses.</p>
  </div>

  <div class="row g-3 mb-4">
    <div class="col-md-6">
      <select id="courseSelect" class="form-select" onchange="loadAnalytics()">
        <option value="">-- Select a Course --</option>
        <c:forEach var="c" items="${courses}"><option value="${c.id}">${c.title}</option></c:forEach>
      </select>
    </div>
  </div>

  <!-- Summary Stats -->
  <div class="row g-3 mb-4" id="statsRow" style="display:none!important">
    <div class="col-6 col-md-3">
      <div class="card border-0 shadow-sm p-3 text-center"><div class="fs-2 fw-bold text-primary" id="sEnrolled">–</div><div class="text-muted small">Enrolled</div></div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card border-0 shadow-sm p-3 text-center"><div class="fs-2 fw-bold text-success" id="sAttend">–</div><div class="text-muted small">Avg Attendance</div></div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card border-0 shadow-sm p-3 text-center"><div class="fs-2 fw-bold text-warning" id="sTopAvg">–</div><div class="text-muted small">Top Student Avg</div></div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card border-0 shadow-sm p-3 text-center"><div class="fs-2 fw-bold text-info" id="sAssignments">–</div><div class="text-muted small">Assignments</div></div>
    </div>
  </div>

  <div class="row g-4" id="chartsRow" style="display:none!important">
    <div class="col-lg-6">
      <div class="chart-card card">
        <h6 class="fw-semibold mb-3"><i class="bi bi-pie-chart me-2 text-primary"></i>Grade Distribution</h6>
        <canvas id="gradeDistChart" height="240"></canvas>
      </div>
    </div>
    <div class="col-lg-6">
      <div class="chart-card card">
        <h6 class="fw-semibold mb-3"><i class="bi bi-trophy me-2 text-warning"></i>Top 10 Students</h6>
        <canvas id="topStudentsChart" height="240"></canvas>
      </div>
    </div>
    <div class="col-lg-12">
      <div class="chart-card card">
        <h6 class="fw-semibold mb-3"><i class="bi bi-clipboard-data me-2 text-success"></i>Assignment Averages</h6>
        <canvas id="assignmentsChart" height="150"></canvas>
      </div>
    </div>
  </div>

  <div id="selectHint" class="text-center text-muted py-5">
    <i class="bi bi-graph-up-arrow fs-1 opacity-25 d-block mb-2"></i>Select a course to view analytics
  </div>
</div>

<script>
let gradeChart, topChart, asgChart;

async function loadAnalytics() {
  const courseId = document.getElementById('courseSelect').value;
  if (!courseId) return;
  const r = await fetch('/slms/teacher/analytics?action=data&courseId=' + courseId);
  const d = await r.json();

  document.getElementById('selectHint').style.display = 'none';
  document.getElementById('statsRow').style.removeProperty('display');
  document.getElementById('chartsRow').style.removeProperty('display');

  document.getElementById('sEnrolled').textContent = d.enrolled || 0;
  document.getElementById('sAttend').textContent = (d.attendanceRate || 0) + '%';
  document.getElementById('sTopAvg').textContent = d.topStudents && d.topStudents.length ? d.topStudents[0].avg + '%' : '–';
  document.getElementById('sAssignments').textContent = d.assignments ? d.assignments.length : 0;

  // Grade Distribution Pie
  if (gradeChart) gradeChart.destroy();
  const gd = d.gradeDistribution || [];
  gradeChart = new Chart(document.getElementById('gradeDistChart'), {
    type: 'doughnut',
    data: {
      labels: gd.map(g=>g.band),
      datasets: [{ data: gd.map(g=>g.count),
        backgroundColor: ['#22c55e','#3b82f6','#f59e0b','#ef4444','#6b7280'] }]
    },
    options: { plugins: { legend: { position:'right' } } }
  });

  // Top Students
  if (topChart) topChart.destroy();
  const ts = d.topStudents || [];
  topChart = new Chart(document.getElementById('topStudentsChart'), {
    type: 'bar',
    data: {
      labels: ts.map(s=>s.name),
      datasets: [{ label: 'Avg Grade', data: ts.map(s=>s.avg), backgroundColor:'rgba(245,158,11,.7)', borderRadius:6 }]
    },
    options: { indexAxis:'y', plugins:{legend:{display:false}}, scales:{x:{beginAtZero:true,max:100}} }
  });

  // Assignments
  if (asgChart) asgChart.destroy();
  const as = d.assignments || [];
  asgChart = new Chart(document.getElementById('assignmentsChart'), {
    type: 'bar',
    data: {
      labels: as.map(a=>a.title),
      datasets: [
        { label: 'Avg Grade', data: as.map(a=>a.avg), backgroundColor:'rgba(99,102,241,.7)', borderRadius:6 },
        { label: 'Submissions', data: as.map(a=>a.submissions), backgroundColor:'rgba(34,197,94,.5)', borderRadius:6 }
      ]
    },
    options: { plugins:{legend:{position:'top'}}, scales:{y:{beginAtZero:true}} }
  });
}
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
