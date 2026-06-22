<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="OMR Evaluations"/>
<%@ include file="/views/base-header.jsp" %>

<div style="min-height:calc(100vh - 64px);background:var(--surface-2);padding:2rem 1.5rem">

  <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-3">
    <div class="d-flex align-items-center gap-3">
      <div class="rounded-xl d-flex align-items-center justify-content-center flex-shrink-0"
           style="width:48px;height:48px;background:linear-gradient(135deg,#10b981,#059669);color:#fff;font-size:1.4rem">
        <i class="bi bi-upc-scan"></i>
      </div>
      <div>
        <h4 class="mb-0 fw-bold">OMR Evaluations</h4>
        <p class="text-muted mb-0" style="font-size:.85rem">Upload answer keys &amp; student responses to auto-calculate marks</p>
      </div>
    </div>
    <a href="${ctx}/omr?action=create" class="btn btn-success fw-semibold">
      <i class="bi bi-plus-lg me-2"></i>New Evaluation
    </a>
  </div>

  <c:if test="${not empty param.deleted}">
    <div class="alert alert-success alert-dismissible fade show mb-3">
      <i class="bi bi-check-circle me-2"></i>Evaluation deleted successfully.
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  </c:if>

  <c:choose>
    <c:when test="${empty evaluations}">
      <div class="card shadow-sm">
        <div class="text-center py-5 text-muted">
          <i class="bi bi-upc-scan" style="font-size:3.5rem;opacity:.2"></i>
          <h5 class="mt-3">No evaluations yet</h5>
          <p class="mb-4">Upload your first answer key and student CSV to get started.</p>
          <a href="${ctx}/omr?action=create" class="btn btn-success">
            <i class="bi bi-plus-lg me-2"></i>Create First Evaluation
          </a>
        </div>
      </div>
    </c:when>
    <c:otherwise>
      <div class="row g-4">
        <c:forEach var="ev" items="${evaluations}">
          <div class="col-md-6 col-xl-4">
            <div class="card shadow-sm h-100">
              <div class="card-body d-flex flex-column gap-3">
                <div class="d-flex align-items-start justify-content-between gap-2">
                  <div>
                    <h6 class="fw-bold mb-1">${ev.title}</h6>
                    <c:if test="${not empty ev.courseTitle}">
                      <span class="badge bg-primary-subtle text-primary" style="font-size:.75rem">
                        <i class="bi bi-collection me-1"></i>${ev.courseTitle}
                      </span>
                    </c:if>
                  </div>
                  <span class="badge bg-success-subtle text-success flex-shrink-0">${ev.totalQuestions} Qs</span>
                </div>

                <div class="row g-2 text-center">
                  <div class="col-4">
                    <div class="p-2 rounded-xl" style="background:var(--surface-3)">
                      <div class="fw-bold" style="font-size:1.1rem">${ev.studentCount}</div>
                      <div class="text-muted" style="font-size:.72rem">Students</div>
                    </div>
                  </div>
                  <div class="col-4">
                    <div class="p-2 rounded-xl" style="background:var(--surface-3)">
                      <div class="fw-bold" style="font-size:1.1rem">
                        <c:choose>
                          <c:when test="${ev.avgMarks != null}"><fmt:formatNumber value="${ev.avgMarks}" maxFractionDigits="1"/></c:when>
                          <c:otherwise>—</c:otherwise>
                        </c:choose>
                      </div>
                      <div class="text-muted" style="font-size:.72rem">Avg Marks</div>
                    </div>
                  </div>
                  <div class="col-4">
                    <div class="p-2 rounded-xl" style="background:var(--surface-3)">
                      <div class="fw-bold" style="font-size:1.1rem"><fmt:formatNumber value="${ev.totalMarks}" maxFractionDigits="0"/></div>
                      <div class="text-muted" style="font-size:.72rem">Max Marks</div>
                    </div>
                  </div>
                </div>

                <div class="text-muted" style="font-size:.78rem">
                  <i class="bi bi-clock me-1"></i>${ev.createdAt}
                </div>

                <div class="d-flex gap-2 mt-auto">
                  <a href="${ctx}/omr?action=view&id=${ev.id}" class="btn btn-sm btn-primary flex-grow-1">
                    <i class="bi bi-table me-1"></i>View Results
                  </a>
                  <a href="${ctx}/omr?action=export&id=${ev.id}" class="btn btn-sm btn-outline-success" title="Export CSV">
                    <i class="bi bi-download"></i>
                  </a>
                  <form method="get" action="${ctx}/omr" class="d-inline"
                        onsubmit="return confirm('Delete this evaluation and all its results?')">
                    <input type="hidden" name="action" value="delete"/>
                    <input type="hidden" name="id" value="${ev.id}"/>
                    <button class="btn btn-sm btn-outline-danger" title="Delete">
                      <i class="bi bi-trash"></i>
                    </button>
                  </form>
                </div>
              </div>
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
</body></html>
