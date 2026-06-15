<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Create Quiz"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row justify-content-center">
  <div class="col-lg-8">
    <h4 class="fw-bold mb-4"><i class="bi bi-pencil-square me-2"></i>Create Quiz</h4>
    <div class="card shadow-sm">
      <div class="card-body">
        <form action="${ctx}/quiz" method="post" id="quizForm">
          <input type="hidden" name="action" value="create"/>
          <input type="hidden" name="courseId" value="${courseId}"/>

          <div class="row g-2 mb-3">
            <div class="col-sm-6">
              <label class="form-label fw-semibold">Quiz Title <span class="text-danger">*</span></label>
              <input type="text" name="title" class="form-control" required/>
            </div>
            <div class="col-sm-3">
              <label class="form-label fw-semibold">Time Limit (min)</label>
              <input type="number" name="timeLimitMinutes" class="form-control" value="30" min="1"/>
            </div>
            <div class="col-sm-3">
              <label class="form-label fw-semibold">Pass % </label>
              <input type="number" name="passPercentage" class="form-control" value="60" min="1" max="100"/>
            </div>
          </div>
          <div class="mb-4">
            <label class="form-label fw-semibold">Description</label>
            <textarea name="description" class="form-control" rows="2"></textarea>
          </div>

          <h5 class="fw-semibold mb-3">Questions</h5>
          <div id="questionsContainer"></div>

          <button type="button" class="btn btn-outline-primary mb-4" onclick="addQuestion()">
            <i class="bi bi-plus me-1"></i>Add Question
          </button>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary">
              <i class="bi bi-save me-1"></i>Create Quiz
            </button>
            <a href="javascript:history.back()" class="btn btn-outline-secondary">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<template id="questionTemplate">
  <div class="card mb-3 question-card">
    <div class="card-body">
      <div class="d-flex justify-content-between mb-2">
        <span class="fw-semibold question-label">Question</span>
        <button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest('.question-card').remove()">Remove</button>
      </div>
      <div class="mb-2">
        <input type="text" name="questionText[]" class="form-control" placeholder="Question text" required/>
      </div>
      <div class="row g-2 mb-2">
        <div class="col-sm-6"><input type="text" name="optionA[]" class="form-control form-control-sm" placeholder="Option A" required/></div>
        <div class="col-sm-6"><input type="text" name="optionB[]" class="form-control form-control-sm" placeholder="Option B" required/></div>
        <div class="col-sm-6"><input type="text" name="optionC[]" class="form-control form-control-sm" placeholder="Option C" required/></div>
        <div class="col-sm-6"><input type="text" name="optionD[]" class="form-control form-control-sm" placeholder="Option D" required/></div>
      </div>
      <div class="row g-2">
        <div class="col-sm-4">
          <label class="form-label form-label-sm">Correct Option</label>
          <select name="correctOption[]" class="form-select form-select-sm">
            <option value="A">A</option><option value="B">B</option>
            <option value="C">C</option><option value="D">D</option>
          </select>
        </div>
        <div class="col-sm-4">
          <label class="form-label form-label-sm">Marks</label>
          <input type="number" name="marks[]" class="form-control form-control-sm" value="1" min="1"/>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
let qCount = 0;
function addQuestion() {
  const tmpl = document.getElementById('questionTemplate').content.cloneNode(true);
  qCount++;
  tmpl.querySelector('.question-label').textContent = 'Question ' + qCount;
  document.getElementById('questionsContainer').appendChild(tmpl);
}
addQuestion(); // start with one question
</script>

<%@ include file="/views/base-footer.jsp" %>
