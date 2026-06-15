<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Student Dashboard"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row mb-4">
  <div class="col-12">
    <h4 class="fw-bold">Welcome back, ${user.firstName}! <span class="fs-5 text-muted">&#128075;</span></h4>
    <p class="text-muted mb-0">Here's an overview of your learning progress.</p>
  </div>
</div>

<!-- Stats row -->
<div class="row g-3 mb-4">
  <div class="col-sm-6 col-lg-3">
    <div class="card border-0 shadow-sm h-100 text-center p-3">
      <i class="bi bi-book text-primary fs-2 mb-1"></i>
      <div class="fs-3 fw-bold">${enrollments.size()}</div>
      <div class="text-muted small">Enrolled Courses</div>
    </div>
  </div>
  <div class="col-sm-6 col-lg-3">
    <div class="card border-0 shadow-sm h-100 text-center p-3">
      <i class="bi bi-bell text-warning fs-2 mb-1"></i>
      <div class="fs-3 fw-bold">${unreadNotifications}</div>
      <div class="text-muted small">Unread Notifications</div>
    </div>
  </div>
  <div class="col-sm-6 col-lg-3">
    <div class="card border-0 shadow-sm h-100 text-center p-3">
      <i class="bi bi-trophy text-success fs-2 mb-1"></i>
      <div class="fs-3 fw-bold">#${leaderboardRank}</div>
      <div class="text-muted small">Leaderboard Rank</div>
    </div>
  </div>
  <div class="col-sm-6 col-lg-3">
    <div class="card border-0 shadow-sm h-100 text-center p-3">
      <i class="bi bi-check2-circle text-info fs-2 mb-1"></i>
      <div class="fs-3 fw-bold">
        <c:set var="completed" value="0"/>
        <c:forEach var="e" items="${enrollments}">
          <c:if test="${e.completed}"><c:set var="completed" value="${completed + 1}"/></c:if>
        </c:forEach>
        ${completed}
      </div>
      <div class="text-muted small">Completed Courses</div>
    </div>
  </div>
</div>

<!-- Enrolled courses -->
<div class="card shadow-sm mb-4">
  <div class="card-header d-flex justify-content-between align-items-center fw-semibold">
    <span><i class="bi bi-journals me-2"></i>My Courses</span>
    <a href="${ctx}/courses" class="btn btn-sm btn-outline-primary">Browse More</a>
  </div>
  <div class="card-body p-0">
    <c:choose>
      <c:when test="${empty enrollments}">
        <p class="text-center text-muted py-4">You haven't enrolled in any courses yet.
          <a href="${ctx}/courses">Browse courses &rarr;</a>
        </p>
      </c:when>
      <c:otherwise>
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light"><tr>
              <th>Course</th><th>Enrolled</th><th>Status</th><th></th>
            </tr></thead>
            <tbody>
            <c:forEach var="e" items="${enrollments}">
              <tr>
                <td class="fw-semibold">${e.courseTitle}</td>
                <td class="text-muted small"><fmt:formatDate value="${e.enrolledAt}" pattern="dd MMM yyyy" type="date"/></td>
                <td>
                  <c:choose>
                    <c:when test="${e.completed}">
                      <span class="badge bg-success">Completed</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-primary">In Progress</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td><a href="${ctx}/course/detail?id=${e.courseId}" class="btn btn-sm btn-outline-secondary">Go to Course</a></td>
              </tr>
            </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<!-- Recent notifications -->
<div class="card shadow-sm">
  <div class="card-header d-flex justify-content-between align-items-center fw-semibold">
    <span><i class="bi bi-bell me-2"></i>Recent Notifications</span>
    <a href="${ctx}/notifications" class="btn btn-sm btn-outline-secondary">View All</a>
  </div>
  <div class="list-group list-group-flush">
    <c:choose>
      <c:when test="${empty notifications}">
        <div class="list-group-item text-muted text-center py-3">No notifications.</div>
      </c:when>
      <c:otherwise>
        <c:forEach var="n" items="${notifications}" varStatus="s">
          <c:if test="${s.index < 5}">
            <div class="list-group-item ${not n.read ? 'bg-light fw-semibold' : ''}">
              <i class="bi bi-dot text-primary me-1"></i>${n.message}
              <div class="text-muted small"><fmt:formatDate value="${n.createdAt}" pattern="dd MMM yyyy HH:mm" type="date"/></div>
            </div>
          </c:if>
        </c:forEach>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
