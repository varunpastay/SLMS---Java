<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="My Feedback"/>
<%@ include file="/views/base-header.jsp" %>

<h4 class="fw-bold mb-2"><i class="bi bi-star me-2"></i>Feedback Received</h4>
<p class="text-muted mb-4">Average Rating: <strong><fmt:formatNumber value="${avgRating}" maxFractionDigits="1"/> / 5</strong></p>

<c:choose>
  <c:when test="${empty feedbacks}">
    <div class="text-center text-muted py-5"><i class="bi bi-star-half fs-1 d-block mb-2"></i>No feedback received yet.</div>
  </c:when>
  <c:otherwise>
    <div class="row g-3">
      <c:forEach var="f" items="${feedbacks}">
        <div class="col-md-6">
          <div class="card shadow-sm h-100">
            <div class="card-body">
              <div class="d-flex justify-content-between mb-2">
                <span class="fw-semibold">${f.studentName}</span>
                <span class="text-warning">
                  <c:forEach begin="1" end="${f.rating}" var="i">&#9733;</c:forEach>
                  <c:forEach begin="${f.rating + 1}" end="5" var="i">&#9734;</c:forEach>
                </span>
              </div>
              <p class="text-muted small mb-1"><i class="bi bi-book me-1"></i>${f.courseTitle}</p>
              <p class="mb-0">${f.comment}</p>
            </div>
            <div class="card-footer text-muted small">
              <fmt:formatDate value="${f.createdAt}" pattern="dd MMM yyyy" type="date"/>
            </div>
          </div>
        </div>
      </c:forEach>
    </div>
  </c:otherwise>
</c:choose>

<%@ include file="/views/base-footer.jsp" %>
