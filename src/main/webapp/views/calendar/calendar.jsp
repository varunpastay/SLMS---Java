<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Calendar – SLMS</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link href="${pageContext.request.contextPath}/css/slms.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.css" rel="stylesheet">
  <style>
    #calendar { background: #fff; border-radius: 16px; padding: 1.5rem; box-shadow: 0 4px 24px rgba(0,0,0,0.08); }
    .fc-event { cursor: pointer; }
    .legend-dot { width:12px;height:12px;border-radius:50%;display:inline-block;margin-right:6px; }
  </style>
</head>
<body>
<jsp:include page="/views/base-header.jsp"/>

<div class="container-fluid py-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <div>
      <h2 class="fw-bold mb-0"><i class="bi bi-calendar3 me-2 text-primary"></i>Academic Calendar</h2>
      <p class="text-muted mb-0">Assignment due dates and quiz schedules</p>
    </div>
    <div class="d-flex gap-3 align-items-center">
      <span><span class="legend-dot" style="background:#dc3545"></span>Assignment Due</span>
      <span><span class="legend-dot" style="background:#0d6efd"></span>Quiz</span>
    </div>
  </div>

  <div id="calendar"></div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.11/index.global.min.js"></script>
<script>
  document.addEventListener('DOMContentLoaded', function () {
    const cal = new FullCalendar.Calendar(document.getElementById('calendar'), {
      initialView: 'dayGridMonth',
      headerToolbar: { left: 'prev,next today', center: 'title', right: 'dayGridMonth,timeGridWeek,listMonth' },
      events: '${pageContext.request.contextPath}/calendar?format=json',
      eventClick: function(info) {
        if (info.event.url) { info.jsEvent.preventDefault(); window.location.href = info.event.url; }
      },
      height: 'auto',
      nowIndicator: true
    });
    cal.render();
  });
</script>
</body>
</html>
