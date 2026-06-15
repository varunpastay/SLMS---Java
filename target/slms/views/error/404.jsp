<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/><title>404 – Page Not Found</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
</head>
<body class="bg-light d-flex align-items-center justify-content-center min-vh-100">
  <div class="text-center">
    <div class="display-1 fw-bold text-warning">404</div>
    <h4 class="fw-bold mt-2">Page Not Found</h4>
    <p class="text-muted">The page you're looking for doesn't exist.</p>
    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">Go to Dashboard</a>
  </div>
</body>
</html>
