<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SLMS – Certificate Verification</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"/>
</head>
<body class="bg-light">
<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-lg-6">
      <div class="text-center mb-4">
        <i class="bi bi-patch-check-fill text-warning" style="font-size:3rem"></i>
        <h3 class="fw-bold mt-2">Certificate Verification</h3>
        <p class="text-muted">Enter a certificate code to verify its authenticity.</p>
      </div>

      <div class="card shadow-sm mb-4">
        <div class="card-body">
          <form method="get" action="" class="d-flex gap-2">
            <input type="text" name="code" class="form-control" placeholder="Enter certificate code..." value="${param.code}"/>
            <button type="submit" class="btn btn-primary">Verify</button>
          </form>
        </div>
      </div>

      <c:if test="${not empty param.code}">
        <c:choose>
          <c:when test="${not empty certificate}">
            <div class="card border-success border-2 shadow text-center">
              <div class="card-body py-4">
                <i class="bi bi-check-circle-fill text-success" style="font-size:3rem"></i>
                <h4 class="fw-bold mt-3 text-success">Valid Certificate</h4>
                <hr/>
                <p class="fs-5 mb-1"><strong>${certificate.studentName}</strong></p>
                <p class="text-muted mb-1">has successfully completed</p>
                <p class="fs-5 fw-bold">${certificate.courseTitle}</p>
                <p class="text-muted small mb-1">Instructor: ${certificate.teacherName}</p>
                <p class="text-muted small">Issued on: <fmt:formatDate value="${certificate.issuedAt}" pattern="dd MMMM yyyy" type="date"/></p>
                <div class="bg-light rounded p-2 mt-2">
                  <code>${certificate.certificateCode}</code>
                </div>
              </div>
            </div>
          </c:when>
          <c:otherwise>
            <div class="card border-danger border-2 shadow text-center">
              <div class="card-body py-4">
                <i class="bi bi-x-circle-fill text-danger" style="font-size:3rem"></i>
                <h4 class="fw-bold mt-3 text-danger">Invalid Certificate</h4>
                <p class="text-muted mt-2">No certificate found with this code. Please check and try again.</p>
              </div>
            </div>
          </c:otherwise>
        </c:choose>
      </c:if>

      <div class="text-center mt-4">
        <a href="${pageContext.request.contextPath}/login" class="text-muted small">
          <i class="bi bi-arrow-left me-1"></i>Back to SLMS
        </a>
      </div>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
