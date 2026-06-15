<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quiz Result"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row justify-content-center">
  <div class="col-lg-8">
    <div class="card shadow mb-4 text-center">
      <div class="card-body py-5">
        <c:choose>
          <c:when test="${attempt.passed}">
            <i class="bi bi-patch-check-fill text-success" style="font-size:4rem"></i>
            <h3 class="fw-bold mt-2 text-success">Congratulations! You Passed!</h3>
          </c:when>
          <c:otherwise>
            <i class="bi bi-x-circle-fill text-danger" style="font-size:4rem"></i>
            <h3 class="fw-bold mt-2 text-danger">Better Luck Next Time</h3>
          </c:otherwise>
        </c:choose>
        <p class="fs-5 mt-2">Quiz: <strong>${quiz.title}</strong></p>
        <div class="display-3 fw-bold ${attempt.passed ? 'text-success' : 'text-danger'}">${attempt.score}%</div>
        <p class="text-muted">Pass threshold: ${quiz.passPercentage}%</p>
        <a href="${ctx}/courses" class="btn btn-primary mt-2">Back to Courses</a>
      </div>
    </div>

    <h5 class="fw-bold mb-3">Question Breakdown</h5>
    <c:forEach var="q" items="${questions}" varStatus="s">
      <c:set var="selected" value="${answers[q.id]}"/>
      <c:set var="correct" value="${q.correctOption}"/>
      <div class="card mb-2 border-${selected == correct ? 'success' : 'danger'}">
        <div class="card-body">
          <p class="fw-semibold mb-2">${s.count}. ${q.questionText}</p>
          <c:forEach items="${['A','B','C','D']}" var="opt">
            <div class="d-flex align-items-center mb-1">
              <c:set var="optText">
                <c:choose>
                  <c:when test="${opt == 'A'}">${q.optionA}</c:when>
                  <c:when test="${opt == 'B'}">${q.optionB}</c:when>
                  <c:when test="${opt == 'C'}">${q.optionC}</c:when>
                  <c:when test="${opt == 'D'}">${q.optionD}</c:when>
                </c:choose>
              </c:set>
              <c:choose>
                <c:when test="${opt == correct}">
                  <span class="badge bg-success me-2">${opt}</span> <span class="text-success fw-semibold">${optText}</span>
                  <i class="bi bi-check-circle-fill text-success ms-2"></i>
                </c:when>
                <c:when test="${opt == selected and selected != correct}">
                  <span class="badge bg-danger me-2">${opt}</span> <span class="text-danger">${optText}</span>
                  <i class="bi bi-x-circle-fill text-danger ms-2"></i>
                </c:when>
                <c:otherwise>
                  <span class="badge bg-light text-dark me-2">${opt}</span> <span class="text-muted">${optText}</span>
                </c:otherwise>
              </c:choose>
            </div>
          </c:forEach>
        </div>
      </div>
    </c:forEach>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
