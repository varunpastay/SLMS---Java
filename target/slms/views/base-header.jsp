<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>SLMS ${not empty pageTitle ? '– '.concat(pageTitle) : ''}</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"/>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/slms.css"/>
</head>
<body>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="user" value="${sessionScope.loggedUser}"/>

<nav class="navbar navbar-expand-lg sticky-top">
  <div class="container-fluid">

    <a class="navbar-brand" href="${ctx}/dashboard">
      <i class="bi bi-mortarboard-fill"></i> SLMS
    </a>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain"
            aria-controls="navbarMain" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarMain">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0 gap-1">

        <li class="nav-item">
          <a class="nav-link" href="${ctx}/courses">
            <i class="bi bi-collection me-1"></i>Courses
          </a>
        </li>

        <li class="nav-item">
          <a class="nav-link" href="${ctx}/calendar">
            <i class="bi bi-calendar3 me-1"></i>Calendar
          </a>
        </li>

        <li class="nav-item">
          <a class="nav-link" href="${ctx}/gradebook">
            <i class="bi bi-table me-1"></i>Grades
          </a>
        </li>

        <li class="nav-item">
          <a class="nav-link" href="${ctx}/forum">
            <i class="bi bi-chat-square-text me-1"></i>Forum
          </a>
        </li>

        <li class="nav-item">
          <a class="nav-link" href="${ctx}/leaderboard">
            <i class="bi bi-trophy me-1"></i>Leaderboard
          </a>
        </li>

        <c:if test="${user.role == 'TEACHER' or user.role == 'ADMIN'}">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
              <i class="bi bi-tools me-1"></i>Manage
            </a>
            <ul class="dropdown-menu">
              <li><a class="dropdown-item" href="${ctx}/course/create">
                <i class="bi bi-plus-circle me-2 text-primary"></i>New Course
              </a></li>
              <li><a class="dropdown-item" href="${ctx}/gradebook">
                <i class="bi bi-table me-2 text-primary"></i>Grade Book
              </a></li>
            </ul>
          </li>
        </c:if>

        <c:if test="${user.role == 'STUDENT'}">
          <li class="nav-item">
            <a class="nav-link" href="${ctx}/certificate/my">
              <i class="bi bi-patch-check me-1"></i>Certificates
            </a>
          </li>
        </c:if>

        <c:if test="${user.role == 'ADMIN'}">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
              <i class="bi bi-shield-lock me-1"></i>Admin
            </a>
            <ul class="dropdown-menu">
              <li><a class="dropdown-item" href="${ctx}/dashboard">
                <i class="bi bi-speedometer2 me-2 text-primary"></i>Dashboard
              </a></li>
              <li><a class="dropdown-item" href="${ctx}/admin/activity-log">
                <i class="bi bi-journal-text me-2 text-primary"></i>Activity Log
              </a></li>
            </ul>
          </li>
        </c:if>

      </ul>

      <ul class="navbar-nav ms-auto align-items-center gap-1">

        <li class="nav-item">
          <a class="nav-link" href="${ctx}/chat" title="Chat">
            <i class="bi bi-chat-dots fs-5"></i>
          </a>
        </li>

        <li class="nav-item notif-bell">
          <a class="nav-link" href="${ctx}/notifications" id="notifBell" title="Notifications">
            <i class="bi bi-bell fs-5"></i>
            <span class="badge bg-danger" id="notifCount" style="display:none">0</span>
          </a>
        </li>

        <li class="nav-item dropdown ms-1">
          <a class="nav-link dropdown-toggle d-flex align-items-center gap-2" href="#" data-bs-toggle="dropdown">
            <c:choose>
              <c:when test="${not empty user.profilePic}">
                <img src="${ctx}/uploads/${user.profilePic}" class="avatar" alt="avatar"/>
              </c:when>
              <c:otherwise>
                <span class="avatar-placeholder">${user.firstName.substring(0,1)}</span>
              </c:otherwise>
            </c:choose>
            <span class="d-none d-lg-inline">${user.firstName}</span>
          </a>
          <ul class="dropdown-menu dropdown-menu-end">
            <li class="px-3 py-2 text-muted" style="font-size:.78rem">
              Signed in as <strong>${user.email}</strong>
            </li>
            <li><hr class="dropdown-divider"/></li>
            <li><a class="dropdown-item" href="${ctx}/profile">
              <i class="bi bi-person me-2"></i>My Profile
            </a></li>
            <li><a class="dropdown-item" href="${ctx}/gradebook">
              <i class="bi bi-bar-chart me-2"></i>My Grades
            </a></li>
            <li><hr class="dropdown-divider"/></li>
            <li>
              <form action="${ctx}/logout" method="post">
                <button class="dropdown-item text-danger" type="submit">
                  <i class="bi bi-box-arrow-right me-2"></i>Logout
                </button>
              </form>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</nav>

<div id="toast-container" class="toast-container"></div>
