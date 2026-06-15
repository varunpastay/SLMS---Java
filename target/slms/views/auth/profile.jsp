<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="My Profile"/>
<%@ include file="/views/base-header.jsp" %>

<div class="row justify-content-center">
  <div class="col-lg-7">
    <h4 class="fw-bold mb-4"><i class="bi bi-person-circle me-2"></i>My Profile</h4>

    <c:if test="${not empty error}">
      <div class="alert alert-danger">${error}</div>
    </c:if>
    <c:if test="${not empty success}">
      <div class="alert alert-success">${success}</div>
    </c:if>

    <div class="card shadow-sm mb-4">
      <div class="card-header fw-semibold">Edit Profile</div>
      <div class="card-body">
        <form action="${ctx}/profile" method="post" enctype="multipart/form-data">
          <input type="hidden" name="action" value="updateProfile"/>
          <div class="text-center mb-3">
            <c:choose>
              <c:when test="${not empty user.profilePic}">
                <img src="${ctx}/uploads/${user.profilePic}" class="rounded-circle mb-2" width="90" height="90" style="object-fit:cover" alt="avatar"/>
              </c:when>
              <c:otherwise>
                <i class="bi bi-person-circle text-secondary" style="font-size:5rem"></i>
              </c:otherwise>
            </c:choose>
            <div class="mt-2">
              <input type="file" name="profilePic" class="form-control form-control-sm" accept="image/*"/>
            </div>
          </div>
          <div class="row g-2 mb-2">
            <div class="col-6">
              <label class="form-label">First Name</label>
              <input type="text" name="firstName" class="form-control" value="${user.firstName}"/>
            </div>
            <div class="col-6">
              <label class="form-label">Last Name</label>
              <input type="text" name="lastName" class="form-control" value="${user.lastName}"/>
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label">Bio</label>
            <textarea name="bio" class="form-control" rows="3">${user.bio}</textarea>
          </div>
          <button type="submit" class="btn btn-primary">
            <i class="bi bi-save me-1"></i>Save Changes
          </button>
        </form>
      </div>
    </div>

    <div class="card shadow-sm">
      <div class="card-header fw-semibold">Change Password</div>
      <div class="card-body">
        <form action="${ctx}/profile" method="post">
          <input type="hidden" name="action" value="changePassword"/>
          <div class="mb-2">
            <label class="form-label">Current Password</label>
            <input type="password" name="currentPassword" class="form-control" required/>
          </div>
          <div class="mb-2">
            <label class="form-label">New Password</label>
            <input type="password" name="newPassword" class="form-control" required/>
          </div>
          <div class="mb-3">
            <label class="form-label">Confirm New Password</label>
            <input type="password" name="confirmPassword" class="form-control" required/>
          </div>
          <button type="submit" class="btn btn-warning">
            <i class="bi bi-lock me-1"></i>Change Password
          </button>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
