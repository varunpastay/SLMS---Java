<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="My Certificates"/>
<%@ include file="/views/base-header.jsp" %>

<h4 class="fw-bold mb-4"><i class="bi bi-patch-check me-2"></i>My Certificates</h4>

<c:choose>
  <c:when test="${empty certificates}">
    <div class="text-center text-muted py-5">
      <i class="bi bi-patch-question fs-1 d-block mb-2"></i>
      No certificates yet. Complete a course to earn one!
      <br/><a href="${ctx}/courses" class="btn btn-outline-primary mt-3">Browse Courses</a>
    </div>
  </c:when>
  <c:otherwise>
    <div class="row g-4">
      <c:forEach var="cert" items="${certificates}">
        <div class="col-md-6 col-lg-4">
          <div class="card shadow text-center h-100 border-warning border-2">
            <div class="card-body py-4">
              <i class="bi bi-award-fill text-warning" style="font-size:3.5rem"></i>
              <h5 class="fw-bold mt-3">${cert.courseTitle}</h5>
              <p class="text-muted small">Instructor: ${cert.teacherName}</p>
              <p class="text-muted small">Issued: <fmt:formatDate value="${cert.issuedAt}" pattern="dd MMMM yyyy" type="date"/></p>
              <div class="bg-light rounded p-2 mt-2">
                <small class="text-muted">Certificate ID:</small><br/>
                <code class="fs-6">${cert.certificateCode}</code>
              </div>
            </div>
            <div class="card-footer bg-transparent">
              <a href="${ctx}/certificate/verify?code=${cert.certificateCode}" target="_blank" class="btn btn-sm btn-outline-warning">
                <i class="bi bi-link-45deg me-1"></i>Verify Certificate
              </a>
            </div>
          </div>
        </div>
      </c:forEach>
    </div>
  </c:otherwise>
</c:choose>

<%@ include file="/views/base-footer.jsp" %>
