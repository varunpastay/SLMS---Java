<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Course Approval – SLMS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<style>
body{background:#f0fff4}
.hero{background:linear-gradient(135deg,#059669,#0284c7);color:#fff;border-radius:16px;padding:28px 32px;margin-bottom:24px}
</style>
</head>
<body>
<%@ include file="/views/base-header.jsp" %>
<div class="container py-4">
  <div class="hero">
    <h2 class="mb-1"><i class="bi bi-patch-check me-2"></i>Course Approval Workflow</h2>
    <p class="mb-0 opacity-75">Review and approve or reject courses submitted by teachers.</p>
  </div>

  <!-- Filter Tabs -->
  <div class="d-flex gap-2 mb-4 flex-wrap">
    <a href="?status=PENDING" class="btn ${statusFilter=='PENDING'?'btn-warning':'btn-outline-warning'}">
      <i class="bi bi-hourglass-split me-1"></i>Pending <span class="badge bg-dark ms-1">${counts['PENDING']!=null?counts['PENDING']:0}</span>
    </a>
    <a href="?status=APPROVED" class="btn ${statusFilter=='APPROVED'?'btn-success':'btn-outline-success'}">
      <i class="bi bi-check-circle me-1"></i>Approved <span class="badge bg-dark ms-1">${counts['APPROVED']!=null?counts['APPROVED']:0}</span>
    </a>
    <a href="?status=REJECTED" class="btn ${statusFilter=='REJECTED'?'btn-danger':'btn-outline-danger'}">
      <i class="bi bi-x-circle me-1"></i>Rejected <span class="badge bg-dark ms-1">${counts['REJECTED']!=null?counts['REJECTED']:0}</span>
    </a>
    <a href="?status=DRAFT" class="btn ${statusFilter=='DRAFT'?'btn-secondary':'btn-outline-secondary'}">
      <i class="bi bi-pencil me-1"></i>Draft <span class="badge bg-dark ms-1">${counts['DRAFT']!=null?counts['DRAFT']:0}</span>
    </a>
  </div>

  <c:choose>
    <c:when test="${empty courses}">
      <div class="text-center text-muted py-5">
        <i class="bi bi-patch-check fs-1 opacity-25 d-block mb-2"></i>No ${statusFilter} courses
      </div>
    </c:when>
    <c:otherwise>
      <div class="row g-3">
        <c:forEach var="c" items="${courses}">
          <div class="col-lg-6">
            <div class="card border-0 shadow-sm h-100">
              <div class="card-body">
                <div class="d-flex justify-content-between mb-2">
                  <h6 class="fw-bold mb-0">${c.title}</h6>
                  <c:choose>
                    <c:when test="${c.status=='PENDING'}"><span class="badge bg-warning text-dark">Pending</span></c:when>
                    <c:when test="${c.status=='APPROVED'}"><span class="badge bg-success">Approved</span></c:when>
                    <c:when test="${c.status=='REJECTED'}"><span class="badge bg-danger">Rejected</span></c:when>
                    <c:otherwise><span class="badge bg-secondary">Draft</span></c:otherwise>
                  </c:choose>
                </div>
                <p class="text-muted small mb-2">${not empty c.description ? c.description : 'No description'}</p>
                <p class="mb-2 small"><i class="bi bi-person me-1 text-primary"></i>${c.teacherName} &nbsp;·&nbsp; <i class="bi bi-clock me-1"></i>${c.createdAt}</p>
                <c:if test="${not empty c.rejectionNote}">
                  <div class="alert alert-danger py-2 small mb-2"><i class="bi bi-exclamation-circle me-1"></i>Rejection: ${c.rejectionNote}</div>
                </c:if>
                <c:if test="${c.status=='PENDING'}">
                  <div class="d-flex gap-2 mt-2">
                    <form method="post" action="${pageContext.request.contextPath}/admin/course-approval" class="flex-grow-1">
                      <input type="hidden" name="action" value="approve">
                      <input type="hidden" name="courseId" value="${c.id}">
                      <button class="btn btn-success btn-sm w-100" onclick="return confirm('Approve this course?')">
                        <i class="bi bi-check me-1"></i>Approve
                      </button>
                    </form>
                    <button class="btn btn-danger btn-sm flex-grow-1" data-bs-toggle="modal" data-bs-target="#rejectModal${c.id}">
                      <i class="bi bi-x me-1"></i>Reject
                    </button>
                  </div>
                </c:if>
              </div>
            </div>
          </div>

          <!-- Reject Modal -->
          <div class="modal fade" id="rejectModal${c.id}" tabindex="-1">
            <div class="modal-dialog"><div class="modal-content">
              <div class="modal-header"><h5 class="modal-title">Reject Course</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
              <form method="post" action="${pageContext.request.contextPath}/admin/course-approval">
                <div class="modal-body">
                  <input type="hidden" name="action" value="reject">
                  <input type="hidden" name="courseId" value="${c.id}">
                  <p>Rejecting: <strong>${c.title}</strong></p>
                  <label class="form-label">Reason (optional)</label>
                  <textarea name="rejectionNote" class="form-control" rows="3" placeholder="Explain why this course is being rejected..."></textarea>
                </div>
                <div class="modal-footer">
                  <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                  <button class="btn btn-danger" type="submit">Reject Course</button>
                </div>
              </form>
            </div></div>
          </div>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
