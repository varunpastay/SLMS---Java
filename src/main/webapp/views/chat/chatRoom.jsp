<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Chat"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row g-3" style="height:75vh">
  <!-- Conversation list -->
  <div class="col-lg-3 col-md-4">
    <div class="card shadow-sm h-100 d-flex flex-column">
      <div class="card-header fw-semibold"><i class="bi bi-chat-dots me-2"></i>Conversations</div>
      <div class="list-group list-group-flush overflow-auto flex-grow-1">
        <c:choose>
          <c:when test="${empty partners}">
            <div class="list-group-item text-muted text-center py-3 small">No conversations yet.</div>
          </c:when>
          <c:otherwise>
            <c:forEach var="p" items="${partners}">
              <a href="${ctx}/chat?with=${p.id}" class="list-group-item list-group-item-action ${other.id == p.id ? 'active' : ''}">
                <div class="d-flex align-items-center">
                  <i class="bi bi-person-circle fs-4 me-2"></i>
                  <div>
                    <div class="fw-semibold">${p.firstName} ${p.lastName}</div>
                    <small>${p.role}</small>
                  </div>
                </div>
              </a>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>

  <!-- Chat window -->
  <div class="col-lg-9 col-md-8">
    <div class="card shadow-sm h-100 d-flex flex-column">
      <c:choose>
        <c:when test="${not empty other}">
          <div class="card-header fw-semibold d-flex align-items-center">
            <i class="bi bi-person-circle fs-4 me-2"></i>${other.firstName} ${other.lastName}
            <span class="badge bg-secondary ms-2">${other.role}</span>
          </div>
          <div class="flex-grow-1 overflow-auto p-3" id="messageBox" style="display:flex;flex-direction:column">
            <c:forEach var="msg" items="${messages}">
              <c:set var="mine" value="${msg.senderId == user.id}"/>
              <div class="d-flex ${mine ? 'justify-content-end' : 'justify-content-start'} mb-2">
                <div class="rounded-3 p-2 px-3 ${mine ? 'bg-primary text-white' : 'bg-light'}" style="max-width:70%">
                  <div>${msg.message}</div>
                  <div class="small ${mine ? 'text-white-50' : 'text-muted'} text-end">
                    <fmt:formatDate value="${msg.sentAt}" pattern="HH:mm" type="date"/>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
          <div class="card-footer">
            <form action="${ctx}/chat" method="post" class="d-flex gap-2">
              <input type="hidden" name="receiverId" value="${other.id}"/>
              <input type="text" name="message" class="form-control" placeholder="Type a message..." required autocomplete="off" id="msgInput"/>
              <button type="submit" class="btn btn-primary px-3">
                <i class="bi bi-send"></i>
              </button>
            </form>
          </div>
        </c:when>
        <c:otherwise>
          <div class="card-body d-flex align-items-center justify-content-center text-muted">
            <div class="text-center">
              <i class="bi bi-chat-dots fs-1 d-block mb-2"></i>
              Select a conversation or search for a user to chat with.
            </div>
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div>

<script>
// Scroll to bottom of message box
const msgBox = document.getElementById('messageBox');
if (msgBox) msgBox.scrollTop = msgBox.scrollHeight;
</script>

<%@ include file="/views/base-footer.jsp" %>
