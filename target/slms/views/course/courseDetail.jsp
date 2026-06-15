<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="${course.title}"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row">
  <!-- Main content -->
  <div class="col-lg-8">
    <div class="card shadow-sm mb-4">
      <c:if test="${not empty course.thumbnail}">
        <img src="${ctx}/uploads/${course.thumbnail}" class="card-img-top" style="max-height:280px;object-fit:cover" alt="thumbnail"/>
      </c:if>
      <div class="card-body">
        <h3 class="card-title fw-bold">${course.title}</h3>
        <p class="text-muted">
          <i class="bi bi-person me-1"></i>${course.teacherName}
          <c:if test="${not empty course.categoryName}">
            &bull; <span class="badge bg-secondary">${course.categoryName}</span>
          </c:if>
          &bull; <i class="bi bi-people me-1"></i>${course.enrollmentCount} students
        </p>
        <p>${course.description}</p>

        <c:if test="${not empty course.youtubeUrl}">
          <div class="ratio ratio-16x9 mb-3">
            <iframe src="${course.youtubeUrl}" allowfullscreen title="Course video"></iframe>
          </div>
        </c:if>

        <c:if test="${param.enrolled == '1'}">
          <div class="alert alert-success"><i class="bi bi-check-circle me-1"></i>Successfully enrolled!</div>
        </c:if>

        <!-- Enroll button for students -->
        <c:if test="${user.role == 'STUDENT'}">
          <c:choose>
            <c:when test="${enrolled}">
              <span class="badge bg-success fs-6 p-2"><i class="bi bi-check-circle me-1"></i>Enrolled</span>
            </c:when>
            <c:when test="${course.published}">
              <form action="${ctx}/course/enroll" method="post">
                <input type="hidden" name="courseId" value="${course.id}"/>
                <button type="submit" class="btn btn-success">
                  <i class="bi bi-plus-circle me-1"></i>Enroll Now
                </button>
              </form>
            </c:when>
          </c:choose>
        </c:if>

        <!-- Teacher actions -->
        <c:if test="${user.role == 'TEACHER' and course.teacherId == user.id or user.role == 'ADMIN'}">
          <a href="${ctx}/course/edit?id=${course.id}" class="btn btn-warning me-2">
            <i class="bi bi-pencil me-1"></i>Edit Course
          </a>
          <button class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#deleteModal">
            <i class="bi bi-trash me-1"></i>Delete
          </button>
        </c:if>
      </div>
    </div>

    <!-- Materials -->
    <div class="card shadow-sm mb-4">
      <div class="card-header fw-semibold d-flex justify-content-between align-items-center">
        <span><i class="bi bi-paperclip me-2"></i>Course Materials</span>
      </div>
      <ul class="list-group list-group-flush">
        <c:choose>
          <c:when test="${empty materials}">
            <li class="list-group-item text-muted text-center py-3">No materials uploaded yet.</li>
          </c:when>
          <c:otherwise>
            <c:forEach var="m" items="${materials}">
              <li class="list-group-item d-flex justify-content-between align-items-center">
                <span><i class="bi bi-file-earmark me-2 text-primary"></i>${m.title}</span>
                <div>
                  <span class="badge bg-light text-dark me-2">${m.materialType}</span>
                  <c:if test="${not empty m.filePath}">
                    <a href="${ctx}/uploads/${m.filePath}" class="btn btn-sm btn-outline-primary" target="_blank">Download</a>
                  </c:if>
                  <c:if test="${user.role == 'TEACHER' and course.teacherId == user.id or user.role == 'ADMIN'}">
                    <form action="${ctx}/material/delete" method="post" class="d-inline">
                      <input type="hidden" name="id" value="${m.id}"/>
                      <button class="btn btn-sm btn-outline-danger ms-1">Delete</button>
                    </form>
                  </c:if>
                </div>
              </li>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </ul>
      <c:if test="${user.role == 'TEACHER' and course.teacherId == user.id or user.role == 'ADMIN'}">
        <div class="card-footer">
          <form action="${ctx}/material/add" method="post" enctype="multipart/form-data" class="row g-2">
            <input type="hidden" name="courseId" value="${course.id}"/>
            <div class="col-sm-4"><input type="text" name="title" class="form-control form-control-sm" placeholder="Material title" required/></div>
            <div class="col-sm-3">
              <select name="materialType" class="form-select form-select-sm">
                <option value="PDF">PDF</option><option value="Video">Video</option>
                <option value="Slides">Slides</option><option value="Other">Other</option>
              </select>
            </div>
            <div class="col-sm-3"><input type="file" name="materialFile" class="form-control form-control-sm" required/></div>
            <div class="col-sm-2"><button type="submit" class="btn btn-sm btn-primary w-100">Upload</button></div>
          </form>
        </div>
      </c:if>
    </div>

    <!-- Assignments -->
    <div class="card shadow-sm mb-4">
      <div class="card-header fw-semibold d-flex justify-content-between align-items-center">
        <span><i class="bi bi-clipboard-check me-2"></i>Assignments</span>
        <c:if test="${user.role == 'TEACHER' and course.teacherId == user.id or user.role == 'ADMIN'}">
          <a href="${ctx}/assignment?action=create&courseId=${course.id}" class="btn btn-sm btn-primary">Add Assignment</a>
        </c:if>
      </div>
      <ul class="list-group list-group-flush">
        <c:choose>
          <c:when test="${empty assignments}"><li class="list-group-item text-muted text-center py-3">No assignments yet.</li></c:when>
          <c:otherwise>
            <c:forEach var="a" items="${assignments}">
              <li class="list-group-item d-flex justify-content-between align-items-center">
                <span><i class="bi bi-file-text me-2 text-warning"></i>${a.title}</span>
                <a href="${ctx}/submission?assignmentId=${a.id}" class="btn btn-sm btn-outline-secondary">
                  ${user.role == 'STUDENT' ? 'Submit' : 'View Submissions'}
                </a>
              </li>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </ul>
    </div>

    <!-- Quizzes -->
    <div class="card shadow-sm mb-4">
      <div class="card-header fw-semibold d-flex justify-content-between align-items-center">
        <span><i class="bi bi-question-circle me-2"></i>Quizzes</span>
        <c:if test="${user.role == 'TEACHER' and course.teacherId == user.id or user.role == 'ADMIN'}">
          <a href="${ctx}/quiz?action=create&courseId=${course.id}" class="btn btn-sm btn-primary">Add Quiz</a>
        </c:if>
      </div>
      <ul class="list-group list-group-flush">
        <c:choose>
          <c:when test="${empty quizzes}"><li class="list-group-item text-muted text-center py-3">No quizzes yet.</li></c:when>
          <c:otherwise>
            <c:forEach var="q" items="${quizzes}">
              <li class="list-group-item d-flex justify-content-between align-items-center">
                <span><i class="bi bi-pencil-square me-2 text-info"></i>${q.title}</span>
                <c:if test="${user.role == 'STUDENT' and enrolled}">
                  <a href="${ctx}/quiz?action=take&id=${q.id}" class="btn btn-sm btn-outline-info">Take Quiz</a>
                </c:if>
              </li>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </ul>
    </div>

    <!-- Feedback -->
    <c:if test="${user.role == 'STUDENT' and enrolled}">
      <div class="card shadow-sm mb-4">
        <div class="card-header fw-semibold"><i class="bi bi-star me-2"></i>Leave Feedback</div>
        <div class="card-body">
          <c:choose>
            <c:when test="${not empty myFeedback}">
              <p class="mb-1">Your rating: ${'&#9733;'.repeat(myFeedback.rating)}</p>
              <p class="text-muted">${myFeedback.comment}</p>
            </c:when>
            <c:otherwise>
              <form action="${ctx}/feedback" method="post">
                <input type="hidden" name="courseId" value="${course.id}"/>
                <input type="hidden" name="teacherId" value="${course.teacherId}"/>
                <div class="mb-2">
                  <label class="form-label">Rating</label>
                  <select name="rating" class="form-select form-select-sm w-auto">
                    <option value="5">5 – Excellent</option>
                    <option value="4">4 – Good</option>
                    <option value="3">3 – Average</option>
                    <option value="2">2 – Poor</option>
                    <option value="1">1 – Very Poor</option>
                  </select>
                </div>
                <div class="mb-2">
                  <textarea name="comment" class="form-control form-control-sm" rows="2" placeholder="Comments..."></textarea>
                </div>
                <button type="submit" class="btn btn-sm btn-warning">Submit Feedback</button>
              </form>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </c:if>
  </div>

  <!-- Sidebar -->
  <div class="col-lg-4">
    <div class="card shadow-sm mb-3">
      <div class="card-body text-center">
        <div class="fs-4 fw-bold text-primary">${course.enrollmentCount}</div>
        <div class="text-muted small">Students Enrolled</div>
      </div>
    </div>
    <div class="card shadow-sm">
      <div class="card-header fw-semibold">Course Info</div>
      <ul class="list-group list-group-flush">
        <li class="list-group-item"><i class="bi bi-person me-2 text-primary"></i><strong>Instructor:</strong> ${course.teacherName}</li>
        <li class="list-group-item"><i class="bi bi-tag me-2 text-secondary"></i><strong>Category:</strong> ${course.categoryName}</li>
        <li class="list-group-item">
          <i class="bi bi-circle-fill me-2 ${course.published ? 'text-success' : 'text-secondary'}"></i>
          <strong>Status:</strong> ${course.published ? 'Published' : 'Draft'}
        </li>
        <li class="list-group-item"><i class="bi bi-clipboard-check me-2 text-warning"></i><strong>Assignments:</strong> ${assignments.size()}</li>
        <li class="list-group-item"><i class="bi bi-question-circle me-2 text-info"></i><strong>Quizzes:</strong> ${quizzes.size()}</li>
      </ul>
    </div>
  </div>
</div>

<!-- Delete confirmation modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">Confirm Delete</h5></div>
      <div class="modal-body">Are you sure you want to delete <strong>${course.title}</strong>? This action cannot be undone.</div>
      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
        <form action="${ctx}/course/delete" method="post" class="d-inline">
          <input type="hidden" name="id" value="${course.id}"/>
          <button type="submit" class="btn btn-danger">Delete</button>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
