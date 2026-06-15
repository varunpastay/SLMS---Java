<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Forum"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row">
  <div class="col-lg-8">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h4 class="fw-bold mb-0"><i class="bi bi-chat-square-text me-2"></i>
        Forum${not empty filterCourse ? ' — '.concat(filterCourse.title) : ''}
      </h4>
      <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#newPostModal">
        <i class="bi bi-plus me-1"></i>New Post
      </button>
    </div>

    <c:choose>
      <c:when test="${empty posts}">
        <div class="text-center text-muted py-5">
          <i class="bi bi-chat-square fs-1 d-block mb-2"></i>No posts yet. Be the first to post!
        </div>
      </c:when>
      <c:otherwise>
        <div class="list-group shadow-sm">
          <c:forEach var="post" items="${posts}">
            <a href="${ctx}/forum?action=post&id=${post.id}" class="list-group-item list-group-item-action">
              <div class="d-flex justify-content-between align-items-start">
                <div>
                  <h6 class="fw-bold mb-1">${post.title}</h6>
                  <p class="text-muted small mb-1">${post.body.length() > 120 ? post.body.substring(0,120).concat('...') : post.body}</p>
                  <small class="text-muted">
                    <i class="bi bi-person me-1"></i>${post.authorName}
                    <c:if test="${not empty post.courseTitle}"> &bull; <i class="bi bi-book me-1"></i>${post.courseTitle}</c:if>
                  </small>
                </div>
                <div class="text-end">
                  <span class="badge bg-light text-dark">
                    <i class="bi bi-chat me-1"></i>${post.commentCount}
                  </span>
                  <div class="text-muted small mt-1">
                    <fmt:formatDate value="${post.createdAt}" pattern="dd MMM" type="date"/>
                  </div>
                </div>
              </div>
            </a>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <div class="col-lg-4">
    <div class="card shadow-sm">
      <div class="card-header fw-semibold">Filter by Course</div>
      <div class="list-group list-group-flush">
        <a href="${ctx}/forum" class="list-group-item list-group-item-action ${empty filterCourse ? 'active' : ''}">All Discussions</a>
        <c:forEach var="c" items="${courses}">
          <a href="${ctx}/forum?courseId=${c.id}" class="list-group-item list-group-item-action ${filterCourse.id == c.id ? 'active' : ''}">${c.title}</a>
        </c:forEach>
      </div>
    </div>
  </div>
</div>

<!-- New Post Modal -->
<div class="modal fade" id="newPostModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">New Forum Post</h5></div>
      <form action="${ctx}/forum" method="post">
        <div class="modal-body">
          <div class="mb-2">
            <label class="form-label">Title <span class="text-danger">*</span></label>
            <input type="text" name="title" class="form-control" required/>
          </div>
          <div class="mb-2">
            <label class="form-label">Body <span class="text-danger">*</span></label>
            <textarea name="body" class="form-control" rows="5" required></textarea>
          </div>
          <div>
            <label class="form-label">Course (optional)</label>
            <select name="courseId" class="form-select">
              <option value="">General</option>
              <c:forEach var="c" items="${courses}">
                <option value="${c.id}">${c.title}</option>
              </c:forEach>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-primary">Post</button>
        </div>
      </form>
    </div>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
