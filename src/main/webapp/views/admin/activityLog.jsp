<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Activity Log – SLMS</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/css/slms.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/views/base-header.jsp"/>

<div class="container-fluid py-4">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <div>
      <h2 class="fw-bold mb-0"><i class="bi bi-journal-text me-2 text-primary"></i>Activity Log</h2>
      <p class="text-muted mb-0">Recent platform actions</p>
    </div>
    <div class="d-flex gap-2">
      <a href="?limit=50" class="btn btn-sm ${limit==50?'btn-primary':'btn-outline-primary'}">Last 50</a>
      <a href="?limit=200" class="btn btn-sm ${limit==200?'btn-primary':'btn-outline-primary'}">Last 200</a>
    </div>
  </div>

  <div class="card shadow-sm">
    <div class="card-body p-0">
      <div class="table-responsive">
        <table class="table table-hover align-middle mb-0" id="logTable">
          <thead class="table-dark">
            <tr>
              <th>#</th>
              <th>User</th>
              <th>Action</th>
              <th>Details</th>
              <th>IP Address</th>
              <th>Time</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="log" items="${logs}" varStatus="s">
              <tr>
                <td class="text-muted">${s.count}</td>
                <td>
                  <c:choose>
                    <c:when test="${not empty log.userName}">${log.userName}</c:when>
                    <c:otherwise><span class="text-muted">System</span></c:otherwise>
                  </c:choose>
                </td>
                <td><span class="badge bg-primary-subtle text-primary">${log.action}</span></td>
                <td class="text-muted" style="max-width:300px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"
                    title="${log.details}">${log.details}</td>
                <td><code class="small">${log.ipAddress}</code></td>
                <td class="text-muted small">
                  <fmt:formatDate value="${log.createdAt}" pattern="MMM dd, yyyy HH:mm"/>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty logs}">
              <tr><td colspan="6" class="text-center text-muted py-5">No activity logs found.</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
