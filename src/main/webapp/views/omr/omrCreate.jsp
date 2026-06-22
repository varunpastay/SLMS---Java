<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="New OMR Evaluation"/>
<%@ include file="/views/base-header.jsp" %>

<div style="min-height:calc(100vh - 64px);background:var(--surface-2);padding:2rem 1.5rem">

  <div class="d-flex align-items-center gap-3 mb-4">
    <a href="${ctx}/omr" class="btn btn-sm btn-outline-secondary">
      <i class="bi bi-arrow-left"></i>
    </a>
    <div>
      <h4 class="mb-0 fw-bold">New OMR Evaluation</h4>
      <p class="text-muted mb-0" style="font-size:.85rem">Upload the answer key and student response CSV to auto-calculate marks</p>
    </div>
  </div>

  <c:if test="${not empty error}">
    <div class="alert alert-danger mb-4"><i class="bi bi-exclamation-triangle me-2"></i>${error}</div>
  </c:if>

  <div class="row g-4">
    <!-- Form -->
    <div class="col-lg-8">
      <div class="card shadow-sm">
        <div class="card-header"><span class="section-title mb-0"><i class="bi bi-upc-scan me-2"></i>Evaluation Details</span></div>
        <div class="card-body">
          <form method="post" action="${ctx}/omr" enctype="multipart/form-data" id="omrForm">
            <input type="hidden" name="action" value="create"/>

            <div class="mb-3">
              <label class="form-label fw-semibold">Evaluation Title <span class="text-danger">*</span></label>
              <input type="text" name="title" class="form-control" placeholder="e.g. Mid-Term Exam – Physics Chapter 3" required/>
            </div>

            <div class="mb-3">
              <label class="form-label fw-semibold">Course <span class="text-muted fw-normal">(optional)</span></label>
              <select name="courseId" class="form-select">
                <option value="">— Not linked to a course —</option>
                <c:forEach var="c" items="${courses}">
                  <option value="${c.id}">${c.title}</option>
                </c:forEach>
              </select>
            </div>

            <div class="row g-3 mb-3">
              <div class="col-md-6">
                <label class="form-label fw-semibold">Marks per Correct Answer</label>
                <input type="number" name="marksPerCorrect" class="form-control" value="1" min="0.25" step="0.25" required/>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold">Negative Marks per Wrong Answer</label>
                <input type="number" name="negativeMarks" class="form-control" value="0" min="0" step="0.25"/>
                <div class="form-text">Set to 0 for no negative marking.</div>
              </div>
            </div>

            <div class="mb-3">
              <label class="form-label fw-semibold">
                Answer Key <span class="text-danger">*</span>
                <span class="text-muted fw-normal ms-1" style="font-size:.8rem">
                  — comma-separated (A,B,C,D,A,…). Number of entries = total questions.
                </span>
              </label>
              <textarea name="answerKey" id="answerKey" class="form-control font-monospace" rows="3"
                        placeholder="A,B,C,D,A,B,C,D,A,B" required
                        oninput="countQuestions()"></textarea>
              <div class="form-text" id="qCount" style="font-weight:500"></div>
            </div>

            <div class="mb-4">
              <label class="form-label fw-semibold">Student Responses CSV <span class="text-danger">*</span></label>
              <input type="file" name="csvFile" id="csvFile" class="form-control" accept=".csv,.txt" required/>
              <div class="form-text">
                First row = header (skipped). Each subsequent row: <code>student_email_or_username,A,B,C,D,…</code>
              </div>
            </div>

            <div class="d-flex gap-3">
              <button type="submit" class="btn btn-success fw-semibold px-4" id="submitBtn">
                <i class="bi bi-cpu me-2"></i>Process &amp; Calculate Marks
              </button>
              <a href="${ctx}/omr" class="btn btn-outline-secondary">Cancel</a>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Help panel -->
    <div class="col-lg-4 d-flex flex-column gap-3">
      <div class="card shadow-sm">
        <div class="card-header"><span class="section-title mb-0"><i class="bi bi-filetype-csv me-2"></i>CSV Format</span></div>
        <div class="card-body">
          <p style="font-size:.83rem;color:#64748b" class="mb-2">Row 1 is the header (skipped). From row 2:</p>
          <pre class="p-2 rounded-xl mb-2" style="background:var(--surface-3);font-size:.75rem;overflow-x:auto">identifier,Q1,Q2,Q3,...
john@school.com,A,B,C,D
jane@school.com,A,A,C,B
roll123,B,B,C,D</pre>
          <ul style="font-size:.82rem;color:#475569;padding-left:1.2rem" class="mb-0">
            <li>First column: student <strong>email</strong> or <strong>username</strong></li>
            <li>Remaining columns: answers (A / B / C / D)</li>
            <li>Leave blank or use <code>-</code> for unattempted</li>
            <li>Matching is case-insensitive</li>
          </ul>
        </div>
      </div>

      <div class="card shadow-sm">
        <div class="card-header"><span class="section-title mb-0"><i class="bi bi-calculator me-2"></i>Scoring</span></div>
        <div class="card-body" style="font-size:.83rem;color:#475569">
          <p class="mb-2"><strong>Score</strong> = (Correct × Marks/Q) − (Wrong × Negative)</p>
          <p class="mb-2">Minimum score is always 0 (no negative total).</p>
          <p class="mb-0">Students matched by email or username get results linked to their SLMS profile.</p>
        </div>
      </div>

      <div class="card shadow-sm border-warning-subtle">
        <div class="card-body" style="font-size:.82rem;color:#92400e;background:#fffbeb;border-radius:12px">
          <i class="bi bi-lightbulb me-2 text-warning"></i>
          You can export from Google Sheets or Excel as <strong>.csv</strong>. Just make sure the first column is the student identifier.
        </div>
      </div>
    </div>
  </div>

</div>

<footer class="py-3 border-top text-center text-muted" style="font-size:.8rem;background:var(--surface)">
  &copy; 2025 <strong>SLMS</strong>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${ctx}/static/js/slms.js"></script>
<script>
  function countQuestions() {
    const val = document.getElementById('answerKey').value.trim();
    if (!val) { document.getElementById('qCount').textContent = ''; return; }
    const count = val.split(',').filter(s => s.trim()).length;
    document.getElementById('qCount').textContent = count + ' question' + (count !== 1 ? 's' : '') + ' detected';
    document.getElementById('qCount').style.color = '#10b981';
  }

  document.getElementById('omrForm').addEventListener('submit', function() {
    const btn = document.getElementById('submitBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Processing…';
  });
</script>
</body></html>
