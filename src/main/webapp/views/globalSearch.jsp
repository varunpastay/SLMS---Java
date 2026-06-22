<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Search – SLMS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<style>
body{background:#f8faff}
.hero{background:linear-gradient(135deg,#1e293b,#334155);color:#fff;border-radius:16px;padding:28px 32px;margin-bottom:24px}
.search-box{background:#fff;border-radius:12px;padding:8px;box-shadow:0 2px 20px rgba(0,0,0,.15)}
.search-box input{border:none;outline:none;font-size:1.1rem;padding:8px 4px}
.result-card{border:none;border-radius:10px;box-shadow:0 1px 6px rgba(0,0,0,.07);transition:transform .15s}
.result-card:hover{transform:translateY(-2px);box-shadow:0 4px 12px rgba(0,0,0,.12)}
.highlight{background:#fef9c3;padding:0 2px;border-radius:3px}
</style>
</head>
<body>
<%@ include file="/views/base-header.jsp" %>
<div class="container py-4">
  <div class="hero">
    <h2 class="mb-3"><i class="bi bi-search me-2"></i>Global Search</h2>
    <form method="get" action="${pageContext.request.contextPath}/search" class="search-box d-flex align-items-center">
      <i class="bi bi-search text-muted ms-2 me-2 fs-5"></i>
      <input type="text" name="q" class="form-control border-0 shadow-none" placeholder="Search courses, assignments, users..." value="${query}" autofocus style="font-size:1.05rem">
      <button type="submit" class="btn btn-primary ms-2 px-4">Search</button>
    </form>
  </div>

  <c:if test="${not empty query}">
    <div class="mb-2 text-muted small">
      Results for: <strong>${query}</strong>
      — <c:set var="total" value="${(courses!=null?courses.size():0)+(assignments!=null?assignments.size():0)+(users!=null?users.size():0)}"/>
      ${total} found
    </div>
  </c:if>

  <c:if test="${empty query}">
    <div class="text-center text-muted py-5">
      <i class="bi bi-search fs-1 opacity-25 d-block mb-2"></i>Enter a search term above
    </div>
  </c:if>

  <!-- Courses -->
  <c:if test="${not empty courses}">
    <h5 class="fw-semibold mb-3 mt-4"><i class="bi bi-book text-primary me-2"></i>Courses <span class="badge bg-primary ms-1">${courses.size()}</span></h5>
    <div class="row g-3 mb-4">
      <c:forEach var="c" items="${courses}">
        <div class="col-md-6">
          <a href="${pageContext.request.contextPath}/courses/${c.id}" class="text-decoration-none">
            <div class="card result-card p-3">
              <div class="fw-semibold text-dark">${c.title}</div>
              <div class="text-muted small mt-1">${not empty c.description ? c.description : 'No description'}</div>
            </div>
          </a>
        </div>
      </c:forEach>
    </div>
  </c:if>

  <!-- Assignments -->
  <c:if test="${not empty assignments}">
    <h5 class="fw-semibold mb-3 mt-2"><i class="bi bi-clipboard text-warning me-2"></i>Assignments <span class="badge bg-warning text-dark ms-1">${assignments.size()}</span></h5>
    <div class="row g-3 mb-4">
      <c:forEach var="a" items="${assignments}">
        <div class="col-md-6">
          <a href="${pageContext.request.contextPath}/assignments/${a.id}" class="text-decoration-none">
            <div class="card result-card p-3">
              <div class="fw-semibold text-dark">${a.title}</div>
              <div class="text-muted small mt-1"><i class="bi bi-book me-1"></i>${a.course}</div>
            </div>
          </a>
        </div>
      </c:forEach>
    </div>
  </c:if>

  <!-- Users (admin only) -->
  <c:if test="${not empty users}">
    <h5 class="fw-semibold mb-3 mt-2"><i class="bi bi-people text-success me-2"></i>Users <span class="badge bg-success ms-1">${users.size()}</span></h5>
    <div class="row g-3 mb-4">
      <c:forEach var="u" items="${users}">
        <div class="col-md-6">
          <div class="card result-card p-3">
            <div class="d-flex justify-content-between">
              <div>
                <div class="fw-semibold">${u.name}</div>
                <div class="text-muted small">${u.email}</div>
              </div>
              <span class="badge ${u.role=='ADMIN'?'bg-danger':u.role=='TEACHER'?'bg-warning text-dark':'bg-primary'}">${u.role}</span>
            </div>
          </div>
        </div>
      </c:forEach>
    </div>
  </c:if>

  <c:if test="${not empty query and empty courses and empty assignments and empty users}">
    <div class="text-center text-muted py-5">
      <i class="bi bi-emoji-frown fs-1 opacity-25 d-block mb-2"></i>
      No results found for "<strong>${query}</strong>".<br>
      <span class="small">Try different keywords or check spelling.</span>
    </div>
  </c:if>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
