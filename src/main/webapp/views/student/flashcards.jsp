<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Flashcards – SLMS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<style>
body{background:#f8f9ff}
.hero{background:linear-gradient(135deg,#f59e0b,#ef4444);color:#fff;border-radius:16px;padding:28px 32px;margin-bottom:24px}
.flashcard{width:100%;height:220px;perspective:1000px;cursor:pointer}
.fc-inner{width:100%;height:100%;position:relative;transform-style:preserve-3d;transition:transform .5s}
.flashcard.flipped .fc-inner{transform:rotateY(180deg)}
.fc-front,.fc-back{position:absolute;width:100%;height:100%;backface-visibility:hidden;border-radius:16px;display:flex;align-items:center;justify-content:center;padding:20px;text-align:center;font-size:1.05rem}
.fc-front{background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;font-weight:600;font-size:1.1rem}
.fc-back{background:#fff;border:2px solid #667eea;color:#1e293b;transform:rotateY(180deg)}
.fc-label{font-size:.7rem;text-transform:uppercase;letter-spacing:1px;position:absolute;top:12px;left:16px;opacity:.7}
.progress-ring{width:48px;height:48px}
</style>
</head>
<body>
<%@ include file="/views/base-header.jsp" %>
<div class="container py-4">
  <div class="hero">
    <h2 class="mb-1"><i class="bi bi-stack me-2"></i>Flashcard Generator</h2>
    <p class="mb-0 opacity-75">Generate AI flashcards from any topic or add your own to study smarter.</p>
  </div>

  <div class="row g-4">
    <!-- Generate panel -->
    <div class="col-lg-4">
      <div class="card shadow-sm border-0 mb-3">
        <div class="card-header bg-white fw-semibold"><i class="bi bi-magic text-warning me-2"></i>Generate with AI</div>
        <div class="card-body">
          <div class="mb-3">
            <label class="form-label">Topic / Subject</label>
            <input type="text" id="topicInput" class="form-control" placeholder="e.g. Photosynthesis, Newton's Laws">
          </div>
          <div class="mb-3">
            <label class="form-label">Course (optional)</label>
            <select id="courseSelect" class="form-select">
              <option value="">-- None --</option>
              <c:forEach var="c" items="${courses}"><option value="${c.id}">${c.title}</option></c:forEach>
            </select>
          </div>
          <button class="btn btn-warning w-100 fw-semibold" onclick="generate()" id="genBtn">
            <i class="bi bi-stars me-1"></i> Generate 8 Cards
          </button>
        </div>
      </div>

      <div class="card shadow-sm border-0">
        <div class="card-header bg-white fw-semibold"><i class="bi bi-plus-circle text-success me-2"></i>Add Manual Card</div>
        <div class="card-body">
          <div class="mb-2"><textarea id="manFront" class="form-control" rows="2" placeholder="Front (Question/Term)"></textarea></div>
          <div class="mb-2"><textarea id="manBack" class="form-control" rows="2" placeholder="Back (Answer/Definition)"></textarea></div>
          <button class="btn btn-success w-100" onclick="addManual()"><i class="bi bi-plus me-1"></i>Add Card</button>
        </div>
      </div>
    </div>

    <!-- Cards display -->
    <div class="col-lg-8">
      <!-- Study mode -->
      <div id="studyMode" class="d-none mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
          <h5 class="mb-0">Study Mode <span id="studyProgress" class="badge bg-secondary"></span></h5>
          <div class="d-flex gap-2">
            <button class="btn btn-outline-secondary btn-sm" onclick="prevCard()"><i class="bi bi-chevron-left"></i></button>
            <button class="btn btn-outline-secondary btn-sm" onclick="nextCard()"><i class="bi bi-chevron-right"></i></button>
            <button class="btn btn-outline-danger btn-sm" onclick="exitStudy()"><i class="bi bi-x"></i> Exit</button>
          </div>
        </div>
        <div class="flashcard" id="studyCard" onclick="flipCard()">
          <div class="fc-inner">
            <div class="fc-front"><span class="fc-label">Question</span><span id="sfrontText"></span></div>
            <div class="fc-back"><span class="fc-label">Answer</span><span id="sbackText"></span></div>
          </div>
        </div>
        <p class="text-center text-muted mt-2 small">Click card to flip • Use arrows to navigate</p>
      </div>

      <!-- Cards grid -->
      <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="mb-0">My Flashcards <span id="countBadge" class="badge bg-primary">0</span></h5>
        <button class="btn btn-outline-primary btn-sm" onclick="startStudy()" id="studyBtn" disabled>
          <i class="bi bi-play-fill me-1"></i>Study All
        </button>
      </div>
      <div id="cardsGrid" class="row g-3">
        <div class="col-12 text-center text-muted py-5">
          <i class="bi bi-stack fs-1 opacity-25 d-block mb-2"></i>
          Generate cards or add manual ones to get started
        </div>
      </div>
    </div>
  </div>
</div>

<script>
let allCards = [];
let studyIdx = 0;

async function loadCards() {
  const r = await fetch('/slms/flashcards?action=list');
  allCards = await r.json();
  renderGrid();
}

function renderGrid() {
  const grid = document.getElementById('cardsGrid');
  document.getElementById('countBadge').textContent = allCards.length;
  document.getElementById('studyBtn').disabled = allCards.length === 0;
  if (allCards.length === 0) {
    grid.innerHTML = '<div class="col-12 text-center text-muted py-5"><i class="bi bi-stack fs-1 opacity-25 d-block mb-2"></i>No flashcards yet. Generate some!</div>';
    return;
  }
  grid.innerHTML = allCards.map(function(c, i) {
    return '<div class="col-md-6">' +
      '<div class="flashcard" onclick="flipCardEl(this)">' +
        '<div class="fc-inner">' +
          '<div class="fc-front"><span class="fc-label">Q</span><span>' + esc(c.front) + '</span></div>' +
          '<div class="fc-back"><span class="fc-label">A</span><span>' + esc(c.back) + '</span></div>' +
        '</div>' +
      '</div>' +
      '<div class="d-flex justify-content-between align-items-center mt-1 px-1">' +
        '<small class="text-muted">' + (c.courseTitle ? '<i class="bi bi-book me-1"></i>' + esc(c.courseTitle) : '') + '</small>' +
        '<button class="btn btn-link text-danger btn-sm p-0" onclick="delCard(' + c.id + ')"><i class="bi bi-trash"></i></button>' +
      '</div>' +
    '</div>';
  }).join('');
}

function flipCardEl(el) { el.classList.toggle('flipped'); }

function esc(t) { const d=document.createElement('div'); d.textContent=t||''; return d.innerHTML; }

async function generate() {
  const topic = document.getElementById('topicInput').value.trim();
  if (!topic) { alert('Please enter a topic'); return; }
  const btn = document.getElementById('genBtn');
  btn.disabled = true; btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Generating...';
  try {
    const fd = new FormData();
    fd.append('action', 'generate'); fd.append('topic', topic);
    fd.append('courseId', document.getElementById('courseSelect').value);
    const r = await fetch('/slms/flashcards', { method:'POST', body: fd });
    const data = await r.json();
    if (data.error) throw new Error(data.error);
    await loadCards();
    document.getElementById('topicInput').value = '';
  } catch(e) { alert('Error: ' + e.message); }
  btn.disabled = false; btn.innerHTML = '<i class="bi bi-stars me-1"></i> Generate 8 Cards';
}

async function addManual() {
  const front = document.getElementById('manFront').value.trim();
  const back = document.getElementById('manBack').value.trim();
  if (!front || !back) { alert('Both front and back are required'); return; }
  const fd = new FormData(); fd.append('action','add'); fd.append('front',front); fd.append('back',back);
  fd.append('courseId', document.getElementById('courseSelect').value);
  await fetch('/slms/flashcards', { method:'POST', body: fd });
  document.getElementById('manFront').value = ''; document.getElementById('manBack').value = '';
  await loadCards();
}

async function delCard(id) {
  if (!confirm('Delete this flashcard?')) return;
  await fetch('/slms/flashcards?action=delete&id=' + id);
  await loadCards();
}

function startStudy() {
  if (allCards.length === 0) return;
  studyIdx = 0; document.getElementById('studyMode').classList.remove('d-none');
  showStudyCard();
}

function exitStudy() { document.getElementById('studyMode').classList.add('d-none'); }

function showStudyCard() {
  const c = allCards[studyIdx];
  document.getElementById('sfrontText').textContent = c.front;
  document.getElementById('sbackText').textContent = c.back;
  document.getElementById('studyCard').classList.remove('flipped');
  document.getElementById('studyProgress').textContent = (studyIdx+1) + '/' + allCards.length;
}

function flipCard() { document.getElementById('studyCard').classList.toggle('flipped'); }
function nextCard() { studyIdx = (studyIdx+1) % allCards.length; showStudyCard(); }
function prevCard() { studyIdx = (studyIdx-1+allCards.length) % allCards.length; showStudyCard(); }

document.addEventListener('keydown', e => {
  const sm = document.getElementById('studyMode');
  if (sm.classList.contains('d-none')) return;
  if (e.key==='ArrowRight') nextCard();
  else if (e.key==='ArrowLeft') prevCard();
  else if (e.key===' ') { e.preventDefault(); flipCard(); }
});

loadCards();
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
