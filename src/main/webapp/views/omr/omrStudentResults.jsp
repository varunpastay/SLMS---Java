<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="My OMR Results"/>
<%@ include file="/views/base-header.jsp" %>

<div style="min-height:calc(100vh - 64px);background:var(--surface-2);padding:2rem 1.5rem">

  <div class="d-flex align-items-center gap-3 mb-4">
    <div class="rounded-xl d-flex align-items-center justify-content-center flex-shrink-0"
         style="width:48px;height:48px;background:linear-gradient(135deg,#10b981,#059669);color:#fff;font-size:1.4rem">
      <i class="bi bi-upc-scan"></i>
    </div>
    <div>
      <h4 class="mb-0 fw-bold">My OMR Results</h4>
      <p class="text-muted mb-0" style="font-size:.85rem">Your evaluated exam sheets and scores</p>
    </div>
  </div>

  <c:choose>
    <c:when test="${empty omrResults}">
      <div class="card shadow-sm">
        <div class="text-center py-5 text-muted">
          <i class="bi bi-upc-scan" style="font-size:3.5rem;opacity:.2"></i>
          <h5 class="mt-3">No OMR results yet</h5>
          <p class="mb-0">Your teacher hasn't processed any OMR sheets for you yet.</p>
        </div>
      </div>
    </c:when>
    <c:otherwise>
      <div class="d-flex flex-column gap-4">
        <c:forEach var="r" items="${omrResults}" varStatus="st">
          <div class="card shadow-sm">
            <div class="card-body">
              <div class="d-flex align-items-start justify-content-between flex-wrap gap-3 mb-3">
                <div>
                  <h5 class="fw-bold mb-1">${r.title}</h5>
                  <div class="text-muted" style="font-size:.82rem">
                    <c:if test="${not empty r.courseTitle}"><i class="bi bi-collection me-1"></i>${r.courseTitle} &bull; </c:if>
                    <i class="bi bi-person me-1"></i>${r.teacherName} &bull;
                    <i class="bi bi-clock me-1"></i>${r.createdAt}
                  </div>
                </div>
                <div class="text-end">
                  <div style="font-size:2rem;font-weight:800;
                    color:<c:choose><c:when test="${r.percentage >= 75}">#10b981</c:when><c:when test="${r.percentage >= 40}">#f59e0b</c:when><c:otherwise>#ef4444</c:otherwise></c:choose>">
                    <fmt:formatNumber value="${r.percentage}" maxFractionDigits="1"/>%
                  </div>
                  <div class="text-muted" style="font-size:.8rem">${r.marksObtained} / ${r.totalMarks}</div>
                </div>
              </div>

              <!-- Score bar -->
              <div class="progress mb-3" style="height:10px;border-radius:9px">
                <div class="progress-bar
                  <c:choose><c:when test="${r.percentage >= 75}">bg-success</c:when><c:when test="${r.percentage >= 40}">bg-warning</c:when><c:otherwise>bg-danger</c:otherwise></c:choose>"
                  style="width:${r.percentage}%;border-radius:9px"></div>
              </div>

              <!-- Quick stats -->
              <div class="d-flex gap-3 flex-wrap mb-3">
                <div class="d-flex align-items-center gap-2 px-3 py-2 rounded-xl" style="background:#dcfce7">
                  <i class="bi bi-check-circle-fill text-success"></i>
                  <span style="font-size:.85rem;font-weight:600;color:#166534">${r.correctCount} Correct</span>
                </div>
                <div class="d-flex align-items-center gap-2 px-3 py-2 rounded-xl" style="background:#fee2e2">
                  <i class="bi bi-x-circle-fill text-danger"></i>
                  <span style="font-size:.85rem;font-weight:600;color:#991b1b">${r.wrongCount} Wrong</span>
                </div>
                <div class="d-flex align-items-center gap-2 px-3 py-2 rounded-xl" style="background:#f1f5f9">
                  <i class="bi bi-dash-circle text-secondary"></i>
                  <span style="font-size:.85rem;font-weight:600;color:#64748b">${r.unattempted} Skipped</span>
                </div>
              </div>

              <!-- Per-question breakdown -->
              <details>
                <summary class="btn btn-sm btn-outline-primary mb-2" style="cursor:pointer">
                  <i class="bi bi-grid me-1"></i>View Question-by-Question Breakdown
                </summary>
                <div class="d-flex flex-wrap gap-2 mt-2"
                     data-key="${r.answerKey}" data-resp="${r.responses}" id="breakdown-${st.index}"></div>
              </details>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>

</div>

<footer class="py-3 border-top text-center text-muted" style="font-size:.8rem;background:var(--surface)">
  &copy; 2025 <strong>SLMS</strong>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${ctx}/static/js/slms.js"></script>
<script>
  document.querySelectorAll('[id^="breakdown-"]').forEach(function(container) {
    const parent = container.closest('details');
    parent.addEventListener('toggle', function() {
      if (!parent.open || container.children.length > 0) return;
      const key   = container.dataset.key.split(',').map(s => s.trim().toUpperCase());
      const resp  = container.dataset.resp.split(',').map(s => s.trim().toUpperCase());
      key.forEach(function(k, i) {
        const ans = resp[i] || '-';
        const skipped = ans === '-' || ans === '';
        const correct = !skipped && ans === k;
        const bg    = skipped ? '#f1f5f9' : (correct ? '#dcfce7' : '#fee2e2');
        const color = skipped ? '#64748b' : (correct ? '#166534' : '#991b1b');
        const icon  = skipped ? '—' : (correct ? '✓' : '✗');
        const div = document.createElement('div');
        div.style.cssText = 'background:' + bg + ';color:' + color + ';border-radius:10px;padding:.5rem .75rem;font-size:.83rem;min-width:90px;text-align:center';
        div.innerHTML = '<div style="font-weight:700;font-size:.7rem;opacity:.6">Q' + (i+1) + '</div>' +
                        '<div style="font-size:1.1rem;font-weight:800">' + (skipped ? '—' : ans) + '</div>' +
                        '<div style="font-size:.72rem">' + icon + ' ' + (skipped ? 'skipped' : (correct ? 'correct' : 'key: ' + k)) + '</div>';
        container.appendChild(div);
      });
    });
  });
</script>
</body></html>
