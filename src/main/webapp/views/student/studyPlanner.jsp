<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Study Planner – SLMS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<style>
body{background:#f0f9ff}
.hero{background:linear-gradient(135deg,#0ea5e9,#6366f1);color:#fff;border-radius:16px;padding:28px 32px;margin-bottom:24px}
.stat-card{border:none;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,.07)}
.goal-card{border-left:4px solid #0ea5e9;border-radius:8px;margin-bottom:10px;background:#fff;padding:12px 16px}
.goal-card.completed{border-left-color:#22c55e;opacity:.7}
</style>
</head>
<body>
<%@ include file="/views/base-header.jsp" %>
<div class="container py-4">
  <div class="hero">
    <h2 class="mb-1"><i class="bi bi-calendar-check me-2"></i>Study Planner</h2>
    <p class="mb-0 opacity-75">Set goals, log study sessions, and track your daily progress.</p>
  </div>

  <!-- Stats -->
  <div class="row g-3 mb-4">
    <div class="col-6 col-md-4">
      <div class="card stat-card p-3 text-center">
        <div class="fs-2 fw-bold text-primary" id="weekHours">–</div>
        <div class="text-muted small">Hours This Week</div>
      </div>
    </div>
    <div class="col-6 col-md-4">
      <div class="card stat-card p-3 text-center">
        <div class="fs-2 fw-bold text-success" id="totalHours">–</div>
        <div class="text-muted small">Total Hours</div>
      </div>
    </div>
    <div class="col-6 col-md-4">
      <div class="card stat-card p-3 text-center">
        <div class="fs-2 fw-bold text-warning" id="goalsComp">${goalsCompleted}</div>
        <div class="text-muted small">Goals Completed</div>
      </div>
    </div>
  </div>

  <div class="row g-4">
    <!-- Add Goal & Log Session -->
    <div class="col-lg-4">
      <div class="card border-0 shadow-sm mb-3">
        <div class="card-header bg-white fw-semibold"><i class="bi bi-flag-fill text-primary me-2"></i>Add Study Goal</div>
        <div class="card-body">
          <div class="mb-2"><input id="gTitle" type="text" class="form-control" placeholder="Goal title (e.g. Finish Chapter 5)"></div>
          <div class="mb-2"><input id="gSubject" type="text" class="form-control" placeholder="Subject (e.g. Math, Physics)"></div>
          <div class="mb-2"><input id="gDate" type="date" class="form-control"></div>
          <div class="mb-3 input-group">
            <input id="gMins" type="number" class="form-control" value="60" min="15" max="720" step="15">
            <span class="input-group-text">min/day</span>
          </div>
          <button class="btn btn-primary w-100" onclick="addGoal()"><i class="bi bi-plus me-1"></i>Add Goal</button>
        </div>
      </div>

      <div class="card border-0 shadow-sm">
        <div class="card-header bg-white fw-semibold"><i class="bi bi-stopwatch text-success me-2"></i>Log Study Session</div>
        <div class="card-body">
          <div class="mb-2"><input id="sSubject" type="text" class="form-control" placeholder="Subject (optional)"></div>
          <div class="mb-2 input-group">
            <input id="sMins" type="number" class="form-control" value="60" min="5" max="600" step="5">
            <span class="input-group-text">minutes</span>
          </div>
          <div class="mb-3"><textarea id="sNotes" class="form-control" rows="2" placeholder="What did you study? (optional)"></textarea></div>
          <button class="btn btn-success w-100" onclick="logSession()"><i class="bi bi-check-circle me-1"></i>Log Session</button>
        </div>
      </div>
    </div>

    <!-- Goals & Sessions -->
    <div class="col-lg-8">
      <ul class="nav nav-pills mb-3" id="plannerTabs">
        <li class="nav-item"><button class="nav-link active" onclick="showTab('goals')">Goals</button></li>
        <li class="nav-item"><button class="nav-link" onclick="showTab('sessions')">Recent Sessions</button></li>
      </ul>

      <div id="tab-goals">
        <div id="goalsList"><div class="text-center text-muted py-4">Loading goals...</div></div>
      </div>
      <div id="tab-sessions" class="d-none">
        <div class="table-responsive">
          <table class="table table-hover">
            <thead class="table-light"><tr><th>Date</th><th>Subject</th><th>Duration</th><th>Notes</th></tr></thead>
            <tbody id="sessionsTbl"><tr><td colspan="4" class="text-center text-muted">Loading...</td></tr></tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
function showTab(t) {
  ['goals','sessions'].forEach(function(x) {
    document.getElementById('tab-'+x).classList.toggle('d-none', x !== t);
  });
  document.querySelectorAll('#plannerTabs .nav-link').forEach(function(b, i) {
    b.classList.toggle('active', ['goals','sessions'][i] === t);
  });
  if (t === 'sessions') loadSessions();
}

async function loadGoals() {
  const r = await fetch('/slms/study-planner?action=goals');
  const goals = await r.json();
  const list = document.getElementById('goalsList');
  if (!goals.length) {
    list.innerHTML = '<div class="text-center text-muted py-4"><i class="bi bi-flag fs-1 opacity-25 d-block mb-2"></i>No goals yet. Add one!</div>';
    return;
  }
  list.innerHTML = goals.map(function(g) {
    var done = g.status === 'COMPLETED';
    return '<div class="goal-card ' + (done ? 'completed' : '') + '">' +
      '<div class="d-flex justify-content-between align-items-start">' +
        '<div>' +
          '<div class="fw-semibold">' + esc(g.title) + (done ? ' <span class="badge bg-success ms-1">Done</span>' : '') + '</div>' +
          '<small class="text-muted">' +
            (g.subject ? '<i class="bi bi-book me-1"></i>' + esc(g.subject) : 'General') +
            (g.targetDate ? ' &middot; <i class="bi bi-calendar me-1"></i>' + g.targetDate : '') +
            ' &middot; ' + Math.floor(g.dailyMins/60) + 'h ' + (g.dailyMins%60 > 0 ? (g.dailyMins%60) + 'm' : '') + '/day' +
          '</small>' +
        '</div>' +
        '<div class="d-flex gap-1">' +
          (!done ? '<button class="btn btn-outline-success btn-sm" onclick="completeGoal(' + g.id + ')"><i class="bi bi-check"></i></button>' : '') +
          '<button class="btn btn-outline-danger btn-sm" onclick="deleteGoal(' + g.id + ')"><i class="bi bi-trash"></i></button>' +
        '</div>' +
      '</div></div>';
  }).join('');
}

async function loadSessions() {
  const r = await fetch('/slms/study-planner?action=sessions');
  const sessions = await r.json();
  const tbl = document.getElementById('sessionsTbl');
  if (!sessions.length) { tbl.innerHTML = '<tr><td colspan="4" class="text-center text-muted">No sessions logged yet</td></tr>'; return; }
  tbl.innerHTML = sessions.map(function(s) {
    return '<tr><td>' + s.date + '</td><td>' + esc(s.subject) + '</td>' +
      '<td><span class="badge bg-primary">' + Math.floor(s.duration/60) + 'h ' + (s.duration%60) + 'm</span></td>' +
      '<td class="text-muted small">' + (esc(s.notes) || '—') + '</td></tr>';
  }).join('');
}

async function loadStats() {
  const r = await fetch('/slms/study-planner?action=sessions');
  const sessions = await r.json();
  const total = sessions.reduce(function(a, s) { return a + s.duration; }, 0);
  const weekAgo = new Date(); weekAgo.setDate(weekAgo.getDate() - 7);
  const week = sessions.filter(function(s) { return new Date(s.date) >= weekAgo; }).reduce(function(a, s) { return a + s.duration; }, 0);
  document.getElementById('weekHours').textContent = (week / 60).toFixed(1);
  document.getElementById('totalHours').textContent = (total / 60).toFixed(1);
}

function esc(t) { var d = document.createElement('div'); d.textContent = t || ''; return d.innerHTML; }

async function addGoal() {
  const title = document.getElementById('gTitle').value.trim();
  if (!title) { alert('Goal title required'); return; }
  const fd = new FormData();
  fd.append('action', 'add-goal'); fd.append('title', title);
  fd.append('subject', document.getElementById('gSubject').value);
  fd.append('targetDate', document.getElementById('gDate').value);
  fd.append('dailyMins', document.getElementById('gMins').value);
  await fetch('/slms/study-planner', { method:'POST', body: fd });
  document.getElementById('gTitle').value = ''; document.getElementById('gSubject').value = '';
  await loadGoals();
}

async function completeGoal(id) {
  const fd = new FormData(); fd.append('action', 'complete-goal'); fd.append('id', id);
  await fetch('/slms/study-planner', { method:'POST', body: fd }); await loadGoals();
}

async function deleteGoal(id) {
  if (!confirm('Delete goal?')) return;
  const fd = new FormData(); fd.append('action', 'delete-goal'); fd.append('id', id);
  await fetch('/slms/study-planner', { method:'POST', body: fd }); await loadGoals();
}

async function logSession() {
  const mins = parseInt(document.getElementById('sMins').value);
  if (!mins || mins < 1) { alert('Enter valid minutes'); return; }
  const fd = new FormData(); fd.append('action', 'log-session');
  fd.append('subject', document.getElementById('sSubject').value);
  fd.append('minutes', mins); fd.append('notes', document.getElementById('sNotes').value);
  await fetch('/slms/study-planner', { method:'POST', body: fd });
  document.getElementById('sNotes').value = ''; await loadStats();
  alert('Session logged! Keep it up!');
}

loadGoals(); loadStats();
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
