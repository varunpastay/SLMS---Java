<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Teacher Requests"/>
<%@ include file="/views/base-header.jsp" %>

<div style="min-height:calc(100vh - 64px);background:var(--surface-2);padding:2rem 1.5rem">

  <div class="d-flex align-items-center gap-3 mb-4">
    <div class="rounded-xl d-flex align-items-center justify-content-center flex-shrink-0"
         style="width:48px;height:48px;background:linear-gradient(135deg,#f59e0b,#d97706);color:#fff;font-size:1.4rem">
      <i class="bi bi-person-check"></i>
    </div>
    <div>
      <h4 class="mb-0 fw-bold">Teacher Registration Requests</h4>
      <p class="text-muted mb-0" style="font-size:.85rem">Review and approve or reject teacher account applications</p>
    </div>
  </div>

  <c:if test="${not empty param.msg}">
    <c:choose>
      <c:when test="${param.msg == 'approved'}">
        <div class="alert alert-success alert-dismissible fade show mb-3">
          <i class="bi bi-check-circle me-2"></i>Teacher account approved and created successfully. A welcome email has been sent.
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      </c:when>
      <c:when test="${param.msg == 'rejected'}">
        <div class="alert alert-warning alert-dismissible fade show mb-3">
          <i class="bi bi-x-circle me-2"></i>Request has been rejected.
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      </c:when>
      <c:when test="${param.msg == 'duplicate'}">
        <div class="alert alert-danger alert-dismissible fade show mb-3">
          <i class="bi bi-exclamation-triangle me-2"></i>Cannot approve — email or username is already registered. Request auto-rejected.
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      </c:when>
      <c:when test="${param.msg == 'not_found'}">
        <div class="alert alert-danger alert-dismissible fade show mb-3">
          <i class="bi bi-exclamation-triangle me-2"></i>Request not found or already reviewed.
          <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
      </c:when>
    </c:choose>
  </c:if>

  <div class="card shadow-sm">
    <div class="card-header d-flex justify-content-between align-items-center">
      <span class="section-title mb-0"><i class="bi bi-list-check me-2"></i>All Requests</span>
      <c:set var="pendingCount" value="0"/>
      <c:forEach var="r" items="${requests}">
        <c:if test="${r.status == 'PENDING'}"><c:set var="pendingCount" value="${pendingCount + 1}"/></c:if>
      </c:forEach>
      <c:if test="${pendingCount > 0}">
        <span class="badge bg-warning text-dark">${pendingCount} pending</span>
      </c:if>
    </div>

    <c:choose>
      <c:when test="${empty requests}">
        <div class="text-center py-5 text-muted">
          <i class="bi bi-inbox" style="font-size:3rem;opacity:.3"></i>
          <p class="mt-2 mb-0">No teacher requests yet.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead style="background:var(--surface-3);font-size:.8rem;text-transform:uppercase;letter-spacing:.05em">
              <tr>
                <th class="px-4 py-3">Applicant</th>
                <th class="py-3">Contact</th>
                <th class="py-3">Reason</th>
                <th class="py-3">Applied</th>
                <th class="py-3">Status</th>
                <th class="py-3 text-end px-4">Actions</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="r" items="${requests}">
                <tr>
                  <td class="px-4 py-3">
                    <div class="fw-semibold">${r.firstName} ${r.lastName}</div>
                    <div class="text-muted" style="font-size:.8rem">@${r.username}</div>
                  </td>
                  <td class="py-3">
                    <a href="mailto:${r.email}" class="text-decoration-none" style="font-size:.85rem">${r.email}</a>
                  </td>
                  <td class="py-3" style="max-width:260px">
                    <c:choose>
                      <c:when test="${not empty r.reason}">
                        <span style="font-size:.83rem;color:#475569">${r.reason}</span>
                      </c:when>
                      <c:otherwise>
                        <span class="text-muted" style="font-size:.82rem">No reason provided</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td class="py-3" style="font-size:.82rem;white-space:nowrap;color:#64748b">
                    ${r.createdAt}
                  </td>
                  <td class="py-3">
                    <c:choose>
                      <c:when test="${r.status == 'PENDING'}">
                        <span class="badge bg-warning text-dark">Pending</span>
                      </c:when>
                      <c:when test="${r.status == 'APPROVED'}">
                        <span class="badge bg-success">Approved</span>
                        <div class="text-muted" style="font-size:.75rem">by ${r.reviewerName}</div>
                      </c:when>
                      <c:otherwise>
                        <span class="badge bg-danger">Rejected</span>
                        <c:if test="${not empty r.reviewerName}">
                          <div class="text-muted" style="font-size:.75rem">by ${r.reviewerName}</div>
                        </c:if>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td class="py-3 px-4 text-end">
                    <c:if test="${r.status == 'PENDING'}">
                      <form method="post" action="${ctx}/admin/teacher-requests" class="d-inline"
                            onsubmit="return confirm('Approve this teacher request?')">
                        <input type="hidden" name="id" value="${r.id}"/>
                        <input type="hidden" name="action" value="approve"/>
                        <button class="btn btn-sm btn-success">
                          <i class="bi bi-check-lg me-1"></i>Approve
                        </button>
                      </form>
                      <form method="post" action="${ctx}/admin/teacher-requests" class="d-inline ms-1"
                            onsubmit="return confirm('Reject this teacher request?')">
                        <input type="hidden" name="id" value="${r.id}"/>
                        <input type="hidden" name="action" value="reject"/>
                        <button class="btn btn-sm btn-outline-danger">
                          <i class="bi bi-x-lg me-1"></i>Reject
                        </button>
                      </form>
                    </c:if>
                    <c:if test="${r.status != 'PENDING'}">
                      <span class="text-muted" style="font-size:.8rem">Reviewed</span>
                    </c:if>
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

<footer class="py-3 border-top text-center text-muted" style="font-size:.8rem;background:var(--surface)">
  &copy; 2025 <strong>SLMS</strong> &mdash; Student Learning Management System
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/static/js/slms.js"></script>
</body>
</html>
