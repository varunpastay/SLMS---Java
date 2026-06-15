<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="${empty course ? 'New Course' : 'Edit Course'}"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row justify-content-center">
  <div class="col-lg-7">
    <h4 class="fw-bold mb-4">
      <i class="bi bi-collection me-2"></i>${empty course ? 'Create New Course' : 'Edit Course'}
    </h4>

    <c:if test="${not empty error}">
      <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="card shadow-sm">
      <div class="card-body">
        <form action="${ctx}/${empty course ? 'course/create' : 'course/edit'}" method="post" enctype="multipart/form-data">
          <c:if test="${not empty course}">
            <input type="hidden" name="id" value="${course.id}"/>
          </c:if>

          <div class="mb-3">
            <label class="form-label fw-semibold">Course Title <span class="text-danger">*</span></label>
            <input type="text" name="title" class="form-control" value="${course.title}" required/>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Description</label>
            <textarea name="description" class="form-control" rows="4">${course.description}</textarea>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Category</label>
            <select name="categoryId" class="form-select">
              <option value="">-- Select Category --</option>
              <c:forEach var="cat" items="${categories}">
                <option value="${cat.id}" ${course.categoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
              </c:forEach>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Thumbnail Image</label>
            <input type="file" name="thumbnail" class="form-control" accept="image/*"/>
            <c:if test="${not empty course.thumbnail}">
              <img src="${ctx}/uploads/${course.thumbnail}" class="mt-2 rounded" style="max-width:200px" alt="current"/>
            </c:if>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">YouTube Embed URL</label>
            <input type="url" name="youtubeUrl" class="form-control" value="${course.youtubeUrl}" placeholder="https://www.youtube.com/embed/..."/>
          </div>
          <div class="mb-3 form-check">
            <input type="checkbox" name="isPublished" class="form-check-input" id="published" ${course.published ? 'checked' : ''}/>
            <label class="form-check-label fw-semibold" for="published">Publish Course</label>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary">
              <i class="bi bi-save me-1"></i>${empty course ? 'Create Course' : 'Save Changes'}
            </button>
            <a href="${ctx}/courses" class="btn btn-outline-secondary">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
