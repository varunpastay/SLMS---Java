<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SLMS – Login</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/slms.css"/>
</head>
<body class="bg-light">
<div class="container d-flex justify-content-center align-items-center min-vh-100">
  <div class="card shadow-lg p-4" style="width:100%;max-width:420px">
    <div class="text-center mb-4">
      <i class="bi bi-mortarboard-fill text-primary" style="font-size:3rem"></i>
      <h3 class="fw-bold mt-2">SLMS</h3>
      <p class="text-muted">Student Learning Management System</p>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger py-2"><i class="bi bi-exclamation-circle me-1"></i>${error}</div>
    </c:if>
    <c:if test="${not empty success}">
      <div class="alert alert-success py-2"><i class="bi bi-check-circle me-1"></i>${success}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/login" method="post" novalidate>
      <div class="mb-3">
        <label class="form-label fw-semibold">Email</label>
        <div class="input-group">
          <span class="input-group-text"><i class="bi bi-envelope"></i></span>
          <input type="email" name="email" class="form-control" placeholder="you@example.com" required autofocus/>
        </div>
      </div>
      <div class="mb-4">
        <label class="form-label fw-semibold">Password</label>
        <div class="input-group">
          <span class="input-group-text"><i class="bi bi-lock"></i></span>
          <input type="password" name="password" class="form-control" placeholder="••••••••" required/>
        </div>
      </div>
      <button type="submit" class="btn btn-primary w-100 py-2">
        <i class="bi bi-box-arrow-in-right me-1"></i>Login
      </button>
    </form>

    <hr/>
    <p class="text-center mb-0">
      Don't have an account?
      <a href="${pageContext.request.contextPath}/register" class="fw-semibold">Register</a>
    </p>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
