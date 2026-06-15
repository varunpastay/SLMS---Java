<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Password – SLMS</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/css/slms.css" rel="stylesheet">
  <style>
    body { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #0f1b35 0%, #1a3a6b 50%, #0f1b35 100%); }
    .auth-card { background: rgba(255,255,255,0.05); backdrop-filter: blur(20px); border: 1px solid rgba(255,255,255,0.15); border-radius: 20px; padding: 2.5rem; width: 100%; max-width: 440px; box-shadow: 0 25px 50px rgba(0,0,0,0.4); }
    .auth-logo { font-size: 2.5rem; font-weight: 800; background: linear-gradient(135deg, #60a5fa, #a78bfa); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
    .form-control { background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.2); color: #fff; border-radius: 10px; padding: 0.75rem 1rem; }
    .form-control:focus { background: rgba(255,255,255,0.12); border-color: #60a5fa; box-shadow: 0 0 0 3px rgba(96,165,250,0.2); color: #fff; }
    .btn-primary { background: linear-gradient(135deg, #3b82f6, #6366f1); border: none; border-radius: 10px; padding: 0.75rem; font-weight: 600; }
    .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(59,130,246,0.4); }
    label { color: rgba(255,255,255,0.8); font-size: 0.875rem; }
  </style>
</head>
<body>
<div class="auth-card animate__animated animate__fadeInUp">
  <div class="auth-logo text-center mb-2">SLMS</div>
  <h5 class="text-white text-center mb-4">Set a New Password</h5>

  <c:if test="${not empty error}">
    <div class="alert alert-danger"><i class="bi bi-exclamation-triangle me-2"></i>${error}</div>
  </c:if>

  <c:choose>
    <c:when test="${not empty token}">
      <form method="post" action="${pageContext.request.contextPath}/reset-password">
        <input type="hidden" name="token" value="${token}">
        <div class="mb-3">
          <label>New Password</label>
          <input type="password" name="newPassword" class="form-control mt-1" placeholder="At least 6 characters" required minlength="6">
        </div>
        <div class="mb-3">
          <label>Confirm Password</label>
          <input type="password" name="confirmPassword" class="form-control mt-1" placeholder="Repeat new password" required>
        </div>
        <button type="submit" class="btn btn-primary w-100">
          <i class="bi bi-lock me-2"></i>Reset Password
        </button>
      </form>
    </c:when>
    <c:otherwise>
      <div class="text-center mt-3">
        <a href="${pageContext.request.contextPath}/forgot-password" class="text-info">
          <i class="bi bi-arrow-left me-1"></i>Request a new reset link
        </a>
      </div>
    </c:otherwise>
  </c:choose>
</div>
</body>
</html>
