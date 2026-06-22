<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="OMR Results"/>
<%@ include file="/views/base-header.jsp" %>

<c:set var="ev" value="${evaluation}"/>

<div style="min-height:calc(100vh - 64px);background:var(--surface-2);padding:2rem 1.5rem">

  <!-- Header -->
  <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4">
    <div class="d-flex align-items-center gap-3">
      <a href="${ctx}/omr" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i></a>
      <div>
        <h4 class="mb-0 fw-bold">${ev.title}</h4>
        <span class="text-muted" style="font-size:.83rem">
          <c:if test="${not empty ev.courseTitle}"><i class="bi bi-collection me-1"></i>${ev.courseTitle} &bull; </c:if>
          ${ev.totalQuestions} Questions &bull; ${ev.totalMarks} Max Marks &bull; ${ev.createdAt}
        </span>
      </div>
    </div>
    <a href="${ctx}/omr?action=export&id=${ev.id}" class="btn btn-outline-success fw-semibold">
      <i class="bi bi-download me-2"></i>Export CSV
    </a>
  </div>

  <!-- Stats row -->
  <c:set var="totalStudents" value="${results.size()}"/>
  <c:set var="totalCorrectSum" value="0"/>
  <c:set var="totalMarksSum" value="0"/>
  <c:set var="passCount" value="0"/>
  <c:forEach var="r" items="${results}">
    <c:set var="totalMarksSum" value="${totalMarksSum + r.marksObtained}"/>
    <c:if test="${r.percentage >= 40}"><c:set var="passCount" value="${passCount + 1}"/></c:if>
  </c:forEach>

  <div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
      <div class="card shadow-sm text-center p-3">
        <div class="fw-bold" style="font-size:1.6rem;color:#3b82f6">${totalStudents}</div>
        <div class="text-muted" style="font-size:.8rem">Total Students</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card shadow-sm text-center p-3">
        <div class="fw-bold" style="font-size:1.6rem;color:#10b981">${passCount}</div>
        <div class="text-muted" style="font-size:.8rem">Passed (≥40%)</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card shadow-sm text-center p-3">
        <div class="fw-bold" style="font-size:1.6rem;color:#f59e0b">
          <c:choose>
            <c:when test="${totalStudents > 0}">
              <fmt:formatNumber value="${totalMarksSum / totalStudents}" maxFractionDigits="1"/>
            </c:when>
            <c:otherwise>0</c:otherwise>
          </c:choose>
        </div>
        <div class="text-muted" style="font-size:.8rem">Avg Marks</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card shadow-sm text-center p-3">
        <div class="fw-bold" style="font-size:1.6rem;color:#8b5cf6">
          <c:choose>
            <c:when test="${not empty results}">${results[0].marksObtained}</c:when>
            <c:otherwise>—</c:otherwise>
          </c:choose>
        </div>
        <div class="text-muted" style="font-size:.8rem">Highest Score</div>
      </div>
    </div>
  </div>

  <!-- Answer Key -->
  <div class="card shadow-sm mb-4">
    <div class="card-header"><span class="section-title mb-0"><i class="bi bi-key me-2"></i>Answer Key</span></div>
    <div class="card-body">
      <div class="d-flex flex-wrap gap-2" id="answerKeyBadges"></div>
    </div>
  </div>

  <!-- Results Table -->
  <div class="card shadow-sm">
    <div class="card-header d-flex justify-content-between align-items-center">
      <span class="section-title mb-0"><i class="bi bi-table me-2"></i>Student Results</span>
      <input type="text" id="searchBox" class="form-control form-control-sm w-auto"
             placeholder="Search student…" oninput="filterTable()" style="min-width:200px"/>
    </div>
    <c:choose>
      <c:when test="${empty results}">
        <div class="text-center py-4 text-muted">No results found.</div>
      </c:when>
      <c:otherwise>
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0" id="resultsTable">
            <thead style="background:var(--surface-3);font-size:.78rem;text-transform:uppercase;letter-spacing:.05em">
              <tr>
                <th class="px-4 py-3">#</th>
                <th class="py-3">Student</th>
                <th class="py-3 text-center text-success">Correct</th>
                <th class="py-3 text-center text-danger">Wrong</th>
                <th class="py-3 text-center text-secondary">Skip</th>
                <th class="py-3">Marks</th>
                <th class="py-3">Score</th>
                <th class="py-3 px-4">Responses</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="r" items="${results}">
                <tr>
                  <td class="px-4 fw-bold text-muted">${r.rank}</td>
                  <td>
                    <div class="fw-semibold"
                         style="<c:if test="${r.linked}">color:#3b82f6</c:if>">
                      <c:choose>
                        <c:when test="${not empty r.studentName}">${r.studentName}</c:when>
                        <c:otherwise>${r.studentIdentifier}</c:otherwise>
                      </c:choose>
                    </div>
                    <div class="text-muted" style="font-size:.77rem">${r.studentIdentifier}
                      <c:if test="${r.linked}"><i class="bi bi-link-45deg text-success ms-1" title="Linked to SLMS profile"></i></c:if>
                    </div>
                  </td>
                  <td class="text-center">
                    <span class="badge bg-success-subtle text-success fw-bold">${r.correctCount}</span>
                  </td>
                  <td class="text-center">
                    <span class="badge bg-danger-subtle text-danger fw-bold">${r.wrongCount}</span>
                  </td>
                  <td class="text-center">
                    <span class="badge bg-secondary-subtle text-secondary fw-bold">${r.unattempted}</span>
                  </td>
                  <td>
                    <span class="fw-bold">${r.marksObtained}</span>
                    <span class="text-muted" style="font-size:.8rem"> / ${ev.totalMarks}</span>
                  </td>
                  <td style="min-width:120px">
                    <div class="d-flex align-items-center gap-2">
                      <div class="progress flex-grow-1" style="height:7px">
                        <div class="progress-bar
                          <c:choose>
                            <c:when test="${r.percentage >= 75}">bg-success</c:when>
                            <c:when test="${r.percentage >= 40}">bg-warning</c:when>
                            <c:otherwise>bg-danger</c:otherwise>
                          </c:choose>"
                          style="width:${r.percentage}%"></div>
                      </div>
                      <span style="font-size:.8rem;min-width:38px"><fmt:formatNumber value="${r.percentage}" maxFractionDigits="1"/>%</span>
                    </div>
                  </td>
                  <td class="px-4">
                    <button class="btn btn-sm btn-outline-primary"
                            onclick="showBreakdown('${r.studentName != null ? r.studentName : r.studentIdentifier}','${r.responses}')">
                      <i class="bi bi-eye me-1"></i>Details
                    </button>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<!-- Breakdown Modal -->
<div class="modal fade" id="breakdownModal" tabindex="-1">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title fw-bold" id="modalTitle">Answer Breakdown</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body" id="modalBody"></div>
    </div>
  </div>
</div>

<footer class="py-3 border-top text-center text-muted" style="font-size:.8rem;background:var(--surface)">
  &copy; 2025 <strong>SLMS</strong>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${ctx}/static/js/slms.js"></script>
<script>
  const answerKey = '${ev.answerKey}'.split(',').map(s => s.trim().toUpperCase());

  // Render answer key badges
  (function() {
    const container = document.getElementById('answerKeyBadges');
    answerKey.forEach((ans, i) => {
      const badge = document.createElement('span');
      badge.className = 'badge rounded-pill fw-semibold';
      badge.style.background = '#e0f2fe';
      badge.style.color = '#0369a1';
      badge.style.fontSize = '.78rem';
      badge.style.padding = '.35em .7em';
      badge.textContent = 'Q' + (i+1) + ': ' + ans;
      container.appendChild(badge);
    });
  })();

  function showBreakdown(name, responsesStr) {
    const responses = responsesStr.split(',').map(s => s.trim().toUpperCase());
    document.getElementById('modalTitle').textContent = name + ' – Answer Breakdown';

    let html = '<div class="d-flex flex-wrap gap-2">';
    responses.forEach((ans, i) => {
      const key = answerKey[i] || '?';
      const correct = ans === key;
      const skipped = ans === '-' || ans === '';
      let bg = skipped ? '#f1f5f9' : (correct ? '#dcfce7' : '#fee2e2');
      let color = skipped ? '#64748b' : (correct ? '#166534' : '#991b1b');
      let icon = skipped ? '—' : (correct ? '✓' : '✗');
      html += '<div style="background:' + bg + ';color:' + color + ';border-radius:10px;padding:.5rem .75rem;font-size:.83rem;min-width:90px;text-align:center">';
      html += '<div style="font-weight:700;font-size:.7rem;opacity:.6">Q' + (i+1) + '</div>';
      html += '<div style="font-size:1.1rem;font-weight:800">' + (ans === '-' || ans === '' ? '—' : ans) + '</div>';
      html += '<div style="font-size:.72rem">' + icon + ' ' + (skipped ? 'skipped' : (correct ? 'correct' : 'key: ' + key)) + '</div>';
      html += '</div>';
    });
    html += '</div>';
    document.getElementById('modalBody').innerHTML = html;
    new bootstrap.Modal(document.getElementById('breakdownModal')).show();
  }

  function filterTable() {
    const q = document.getElementById('searchBox').value.toLowerCase();
    document.querySelectorAll('#resultsTable tbody tr').forEach(row => {
      row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
  }
</script>
</body></html>
