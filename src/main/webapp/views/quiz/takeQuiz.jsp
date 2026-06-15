<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Take Quiz"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row justify-content-center">
  <div class="col-lg-8">
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h4 class="fw-bold mb-0"><i class="bi bi-pencil-square me-2"></i>${quiz.title}</h4>
      <div class="badge bg-warning text-dark fs-6 p-2" id="timerBadge">
        <i class="bi bi-clock me-1"></i><span id="timerDisplay">${quiz.timeLimitMinutes}:00</span>
      </div>
    </div>
    <p class="text-muted">${quiz.description}</p>

    <form action="${ctx}/quiz" method="post" id="quizForm">
      <input type="hidden" name="action" value="submit"/>
      <input type="hidden" name="quizId" value="${quiz.id}"/>

      <c:forEach var="q" items="${quiz.questions}" varStatus="s">
        <div class="card shadow-sm mb-3">
          <div class="card-body">
            <p class="fw-semibold mb-3">${s.count}. ${q.questionText} <span class="badge bg-secondary ms-1">${q.marks} mark${q.marks > 1 ? 's' : ''}</span></p>
            <div class="list-group">
              <c:forEach items="${['A','B','C','D']}" var="opt">
                <label class="list-group-item list-group-item-action">
                  <input type="radio" name="q_${q.id}" value="${opt}" class="me-2"/>
                  <strong>${opt}.</strong>
                  <c:choose>
                    <c:when test="${opt == 'A'}">${q.optionA}</c:when>
                    <c:when test="${opt == 'B'}">${q.optionB}</c:when>
                    <c:when test="${opt == 'C'}">${q.optionC}</c:when>
                    <c:when test="${opt == 'D'}">${q.optionD}</c:when>
                  </c:choose>
                </label>
              </c:forEach>
            </div>
          </div>
        </div>
      </c:forEach>

      <button type="submit" class="btn btn-success btn-lg w-100">
        <i class="bi bi-check-circle me-1"></i>Submit Quiz
      </button>
    </form>
  </div>
</div>

<script>
(function() {
  let totalSecs = ${quiz.timeLimitMinutes} * 60;
  const display = document.getElementById('timerDisplay');
  const form    = document.getElementById('quizForm');
  const tick = setInterval(function() {
    totalSecs--;
    if (totalSecs <= 0) {
      clearInterval(tick);
      form.submit();
      return;
    }
    const m = Math.floor(totalSecs / 60).toString().padStart(2, '0');
    const s = (totalSecs % 60).toString().padStart(2, '0');
    display.textContent = m + ':' + s;
    if (totalSecs <= 60) {
      document.getElementById('timerBadge').classList.replace('bg-warning', 'bg-danger');
      document.getElementById('timerBadge').classList.remove('text-dark');
    }
  }, 1000);
})();
</script>

<%@ include file="/views/base-footer.jsp" %>
