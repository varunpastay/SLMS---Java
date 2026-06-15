<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="${empty assignment ? 'New Assignment' : 'Edit Assignment'}"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row justify-content-center">
  <div class="col-lg-6">
    <h4 class="fw-bold mb-4">${empty assignment ? 'Create Assignment' : 'Edit Assignment'}</h4>
    <div class="card shadow-sm">
      <div class="card-body">
        <form action="${ctx}/assignment" method="post">
          <input type="hidden" name="courseId" value="${not empty assignment ? assignment.courseId : courseId}"/>
          <c:if test="${not empty assignment}">
            <input type="hidden" name="id" value="${assignment.id}"/>
          </c:if>
          <div class="mb-3">
            <label class="form-label fw-semibold">Title <span class="text-danger">*</span></label>
            <input type="text" name="title" class="form-control" value="${assignment.title}" required/>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Description</label>
            <textarea name="description" class="form-control" rows="4">${assignment.description}</textarea>
          </div>
          <div class="row g-2 mb-3">
            <div class="col-sm-6">
              <label class="form-label fw-semibold">Due Date</label>
              <input type="datetime-local" name="dueDate" class="form-control"/>
            </div>
            <div class="col-sm-6">
              <label class="form-label fw-semibold">Max Marks</label>
              <input type="number" name="maxMarks" class="form-control" value="${not empty assignment ? assignment.maxMarks : 100}" min="1"/>
            </div>
          </div>
          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary">
              <i class="bi bi-save me-1"></i>${empty assignment ? 'Create' : 'Update'}
            </button>
            <a href="javascript:history.back()" class="btn btn-outline-secondary">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
