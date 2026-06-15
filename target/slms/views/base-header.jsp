<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SLMS ${not empty pageTitle ? '- '.concat(pageTitle) : ''}</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/slms.css"/>
</head>
<body>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="user" value="${sessionScope.loggedUser}"/>

<nav class="navbar navbar-expand-lg navbar-dark bg-primary sticky-top shadow-sm">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold" href="${ctx}/dashboard">
      <i class="bi bi-mortarboard-fill me-1"></i>SLMS
    </a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarMain">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">
        <li class="nav-item">
          <a class="nav-link" href="${ctx}/courses"><i class="bi bi-book me-1"></i>Courses</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${ctx}/forum"><i class="bi bi-chat-square-text me-1"></i>Forum</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${ctx}/leaderboard"><i class="bi bi-trophy me-1"></i>Leaderboard</a>
        </li>
        <c:if test="${user.role == 'TEACHER' or user.role == 'ADMIN'}">
        <li class="nav-item">
          <a class="nav-link" href="${ctx}/course/create"><i class="bi bi-plus-circle me-1"></i>New Course</a>
        </li>
        </c:if>
        <c:if test="${user.role == 'STUDENT'}">
        <li class="nav-item">
          <a class="nav-link" href="${ctx}/certificate/my"><i class="bi bi-patch-check me-1"></i>Certificates</a>
        </li>
        </c:if>
        <c:if test="${user.role == 'ADMIN'}">
        <li class="nav-item">
          <a class="nav-link" href="${ctx}/dashboard"><i class="bi bi-shield-lock me-1"></i>Admin</a>
        </li>
        </c:if>
      </ul>
      <ul class="navbar-nav ms-auto align-items-center">
        <li class="nav-item me-2">
          <a class="nav-link" href="${ctx}/chat"><i class="bi bi-chat-dots me-1"></i>Chat</a>
        </li>
        <li class="nav-item me-2">
          <a class="nav-link position-relative" href="${ctx}/notifications" id="notifBell">
            <i class="bi bi-bell fs-5"></i>
            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" id="notifCount" style="display:none">0</span>
          </a>
        </li>
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" data-bs-toggle="dropdown">
            <c:choose>
              <c:when test="${not empty user.profilePic}">
                <img src="${ctx}/uploads/${user.profilePic}" class="rounded-circle me-1" width="28" height="28" style="object-fit:cover" alt="avatar"/>
              </c:when>
              <c:otherwise>
                <i class="bi bi-person-circle fs-5 me-1"></i>
              </c:otherwise>
            </c:choose>
            ${user.firstName}
          </a>
          <ul class="dropdown-menu dropdown-menu-end">
            <li><a class="dropdown-item" href="${ctx}/profile"><i class="bi bi-person me-2"></i>Profile</a></li>
            <li><hr class="dropdown-divider"/></li>
            <li>
              <form action="${ctx}/logout" method="post" class="d-inline">
                <button class="dropdown-item text-danger" type="submit"><i class="bi bi-box-arrow-right me-2"></i>Logout</button>
              </form>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</nav>

<div class="container-fluid py-4">
