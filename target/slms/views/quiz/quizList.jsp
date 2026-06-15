<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quizzes - ${course.title}"/>
<%@ include file="/views/base-header.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-4">
  <h4 class="fw-bold mb-0"><i class="bi bi-question-circle me-2"></i>Quizzes — ${course.title}</h4>
  <c:if test="${user.role == 'TEACHER' or user.role == 'ADMIN'}">
    <a href="${ctx}/quiz?action=create&courseId=${course.id}" class="btn btn-primary">
      <i class="bi bi-plus me-1"></i>Add Quiz
    </a>
  </c:if>
</div>

<c:choose>
  <c:when test="${empty quizzes}">
    <div class="text-center text-muted py-5">
      <i class="bi bi-question-circle fs-1 d-block mb-2"></i>No quizzes yet.
    </div>
  </c:when>
  <c:otherwise>
    <div class="row g-3">
      <c:forEach var="q" items="${quizzes}">
        <div class="col-md-6 col-lg-4">
          <div class="card shadow-sm h-100">
            <div class="card-body">
              <h6 class="fw-bold"><i class="bi bi-pencil-square me-2 text-info"></i>${q.title}</h6>
              <p class="text-muted small mb-2">${q.description}</p>
              <div class="d-flex gap-2 flex-wrap small text-muted mb-3">
                <span><i class="bi bi-clock me-1"></i>${q.timeLimitMinutes} min</span>
                <span><i class="bi bi-bar-chart me-1"></i>Pass: ${q.passPercentage}%</span>
              </div>
              <div class="d-flex gap-2">
                <c:if test="${user.role == 'STUDENT'}">
                  <a href="${ctx}/quiz?action=take&id=${q.id}" class="btn btn-sm btn-outline-info">
                    <i class="bi bi-play me-1"></i>Take Quiz
                  </a>
                </c:if>
                <c:if test="${user.role == 'TEACHER' or user.role == 'ADMIN'}">
                  <form action="${ctx}/quiz" method="post" class="d-inline"
                        onsubmit="return confirm('Delete this quiz?')">
                    <input type="hidden" name="action" value="delete"/>
                    <input type="hidden" name="id" value="${q.id}"/>
                    <button class="btn btn-sm btn-outline-danger">
                      <i class="bi bi-trash me-1"></i>Delete
                    </button>
                  </form>
                </c:if>
              </div>
            </div>
          </div>
        </div>
      </c:forEach>
    </div>
  </c:otherwise>
</c:choose>

<div class="mt-4">
  <a href="${ctx}/course/detail?id=${course.id}" class="btn btn-outline-secondary">
    <i class="bi bi-arrow-left me-1"></i>Back to Course
  </a>
</div>

<%@ include file="/views/base-footer.jsp" %>
