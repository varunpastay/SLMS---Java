<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>AI Doubt Solver – SLMS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<style>
body{background:#f0f4ff;min-height:100vh}
.chat-box{height:420px;overflow-y:auto;display:flex;flex-direction:column;gap:12px;padding:16px;background:#fff;border-radius:12px;border:1px solid #dee2e6}
.msg-user{align-self:flex-end;background:#4f46e5;color:#fff;border-radius:16px 16px 4px 16px;padding:10px 16px;max-width:75%;font-size:.92rem}
.msg-ai{align-self:flex-start;background:#f1f5fe;color:#1e293b;border-radius:16px 16px 16px 4px;padding:12px 16px;max-width:85%;font-size:.92rem;line-height:1.65;white-space:pre-line}
.msg-ai .avatar{width:28px;height:28px;background:#4f46e5;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;color:#fff;font-size:.75rem;margin-right:8px;flex-shrink:0}
.typing{display:none;align-self:flex-start;padding:10px 16px;background:#f1f5fe;border-radius:16px;font-size:.85rem;color:#6c757d}
.typing.show{display:block}
.hero{background:linear-gradient(135deg,#4f46e5,#7c3aed);color:#fff;border-radius:16px;padding:28px 32px;margin-bottom:24px}
</style>
</head>
<body>
<%@ include file="/views/base-header.jsp" %>
<div class="container py-4" style="max-width:820px">
  <div class="hero">
    <h2 class="mb-1"><i class="bi bi-robot me-2"></i>AI Doubt Solver</h2>
    <p class="mb-0 opacity-75">Ask any question and get instant, clear explanations from your AI tutor.</p>
  </div>

  <div class="card shadow-sm border-0 mb-3">
    <div class="card-body p-3">
      <div class="row g-2 mb-3">
        <div class="col-md-6">
          <select id="subjectSel" class="form-select">
            <option value="">-- No subject filter --</option>
            <c:forEach var="c" items="${courses}">
              <option value="${c.title}">${c.title}</option>
            </c:forEach>
          </select>
        </div>
        <div class="col-md-6 d-flex gap-2">
          <button class="btn btn-outline-secondary btn-sm" onclick="clearChat()"><i class="bi bi-trash me-1"></i>Clear Chat</button>
        </div>
      </div>
      <div class="chat-box" id="chatBox">
        <div class="msg-ai">
          <span class="d-flex align-items-start gap-2">
            <span class="avatar"><i class="bi bi-robot"></i></span>
            <span>Hi! I'm your AI tutor. Ask me anything — concepts, formulas, examples, or tricky problems. I'm here to help! 🎓</span>
          </span>
        </div>
      </div>
      <div class="typing" id="typing"><i class="bi bi-three-dots"></i> Thinking...</div>
    </div>
    <div class="card-footer bg-white border-top-0 pt-0 pb-3 px-3">
      <div class="input-group">
        <textarea id="qInput" class="form-control" rows="2" placeholder="Type your doubt or question here..." style="resize:none;border-radius:10px 0 0 10px"></textarea>
        <button class="btn btn-primary px-4" onclick="askDoubt()" id="sendBtn">
          <i class="bi bi-send-fill"></i>
        </button>
      </div>
      <small class="text-muted mt-1 d-block">Press Enter to send, Shift+Enter for new line</small>
    </div>
  </div>

  <div class="row g-3">
    <div class="col-md-4">
      <div class="card border-0 shadow-sm h-100 text-center p-3" style="cursor:pointer" onclick="quickAsk('Explain like I am 10 years old')">
        <i class="bi bi-emoji-smile fs-2 text-warning"></i>
        <div class="mt-2 fw-semibold">ELI5 Mode</div>
        <small class="text-muted">Simple explanation</small>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card border-0 shadow-sm h-100 text-center p-3" style="cursor:pointer" onclick="quickAsk('Give me a real-world example')">
        <i class="bi bi-lightbulb fs-2 text-success"></i>
        <div class="mt-2 fw-semibold">Real Example</div>
        <small class="text-muted">Practical use case</small>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card border-0 shadow-sm h-100 text-center p-3" style="cursor:pointer" onclick="quickAsk('Give me a memory trick to remember this')">
        <i class="bi bi-brain fs-2 text-info"></i>
        <div class="mt-2 fw-semibold">Memory Tip</div>
        <small class="text-muted">Mnemonics & tricks</small>
      </div>
    </div>
  </div>
</div>

<script>
const chatBox = document.getElementById('chatBox');
const qInput = document.getElementById('qInput');

qInput.addEventListener('keydown', e => {
  if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); askDoubt(); }
});

function addMsg(text, isUser) {
  const div = document.createElement('div');
  if (isUser) {
    div.className = 'msg-user'; div.textContent = text;
  } else {
    div.className = 'msg-ai';
    div.innerHTML = '<span class="d-flex align-items-start gap-2"><span class="avatar"><i class="bi bi-robot"></i></span><span>' + escHtml(text) + '</span></span>';
  }
  chatBox.appendChild(div);
  chatBox.scrollTop = chatBox.scrollHeight;
}

function escHtml(t) { const d=document.createElement('div'); d.textContent=t; return d.innerHTML; }

function quickAsk(prefix) { qInput.value = prefix + ': ' + qInput.value; qInput.focus(); }

function clearChat() {
  chatBox.innerHTML = '<div class="msg-ai"><span class="d-flex align-items-start gap-2"><span class="avatar"><i class="bi bi-robot"></i></span><span>Chat cleared. What would you like to know? 📚</span></span></div>';
}

async function askDoubt() {
  const q = qInput.value.trim(); if (!q) return;
  const subject = document.getElementById('subjectSel').value;
  addMsg(q, true); qInput.value = '';
  document.getElementById('typing').classList.add('show');
  document.getElementById('sendBtn').disabled = true;
  try {
    const fd = new FormData();
    fd.append('question', q); fd.append('subject', subject);
    const r = await fetch('/slms/ai-doubt', { method:'POST', body: fd });
    const data = await r.json();
    document.getElementById('typing').classList.remove('show');
    if (data.answer) addMsg(data.answer, false);
    else addMsg('Error: ' + (data.error || 'Unknown error. Please try again.'), false);
  } catch(e) {
    document.getElementById('typing').classList.remove('show');
    addMsg('Connection error. Please try again.', false);
  }
  document.getElementById('sendBtn').disabled = false;
}
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
