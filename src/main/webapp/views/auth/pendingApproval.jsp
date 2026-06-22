<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SLMS – Request Submitted</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"/>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <style>
    body {
      min-height: 100vh;
      background: linear-gradient(135deg, #0f1b35 0%, #1e3a6e 50%, #312e81 100%);
      display: flex; align-items: center; justify-content: center;
      font-family: 'Inter', sans-serif;
    }
    .card {
      background: rgba(255,255,255,.97);
      border-radius: 24px;
      padding: 3rem 2.5rem;
      max-width: 480px;
      width: 100%;
      box-shadow: 0 30px 80px rgba(0,0,0,.45);
      text-align: center;
    }
    .icon-ring {
      width: 88px; height: 88px;
      border-radius: 50%;
      background: linear-gradient(135deg, #f59e0b, #d97706);
      display: inline-flex; align-items: center; justify-content: center;
      font-size: 2.5rem; color: #fff;
      margin-bottom: 1.5rem;
    }
    h2 { font-weight: 800; font-size: 1.5rem; color: #0f172a; }
    p  { color: #64748b; font-size: .9rem; line-height: 1.6; }
    .step {
      display: flex; align-items: flex-start; gap: .75rem;
      text-align: left; margin-bottom: .75rem;
      background: #f8fafc; border-radius: 12px; padding: .75rem 1rem;
    }
    .step-num {
      width: 28px; height: 28px; flex-shrink: 0;
      border-radius: 50%; background: #3b82f6; color: #fff;
      font-size: .75rem; font-weight: 700;
      display: flex; align-items: center; justify-content: center;
    }
    .step-text { font-size: .85rem; color: #334155; }
  </style>
</head>
<body>
<div class="card">
  <div class="icon-ring"><i class="bi bi-hourglass-split"></i></div>
  <h2>Request Submitted!</h2>
  <p class="mb-4">Your teacher account request has been sent to the admin for review. Here's what happens next:</p>

  <div class="step">
    <div class="step-num">1</div>
    <div class="step-text"><strong>Admin reviews</strong> your request, qualifications, and reason in the admin panel.</div>
  </div>
  <div class="step">
    <div class="step-num">2</div>
    <div class="step-text"><strong>You receive an email</strong> once your account is approved and ready to use.</div>
  </div>
  <div class="step">
    <div class="step-num">3</div>
    <div class="step-text"><strong>Log in</strong> with the credentials you registered with and start teaching!</div>
  </div>

  <p class="mt-4 mb-4" style="font-size:.82rem;color:#94a3b8">
    This usually takes 1–2 business days. If you have questions, contact your institution's administrator.
  </p>

  <a href="${pageContext.request.contextPath}/login"
     class="btn btn-primary w-100 fw-bold py-2" style="border-radius:12px">
    <i class="bi bi-box-arrow-in-right me-2"></i>Back to Login
  </a>
</div>
</body>
</html>
