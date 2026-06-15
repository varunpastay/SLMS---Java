<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Admin Dashboard"/>
<%@ include file="/views/base-header.jsp" %>

<h4 class="fw-bold mb-4"><i class="bi bi-shield-lock me-2"></i>Admin Dashboard</h4>

<div class="row g-3 mb-4">
  <div class="col-sm-4">
    <div class="card border-0 shadow-sm text-center p-3">
      <i class="bi bi-people text-primary fs-2 mb-1"></i>
      <div class="fs-3 fw-bold">${totalUsers}</div>
      <div class="text-muted small">Total Users</div>
    </div>
  </div>
  <div class="col-sm-4">
    <div class="card border-0 shadow-sm text-center p-3">
      <i class="bi bi-collection text-success fs-2 mb-1"></i>
      <div class="fs-3 fw-bold">${totalCourses}</div>
      <div class="text-muted small">Total Courses</div>
    </div>
  </div>
  <div class="col-sm-4">
    <div class="card border-0 shadow-sm text-center p-3">
      <i class="bi bi-person-check text-warning fs-2 mb-1"></i>
      <div class="fs-3 fw-bold">${totalEnrollments}</div>
      <div class="text-muted small">Total Enrollments</div>
    </div>
  </div>
</div>

<div class="card shadow-sm">
  <div class="card-header fw-semibold"><i class="bi bi-people me-2"></i>All Users</div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover align-middle mb-0">
        <thead class="table-light">
          <tr><th>#</th><th>Name</th><th>Email</th><th>Role</th><th>Joined</th><th>Status</th><th>Action</th></tr>
        </thead>
        <tbody>
        <c:forEach var="u" items="${allUsers}" varStatus="s">
          <tr>
            <td class="text-muted">${s.count}</td>
            <td class="fw-semibold">${u.firstName} ${u.lastName}</td>
            <td class="text-muted small">${u.email}</td>
            <td>
              <c:choose>
                <c:when test="${u.role == 'ADMIN'}"><span class="badge bg-danger">Admin</span></c:when>
                <c:when test="${u.role == 'TEACHER'}"><span class="badge bg-info text-dark">Teacher</span></c:when>
                <c:otherwise><span class="badge bg-primary">Student</span></c:otherwise>
              </c:choose>
            </td>
            <td class="text-muted small"><fmt:formatDate value="${u.dateJoined}" pattern="dd MMM yyyy" type="date"/></td>
            <td>
              <c:choose>
                <c:when test="${u.active}"><span class="badge bg-success">Active</span></c:when>
                <c:otherwise><span class="badge bg-secondary">Inactive</span></c:otherwise>
              </c:choose>
            </td>
            <td>
              <form action="${ctx}/admin/user/toggle" method="post" class="d-inline">
                <input type="hidden" name="id" value="${u.id}"/>
                <button class="btn btn-sm ${u.active ? 'btn-outline-warning' : 'btn-outline-success'}" type="submit">
                  ${u.active ? 'Deactivate' : 'Activate'}
                </button>
              </form>
            </td>
          </tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
