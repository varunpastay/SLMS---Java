<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/><title>403 – Access Denied</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
</head>
<body class="bg-light d-flex align-items-center justify-content-center min-vh-100">
  <div class="text-center">
    <div class="display-1 fw-bold text-danger">403</div>
    <h4 class="fw-bold mt-2">Access Denied</h4>
    <p class="text-muted">You don't have permission to view this page.</p>
    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">Go to Dashboard</a>
  </div>
</body>
</html>
