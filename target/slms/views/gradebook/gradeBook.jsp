<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Grade Book – SLMS</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/css/slms.css" rel="stylesheet">
  <style>
    .grade-cell { min-width: 80px; text-align: center; }
    .grade-badge { font-size: 0.8rem; padding: 4px 8px; border-radius: 20px; }
  </style>
</head>
<body>
<jsp:include page="/views/base-header.jsp"/>

<div class="container-fluid py-4">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <div>
      <h2 class="fw-bold mb-0"><i class="bi bi-table me-2 text-primary"></i>Grade Book</h2>
      <p class="text-muted mb-0">Student performance overview</p>
    </div>
  </div>

  <%-- Course picker --%>
  <form method="get" action="${pageContext.request.contextPath}/gradebook" class="card shadow-sm mb-4">
    <div class="card-body d-flex gap-3 align-items-end flex-wrap">
      <div class="flex-grow-1">
        <label class="form-label fw-semibold">Select Course</label>
        <select name="courseId" class="form-select" onchange="this.form.submit()">
          <option value="">— Choose a course —</option>
          <c:forEach var="c" items="${courses}">
            <option value="${c.id}" ${c.id == course.id ? 'selected' : ''}>${c.title}</option>
          </c:forEach>
        </select>
      </div>
    </div>
  </form>

  <c:if test="${not empty course}">
    <h5 class="fw-semibold mb-3">${course.title}</h5>

    <div class="card shadow-sm">
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-bordered table-hover align-middle mb-0">
            <thead class="table-dark">
              <tr>
                <th>Student</th>
                <c:forEach var="a" items="${assignments}">
                  <th class="grade-cell" title="${a.title}">
                    ${a.title.length() > 12 ? a.title.substring(0,12).concat('…') : a.title}
                    <div class="text-muted fw-normal" style="font-size:0.7rem">/${a.maxMarks}</div>
                  </th>
                </c:forEach>
                <c:forEach var="q" items="${quizzes}">
                  <th class="grade-cell" title="${q.title}">
                    ${q.title.length() > 12 ? q.title.substring(0,12).concat('…') : q.title}
                    <div class="text-muted fw-normal" style="font-size:0.7rem">Quiz%</div>
                  </th>
                </c:forEach>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="enr" items="${enrollments}">
                <tr>
                  <td class="fw-semibold">${enr.studentName}</td>
                  <c:forEach var="a" items="${assignments}">
                    <td class="grade-cell">
                      <c:set var="sub" value="${gradeGrid[enr.studentId][a.id]}"/>
                      <c:choose>
                        <c:when test="${not empty sub and sub.graded}">
                          <span class="grade-badge bg-success-subtle text-success">${sub.marksObtained}/${a.maxMarks}</span>
                        </c:when>
                        <c:when test="${not empty sub}">
                          <span class="grade-badge bg-warning-subtle text-warning">Submitted</span>
                        </c:when>
                        <c:otherwise>
                          <span class="grade-badge bg-secondary-subtle text-secondary">—</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </c:forEach>
                  <c:forEach var="q" items="${quizzes}">
                    <td class="grade-cell">
                      <c:set var="att" value="${quizGrid[enr.studentId][q.id]}"/>
                      <c:choose>
                        <c:when test="${not empty att}">
                          <span class="grade-badge ${att.passed ? 'bg-success-subtle text-success' : 'bg-danger-subtle text-danger'}">
                            ${att.score}%
                          </span>
                        </c:when>
                        <c:otherwise>
                          <span class="grade-badge bg-secondary-subtle text-secondary">—</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </c:forEach>
                </tr>
              </c:forEach>
              <c:if test="${empty enrollments}">
                <tr><td colspan="20" class="text-center text-muted py-4">No students enrolled yet.</td></tr>
              </c:if>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </c:if>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
