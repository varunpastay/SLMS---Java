<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Feedback"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row justify-content-center">
  <div class="col-lg-5">
    <h4 class="fw-bold mb-4"><i class="bi bi-star me-2"></i>Leave Feedback</h4>
    <div class="card shadow-sm">
      <div class="card-body">
        <p class="text-muted mb-3">Course: <strong>${course.title}</strong></p>
        <form action="${ctx}/feedback" method="post">
          <input type="hidden" name="courseId" value="${course.id}"/>
          <input type="hidden" name="teacherId" value="${course.teacherId}"/>
          <div class="mb-3">
            <label class="form-label fw-semibold">Rating</label>
            <div class="d-flex gap-2">
              <c:forEach begin="1" end="5" var="i">
                <div class="form-check">
                  <input type="radio" name="rating" value="${i}" id="r${i}" class="form-check-input" required/>
                  <label class="form-check-label" for="r${i}">${i} &#9733;</label>
                </div>
              </c:forEach>
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Comment</label>
            <textarea name="comment" class="form-control" rows="4" placeholder="Share your experience..."></textarea>
          </div>
          <button type="submit" class="btn btn-warning w-100">
            <i class="bi bi-star me-1"></i>Submit Feedback
          </button>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
