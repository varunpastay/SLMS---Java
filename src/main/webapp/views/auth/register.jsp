<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SLMS – Register</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"/>
</head>
<body class="bg-light">
<div class="container d-flex justify-content-center align-items-center min-vh-100 py-4">
  <div class="card shadow-lg p-4" style="width:100%;max-width:500px">
    <div class="text-center mb-3">
      <i class="bi bi-mortarboard-fill text-primary" style="font-size:2.5rem"></i>
      <h4 class="fw-bold mt-1">Create your SLMS account</h4>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger py-2">${error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/register" method="post" novalidate>
      <div class="row g-2 mb-2">
        <div class="col-6">
          <label class="form-label fw-semibold">First Name</label>
          <input type="text" name="firstName" class="form-control" required/>
        </div>
        <div class="col-6">
          <label class="form-label fw-semibold">Last Name</label>
          <input type="text" name="lastName" class="form-control"/>
        </div>
      </div>
      <div class="mb-2">
        <label class="form-label fw-semibold">Username</label>
        <input type="text" name="username" class="form-control" required/>
      </div>
      <div class="mb-2">
        <label class="form-label fw-semibold">Email</label>
        <input type="email" name="email" class="form-control" required/>
      </div>
      <div class="mb-2">
        <label class="form-label fw-semibold">Password</label>
        <input type="password" name="password" class="form-control" minlength="6" required/>
      </div>
      <div class="mb-3">
        <label class="form-label fw-semibold">Confirm Password</label>
        <input type="password" name="confirmPassword" class="form-control" required/>
      </div>
      <div class="mb-3">
        <label class="form-label fw-semibold">Register as</label>
        <select name="role" class="form-select">
          <option value="STUDENT">Student</option>
          <option value="TEACHER">Teacher</option>
        </select>
      </div>
      <button type="submit" class="btn btn-success w-100 py-2">
        <i class="bi bi-person-plus me-1"></i>Create Account
      </button>
    </form>

    <hr/>
    <p class="text-center mb-0">
      Already have an account?
      <a href="${pageContext.request.contextPath}/login" class="fw-semibold">Login</a>
    </p>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
