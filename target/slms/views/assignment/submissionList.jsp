<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Submissions"/>
<%@ include file="/views/base-header.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-4">
  <h4 class="fw-bold mb-0"><i class="bi bi-inbox me-2"></i>Submissions — ${assignment.title}</h4>
  <div class="d-flex align-items-center gap-3">
    <span class="text-muted small">Max Marks: <strong>${assignment.maxMarks}</strong></span>
    <a href="${ctx}/course/detail?id=${assignment.courseId}" class="btn btn-sm btn-outline-secondary">
      <i class="bi bi-arrow-left me-1"></i>Back to Course
    </a>
  </div>
</div>

<div class="card shadow-sm">
  <div class="card-body p-0">
    <c:choose>
      <c:when test="${empty submissions}">
        <p class="text-center text-muted py-5">No submissions yet.</p>
      </c:when>
      <c:otherwise>
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
              <tr>
                <th>Student</th>
                <th>Submitted At</th>
                <th>File</th>
                <th>Marks / ${assignment.maxMarks}</th>
                <th>Feedback</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
            <c:forEach var="s" items="${submissions}">
              <tr>
                <td class="fw-semibold">${s.studentName}</td>
                <td class="small text-muted">
                  <fmt:formatDate value="${s.submittedAt}" pattern="dd MMM yyyy HH:mm"/>
                </td>
                <td>
                  <c:if test="${not empty s.filePath}">
                    <a href="${ctx}/uploads/${s.filePath}" target="_blank" class="btn btn-sm btn-outline-primary">
                      <i class="bi bi-download me-1"></i>Download
                    </a>
                  </c:if>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${s.graded}">
                      <span class="fw-bold text-success">${s.marksObtained}</span>
                      <span class="text-muted">/ ${assignment.maxMarks}</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge bg-warning text-dark">Ungraded</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="small text-muted" style="max-width:200px">
                  <c:if test="${not empty s.feedback}">${s.feedback}</c:if>
                </td>
                <td>
                  <a href="${ctx}/submission?action=grade&id=${s.id}" class="btn btn-sm btn-outline-success">
                    <i class="bi bi-pencil me-1"></i>${s.graded ? 'Re-grade' : 'Grade'}
                  </a>
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
