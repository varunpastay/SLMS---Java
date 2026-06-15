<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SLMS – Verify Email</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/slms.css"/>
</head>
<body class="bg-light">
<div class="container d-flex justify-content-center align-items-center min-vh-100">
  <div class="card shadow-lg p-4" style="width:100%;max-width:420px">

    <div class="text-center mb-4">
      <i class="bi bi-envelope-check-fill text-primary" style="font-size:3rem"></i>
      <h3 class="fw-bold mt-2">Verify Your Email</h3>
      <p class="text-muted">We sent a 6-digit OTP to your email address. Enter it below to complete registration.</p>
    </div>

    <c:if test="${not empty error}">
      <div class="alert alert-danger py-2"><i class="bi bi-exclamation-circle me-1"></i>${error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/verify-otp" method="post" novalidate>
      <div class="mb-4">
        <label class="form-label fw-semibold">Enter OTP</label>
        <input type="text" name="otp" class="form-control form-control-lg text-center fw-bold"
               maxlength="6" placeholder="000000" required autofocus
               style="font-size:1.8rem;letter-spacing:10px"/>
        <div class="form-text text-center">OTP expires in 5 minutes.</div>
      </div>
      <button type="submit" class="btn btn-primary w-100 py-2">
        <i class="bi bi-check2-circle me-1"></i>Verify &amp; Create Account
      </button>
    </form>

    <hr/>
    <p class="text-center mb-0 small text-muted">
      Wrong email?
      <a href="${pageContext.request.contextPath}/register" class="fw-semibold">Start over</a>
    </p>

  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  // Countdown timer
  let seconds = 300;
  const timerEl = document.querySelector('.form-text');
  const interval = setInterval(() => {
    seconds--;
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    timerEl.textContent = `OTP expires in ${m}:${s.toString().padStart(2,'0')}`;
    if (seconds <= 0) {
      clearInterval(interval);
      timerEl.textContent = 'OTP has expired. Please register again.';
      timerEl.classList.add('text-danger');
      document.querySelector('button[type=submit]').disabled = true;
    }
  }, 1000);
</script>
</body>
</html>
