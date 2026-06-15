<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SLMS – Create Account</title>
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
      padding: 2rem 1rem;
      overflow-x: hidden;
      position: relative;
    }
    body::before {
      content: '';
      position: fixed;
      width: 450px; height: 450px;
      background: rgba(96,165,250,.1);
      border-radius: 50%;
      filter: blur(90px);
      top: -120px; right: -120px;
      pointer-events: none;
    }

    .register-card {
      background: rgba(255,255,255,.97);
      border-radius: 24px;
      padding: 2.5rem;
      width: 100%;
      max-width: 520px;
      box-shadow: 0 30px 80px rgba(0,0,0,.45);
      position: relative;
      z-index: 1;
      animation: fadeUp .4s ease;
    }
    @keyframes fadeUp {
      from { opacity:0; transform:translateY(20px); }
      to   { opacity:1; transform:translateY(0); }
    }

    .register-logo {
      font-size: 2.8rem;
      background: linear-gradient(135deg, #3b82f6, #6366f1);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }
    .register-card h2 { font-weight: 800; font-size: 1.4rem; color: #0f172a; }
    .register-card .sub { color: #64748b; font-size: 0.875rem; margin-bottom: 1.5rem; }

    .form-control, .form-select {
      background: #f8fafc !important;
      border: 1.5px solid #e2e8f0 !important;
      color: #0f172a !important;
    }
    .form-control:focus, .form-select:focus {
      background: #fff !important;
      border-color: #3b82f6 !important;
    }

    .role-options { display: flex; gap: 0.75rem; }
    .role-option input[type=radio] { display: none; }
    .role-option label {
      flex: 1;
      border: 2px solid #e2e8f0;
      border-radius: 12px;
      padding: 0.75rem;
      text-align: center;
      cursor: pointer;
      transition: all 0.2s;
      font-size: 0.875rem;
      font-weight: 500;
      color: #64748b;
    }
    .role-option label i { display: block; font-size: 1.5rem; margin-bottom: 0.25rem; }
    .role-option input:checked + label {
      border-color: #3b82f6;
      background: #eff6ff;
      color: #1d4ed8;
      box-shadow: 0 0 0 3px rgba(59,130,246,.15);
    }

    .btn-register {
      background: linear-gradient(135deg, #3b82f6, #6366f1);
      border: none;
      color: #fff;
      font-weight: 700;
      padding: 0.75rem;
      border-radius: 12px;
      font-size: 0.95rem;
      width: 100%;
      transition: all 0.2s;
    }
    .btn-register:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(59,130,246,.4); color:#fff; }
    .strength-bar { height: 4px; border-radius: 4px; background: #e2e8f0; margin-top: 6px; overflow: hidden; }
    .strength-fill { height: 100%; border-radius: 4px; width: 0; transition: all .3s; }
  </style>
</head>
<body>

<div class="register-card">
  <div class="text-center mb-3">
    <div class="register-logo"><i class="bi bi-mortarboard-fill"></i></div>
    <h2 class="mt-2">Create your account</h2>
    <p class="sub">Join thousands of learners on SLMS today.</p>
  </div>

  <c:if test="${not empty error}">
    <div class="alert alert-danger mb-3"><i class="bi bi-exclamation-triangle me-2"></i>${error}</div>
  </c:if>

  <form action="${pageContext.request.contextPath}/register" method="post" novalidate id="regForm">
    <div class="row g-2 mb-3">
      <div class="col-6">
        <label class="form-label">First Name</label>
        <input type="text" name="firstName" class="form-control" placeholder="John" required/>
      </div>
      <div class="col-6">
        <label class="form-label">Last Name</label>
        <input type="text" name="lastName" class="form-control" placeholder="Doe"/>
      </div>
    </div>

    <div class="mb-3">
      <label class="form-label">Username</label>
      <div class="input-group">
        <span class="input-group-text" style="background:#f8fafc;border:1.5px solid #e2e8f0;border-right:none"><i class="bi bi-at"></i></span>
        <input type="text" name="username" class="form-control" placeholder="johndoe" required style="border-left:none"/>
      </div>
    </div>

    <div class="mb-3">
      <label class="form-label">Email Address</label>
      <div class="input-group">
        <span class="input-group-text" style="background:#f8fafc;border:1.5px solid #e2e8f0;border-right:none"><i class="bi bi-envelope"></i></span>
        <input type="email" name="email" class="form-control" placeholder="john@example.com" required style="border-left:none"/>
      </div>
    </div>

    <div class="mb-1">
      <label class="form-label">Password</label>
      <input type="password" name="password" id="regPwd" class="form-control" placeholder="At least 6 characters" minlength="6" required oninput="checkStrength(this.value)"/>
      <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
      <div id="strengthText" class="mt-1" style="font-size:.75rem; color:#64748b"></div>
    </div>

    <div class="mb-3">
      <label class="form-label">Confirm Password</label>
      <input type="password" name="confirmPassword" class="form-control" placeholder="Repeat password" required/>
    </div>

    <div class="mb-4">
      <label class="form-label">I am a…</label>
      <div class="role-options">
        <div class="role-option">
          <input type="radio" name="role" id="roleStudent" value="STUDENT" checked/>
          <label for="roleStudent">
            <i class="bi bi-person-graduation"></i>Student
          </label>
        </div>
        <div class="role-option">
          <input type="radio" name="role" id="roleTeacher" value="TEACHER"/>
          <label for="roleTeacher">
            <i class="bi bi-person-badge"></i>Teacher
          </label>
        </div>
      </div>
    </div>

    <button type="submit" class="btn-register">
      <i class="bi bi-person-plus me-2"></i>Create Account
    </button>
  </form>

  <div class="text-center mt-4" style="font-size:.875rem; color:#64748b">
    Already have an account?
    <a href="${pageContext.request.contextPath}/login" class="fw-semibold text-primary">Sign in</a>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  function checkStrength(v) {
    const fill = document.getElementById('strengthFill');
    const txt  = document.getElementById('strengthText');
    let score = 0;
    if (v.length >= 6) score++;
    if (v.length >= 10) score++;
    if (/[A-Z]/.test(v)) score++;
    if (/[0-9]/.test(v)) score++;
    if (/[^a-zA-Z0-9]/.test(v)) score++;
    const pct = (score / 5) * 100;
    const colors = ['#ef4444','#f59e0b','#f59e0b','#10b981','#10b981'];
    const labels = ['Too short','Weak','Fair','Strong','Very strong'];
    fill.style.width = pct + '%';
    fill.style.background = colors[score - 1] || '#e2e8f0';
    txt.textContent = score > 0 ? labels[score - 1] : '';
    txt.style.color = colors[score - 1] || '#64748b';
  }
</script>
</body>
</html>
