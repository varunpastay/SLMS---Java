<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Progress Dashboard – SLMS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
body{background:#f8faff}
.hero{background:linear-gradient(135deg,#6366f1,#8b5cf6);color:#fff;border-radius:16px;padding:28px 32px;margin-bottom:24px}
.stat-card{border:none;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,.07)}
.chart-card{border:none;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,.07);padding:20px}
</style>
</head>
<body>
<%@ include file="/views/base-header.jsp" %>
<div class="container py-4">
  <div class="hero">
    <h2 class="mb-1"><i class="bi bi-bar-chart-fill me-2"></i>Progress Dashboard</h2>
    <p class="mb-0 opacity-75">Visual overview of your grades, quizzes, study hours, and OMR results.</p>
  </div>

  <!-- Summary Stats -->
  <div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
      <div class="stat-card card p-3 text-center">
        <div class="fs-2 fw-bold text-primary" id="statCourses">–</div>
        <div class="text-muted small">Enrolled Courses</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="stat-card card p-3 text-center">
        <div class="fs-2 fw-bold text-success" id="statAvg">–</div>
        <div class="text-muted small">Overall Avg Grade</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="stat-card card p-3 text-center">
        <div class="fs-2 fw-bold text-warning" id="statQuizzes">–</div>
        <div class="text-muted small">Quizzes Taken</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="stat-card card p-3 text-center">
        <div class="fs-2 fw-bold text-info" id="statStudy">–</div>
        <div class="text-muted small">Study Hours (7d)</div>
      </div>
    </div>
  </div>

  <div class="row g-4">
    <!-- Course Grades -->
    <div class="col-lg-6">
      <div class="chart-card card">
        <h6 class="fw-semibold mb-3"><i class="bi bi-bar-chart me-2 text-primary"></i>Average Grade by Course</h6>
        <canvas id="gradesChart" height="220"></canvas>
        <div id="noGrades" class="text-center text-muted py-3 d-none">No grade data yet</div>
      </div>
    </div>
    <!-- Study Hours -->
    <div class="col-lg-6">
      <div class="chart-card card">
        <h6 class="fw-semibold mb-3"><i class="bi bi-clock me-2 text-success"></i>Study Hours (Last 7 Days)</h6>
        <canvas id="studyChart" height="220"></canvas>
        <div id="noStudy" class="text-center text-muted py-3 d-none">No study sessions logged yet</div>
      </div>
    </div>
    <!-- Quiz Scores -->
    <div class="col-lg-6">
      <div class="chart-card card">
        <h6 class="fw-semibold mb-3"><i class="bi bi-lightning me-2 text-warning"></i>Recent Quiz Scores</h6>
        <canvas id="quizChart" height="220"></canvas>
        <div id="noQuiz" class="text-center text-muted py-3 d-none">No quizzes taken yet</div>
      </div>
    </div>
    <!-- OMR Scores -->
    <div class="col-lg-6">
      <div class="chart-card card">
        <h6 class="fw-semibold mb-3"><i class="bi bi-clipboard2-check me-2 text-danger"></i>OMR Evaluation Scores</h6>
        <canvas id="omrChart" height="220"></canvas>
        <div id="noOmr" class="text-center text-muted py-3 d-none">No OMR results yet</div>
      </div>
    </div>
  </div>
</div>

<script>
async function loadData() {
  const r = await fetch('/slms/progress-dashboard?action=data');
  const d = await r.json();

  document.getElementById('statCourses').textContent = d.enrolledCourses || 0;
  document.getElementById('statAvg').textContent = (d.overallAvg || 0) + '%';
  document.getElementById('statQuizzes').textContent = (d.quizzes || []).length;

  const study7d = (d.studyHours||[]).reduce((a,s)=>a+s.hours,0);
  document.getElementById('statStudy').textContent = study7d.toFixed(1) + 'h';

  // Grades chart
  if (d.grades && d.grades.length > 0) {
    new Chart(document.getElementById('gradesChart'), {
      type: 'bar',
      data: {
        labels: d.grades.map(g=>g.course),
        datasets: [{ label: 'Avg Grade (%)', data: d.grades.map(g=>g.avg.toFixed(1)),
          backgroundColor: 'rgba(99,102,241,.7)', borderRadius: 6 }]
      },
      options: { plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true,max:100}} }
    });
  } else { document.getElementById('noGrades').classList.remove('d-none'); document.getElementById('gradesChart').classList.add('d-none'); }

  // Study hours chart
  if (d.studyHours && d.studyHours.length > 0) {
    new Chart(document.getElementById('studyChart'), {
      type: 'line',
      data: {
        labels: d.studyHours.map(s=>s.date),
        datasets: [{ label: 'Hours', data: d.studyHours.map(s=>s.hours.toFixed(1)),
          borderColor:'#22c55e', backgroundColor:'rgba(34,197,94,.15)', fill:true, tension:.4 }]
      },
      options: { plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true}} }
    });
  } else { document.getElementById('noStudy').classList.remove('d-none'); document.getElementById('studyChart').classList.add('d-none'); }

  // Quiz chart
  if (d.quizzes && d.quizzes.length > 0) {
    new Chart(document.getElementById('quizChart'), {
      type: 'line',
      data: {
        labels: d.quizzes.map((q,i)=>'Quiz '+(i+1)),
        datasets: [{ label: 'Score %', data: d.quizzes.map(q=>Math.round(q.score/q.total*100)),
          borderColor:'#f59e0b', backgroundColor:'rgba(245,158,11,.15)', fill:true, tension:.4 }]
      },
      options: { plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true,max:100}} }
    });
  } else { document.getElementById('noQuiz').classList.remove('d-none'); document.getElementById('quizChart').classList.add('d-none'); }

  // OMR chart
  if (d.omrScores && d.omrScores.length > 0) {
    new Chart(document.getElementById('omrChart'), {
      type: 'bar',
      data: {
        labels: d.omrScores.map(o=>o.title),
        datasets: [{ label: 'Score %', data: d.omrScores.map(o=>Math.round(o.score/o.total*100)),
          backgroundColor: 'rgba(239,68,68,.7)', borderRadius: 6 }]
      },
      options: { plugins:{legend:{display:false}}, scales:{y:{beginAtZero:true,max:100}} }
    });
  } else { document.getElementById('noOmr').classList.remove('d-none'); document.getElementById('omrChart').classList.add('d-none'); }
}
loadData();
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
