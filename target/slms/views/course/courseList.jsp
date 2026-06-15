<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Courses"/>
<%@ include file="/views/base-header.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-4">
  <h4 class="fw-bold mb-0"><i class="bi bi-book me-2"></i>Courses</h4>
  <c:if test="${user.role == 'TEACHER' or user.role == 'ADMIN'}">
    <a href="${ctx}/course/create" class="btn btn-primary">
      <i class="bi bi-plus me-1"></i>New Course
    </a>
  </c:if>
</div>

<!-- Search / filter bar -->
<div class="card shadow-sm mb-4">
  <div class="card-body">
    <form method="get" action="${ctx}/courses" class="row g-2 align-items-end">
      <div class="col-sm-6">
        <input type="text" name="q" class="form-control" placeholder="Search courses..." value="${param.q}"/>
      </div>
      <div class="col-sm-4">
        <select name="category" class="form-select">
          <option value="">All Categories</option>
          <c:forEach var="cat" items="${categories}">
            <option value="${cat.id}" ${param.category == cat.id ? 'selected' : ''}>${cat.name}</option>
          </c:forEach>
        </select>
      </div>
      <div class="col-sm-2">
        <button type="submit" class="btn btn-outline-primary w-100">
          <i class="bi bi-search"></i> Filter
        </button>
      </div>
    </form>
  </div>
</div>

<c:choose>
  <c:when test="${empty courses}">
    <div class="text-center py-5 text-muted">
      <i class="bi bi-search fs-1 d-block mb-2"></i>
      No courses found.
    </div>
  </c:when>
  <c:otherwise>
    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
      <c:forEach var="course" items="${courses}">
        <div class="col">
          <div class="card h-100 shadow-sm">
            <c:choose>
              <c:when test="${not empty course.thumbnail}">
                <img src="${ctx}/uploads/${course.thumbnail}" class="card-img-top" style="height:160px;object-fit:cover" alt="thumbnail"/>
              </c:when>
              <c:otherwise>
                <div class="card-img-top bg-primary bg-opacity-10 d-flex align-items-center justify-content-center" style="height:160px">
                  <i class="bi bi-book text-primary" style="font-size:3rem"></i>
                </div>
              </c:otherwise>
            </c:choose>
            <div class="card-body d-flex flex-column">
              <h6 class="card-title fw-bold">${course.title}</h6>
              <p class="card-text text-muted small flex-grow-1">
                ${course.description.length() > 100 ? course.description.substring(0,100).concat('...') : course.description}
              </p>
              <div class="d-flex justify-content-between align-items-center mt-2">
                <small class="text-muted">
                  <i class="bi bi-people me-1"></i>${course.enrollmentCount} students
                </small>
                <c:if test="${not empty course.categoryName}">
                  <span class="badge bg-secondary">${course.categoryName}</span>
                </c:if>
              </div>
            </div>
            <div class="card-footer bg-transparent border-top-0">
              <a href="${ctx}/course/detail?id=${course.id}" class="btn btn-outline-primary btn-sm w-100">
                View Course
              </a>
            </div>
          </div>
        </div>
      </c:forEach>
    </div>
  </c:otherwise>
</c:choose>

<%@ include file="/views/base-footer.jsp" %>
