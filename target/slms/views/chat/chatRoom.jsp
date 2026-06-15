<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Chat"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row g-3" style="height:80vh">
  <!-- Sidebar: Conversations + All Users -->
  <div class="col-lg-3 col-md-4">
    <div class="card shadow-sm h-100 d-flex flex-column">
      <div class="card-header fw-semibold d-flex justify-content-between align-items-center">
        <span><i class="bi bi-chat-dots me-2"></i>Messages</span>
        <button class="btn btn-sm btn-outline-primary" data-bs-toggle="collapse" data-bs-target="#newChatPanel">
          <i class="bi bi-pencil-square"></i>
        </button>
      </div>

      <!-- New Chat Panel -->
      <div class="collapse" id="newChatPanel">
        <div class="p-2 border-bottom bg-light">
          <small class="text-muted fw-semibold d-block mb-1">Start new conversation</small>
          <input type="text" id="userSearch" class="form-control form-control-sm" placeholder="Search users..."/>
          <div class="list-group mt-1" id="userSearchResults" style="max-height:180px;overflow-y:auto">
            <c:forEach var="u" items="${allUsers}">
              <a href="${ctx}/chat?with=${u.id}"
                 class="list-group-item list-group-item-action py-1 small user-item"
                 data-name="${u.firstName} ${u.lastName} ${u.username}">
                <i class="bi bi-person-circle me-1"></i>${u.firstName} ${u.lastName}
                <small class="text-muted">(${u.role})</small>
              </a>
            </c:forEach>
          </div>
        </div>
      </div>

      <!-- Existing Conversations -->
      <div class="list-group list-group-flush overflow-auto flex-grow-1">
        <c:choose>
          <c:when test="${empty partners}">
            <div class="list-group-item text-muted text-center py-4 small">
              <i class="bi bi-chat-dots d-block fs-3 mb-1"></i>
              No conversations yet.<br/>Click <strong>✏</strong> to start one.
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="p" items="${partners}">
              <a href="${ctx}/chat?with=${p.id}"
                 class="list-group-item list-group-item-action ${other.id == p.id ? 'active' : ''}">
                <div class="d-flex align-items-center">
                  <c:choose>
                    <c:when test="${not empty p.profilePic}">
                      <img src="${ctx}/uploads/${p.profilePic}" class="rounded-circle me-2" width="32" height="32" style="object-fit:cover" alt="avatar"/>
                    </c:when>
                    <c:otherwise>
                      <i class="bi bi-person-circle fs-4 me-2"></i>
                    </c:otherwise>
                  </c:choose>
                  <div>
                    <div class="fw-semibold">${p.firstName} ${p.lastName}</div>
                    <small class="text-muted">${p.role}</small>
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
            <c:choose>
              <c:when test="${not empty other.profilePic}">
                <img src="${ctx}/uploads/${other.profilePic}" class="rounded-circle me-2" width="32" height="32" style="object-fit:cover" alt="avatar"/>
              </c:when>
              <c:otherwise>
                <i class="bi bi-person-circle fs-4 me-2"></i>
              </c:otherwise>
            </c:choose>
            ${other.firstName} ${other.lastName}
            <span class="badge bg-secondary ms-2">${other.role}</span>
          </div>
          <div class="flex-grow-1 overflow-auto p-3" id="messageBox" style="display:flex;flex-direction:column">
            <c:choose>
              <c:when test="${empty messages}">
                <div class="m-auto text-center text-muted">
                  <i class="bi bi-chat fs-2 d-block mb-2"></i>
                  Say hello to ${other.firstName}!
                </div>
              </c:when>
              <c:otherwise>
                <c:forEach var="msg" items="${messages}">
                  <c:set var="mine" value="${msg.senderId == user.id}"/>
                  <div class="d-flex ${mine ? 'justify-content-end' : 'justify-content-start'} mb-2">
                    <div class="rounded-3 p-2 px-3 ${mine ? 'bg-primary text-white' : 'bg-light border'}" style="max-width:70%">
                      <div>${msg.message}</div>
                      <div class="small ${mine ? 'text-white-50' : 'text-muted'} text-end mt-1">
                        <fmt:formatDate value="${msg.sentAt}" pattern="HH:mm"/>
                      </div>
                    </div>
                  </div>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </div>
          <div class="card-footer">
            <form action="${ctx}/chat" method="post" class="d-flex gap-2" id="msgForm">
              <input type="hidden" name="receiverId" value="${other.id}"/>
              <input type="text" name="message" class="form-control" placeholder="Type a message..."
                     required autocomplete="off" id="msgInput"/>
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
              Select a conversation or click <strong>✏</strong> to start a new one.
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

// Live user search filter
const searchInput = document.getElementById('userSearch');
if (searchInput) {
  searchInput.addEventListener('input', function() {
    const q = this.value.toLowerCase();
    document.querySelectorAll('.user-item').forEach(function(el) {
      const name = el.getAttribute('data-name').toLowerCase();
      el.style.display = name.includes(q) ? '' : 'none';
    });
  });
}
</script>

<%@ include file="/views/base-footer.jsp" %>
