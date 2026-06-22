<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Announcements – SLMS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<style>
body{background:#fff8f0}
.hero{background:linear-gradient(135deg,#f97316,#dc2626);color:#fff;border-radius:16px;padding:28px 32px;margin-bottom:24px}
.announce-card{border-left:4px solid #f97316;border-radius:8px;background:#fff;padding:16px;margin-bottom:12px;box-shadow:0 1px 4px rgba(0,0,0,.06)}
.badge-all{background:#6366f1}.badge-student{background:#22c55e}.badge-teacher{background:#f59e0b}.badge-admin{background:#ef4444}
</style>
</head>
<body>
<%@ include file="/views/base-header.jsp" %>
<div class="container py-4">
  <div class="hero">
    <h2 class="mb-1"><i class="bi bi-megaphone-fill me-2"></i>Announcement Broadcast</h2>
    <p class="mb-0 opacity-75">Send system-wide announcements to students, teachers, or everyone.</p>
  </div>

  <c:if test="${not empty param.success}">
    <div class="alert alert-success alert-dismissible fade show"><i class="bi bi-check-circle me-2"></i>${param.success}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>
  </c:if>

  <div class="row g-4">
    <!-- Send Announcement -->
    <div class="col-lg-4">
      <div class="card border-0 shadow-sm">
        <div class="card-header bg-white fw-semibold"><i class="bi bi-send-fill text-warning me-2"></i>Send Announcement</div>
        <div class="card-body">
          <form method="post" action="${pageContext.request.contextPath}/admin/announcements">
            <input type="hidden" name="action" value="send">
            <div class="mb-3">
              <label class="form-label">Title</label>
              <input type="text" name="title" class="form-control" required placeholder="Announcement title">
            </div>
            <div class="mb-3">
              <label class="form-label">Message</label>
              <textarea name="message" class="form-control" rows="4" required placeholder="Write your announcement here..."></textarea>
            </div>
            <div class="mb-3">
              <label class="form-label">Send To</label>
              <select name="targetRole" class="form-select">
                <option value="ALL">Everyone</option>
                <option value="STUDENT">Students Only</option>
                <option value="TEACHER">Teachers Only</option>
                <option value="ADMIN">Admins Only</option>
              </select>
            </div>
            <button type="submit" class="btn btn-warning w-100 fw-semibold">
              <i class="bi bi-megaphone me-2"></i>Broadcast Now
            </button>
          </form>
        </div>
      </div>
    </div>

    <!-- Past Announcements -->
    <div class="col-lg-8">
      <h5 class="fw-semibold mb-3">Past Announcements <span class="badge bg-secondary">${announcements.size()}</span></h5>
      <c:choose>
        <c:when test="${empty announcements}">
          <div class="text-center text-muted py-5">
            <i class="bi bi-megaphone fs-1 opacity-25 d-block mb-2"></i>No announcements yet
          </div>
        </c:when>
        <c:otherwise>
          <c:forEach var="a" items="${announcements}">
            <div class="announce-card">
              <div class="d-flex justify-content-between align-items-start">
                <div>
                  <div class="fw-semibold">${a.title}</div>
                  <p class="mb-1 text-secondary mt-1">${a.message}</p>
                  <small class="text-muted">
                    <i class="bi bi-person me-1"></i>${a.senderName}
                    &nbsp;·&nbsp;<i class="bi bi-clock me-1"></i>${a.createdAt}
                    &nbsp;·&nbsp;<span class="badge badge-${a.targetRole.toLowerCase()}">${a.targetRole}</span>
                  </small>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/admin/announcements" class="ms-2">
                  <input type="hidden" name="action" value="delete">
                  <input type="hidden" name="id" value="${a.id}">
                  <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete this announcement?')">
                    <i class="bi bi-trash"></i>
                  </button>
                </form>
              </div>
            </div>
          </c:forEach>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
