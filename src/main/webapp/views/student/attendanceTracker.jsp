<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>My Attendance – SLMS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<style>
body{background:#f0fdf4}
.hero{background:linear-gradient(135deg,#16a34a,#15803d);color:#fff;border-radius:16px;padding:28px 32px;margin-bottom:24px}
.att-bar{height:12px;border-radius:6px}
.status-PRESENT{color:#16a34a;font-weight:600}.status-ABSENT{color:#dc2626;font-weight:600}.status-LATE{color:#d97706;font-weight:600}
</style>
</head>
<body>
<%@ include file="/views/base-header.jsp" %>
<div class="container py-4">
  <div class="hero">
    <h2 class="mb-1"><i class="bi bi-person-check me-2"></i>My Attendance</h2>
    <p class="mb-0 opacity-75">Track your attendance percentage across all enrolled courses.</p>
  </div>

  <!-- Course summaries -->
  <h5 class="fw-semibold mb-3">Attendance by Course</h5>
  <c:choose>
    <c:when test="${empty coursesSummary}">
      <div class="text-center text-muted py-4">
        <i class="bi bi-calendar-x fs-1 opacity-25 d-block mb-2"></i>No attendance records found. Enroll in courses first.
      </div>
    </c:when>
    <c:otherwise>
      <div class="row g-3 mb-4">
        <c:forEach var="c" items="${coursesSummary}">
          <c:set var="pct" value="${c.pct}"/>
          <div class="col-md-6 col-lg-4">
            <a href="?courseId=${c.courseId}" class="text-decoration-none">
              <div class="card border-0 shadow-sm p-3 h-100">
                <div class="fw-semibold mb-1">${c.title}</div>
                <c:choose>
                  <c:when test="${c.pct == -1}">
                    <div class="text-muted small mb-2">No records yet</div>
                    <div class="progress att-bar mb-2"><div class="progress-bar bg-secondary" style="width:0%"></div></div>
                  </c:when>
                  <c:otherwise>
                    <div class="d-flex gap-3 small mb-2">
                      <span class="text-success"><i class="bi bi-check-circle me-1"></i>${c.present} Present</span>
                      <span class="text-danger"><i class="bi bi-x-circle me-1"></i>${c.absent} Absent</span>
                    </div>
                    <div class="progress mb-2" style="height:10px">
                      <div class="progress-bar ${c.pct >= 75 ? 'bg-success' : c.pct >= 50 ? 'bg-warning' : 'bg-danger'}" style="width:${c.pct}%"></div>
                    </div>
                    <div class="d-flex justify-content-between">
                      <small class="text-muted">${c.total} classes</small>
                      <span class="badge ${c.pct >= 75 ? 'bg-success' : c.pct >= 50 ? 'bg-warning text-dark' : 'bg-danger'}">${c.pct}%</span>
                    </div>
                  </c:otherwise>
                </c:choose>
              </div>
            </a>
          </div>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>

  <!-- Attendance Records -->
  <c:if test="${not empty records}">
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h5 class="fw-semibold mb-0">Recent Records ${not empty selectedCourse ? '(Filtered)' : ''}</h5>
      <c:if test="${not empty selectedCourse}">
        <a href="${pageContext.request.contextPath}/my-attendance" class="btn btn-sm btn-outline-secondary">Clear Filter</a>
      </c:if>
    </div>
    <div class="card border-0 shadow-sm">
      <div class="table-responsive">
        <table class="table mb-0">
          <thead class="table-light"><tr><th>Date</th><th>Course</th><th>Status</th></tr></thead>
          <tbody>
            <c:forEach var="r" items="${records}">
              <tr>
                <td>${r.date}</td>
                <td>${r.course}</td>
                <td><span class="status-${r.status}">
                  <c:choose>
                    <c:when test="${r.status=='PRESENT'}"><i class="bi bi-check-circle me-1"></i>Present</c:when>
                    <c:when test="${r.status=='ABSENT'}"><i class="bi bi-x-circle me-1"></i>Absent</c:when>
                    <c:when test="${r.status=='LATE'}"><i class="bi bi-clock me-1"></i>Late</c:when>
                    <c:otherwise>${r.status}</c:otherwise>
                  </c:choose>
                </span></td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>
  </c:if>
  <c:if test="${empty records and not empty coursesSummary}">
    <p class="text-muted mt-3 small"><i class="bi bi-info-circle me-1"></i>No individual attendance records yet. Records appear once your teacher marks attendance.</p>
  </c:if>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
