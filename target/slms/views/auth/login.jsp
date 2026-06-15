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
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/slms.css"/>
  <style>
    body {
      min-height: 100vh;
      background: linear-gradient(135deg, #0f1b35 0%, #1e3a6e 50%, #312e81 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 1rem;
      overflow: hidden;
      position: relative;
    }

    /* Floating orbs */
    body::before, body::after {
      content: '';
      position: fixed;
      border-radius: 50%;
      filter: blur(80px);
      z-index: 0;
      animation: floatOrb 10s ease-in-out infinite alternate;
    }
    body::before {
      width: 400px; height: 400px;
      background: rgba(96,165,250,.15);
      top: -100px; left: -100px;
    }
    body::after {
      width: 350px; height: 350px;
      background: rgba(167,139,250,.12);
      bottom: -80px; right: -80px;
      animation-direction: alternate-reverse;
    }
    @keyframes floatOrb {
      from { transform: translate(0,0) scale(1); }
      to   { transform: translate(30px,20px) scale(1.1); }
    }

    .auth-wrap {
      display: flex;
      width: 100%;
      max-width: 900px;
      border-radius: 24px;
      overflow: hidden;
      box-shadow: 0 30px 80px rgba(0,0,0,.5);
      position: relative;
      z-index: 1;
    }

    /* Left panel — branding */
    .auth-brand {
      flex: 1;
      background: linear-gradient(160deg, rgba(255,255,255,.06) 0%, rgba(255,255,255,.02) 100%);
      backdrop-filter: blur(16px);
      border: 1px solid rgba(255,255,255,.12);
      border-right: none;
      padding: 3rem;
      display: flex;
      flex-direction: column;
      justify-content: center;
      color: #fff;
    }
    .auth-brand .logo-icon {
      font-size: 3.5rem;
      background: linear-gradient(135deg, #60a5fa, #a78bfa);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      margin-bottom: 1.5rem;
    }
    .auth-brand h1 {
      font-size: 2.2rem;
      font-weight: 800;
      margin-bottom: 0.75rem;
      background: linear-gradient(135deg, #e0f2fe, #e9d5ff);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }
    .auth-brand p { color: rgba(255,255,255,.65); font-size: 0.95rem; line-height: 1.7; }
    .feature-list { list-style: none; padding: 0; margin: 1.5rem 0 0; }
    .feature-list li { color: rgba(255,255,255,.7); font-size: 0.875rem; padding: 0.4rem 0; display: flex; align-items: center; gap: 0.5rem; }
    .feature-list li i { color: #60a5fa; }

    /* Right panel — form */
    .auth-form-panel {
      width: 380px;
      background: rgba(255,255,255,.97);
      padding: 2.5rem;
      display: flex;
      flex-direction: column;
      justify-content: center;
    }
    .auth-form-panel h2 { font-weight: 800; font-size: 1.5rem; color: #0f172a; margin-bottom: 0.25rem; }
    .auth-form-panel .sub { color: #64748b; font-size: 0.875rem; margin-bottom: 1.75rem; }

    .auth-form-panel .form-control {
      background: #f8fafc;
      border: 1.5px solid #e2e8f0;
    }
    .auth-form-panel .form-control:focus {
      background: #fff;
    }
    .auth-form-panel .input-group-text {
      background: #f8fafc;
      border: 1.5px solid #e2e8f0;
      color: #64748b;
    }
    .auth-form-panel .input-group .form-control { color: #0f172a; }

    .btn-auth {
      background: linear-gradient(135deg, #3b82f6, #6366f1);
      border: none;
      color: #fff;
      font-weight: 700;
      padding: 0.75rem;
      border-radius: 12px;
      font-size: 0.95rem;
      transition: all 0.2s;
      position: relative;
      overflow: hidden;
    }
    .btn-auth:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(59,130,246,.4); color:#fff; }
    .btn-auth:active { transform: scale(0.98); }

    @media (max-width: 680px) {
      .auth-brand { display: none; }
      .auth-form-panel { width: 100%; border-radius: 24px; }
      .auth-wrap { border-radius: 24px; }
    }

    /* msg=passwordReset param */
    .msg-banner {
      background: #ecfdf5;
      border-left: 4px solid #10b981;
      border-radius: 8px;
      padding: 0.75rem 1rem;
      color: #065f46;
      font-size: 0.875rem;
      margin-bottom: 1rem;
    }
  </style>
</head>
<body>

<div class="auth-wrap">
  <!-- Branding panel -->
  <div class="auth-brand">
    <div class="logo-icon"><i class="bi bi-mortarboard-fill"></i></div>
    <h1>SLMS</h1>
    <p>Your complete Student Learning Management System. Learn, grow, and achieve more.</p>
    <ul class="feature-list">
      <li><i class="bi bi-check-circle-fill"></i>Interactive courses & assignments</li>
      <li><i class="bi bi-check-circle-fill"></i>Real-time quiz assessments</li>
      <li><i class="bi bi-check-circle-fill"></i>PDF certificates on completion</li>
      <li><i class="bi bi-check-circle-fill"></i>Live chat & discussion forums</li>
    </ul>
  </div>

  <!-- Form panel -->
  <div class="auth-form-panel">
    <h2>Welcome back</h2>
    <p class="sub">Sign in to your account to continue learning.</p>

    <c:if test="${param.msg == 'passwordReset'}">
      <div class="msg-banner"><i class="bi bi-check-circle me-2"></i>Password reset! You can now log in.</div>
    </c:if>
    <c:if test="${not empty error}">
      <div class="alert alert-danger py-2"><i class="bi bi-exclamation-circle me-1"></i>${error}</div>
    </c:if>
    <c:if test="${not empty success}">
      <div class="alert alert-success py-2"><i class="bi bi-check-circle me-1"></i>${success}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/login" method="post" novalidate>
      <div class="mb-3">
        <label class="form-label">Email</label>
        <div class="input-group">
          <span class="input-group-text"><i class="bi bi-envelope"></i></span>
          <input type="email" name="email" class="form-control" placeholder="you@example.com" required autofocus/>
        </div>
      </div>
      <div class="mb-1">
        <label class="form-label">Password</label>
        <div class="input-group">
          <span class="input-group-text"><i class="bi bi-lock"></i></span>
          <input type="password" name="password" id="pwdInput" class="form-control" placeholder="••••••••" required/>
          <button type="button" class="btn btn-outline-secondary border-start-0" id="pwdToggle" tabindex="-1"
                  onclick="togglePwd()" style="border:1.5px solid #e2e8f0;border-left:none;border-radius:0 10px 10px 0">
            <i class="bi bi-eye" id="pwdIcon"></i>
          </button>
        </div>
      </div>
      <div class="text-end mb-4">
        <a href="${pageContext.request.contextPath}/forgot-password" class="text-primary" style="font-size:.825rem">
          Forgot password?
        </a>
      </div>
      <button type="submit" class="btn btn-auth w-100">
        <i class="bi bi-box-arrow-in-right me-2"></i>Sign In
      </button>
    </form>

    <div class="text-center mt-4" style="font-size:.875rem; color:#64748b">
      New here?
      <a href="${pageContext.request.contextPath}/register" class="fw-semibold text-primary">Create an account</a>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  function togglePwd() {
    const i = document.getElementById('pwdInput');
    const ic = document.getElementById('pwdIcon');
    i.type = i.type === 'password' ? 'text' : 'password';
    ic.className = i.type === 'password' ? 'bi bi-eye' : 'bi bi-eye-slash';
  }
</script>
</body>
</html>
