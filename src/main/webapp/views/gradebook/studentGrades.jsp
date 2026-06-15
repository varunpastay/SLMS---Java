<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Grades – SLMS</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/css/slms.css" rel="stylesheet">
</head>
<body>
<jsp:include page="/views/base-header.jsp"/>

<div class="container py-4">
  <h2 class="fw-bold mb-4"><i class="bi bi-bar-chart me-2 text-primary"></i>My Grades</h2>

  <%-- Assignment Grades --%>
  <div class="card shadow-sm mb-4">
    <div class="card-header bg-white fw-semibold"><i class="bi bi-file-earmark-text me-2"></i>Assignment Grades</div>
    <div class="table-responsive">
      <table class="table table-hover align-middle mb-0">
        <thead class="table-light">
          <tr><th>Assignment</th><th>Marks</th><th>Feedback</th><th>Submitted</th></tr>
        </thead>
        <tbody>
          <c:forEach var="sub" items="${submissions}">
            <tr>
              <td class="fw-semibold">${sub.assignmentTitle}</td>
              <td>
                <c:choose>
                  <c:when test="${sub.graded}">
                    <span class="badge bg-success-subtle text-success fs-6">${sub.marksObtained}</span>
                  </c:when>
                  <c:otherwise><span class="badge bg-warning-subtle text-warning">Pending</span></c:otherwise>
                </c:choose>
              </td>
              <td class="text-muted small">${not empty sub.feedback ? sub.feedback : '—'}</td>
              <td class="text-muted small">
                <fmt:formatDate value="${sub.submittedAt}" pattern="MMM dd, yyyy"/>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty submissions}">
            <tr><td colspan="4" class="text-center text-muted py-4">No submissions yet.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>

  <%-- Quiz Grades --%>
  <div class="card shadow-sm">
    <div class="card-header bg-white fw-semibold"><i class="bi bi-patch-question me-2"></i>Quiz Results</div>
    <div class="table-responsive">
      <table class="table table-hover align-middle mb-0">
        <thead class="table-light">
          <tr><th>Quiz</th><th>Score</th><th>Status</th><th>Attempted</th></tr>
        </thead>
        <tbody>
          <c:forEach var="att" items="${attempts}">
            <tr>
              <td class="fw-semibold">${att.quizTitle}</td>
              <td><span class="badge ${att.passed ? 'bg-success' : 'bg-danger'}">${att.score}%</span></td>
              <td>
                <c:choose>
                  <c:when test="${att.passed}"><span class="text-success fw-semibold"><i class="bi bi-check-circle me-1"></i>Passed</span></c:when>
                  <c:otherwise><span class="text-danger fw-semibold"><i class="bi bi-x-circle me-1"></i>Failed</span></c:otherwise>
                </c:choose>
              </td>
              <td class="text-muted small">
                <fmt:formatDate value="${att.attemptedAt}" pattern="MMM dd, yyyy HH:mm"/>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty attempts}">
            <tr><td colspan="4" class="text-center text-muted py-4">No quiz attempts yet.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
