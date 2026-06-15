<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Submissions"/>
<%@ include file="/views/base-header.jsp" %>

<h4 class="fw-bold mb-3"><i class="bi bi-inbox me-2"></i>Submissions — ${assignment.title}</h4>

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
              <tr><th>Student</th><th>Submitted At</th><th>File</th><th>Marks</th><th>Action</th></tr>
            </thead>
            <tbody>
            <c:forEach var="s" items="${submissions}">
              <tr>
                <td class="fw-semibold">${s.studentName}</td>
                <td class="small text-muted"><fmt:formatDate value="${s.submittedAt}" pattern="dd MMM yyyy HH:mm" type="date"/></td>
                <td>
                  <c:if test="${not empty s.filePath}">
                    <a href="${ctx}/uploads/${s.filePath}" target="_blank" class="btn btn-sm btn-outline-primary">Download</a>
                  </c:if>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${s.graded}">${s.marksObtained}</c:when>
                    <c:otherwise><span class="badge bg-warning text-dark">Ungraded</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <a href="${ctx}/submission?action=grade&id=${s.id}" class="btn btn-sm btn-outline-success">Grade</a>
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
