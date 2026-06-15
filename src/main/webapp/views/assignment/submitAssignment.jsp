<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Submit Assignment"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row justify-content-center">
  <div class="col-lg-6">
    <h4 class="fw-bold mb-3"><i class="bi bi-upload me-2"></i>${assignment.title}</h4>
    <p class="text-muted">${assignment.description}</p>

    <c:if test="${param.success == '1'}">
      <div class="alert alert-success"><i class="bi bi-check-circle me-1"></i>Assignment submitted successfully!</div>
    </c:if>
    <c:if test="${param.error == 'already'}">
      <div class="alert alert-warning">You have already submitted this assignment.</div>
    </c:if>

    <c:choose>
      <c:when test="${not empty submission}">
        <div class="card shadow-sm mb-3">
          <div class="card-body">
            <h6 class="fw-semibold">Your Submission</h6>
            <p class="mb-1"><i class="bi bi-file-earmark me-2"></i>
              <a href="${ctx}/uploads/${submission.filePath}" target="_blank">Download submitted file</a>
            </p>
            <c:if test="${submission.graded}">
              <div class="alert alert-info mt-2 mb-0">
                <strong>Grade:</strong> ${submission.marksObtained} / ${assignment.maxMarks}<br/>
                <strong>Feedback:</strong> ${submission.feedback}
              </div>
            </c:if>
            <c:if test="${not submission.graded}">
              <span class="badge bg-warning text-dark mt-2">Pending grading</span>
            </c:if>
          </div>
        </div>
      </c:when>
      <c:otherwise>
        <div class="card shadow-sm">
          <div class="card-body">
            <form action="${ctx}/submission" method="post" enctype="multipart/form-data">
              <input type="hidden" name="assignmentId" value="${assignment.id}"/>
              <div class="mb-3">
                <label class="form-label fw-semibold">Upload your work (PDF, DOCX)</label>
                <input type="file" name="submissionFile" class="form-control" accept=".pdf,.doc,.docx" required/>
              </div>
              <button type="submit" class="btn btn-primary">
                <i class="bi bi-upload me-1"></i>Submit Assignment
              </button>
            </form>
          </div>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
