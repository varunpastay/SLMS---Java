<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="${post.title}"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row justify-content-center">
  <div class="col-lg-8">
    <a href="${ctx}/forum" class="btn btn-sm btn-outline-secondary mb-3">
      <i class="bi bi-arrow-left me-1"></i>Back to Forum
    </a>

    <!-- Original post -->
    <div class="card shadow-sm mb-4">
      <div class="card-body">
        <h4 class="card-title fw-bold">${post.title}</h4>
        <p class="text-muted small mb-3">
          <i class="bi bi-person me-1"></i>${post.authorName}
          <c:if test="${not empty post.courseTitle}"> &bull; <i class="bi bi-book me-1"></i>${post.courseTitle}</c:if>
          &bull; <fmt:formatDate value="${post.createdAt}" pattern="dd MMM yyyy HH:mm" type="date"/>
        </p>
        <p class="card-text">${post.body}</p>
        <c:if test="${user.id == post.authorId or user.role == 'ADMIN'}">
          <form action="${ctx}/forum" method="post" class="d-inline">
            <input type="hidden" name="action" value="deletePost"/>
            <input type="hidden" name="id" value="${post.id}"/>
            <button class="btn btn-sm btn-outline-danger">
              <i class="bi bi-trash me-1"></i>Delete Post
            </button>
          </form>
        </c:if>
      </div>
    </div>

    <!-- Comments -->
    <h5 class="fw-semibold mb-3"><i class="bi bi-chat me-2"></i>Comments (${post.comments.size()})</h5>
    <c:forEach var="comment" items="${post.comments}">
      <div class="card mb-2 border-start border-3 border-primary">
        <div class="card-body py-2">
          <p class="mb-1">${comment.body}</p>
          <small class="text-muted">
            <i class="bi bi-person me-1"></i>${comment.authorName}
            &bull; <fmt:formatDate value="${comment.createdAt}" pattern="dd MMM yyyy HH:mm" type="date"/>
          </small>
          <c:if test="${user.id == comment.authorId or user.role == 'ADMIN'}">
            <form action="${ctx}/forum" method="post" class="d-inline ms-2">
              <input type="hidden" name="action" value="deleteComment"/>
              <input type="hidden" name="id" value="${comment.id}"/>
              <input type="hidden" name="postId" value="${post.id}"/>
              <button class="btn btn-sm btn-link text-danger p-0">Delete</button>
            </form>
          </c:if>
        </div>
      </div>
    </c:forEach>

    <!-- Reply form -->
    <div class="card shadow-sm mt-3">
      <div class="card-body">
        <h6 class="fw-semibold mb-3">Add a Comment</h6>
        <form action="${ctx}/forum" method="post">
          <input type="hidden" name="action" value="comment"/>
          <input type="hidden" name="postId" value="${post.id}"/>
          <div class="mb-2">
            <textarea name="body" class="form-control" rows="3" placeholder="Write your comment..." required></textarea>
          </div>
          <button type="submit" class="btn btn-primary btn-sm">
            <i class="bi bi-send me-1"></i>Post Comment
          </button>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
