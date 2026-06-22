<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="NoteWise – AI Learning"/>
<%@ include file="/views/base-header.jsp" %>

<style>
/* ── NoteWise custom styles ─────────────────────────────────────── */
.nw-hero{background:linear-gradient(135deg,#6366f1 0%,#8b5cf6 50%,#a855f7 100%);
  color:#fff;padding:2rem 1.5rem 1.5rem;border-radius:1rem;margin-bottom:1.5rem;position:relative;overflow:hidden}
.nw-hero::after{content:'';position:absolute;right:-40px;top:-40px;width:200px;height:200px;
  background:rgba(255,255,255,.08);border-radius:50%}
.nw-hero h1{font-size:1.9rem;font-weight:800;margin:0}
.nw-hero p{opacity:.85;margin:0}
.nw-clara-chip{display:inline-flex;align-items:center;gap:.5rem;background:rgba(255,255,255,.15);
  backdrop-filter:blur(8px);border-radius:2rem;padding:.35rem .9rem .35rem .35rem;font-size:.85rem;margin-bottom:.75rem}
.nw-clara-chip .avatar-c{width:32px;height:32px;border-radius:50%;
  background:linear-gradient(135deg,#f59e0b,#ef4444);display:flex;align-items:center;
  justify-content:center;font-size:1rem}

.nw-drop-zone{border:2px dashed #6366f1;border-radius:1rem;padding:3rem 2rem;text-align:center;
  cursor:pointer;transition:.2s;background:var(--surface-3)}
.nw-drop-zone:hover,.nw-drop-zone.drag-over{background:rgba(99,102,241,.08);border-color:#4f46e5}
.nw-drop-zone i{font-size:3rem;color:#6366f1;display:block;margin-bottom:.75rem}

.concept-chip{display:inline-flex;align-items:center;gap:.4rem;background:rgba(99,102,241,.12);
  color:#6366f1;border:1px solid rgba(99,102,241,.25);border-radius:2rem;
  padding:.3rem .8rem;font-size:.8rem;font-weight:500;margin:.2rem}

.diff-badge{padding:.3rem .75rem;border-radius:2rem;font-size:.78rem;font-weight:600}
.diff-Beginner{background:#dcfce7;color:#16a34a}
.diff-Intermediate{background:#fef3c7;color:#d97706}
.diff-Advanced{background:#fee2e2;color:#dc2626}

.clara-bubble{background:linear-gradient(135deg,rgba(99,102,241,.08),rgba(139,92,246,.08));
  border-left:4px solid #6366f1;border-radius:.5rem 1rem 1rem .5rem;padding:1.25rem 1.5rem;
  font-size:.95rem;line-height:1.7;white-space:pre-wrap}
.clara-avatar-sm{width:40px;height:40px;border-radius:50%;flex-shrink:0;
  background:linear-gradient(135deg,#6366f1,#a855f7);
  display:flex;align-items:center;justify-content:center;font-size:1.2rem;color:#fff}

.tts-bar{display:flex;align-items:center;gap:.75rem;padding:.75rem 1rem;
  background:var(--surface-3);border-radius:.75rem;flex-wrap:wrap}
.tts-bar button{border:none;background:none;padding:.4rem;border-radius:.5rem;cursor:pointer;
  font-size:1.1rem;transition:.15s;color:var(--text-muted)}
.tts-bar button:hover{background:rgba(99,102,241,.12);color:#6366f1}
.tts-bar button.active{color:#6366f1}
.tts-subtitle{font-size:.85rem;color:var(--text-muted);margin-top:.75rem;min-height:2.5rem;
  line-height:1.5;padding:.5rem .75rem;background:var(--surface-3);border-radius:.5rem}
.tts-subtitle .hl{background:rgba(99,102,241,.2);border-radius:.25rem;padding:.05rem .2rem}

.quiz-option{display:flex;align-items:flex-start;gap:.75rem;padding:.75rem 1rem;border-radius:.75rem;
  border:2px solid transparent;cursor:pointer;transition:.15s;background:var(--surface-3);margin:.4rem 0}
.quiz-option:hover{border-color:#6366f1;background:rgba(99,102,241,.05)}
.quiz-option.selected{border-color:#6366f1;background:rgba(99,102,241,.08)}
.quiz-option.correct{border-color:#16a34a;background:#dcfce7}
.quiz-option.wrong{border-color:#dc2626;background:#fee2e2}
.quiz-option .opt-letter{width:28px;height:28px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-weight:700;font-size:.8rem;flex-shrink:0;
  background:rgba(99,102,241,.15);color:#6366f1}
.quiz-option.correct .opt-letter{background:#16a34a;color:#fff}
.quiz-option.wrong .opt-letter{background:#dc2626;color:#fff}

.q-card{background:var(--surface);border-radius:.75rem;padding:1.25rem;margin-bottom:1.25rem;
  border:1px solid var(--border)}
.q-num{font-size:.75rem;color:var(--text-muted);font-weight:600;text-transform:uppercase;margin-bottom:.4rem}
.q-text{font-weight:600;margin-bottom:.75rem}

.score-ring{position:relative;display:inline-flex;align-items:center;justify-content:center}
.score-ring svg{transform:rotate(-90deg)}
.score-ring .score-text{position:absolute;text-align:center}
.score-ring .score-pct{font-size:1.6rem;font-weight:800;line-height:1}
.score-ring .score-label{font-size:.7rem;color:var(--text-muted)}

.chat-messages{max-height:320px;overflow-y:auto;padding:.75rem;display:flex;flex-direction:column;gap:.75rem}
.chat-msg{max-width:85%;padding:.75rem 1rem;border-radius:1rem;font-size:.9rem;line-height:1.5}
.chat-msg.student{background:linear-gradient(135deg,#6366f1,#8b5cf6);color:#fff;
  border-bottom-right-radius:.25rem;align-self:flex-end}
.chat-msg.clara{background:var(--surface-3);border-bottom-left-radius:.25rem;align-self:flex-start}

.xp-level{padding:.5rem 1rem;border-radius:2rem;font-weight:700;font-size:.85rem}
.level-beginner{background:#e0e7ff;color:#4f46e5}
.level-explorer{background:#fef3c7;color:#d97706}
.level-master{background:#dcfce7;color:#16a34a}
.level-scholar{background:linear-gradient(135deg,#6366f1,#a855f7);color:#fff}

.nw-hist-item{padding:.6rem .75rem;border-radius:.5rem;cursor:pointer;transition:.15s;
  border:1px solid transparent}
.nw-hist-item:hover{background:rgba(99,102,241,.08);border-color:rgba(99,102,241,.2)}
.nw-hist-item .hist-topic{font-weight:600;font-size:.85rem;
  white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.nw-hist-item .hist-meta{font-size:.75rem;color:var(--text-muted)}

.nw-loading-overlay{position:fixed;inset:0;background:rgba(0,0,0,.45);backdrop-filter:blur(4px);
  z-index:9999;display:flex;align-items:center;justify-content:center;flex-direction:column;gap:1rem}
.nw-loading-overlay .nw-spinner{width:56px;height:56px;border:4px solid rgba(255,255,255,.2);
  border-top-color:#fff;border-radius:50%;animation:spin .8s linear infinite}
@keyframes spin{to{transform:rotate(360deg)}}
.nw-loading-overlay p{color:#fff;font-size:1rem;font-weight:500}
</style>

<div style="min-height:calc(100vh - 64px);background:var(--surface-2);padding:2rem 1.5rem">

<!-- Loading overlay -->
<div id="nwLoading" class="nw-loading-overlay" style="display:none">
  <div class="nw-spinner"></div>
  <p id="nwLoadingMsg">Ms. Clara is reading your notes…</p>
</div>

<!-- Hero -->
<div class="nw-hero mb-4">
  <div class="nw-clara-chip">
    <span class="avatar-c">👩‍🏫</span>
    <span>Ms. Clara – Your AI Teacher</span>
  </div>
  <h1><i class="bi bi-stars me-2"></i>NoteWise</h1>
  <p>Upload your handwritten notes and get a personalized AI lesson, voice explanation, and quiz.</p>
</div>

<div class="row g-4">

  <!-- ── Main content column ──────────────────────────────────────────────── -->
  <div class="col-lg-8">

    <!-- Upload card -->
    <div id="uploadCard" class="card shadow-sm mb-4">
      <div class="card-header">
        <span class="section-title mb-0"><i class="bi bi-cloud-upload me-2"></i>Upload Your Notes</span>
      </div>
      <div class="card-body">
        <div id="dropZone" class="nw-drop-zone" onclick="document.getElementById('noteInput').click()">
          <i class="bi bi-file-earmark-image"></i>
          <h5 class="mb-1">Drag &amp; drop your note image here</h5>
          <p class="text-muted mb-3">Supports JPG, PNG, JPEG · Max 10MB</p>
          <button class="btn btn-primary" type="button"
                  onclick="event.stopPropagation();document.getElementById('noteInput').click()">
            <i class="bi bi-folder2-open me-2"></i>Browse Files
          </button>
          <input type="file" id="noteInput" accept="image/*" style="display:none">
        </div>
        <div id="previewArea" style="display:none" class="mt-3">
          <div class="d-flex align-items-start gap-3">
            <img id="previewImg" style="max-height:220px;border-radius:.75rem;object-fit:contain;border:1px solid var(--border)" alt="preview"/>
            <div class="flex-grow-1">
              <div class="fw-semibold mb-1" id="previewFileName"></div>
              <div class="text-muted small mb-3" id="previewFileSize"></div>
              <button class="btn btn-primary" id="analyzeBtn" onclick="analyzeNotes()">
                <i class="bi bi-magic me-2"></i>Analyze with Ms. Clara
              </button>
              <button class="btn btn-outline-secondary ms-2" onclick="resetUpload()">
                <i class="bi bi-arrow-counterclockwise me-1"></i>Change
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Analysis card -->
    <div id="analysisCard" class="card shadow-sm mb-4" style="display:none">
      <div class="card-header d-flex justify-content-between align-items-center">
        <span class="section-title mb-0"><i class="bi bi-diagram-3 me-2"></i>Note Analysis</span>
        <span id="diffBadge" class="diff-badge"></span>
      </div>
      <div class="card-body">
        <div class="row g-3 mb-3">
          <div class="col-sm-6">
            <div class="p-3 rounded-xl" style="background:var(--surface-3)">
              <div class="text-muted small mb-1">Topic</div>
              <div class="fw-bold fs-5" id="anTopic">—</div>
            </div>
          </div>
          <div class="col-sm-3">
            <div class="p-3 rounded-xl" style="background:var(--surface-3)">
              <div class="text-muted small mb-1">Study Time</div>
              <div class="fw-bold fs-5"><span id="anTime">—</span> min</div>
            </div>
          </div>
          <div class="col-sm-3">
            <div class="p-3 rounded-xl" style="background:var(--surface-3)">
              <div class="text-muted small mb-1">XP Earned</div>
              <div class="fw-bold fs-5 text-warning">+<span id="anXp">50</span> ⭐</div>
            </div>
          </div>
        </div>
        <div class="mb-3">
          <div class="text-muted small mb-2 fw-semibold">Key Concepts</div>
          <div id="anConcepts"></div>
        </div>
        <div>
          <div class="text-muted small mb-2 fw-semibold">Summary</div>
          <p id="anSummary" class="mb-0" style="color:var(--text-secondary)"></p>
        </div>
      </div>
    </div>

    <!-- Explanation card (Ms. Clara) -->
    <div id="explanationCard" class="card shadow-sm mb-4" style="display:none">
      <div class="card-header">
        <span class="section-title mb-0"><i class="bi bi-person-video3 me-2"></i>Ms. Clara Explains</span>
      </div>
      <div class="card-body">
        <div class="d-flex gap-3 mb-3">
          <div class="clara-avatar-sm">👩‍🏫</div>
          <div class="flex-grow-1">
            <div class="fw-semibold mb-1">Ms. Clara</div>
            <div class="text-muted small">AI Teacher · Always patient &amp; encouraging</div>
          </div>
        </div>

        <!-- TTS Controls -->
        <div class="tts-bar mb-3">
          <button id="ttsPlay"  title="Play"  onclick="ttsPlayPause()"><i class="bi bi-play-fill"></i></button>
          <button id="ttsPause" title="Pause" onclick="ttsPlayPause()" style="display:none"><i class="bi bi-pause-fill"></i></button>
          <button title="Stop"  onclick="ttsStop()"><i class="bi bi-stop-fill"></i></button>
          <div class="vr"></div>
          <button title="Slower" onclick="adjustRate(-0.1)"><i class="bi bi-skip-backward"></i></button>
          <span id="rateLabel" style="font-size:.8rem;min-width:3ch">1.0×</span>
          <button title="Faster" onclick="adjustRate(0.1)"><i class="bi bi-skip-forward"></i></button>
          <div class="vr"></div>
          <button id="ttsMute" title="Mute" onclick="toggleMute()"><i class="bi bi-volume-up-fill"></i></button>
          <span class="ms-auto text-muted small" id="ttsBrowserNote"></span>
        </div>

        <div class="clara-bubble" id="explanationText"></div>
        <div class="tts-subtitle mt-2" id="ttsSubtitle">
          <span class="text-muted fst-italic">Press ▶ to hear Ms. Clara speak…</span>
        </div>
      </div>
    </div>

    <!-- Quiz card -->
    <div id="quizCard" class="card shadow-sm mb-4" style="display:none">
      <div class="card-header d-flex justify-content-between align-items-center">
        <span class="section-title mb-0"><i class="bi bi-patch-question me-2"></i>Knowledge Quiz</span>
        <button class="btn btn-sm btn-primary" id="genQuizBtn" onclick="generateQuiz()">
          <i class="bi bi-magic me-1"></i>Generate Quiz
        </button>
      </div>
      <div class="card-body" id="quizBody">
        <div class="text-center py-4 text-muted">
          <i class="bi bi-patch-question" style="font-size:2.5rem;opacity:.3;display:block;margin-bottom:.5rem"></i>
          Click <strong>Generate Quiz</strong> to test your understanding.
        </div>
      </div>
    </div>

    <!-- Chat / Doubt solver card -->
    <div id="chatCard" class="card shadow-sm mb-4" style="display:none">
      <div class="card-header">
        <span class="section-title mb-0"><i class="bi bi-chat-heart me-2"></i>Ask Ms. Clara</span>
      </div>
      <div class="card-body p-0">
        <div class="chat-messages" id="chatMessages">
          <div class="chat-msg clara">
            Hi! I'm Ms. Clara 👋 I've read your notes. Ask me anything about the topic and I'll explain it clearly!
          </div>
        </div>
        <div class="p-3 border-top d-flex gap-2">
          <input type="text" id="chatInput" class="form-control"
                 placeholder="e.g. What is the difference between run() and start()?"
                 onkeydown="if(event.key==='Enter') sendChat()">
          <button class="btn btn-primary" onclick="sendChat()">
            <i class="bi bi-send-fill"></i>
          </button>
        </div>
      </div>
    </div>

  </div><!-- /col-lg-8 -->

  <!-- ── Sidebar ──────────────────────────────────────────────────────────── -->
  <div class="col-lg-4 d-flex flex-column gap-4">

    <!-- XP & Progress -->
    <div class="card shadow-sm">
      <div class="card-header">
        <span class="section-title mb-0"><i class="bi bi-stars me-2"></i>Your Progress</span>
      </div>
      <div class="card-body text-center">
        <div class="score-ring mb-3">
          <svg width="100" height="100" viewBox="0 0 100 100">
            <circle cx="50" cy="50" r="42" fill="none" stroke="var(--surface-3)" stroke-width="8"/>
            <circle id="xpArc" cx="50" cy="50" r="42" fill="none"
                    stroke="#6366f1" stroke-width="8"
                    stroke-dasharray="264" stroke-dashoffset="264"
                    stroke-linecap="round"/>
          </svg>
          <div class="score-text">
            <div class="score-pct" id="xpDisplay">${totalXp}</div>
            <div class="score-label">XP</div>
          </div>
        </div>
        <div class="xp-level mb-3" id="levelBadge">—</div>
        <div class="d-flex justify-content-around text-center">
          <div>
            <div class="fw-bold fs-5" id="streakDisplay">${streak}</div>
            <div class="text-muted small">🔥 Streak</div>
          </div>
          <div>
            <div class="fw-bold fs-5" id="conceptsLearned">0</div>
            <div class="text-muted small">Concepts</div>
          </div>
          <div>
            <div class="fw-bold fs-5" id="quizScore">—</div>
            <div class="text-muted small">Quiz Score</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Session history -->
    <div class="card shadow-sm flex-grow-1">
      <div class="card-header">
        <span class="section-title mb-0"><i class="bi bi-clock-history me-2"></i>Note History</span>
      </div>
      <div class="card-body p-2" id="historyList">
        <div class="text-center py-4 text-muted small">
          <i class="bi bi-journal-x" style="font-size:2rem;opacity:.3;display:block;margin-bottom:.5rem"></i>
          No sessions yet
        </div>
      </div>
    </div>

  </div>
</div><!-- /row -->
</div><!-- /page content -->

<footer class="py-3 border-top text-center text-muted" style="font-size:.8rem;background:var(--surface)">
  &copy; 2025 <strong>SLMS</strong> &mdash; NoteWise powered by Google Gemini
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/static/js/slms.js"></script>
<script>
// ── State ──────────────────────────────────────────────────────────────────
const ctx       = '${pageContext.request.contextPath}';
let currentFile = null;
let session     = null;   // current loaded session data
let currentQuiz = null;   // {quizId, questions}
let ttsRate     = 1.0;
let ttsMuted    = false;
let ttsUtterance = null;
let isSpeaking  = false;
let isPaused    = false;
let totalXp     = ${totalXp};
let streak      = ${streak};

// ── Boot ───────────────────────────────────────────────────────────────────
(function init() {
  updateXpRing(totalXp);
  updateLevelBadge(totalXp);

  // Load history
  try {
    const hist = JSON.parse('${nwSessions}'.replace(/&quot;/g,'\"').replace(/&#39;/g,"'"));
    renderHistory(hist);
  } catch(e) {}

  // Check TTS support
  if (!('speechSynthesis' in window)) {
    document.getElementById('ttsBrowserNote').textContent = 'TTS not supported in this browser';
  }

  // Drag-and-drop
  const dz = document.getElementById('dropZone');
  dz.addEventListener('dragover',  e => { e.preventDefault(); dz.classList.add('drag-over'); });
  dz.addEventListener('dragleave', () => dz.classList.remove('drag-over'));
  dz.addEventListener('drop', e => {
    e.preventDefault(); dz.classList.remove('drag-over');
    const f = e.dataTransfer.files[0];
    if (f) handleFile(f);
  });

  document.getElementById('noteInput').addEventListener('change', e => {
    if (e.target.files[0]) handleFile(e.target.files[0]);
  });
})();

// ── File handling ──────────────────────────────────────────────────────────
function handleFile(file) {
  if (!file.type.startsWith('image/')) {
    showToast('Please upload an image file (JPG, PNG, JPEG)', 'warning'); return;
  }
  currentFile = file;
  const reader = new FileReader();
  reader.onload = e => {
    document.getElementById('previewImg').src = e.target.result;
    document.getElementById('previewFileName').textContent = file.name;
    document.getElementById('previewFileSize').textContent = (file.size / 1024).toFixed(0) + ' KB';
    document.getElementById('dropZone').style.display   = 'none';
    document.getElementById('previewArea').style.display = '';
  };
  reader.readAsDataURL(file);
}

function resetUpload() {
  currentFile = null;
  document.getElementById('noteInput').value = '';
  document.getElementById('dropZone').style.display   = '';
  document.getElementById('previewArea').style.display = 'none';
}

// ── Analyze ────────────────────────────────────────────────────────────────
async function analyzeNotes() {
  if (!currentFile) return;
  showLoading('Ms. Clara is reading your notes…');

  const fd = new FormData();
  fd.append('action', 'analyze');
  fd.append('noteImage', currentFile);

  try {
    const res  = await fetch(ctx + '/notewise', { method: 'POST', body: fd });
    const data = await res.json();
    hideLoading();

    if (data.error) { showToast('Error: ' + data.error, 'danger'); return; }

    session = data;
    renderAnalysis(data);
    renderExplanation(data.explanation);
    showCards(['analysisCard','explanationCard','quizCard','chatCard']);
    totalXp += data.xpEarned || 50;
    updateXpRing(totalXp);
    updateLevelBadge(totalXp);
    document.getElementById('xpDisplay').textContent = totalXp;
    document.getElementById('conceptsLearned').textContent =
      (data.concepts || []).length;
    showToast('+' + (data.xpEarned||50) + ' XP earned! 🎉', 'success');

    // Add to history list (prepend)
    prependHistory({ id: data.sessionId, topic: data.topic,
      difficulty: data.difficulty, studyMinutes: data.studyTimeMinutes });
  } catch(e) {
    hideLoading();
    showToast('Failed to connect to AI. Check your API key.', 'danger');
    console.error(e);
  }
}

function renderAnalysis(data) {
  document.getElementById('anTopic').textContent   = data.topic || '—';
  document.getElementById('anTime').textContent    = data.studyTimeMinutes || '—';
  document.getElementById('anXp').textContent      = data.xpEarned || 50;
  document.getElementById('anSummary').textContent = data.summary || '';

  const badge = document.getElementById('diffBadge');
  badge.textContent = data.difficulty || '';
  badge.className   = 'diff-badge diff-' + (data.difficulty || 'Intermediate');

  const cc = document.getElementById('anConcepts');
  cc.innerHTML = '';
  (data.concepts || []).forEach(c => {
    const chip = document.createElement('span');
    chip.className   = 'concept-chip';
    chip.textContent = c;
    cc.appendChild(chip);
  });
}

// ── Explanation + TTS ──────────────────────────────────────────────────────
function renderExplanation(text) {
  document.getElementById('explanationText').textContent = text || '';
}

let sentences = [];
let sentIdx   = 0;

function ttsPlayPause() {
  if (!('speechSynthesis' in window)) return;
  if (isSpeaking && !isPaused) {
    window.speechSynthesis.pause();
    isPaused = true;
    setTtsUI('paused');
  } else if (isPaused) {
    window.speechSynthesis.resume();
    isPaused = false;
    setTtsUI('playing');
  } else {
    const text = document.getElementById('explanationText').textContent;
    if (!text) return;
    sentences = text.match(/[^.!?]+[.!?]+/g) || [text];
    sentIdx   = 0;
    speakNext();
  }
}

function speakNext() {
  if (sentIdx >= sentences.length) { setTtsUI('stopped'); return; }
  window.speechSynthesis.cancel();

  const utterance = new SpeechSynthesisUtterance(sentences[sentIdx]);
  utterance.rate   = ttsMuted ? 0 : ttsRate;
  utterance.volume = ttsMuted ? 0 : 1;
  utterance.pitch  = 1.1;

  const voices = window.speechSynthesis.getVoices();
  const fv = voices.find(v =>
    /zira|samantha|female|google uk english female|karen|moira/i.test(v.name)
  );
  if (fv) utterance.voice = fv;

  utterance.onstart = () => {
    isSpeaking = true; isPaused = false;
    setTtsUI('playing');
    highlightSubtitle(sentences[sentIdx]);
  };
  utterance.onend = () => {
    sentIdx++;
    speakNext();
  };
  utterance.onerror = () => setTtsUI('stopped');

  ttsUtterance = utterance;
  window.speechSynthesis.speak(utterance);
}

function ttsStop() {
  window.speechSynthesis.cancel();
  isSpeaking = false; isPaused = false; sentIdx = 0;
  setTtsUI('stopped');
  document.getElementById('ttsSubtitle').innerHTML =
    '<span class="text-muted fst-italic">Press ▶ to hear Ms. Clara speak…</span>';
}

function adjustRate(delta) {
  ttsRate = Math.min(2, Math.max(0.5, +(ttsRate + delta).toFixed(1)));
  document.getElementById('rateLabel').textContent = ttsRate.toFixed(1) + '×';
  if (isSpeaking) { ttsStop(); ttsPlayPause(); }
}

function toggleMute() {
  ttsMuted = !ttsMuted;
  const btn = document.getElementById('ttsMute');
  btn.innerHTML = ttsMuted
    ? '<i class="bi bi-volume-mute-fill text-danger"></i>'
    : '<i class="bi bi-volume-up-fill"></i>';
  if (ttsUtterance) ttsUtterance.volume = ttsMuted ? 0 : 1;
}

function setTtsUI(state) {
  document.getElementById('ttsPlay').style.display  = state === 'playing' ? 'none' : '';
  document.getElementById('ttsPause').style.display = state === 'playing' ? '' : 'none';
  if (state === 'stopped') { isSpeaking = false; isPaused = false; }
}

function highlightSubtitle(sentence) {
  const el = document.getElementById('ttsSubtitle');
  el.innerHTML = '<span class="hl">' + escHtml(sentence.trim()) + '</span>';
}

// ── Quiz ───────────────────────────────────────────────────────────────────
async function generateQuiz() {
  if (!session) return;
  const btn = document.getElementById('genQuizBtn');
  btn.disabled = true; btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Generating…';
  showLoading('Ms. Clara is writing quiz questions…');

  try {
    const params = new URLSearchParams({ action: 'quiz', sessionId: session.sessionId });
    const res    = await fetch(ctx + '/notewise', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params
    });
    const data = await res.json();
    hideLoading();
    btn.disabled = false; btn.innerHTML = '<i class="bi bi-magic me-1"></i>Regenerate';

    if (data.error) { showToast('Quiz error: ' + data.error, 'danger'); return; }
    currentQuiz = data;
    renderQuiz(data.questions);
  } catch(e) {
    hideLoading(); btn.disabled = false;
    btn.innerHTML = '<i class="bi bi-magic me-1"></i>Generate Quiz';
    showToast('Quiz generation failed', 'danger');
  }
}

function renderQuiz(questions) {
  const body = document.getElementById('quizBody');
  body.innerHTML = '';
  questions.forEach(function(q, i) {
    const card = document.createElement('div');
    card.className = 'q-card';
    var html = '<div class="q-num">Question ' + (i+1) + ' of ' + questions.length + '</div>';
    html += '<div class="q-text">' + escHtml(q.q) + '</div>';
    ['a','b','c','d'].forEach(function(opt) {
      html += '<div class="quiz-option" id="opt_' + i + '_' + opt + '" onclick="selectOpt(' + i + ',\'' + opt + '\')">';
      html += '<div class="opt-letter">' + opt.toUpperCase() + '</div>';
      html += '<div>' + escHtml(q[opt]) + '</div>';
      html += '</div>';
    });
    card.innerHTML = html;
    body.appendChild(card);
  });

  const submitDiv = document.createElement('div');
  submitDiv.className = 'text-center mt-3';
  submitDiv.innerHTML = `<button class="btn btn-primary btn-lg" onclick="submitQuiz()">
    <i class="bi bi-check2-circle me-2"></i>Submit Quiz</button>`;
  body.appendChild(submitDiv);
}

const quizAnswers = {};

function selectOpt(qIdx, opt) {
  ['a','b','c','d'].forEach(o => {
    const el = document.getElementById('opt_'+qIdx+'_'+o);
    if (el) el.classList.remove('selected');
  });
  const sel = document.getElementById('opt_'+qIdx+'_'+opt);
  if (sel) sel.classList.add('selected');
  quizAnswers[qIdx] = opt;
}

async function submitQuiz() {
  if (!currentQuiz) return;
  const n = currentQuiz.questions.length;
  const answers = Array.from({length: n}, (_, i) => quizAnswers[i] || '');

  showLoading('Ms. Clara is checking your answers…');
  try {
    const params = new URLSearchParams({
      action: 'submit', quizId: currentQuiz.quizId,
      answers: JSON.stringify(answers)
    });
    const res  = await fetch(ctx + '/notewise', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params
    });
    const data = await res.json();
    hideLoading();
    if (data.error) { showToast('Submit error: ' + data.error, 'danger'); return; }
    renderQuizResults(data);
  } catch(e) {
    hideLoading(); showToast('Submit failed', 'danger');
  }
}

function renderQuizResults(data) {
  const pct   = Math.round((data.score / data.total) * 100);
  const color = pct >= 80 ? '#16a34a' : pct >= 50 ? '#d97706' : '#dc2626';
  const msg   = pct === 100 ? 'Perfect score! 🎉'
              : pct >= 80   ? 'Excellent work! 🌟'
              : pct >= 50   ? 'Good effort! Keep going 💪'
              : 'Don\'t worry, Ms. Clara will help you review 📚';

  const dash    = 2 * Math.PI * 47;
  const offset  = dash * (1 - pct / 100);
  const body    = document.getElementById('quizBody');

  var html = '<div class="text-center py-3 mb-4">';
  html += '<div class="score-ring mb-2">';
  html += '<svg width="110" height="110" viewBox="0 0 110 110">';
  html += '<circle cx="55" cy="55" r="47" fill="none" stroke="var(--surface-3)" stroke-width="9"/>';
  html += '<circle cx="55" cy="55" r="47" fill="none" stroke="' + color + '" stroke-width="9"';
  html += ' stroke-dasharray="' + dash + '" stroke-dashoffset="' + offset + '"';
  html += ' stroke-linecap="round" style="transform:rotate(-90deg);transform-origin:55px 55px"/>';
  html += '</svg>';
  html += '<div class="score-text">';
  html += '<div class="score-pct" style="color:' + color + '">' + pct + '%</div>';
  html += '<div class="score-label">' + data.score + '/' + data.total + '</div>';
  html += '</div></div>';
  html += '<div class="fw-semibold">' + msg + '</div>';
  html += '<div class="text-warning fw-bold mt-1">+' + data.xpEarned + ' XP earned ⭐</div>';
  html += '</div>';
  body.innerHTML = html;

  data.results.forEach(function(r, i) {
    var cls  = r.correct ? 'border-success bg-success-subtle' : 'border-danger bg-danger-subtle';
    var icon = r.correct ? '✅' : '❌';
    var opts = {a: r.optionA, b: r.optionB, c: r.optionC, d: r.optionD};
    var row  = '<div class="q-card border ' + cls + ' mb-3">';
    row += '<div class="q-num">Q' + (i+1) + ' ' + icon + '</div>';
    row += '<div class="q-text">' + escHtml(r.question) + '</div>';
    ['a','b','c','d'].forEach(function(opt) {
      var extra = '';
      if (opt === r.correctAnswer) extra = ' fw-bold text-success';
      else if (opt === r.givenAnswer && !r.correct) extra = ' text-danger text-decoration-line-through';
      row += '<div class="d-flex align-items-center gap-2 py-1' + extra + '">';
      row += '<div class="opt-letter">' + opt.toUpperCase() + '</div>';
      row += '<div>' + escHtml(opts[opt]) + '</div></div>';
    });
    if (!r.correct) {
      row += '<div class="mt-2 p-2 rounded" style="background:rgba(99,102,241,.08);font-size:.85rem">';
      row += '<strong>Ms. Clara says:</strong> ' + escHtml(r.explanation) + '</div>';
    }
    row += '</div>';
    body.innerHTML += row;
  });

  body.innerHTML += '<div class="text-center"><button class="btn btn-outline-primary" onclick="generateQuiz()">'
    + '<i class="bi bi-arrow-clockwise me-1"></i>Try Again</button></div>';

  // Update sidebar score
  document.getElementById('quizScore').textContent = pct + '%';
  totalXp += data.xpEarned || 0;
  updateXpRing(totalXp);
  updateLevelBadge(totalXp);
  document.getElementById('xpDisplay').textContent = totalXp;
  showToast('+' + data.xpEarned + ' XP from quiz! 🎉', 'success');
}

// ── Chat ───────────────────────────────────────────────────────────────────
async function sendChat() {
  if (!session) return;
  const input = document.getElementById('chatInput');
  const q     = input.value.trim();
  if (!q) return;
  input.value = '';

  appendChatMsg('student', q);
  const typing = appendChatMsg('clara', '…');

  try {
    const params = new URLSearchParams({
      action: 'chat', sessionId: session.sessionId, question: q
    });
    const res  = await fetch(ctx + '/notewise', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params
    });
    const data = await res.json();
    typing.textContent = data.answer || 'Sorry, I could not answer that.';
    scrollChat();
  } catch(e) {
    typing.textContent = 'Sorry, something went wrong. Please try again.';
  }
}

function appendChatMsg(role, text) {
  const msgs = document.getElementById('chatMessages');
  const div  = document.createElement('div');
  div.className   = 'chat-msg ' + role;
  div.textContent = text;
  msgs.appendChild(div);
  scrollChat();
  return div;
}

function scrollChat() {
  const msgs = document.getElementById('chatMessages');
  msgs.scrollTop = msgs.scrollHeight;
}

// ── History ────────────────────────────────────────────────────────────────
function renderHistory(sessions) {
  const list = document.getElementById('historyList');
  if (!sessions || sessions.length === 0) return;
  list.innerHTML = '';
  sessions.forEach(s => prependHistory(s, list));
}

function prependHistory(s, container) {
  const list = container || document.getElementById('historyList');
  if (list.querySelector('.text-center')) list.innerHTML = '';
  const div = document.createElement('div');
  div.className = 'nw-hist-item';
  div.onclick   = function() { loadSession(s.id); };
  var diff = s.difficulty || 'Intermediate';
  div.innerHTML = '<div class="hist-topic">' + escHtml(s.topic || 'Unknown topic') + '</div>'
    + '<div class="hist-meta">'
    + '<span class="diff-badge diff-' + diff + '" style="font-size:.7rem;padding:.15rem .5rem">' + diff + '</span>'
    + '<span class="ms-2">' + (s.studyMinutes || '?') + ' min</span>'
    + '</div>';
  list.insertBefore(div, list.firstChild);
}

async function loadSession(sessionId) {
  showLoading('Loading session…');
  try {
    const params = new URLSearchParams({ action: 'load', sessionId });
    const res    = await fetch(ctx + '/notewise', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params
    });
    const data = await res.json();
    hideLoading();
    if (data.error) { showToast(data.error, 'danger'); return; }
    session = data;
    renderAnalysis(data);
    renderExplanation(data.explanation);
    showCards(['analysisCard','explanationCard','quizCard','chatCard']);
    document.getElementById('quizBody').innerHTML = '<div class="text-center py-4 text-muted">'
      + '<i class="bi bi-patch-question" style="font-size:2.5rem;opacity:.3;display:block;margin-bottom:.5rem"></i>'
      + 'Click <strong>Generate Quiz</strong> to test your understanding.</div>';
    document.getElementById('genQuizBtn').innerHTML = '<i class="bi bi-magic me-1"></i>Generate Quiz';
    document.getElementById('genQuizBtn').disabled = false;
    document.getElementById('conceptsLearned').textContent = (data.concepts||[]).length;
    showToast('Session loaded: ' + data.topic, 'info');
    window.scrollTo({top:0, behavior:'smooth'});
  } catch(e) {
    hideLoading(); showToast('Failed to load session', 'danger');
  }
}

// ── XP & Level ────────────────────────────────────────────────────────────
function updateXpRing(xp) {
  const max    = 1000;
  const pct    = Math.min(xp / max, 1);
  const arc    = document.getElementById('xpArc');
  if (!arc) return;
  const dash   = 2 * Math.PI * 42;
  arc.style.strokeDasharray  = dash;
  arc.style.strokeDashoffset = dash * (1 - pct);
}

function updateLevelBadge(xp) {
  const badge = document.getElementById('levelBadge');
  if (!badge) return;
  let level, cls;
  if      (xp < 100)  { level = '🌱 Beginner Learner';   cls = 'level-beginner'; }
  else if (xp < 300)  { level = '🔭 Concept Explorer';   cls = 'level-explorer'; }
  else if (xp < 600)  { level = '🏆 Quiz Master';        cls = 'level-master';   }
  else                { level = '🎓 NoteWise Scholar';   cls = 'level-scholar';  }
  badge.textContent = level;
  badge.className   = 'xp-level ' + cls;
}

// ── Loading overlay ────────────────────────────────────────────────────────
function showLoading(msg) {
  document.getElementById('nwLoadingMsg').textContent = msg || 'Loading…';
  document.getElementById('nwLoading').style.display  = 'flex';
}
function hideLoading() {
  document.getElementById('nwLoading').style.display = 'none';
}

// ── Utility ────────────────────────────────────────────────────────────────
function showCards(ids) {
  ids.forEach(id => { const el = document.getElementById(id); if(el) el.style.display=''; });
}

function escHtml(str) {
  if (!str) return '';
  return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
            .replace(/"/g,'&quot;').replace(/'/g,'&#39;');
}

function showToast(msg, type) {
  const tc  = document.getElementById('toast-container');
  const div = document.createElement('div');
  div.className = 'toast align-items-center text-bg-' + (type||'info') + ' border-0 show';
  div.setAttribute('role','alert');
  div.innerHTML = '<div class="d-flex"><div class="toast-body">' + escHtml(msg) + '</div>'
    + '<button type="button" class="btn-close btn-close-white me-2 m-auto" onclick="this.closest(\'.toast\').remove()"></button></div>';
  tc.appendChild(div);
  setTimeout(function() { div.remove(); }, 4000);
}

// Boot XP ring
updateXpRing(totalXp);
updateLevelBadge(totalXp);
</script>
</body>
</html>
