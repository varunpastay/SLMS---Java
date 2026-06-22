<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Attendance Management – SLMS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<style>
body{background:#f8fffe}
.hero{background:linear-gradient(135deg,#10b981,#059669);color:#fff;border-radius:16px;padding:28px 32px;margin-bottom:24px}
</style>
</head>
<body>
<%@ include file="/views/base-header.jsp" %>
<div class="container py-4">
  <div class="hero">
    <h2 class="mb-1"><i class="bi bi-calendar-check me-2"></i>Attendance Management</h2>
    <p class="mb-0 opacity-75">Mark and track student attendance for your courses.</p>
  </div>

  <div class="row g-3 mb-4">
    <div class="col-md-5">
      <select id="courseSelect" class="form-select" onchange="loadSummary()">
        <option value="">-- Select Course --</option>
        <c:forEach var="c" items="${courses}"><option value="${c.id}">${c.title}</option></c:forEach>
      </select>
    </div>
    <div class="col-md-3">
      <input type="date" id="dateSelect" class="form-control" value="">
    </div>
    <div class="col-md-4 d-flex gap-2">
      <button class="btn btn-primary" onclick="loadMarkAttendance()"><i class="bi bi-pencil me-1"></i>Mark Attendance</button>
      <button class="btn btn-outline-secondary" onclick="loadSummary()"><i class="bi bi-bar-chart me-1"></i>Summary</button>
    </div>
  </div>

  <!-- Mark Attendance Panel -->
  <div id="markPanel" class="d-none">
    <div class="card border-0 shadow-sm mb-4">
      <div class="card-header bg-white d-flex justify-content-between align-items-center">
        <span class="fw-semibold">Mark Attendance – <span id="markDate"></span></span>
        <div class="d-flex gap-2">
          <button class="btn btn-sm btn-outline-success" onclick="markAll('PRESENT')">All Present</button>
          <button class="btn btn-sm btn-outline-danger" onclick="markAll('ABSENT')">All Absent</button>
          <button class="btn btn-sm btn-primary" onclick="saveAll()"><i class="bi bi-save me-1"></i>Save All</button>
        </div>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table mb-0">
            <thead class="table-light"><tr><th>#</th><th>Student</th><th>Email</th><th>Status</th></tr></thead>
            <tbody id="markTbl"></tbody>
          </table>
        </div>
      </div>
    </div>
  </div>

  <!-- Summary Panel -->
  <div id="summaryPanel" class="d-none">
    <div class="card border-0 shadow-sm">
      <div class="card-header bg-white fw-semibold">Attendance Summary</div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table mb-0">
            <thead class="table-light"><tr><th>Student</th><th>Present</th><th>Absent</th><th>Total</th><th>Attendance %</th></tr></thead>
            <tbody id="summaryTbl"></tbody>
          </table>
        </div>
      </div>
    </div>
  </div>

  <div id="selectHint" class="text-center text-muted py-5">
    <i class="bi bi-person-check fs-1 opacity-25 d-block mb-2"></i>
    Select a course to manage attendance
  </div>
</div>

<script>
let students = [];

function today() { return new Date().toISOString().split('T')[0]; }
document.getElementById('dateSelect').value = today();

async function loadMarkAttendance() {
  const courseId = document.getElementById('courseSelect').value;
  const date = document.getElementById('dateSelect').value;
  if (!courseId) { alert('Select a course'); return; }
  const r = await fetch('/slms/teacher/attendance?action=records&courseId=' + courseId + '&date=' + date);
  students = await r.json();
  document.getElementById('markDate').textContent = date;
  document.getElementById('selectHint').classList.add('d-none');
  document.getElementById('summaryPanel').classList.add('d-none');
  document.getElementById('markPanel').classList.remove('d-none');
  const tbl = document.getElementById('markTbl');
  tbl.innerHTML = students.map(function(s, i) {
    var pChk = s.status === 'PRESENT' ? 'checked' : '';
    var aChk = s.status === 'ABSENT' ? 'checked' : '';
    var lChk = s.status === 'LATE' ? 'checked' : '';
    return '<tr>' +
      '<td>' + (i+1) + '</td>' +
      '<td class="fw-semibold">' + esc(s.name) + '</td>' +
      '<td class="text-muted small">' + esc(s.email || '') + '</td>' +
      '<td><div class="btn-group btn-group-sm" role="group">' +
        '<input type="radio" class="btn-check" name="status_' + s.studentId + '" id="p_' + s.studentId + '" value="PRESENT" ' + pChk + '>' +
        '<label class="btn btn-outline-success" for="p_' + s.studentId + '">Present</label>' +
        '<input type="radio" class="btn-check" name="status_' + s.studentId + '" id="a_' + s.studentId + '" value="ABSENT" ' + aChk + '>' +
        '<label class="btn btn-outline-danger" for="a_' + s.studentId + '">Absent</label>' +
        '<input type="radio" class="btn-check" name="status_' + s.studentId + '" id="l_' + s.studentId + '" value="LATE" ' + lChk + '>' +
        '<label class="btn btn-outline-warning" for="l_' + s.studentId + '">Late</label>' +
      '</div></td></tr>';
  }).join('');
}

function markAll(status) {
  students.forEach(function(s) {
    var prefix = status === 'PRESENT' ? 'p' : status === 'ABSENT' ? 'a' : 'l';
    var el = document.getElementById(prefix + '_' + s.studentId);
    if (el) el.checked = true;
  });
}

async function saveAll() {
  const courseId = document.getElementById('courseSelect').value;
  const date = document.getElementById('dateSelect').value;
  const fd = new FormData();
  fd.append('action', 'bulk-mark');
  fd.append('courseId', courseId);
  fd.append('date', date);
  students.forEach(function(s) {
    var checked = document.querySelector('input[name="status_' + s.studentId + '"]:checked');
    if (checked) { fd.append('studentId', s.studentId); fd.append('status', checked.value); }
  });
  const r = await fetch('/slms/teacher/attendance', { method:'POST', body: fd });
  const data = await r.json();
  if (data.ok) alert('Attendance saved successfully!');
  else alert('Error: ' + data.error);
}

async function loadSummary() {
  const courseId = document.getElementById('courseSelect').value;
  if (!courseId) { alert('Select a course'); return; }
  const r = await fetch('/slms/teacher/attendance?action=summary&courseId=' + courseId);
  const data = await r.json();
  document.getElementById('selectHint').classList.add('d-none');
  document.getElementById('markPanel').classList.add('d-none');
  document.getElementById('summaryPanel').classList.remove('d-none');
  const tbl = document.getElementById('summaryTbl');
  if (!data.length) { tbl.innerHTML = '<tr><td colspan="5" class="text-center text-muted">No students enrolled</td></tr>'; return; }
  tbl.innerHTML = data.map(function(s) {
    var color = s.pct >= 75 ? 'success' : s.pct >= 50 ? 'warning' : 'danger';
    return '<tr>' +
      '<td><div class="fw-semibold">' + esc(s.name) + '</div><small class="text-muted">' + esc(s.email) + '</small></td>' +
      '<td><span class="badge bg-success">' + s.present + '</span></td>' +
      '<td><span class="badge bg-danger">' + s.absent + '</span></td>' +
      '<td>' + s.total + '</td>' +
      '<td><div class="d-flex align-items-center gap-2"><div class="progress flex-grow-1" style="height:8px"><div class="progress-bar bg-' + color + '" style="width:' + s.pct + '%"></div></div><span class="badge bg-' + color + '">' + s.pct + '%</span></div></td>' +
      '</tr>';
  }).join('');
}

function esc(t) { var d = document.createElement('div'); d.textContent = t || ''; return d.innerHTML; }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
