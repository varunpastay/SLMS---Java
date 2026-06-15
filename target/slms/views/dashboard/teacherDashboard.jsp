<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Teacher Dashboard"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row mb-4">
  <div class="col-12">
    <h4 class="fw-bold">Teacher Dashboard</h4>
    <p class="text-muted">Hello ${user.firstName}, here's your teaching overview.</p>
  </div>
</div>

<div class="row g-3 mb-4">
  <div class="col-sm-6 col-lg-3">
    <div class="card border-0 shadow-sm text-center p-3">
      <i class="bi bi-collection text-primary fs-2 mb-1"></i>
      <div class="fs-3 fw-bold">${courses.size()}</div>
      <div class="text-muted small">My Courses</div>
    </div>
  </div>
  <div class="col-sm-6 col-lg-3">
    <div class="card border-0 shadow-sm text-center p-3">
      <i class="bi bi-people text-success fs-2 mb-1"></i>
      <div class="fs-3 fw-bold">${totalEnrollments}</div>
      <div class="text-muted small">Total Students</div>
    </div>
  </div>
  <div class="col-sm-6 col-lg-3">
    <div class="card border-0 shadow-sm text-center p-3">
      <i class="bi bi-hourglass-split text-warning fs-2 mb-1"></i>
      <div class="fs-3 fw-bold">${pendingGrades}</div>
      <div class="text-muted small">Pending Grades</div>
    </div>
  </div>
  <div class="col-sm-6 col-lg-3">
    <div class="card border-0 shadow-sm text-center p-3">
      <i class="bi bi-bell text-danger fs-2 mb-1"></i>
      <div class="fs-3 fw-bold">${unreadNotifications}</div>
      <div class="text-muted small">Notifications</div>
    </div>
  </div>
</div>

<div class="card shadow-sm">
  <div class="card-header d-flex justify-content-between align-items-center fw-semibold">
    <span><i class="bi bi-collection me-2"></i>My Courses</span>
    <a href="${ctx}/course/create" class="btn btn-sm btn-primary">
      <i class="bi bi-plus me-1"></i>New Course
    </a>
  </div>
  <div class="card-body p-0">
    <c:choose>
      <c:when test="${empty courses}">
        <p class="text-center text-muted py-4">You haven't created any courses yet.</p>
      </c:when>
      <c:otherwise>
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
              <tr><th>Title</th><th>Status</th><th>Students</th><th>Actions</th></tr>
            </thead>
            <tbody>
            <c:forEach var="c" items="${courses}">
              <tr>
                <td class="fw-semibold">${c.title}</td>
                <td>
                  <c:choose>
                    <c:when test="${c.published}"><span class="badge bg-success">Published</span></c:when>
                    <c:otherwise><span class="badge bg-secondary">Draft</span></c:otherwise>
                  </c:choose>
                </td>
                <td>${c.enrollmentCount}</td>
                <td>
                  <a href="${ctx}/course/detail?id=${c.id}" class="btn btn-sm btn-outline-primary me-1">View</a>
                  <a href="${ctx}/course/edit?id=${c.id}" class="btn btn-sm btn-outline-secondary">Edit</a>
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

<%@ include file="/views/base-footer.jsp" %>
