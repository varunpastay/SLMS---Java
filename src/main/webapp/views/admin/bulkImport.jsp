<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Bulk Student Import – SLMS</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">
<style>
body{background:#f5f3ff}
.hero{background:linear-gradient(135deg,#7c3aed,#4f46e5);color:#fff;border-radius:16px;padding:28px 32px;margin-bottom:24px}
.drop-zone{border:2px dashed #7c3aed;border-radius:12px;padding:40px;text-align:center;cursor:pointer;transition:background .2s}
.drop-zone:hover{background:#f5f3ff}
.result-ok{color:#16a34a}.result-skip{color:#d97706}.result-fail{color:#dc2626}
</style>
</head>
<body>
<%@ include file="/views/base-header.jsp" %>
<div class="container py-4" style="max-width:800px">
  <div class="hero">
    <h2 class="mb-1"><i class="bi bi-upload me-2"></i>Bulk Student Import</h2>
    <p class="mb-0 opacity-75">Import multiple students at once from a CSV file.</p>
  </div>

  <c:if test="${not empty error}">
    <div class="alert alert-danger"><i class="bi bi-exclamation-circle me-2"></i>${error}</div>
  </c:if>

  <c:choose>
    <c:when test="${not empty results}">
      <!-- Results -->
      <div class="card border-0 shadow-sm mb-4">
        <div class="card-header bg-white fw-semibold">Import Results</div>
        <div class="card-body">
          <div class="row g-3 mb-3">
            <div class="col-4 text-center"><div class="fs-2 fw-bold text-success">${success}</div><div class="text-muted small">Created</div></div>
            <div class="col-4 text-center"><div class="fs-2 fw-bold text-warning">${skipped}</div><div class="text-muted small">Skipped</div></div>
            <div class="col-4 text-center"><div class="fs-2 fw-bold text-danger">${failed}</div><div class="text-muted small">Failed</div></div>
          </div>
          <div style="max-height:300px;overflow-y:auto;font-family:monospace;font-size:.85rem">
            <c:forEach var="r" items="${results}">
              <div class="${r.startsWith('✅')?'result-ok':r.startsWith('⚠️')?'result-skip':'result-fail'}">${r}</div>
            </c:forEach>
          </div>
        </div>
      </div>
      <a href="${pageContext.request.contextPath}/admin/bulk-import" class="btn btn-primary">
        <i class="bi bi-upload me-2"></i>Import Another File
      </a>
    </c:when>
    <c:otherwise>
      <!-- Upload form -->
      <div class="card border-0 shadow-sm mb-4">
        <div class="card-body">
          <form method="post" enctype="multipart/form-data" action="${pageContext.request.contextPath}/admin/bulk-import">
            <div class="drop-zone mb-3" onclick="document.getElementById('csvFile').click()">
              <i class="bi bi-file-earmark-spreadsheet fs-1 text-primary d-block mb-2"></i>
              <div class="fw-semibold">Click to select CSV file</div>
              <div class="text-muted small mt-1">or drag and drop</div>
              <div id="fileName" class="mt-2 text-primary fw-semibold"></div>
            </div>
            <input type="file" id="csvFile" name="csvFile" accept=".csv" class="d-none" onchange="showFile(this)">
            <button type="submit" class="btn btn-primary w-100 fw-semibold">
              <i class="bi bi-cloud-upload me-2"></i>Import Students
            </button>
          </form>
        </div>
      </div>

      <!-- Format guide -->
      <div class="card border-0 shadow-sm">
        <div class="card-header bg-white fw-semibold"><i class="bi bi-info-circle me-2 text-info"></i>CSV Format Guide</div>
        <div class="card-body">
          <p class="text-muted small mb-3">First row must be a header. Columns:</p>
          <div class="bg-light rounded p-3 font-monospace small">
            name,email,username,password<br>
            John Doe,john@email.com,johndoe,MyPass123<br>
            Jane Smith,jane@email.com,janesmith,Pass@456<br>
            Bob Kumar,bob@email.com,,  &lt;-- username auto-generated, default password: Student@123
          </div>
          <ul class="mt-3 small text-muted">
            <li>Username is optional — auto-generated from email if empty</li>
            <li>Password is optional — defaults to <code>Student@123</code></li>
            <li>Duplicate emails/usernames are skipped (not deleted)</li>
            <li>Max file size: 5MB</li>
          </ul>
          <a href="#" onclick="downloadSample()" class="btn btn-outline-secondary btn-sm">
            <i class="bi bi-download me-1"></i>Download Sample CSV
          </a>
        </div>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<script>
function showFile(input) {
  document.getElementById('fileName').textContent = input.files[0] ? '📄 ' + input.files[0].name : '';
}

const dz = document.querySelector('.drop-zone');
if (dz) {
  dz.addEventListener('dragover', e => { e.preventDefault(); dz.style.background='#ede9fe'; });
  dz.addEventListener('dragleave', () => dz.style.background='');
  dz.addEventListener('drop', e => {
    e.preventDefault(); dz.style.background='';
    const file = e.dataTransfer.files[0];
    if (file) { document.getElementById('csvFile').files = e.dataTransfer.files; showFile(document.getElementById('csvFile')); }
  });
}

function downloadSample() {
  const csv = 'name,email,username,password\nJohn Doe,john@example.com,johndoe,MyPass123\nJane Smith,jane@example.com,,\n';
  const blob = new Blob([csv], { type: 'text/csv' });
  const a = document.createElement('a'); a.href = URL.createObjectURL(blob);
  a.download = 'students_sample.csv'; a.click();
}
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
