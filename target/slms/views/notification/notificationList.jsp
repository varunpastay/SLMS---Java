<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Notifications"/>
<%@ include file="/views/base-header.jsp" %>

<div class="d-flex justify-content-between align-items-center mb-4">
  <h4 class="fw-bold mb-0"><i class="bi bi-bell me-2"></i>Notifications</h4>
  <form action="${ctx}/notifications" method="post">
    <input type="hidden" name="action" value="markAllRead"/>
    <button type="submit" class="btn btn-outline-secondary btn-sm">
      <i class="bi bi-check2-all me-1"></i>Mark All Read
    </button>
  </form>
</div>

<div class="card shadow-sm">
  <c:choose>
    <c:when test="${empty notifications}">
      <div class="card-body text-center text-muted py-5">
        <i class="bi bi-bell-slash fs-1 d-block mb-2"></i>No notifications.
      </div>
    </c:when>
    <c:otherwise>
      <div class="list-group list-group-flush">
        <c:forEach var="n" items="${notifications}">
          <div class="list-group-item d-flex justify-content-between align-items-start ${not n.read ? 'bg-light' : ''}">
            <div>
              <i class="bi bi-dot ${not n.read ? 'text-primary' : 'text-muted'} me-1" style="font-size:1.2rem"></i>
              <span class="${not n.read ? 'fw-semibold' : ''}">${n.message}</span>
              <div class="text-muted small ms-3">
                <fmt:formatDate value="${n.createdAt}" pattern="dd MMM yyyy HH:mm" type="date"/>
              </div>
            </div>
            <form action="${ctx}/notifications" method="post" class="ms-2">
              <input type="hidden" name="action" value="delete"/>
              <input type="hidden" name="id" value="${n.id}"/>
              <button class="btn btn-sm btn-link text-muted p-0"><i class="bi bi-x-lg"></i></button>
            </form>
          </div>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="/views/base-footer.jsp" %>
