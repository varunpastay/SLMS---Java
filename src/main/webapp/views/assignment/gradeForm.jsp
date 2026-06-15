<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Grade Submission"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row justify-content-center">
  <div class="col-lg-6">
    <h4 class="fw-bold mb-4"><i class="bi bi-check2-square me-2"></i>Grade Submission</h4>
    <div class="card shadow-sm mb-3">
      <div class="card-body">
        <p class="mb-1"><strong>Student:</strong> ${submission.studentName}</p>
        <p class="mb-2"><strong>Assignment:</strong> ${submission.assignmentTitle}</p>
        <c:if test="${not empty submission.filePath}">
          <a href="${ctx}/uploads/${submission.filePath}" target="_blank" class="btn btn-sm btn-outline-primary">
            <i class="bi bi-download me-1"></i>Download Submission
          </a>
        </c:if>
      </div>
    </div>
    <div class="card shadow-sm">
      <div class="card-body">
        <form action="${ctx}/submission" method="post">
          <input type="hidden" name="action" value="grade"/>
          <input type="hidden" name="id" value="${submission.id}"/>
          <div class="mb-3">
            <label class="form-label fw-semibold">Marks Obtained</label>
            <input type="number" name="marks" class="form-control" step="0.01" min="0"
                   value="${submission.marksObtained}" required/>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Feedback</label>
            <textarea name="feedback" class="form-control" rows="4">${submission.feedback}</textarea>
          </div>
          <button type="submit" class="btn btn-success">
            <i class="bi bi-check-circle me-1"></i>Save Grade
          </button>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
