<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Assignments"/>
<%@ include file="/views/base-header.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-4">
  <h4 class="fw-bold mb-0"><i class="bi bi-clipboard-check me-2"></i>Assignments — ${course.title}</h4>
  <c:if test="${user.role == 'TEACHER' or user.role == 'ADMIN'}">
    <a href="${ctx}/assignment?action=create&courseId=${course.id}" class="btn btn-primary">
      <i class="bi bi-plus me-1"></i>Add Assignment
    </a>
  </c:if>
</div>

<div class="card shadow-sm">
  <div class="card-body p-0">
    <c:choose>
      <c:when test="${empty assignments}">
        <p class="text-center text-muted py-5">No assignments yet.</p>
      </c:when>
      <c:otherwise>
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
              <tr><th>Title</th><th>Due Date</th><th>Max Marks</th><th>Actions</th></tr>
            </thead>
            <tbody>
            <c:forEach var="a" items="${assignments}">
              <tr>
                <td class="fw-semibold">${a.title}</td>
                <td class="text-muted small">
                  <c:if test="${not empty a.dueDate}"><fmt:formatDate value="${a.dueDate}" pattern="dd MMM yyyy HH:mm" type="date"/></c:if>
                </td>
                <td>${a.maxMarks}</td>
                <td>
                  <c:if test="${user.role == 'STUDENT'}">
                    <a href="${ctx}/submission?assignmentId=${a.id}" class="btn btn-sm btn-outline-primary">Submit</a>
                  </c:if>
                  <c:if test="${user.role == 'TEACHER' or user.role == 'ADMIN'}">
                    <a href="${ctx}/submission?action=view&assignmentId=${a.id}" class="btn btn-sm btn-outline-secondary me-1">Submissions</a>
                    <form action="${ctx}/assignment" method="post" class="d-inline">
                      <input type="hidden" name="action" value="delete"/>
                      <input type="hidden" name="id" value="${a.id}"/>
                      <button class="btn btn-sm btn-outline-danger">Delete</button>
                    </form>
                  </c:if>
                </td>
              </tr>
            </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
