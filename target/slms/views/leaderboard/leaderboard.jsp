<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Leaderboard"/>
<%@ include file="/views/base-header.jsp" %>

<h4 class="fw-bold mb-4"><i class="bi bi-trophy me-2 text-warning"></i>Leaderboard</h4>

<div class="card shadow-sm">
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover align-middle mb-0">
        <thead class="table-light">
          <tr>
            <th style="width:60px">Rank</th>
            <th>Student</th>
            <th>Total Score</th>
            <th>Quizzes Passed</th>
            <th>Assignments Graded</th>
          </tr>
        </thead>
        <tbody>
        <c:forEach var="entry" items="${entries}">
          <tr class="${entry.studentId == user.id ? 'table-warning fw-bold' : ''}">
            <td class="text-center">
              <c:choose>
                <c:when test="${entry.rank == 1}"><span class="fs-4">&#127947;</span></c:when>
                <c:when test="${entry.rank == 2}"><span class="fs-4">&#129352;</span></c:when>
                <c:when test="${entry.rank == 3}"><span class="fs-4">&#129353;</span></c:when>
                <c:otherwise><span class="text-muted">#${entry.rank}</span></c:otherwise>
              </c:choose>
            </td>
            <td>
              <div class="d-flex align-items-center">
                <c:choose>
                  <c:when test="${not empty entry.profilePic}">
                    <img src="${ctx}/uploads/${entry.profilePic}" class="rounded-circle me-2" width="32" height="32" style="object-fit:cover" alt="avatar"/>
                  </c:when>
                  <c:otherwise>
                    <i class="bi bi-person-circle fs-4 me-2 text-secondary"></i>
                  </c:otherwise>
                </c:choose>
                ${entry.studentName}
                <c:if test="${entry.studentId == user.id}">
                  <span class="badge bg-warning text-dark ms-2">You</span>
                </c:if>
              </div>
            </td>
            <td class="fw-bold"><fmt:formatNumber value="${entry.totalScore}" maxFractionDigits="1"/></td>
            <td>${entry.quizzesPassed}</td>
            <td>${entry.assignmentsGraded}</td>
          </tr>
        </c:forEach>
        <c:if test="${empty entries}">
          <tr><td colspan="5" class="text-center text-muted py-5">No data yet.</td></tr>
        </c:if>
        </tbody>
      </table>
    </div>
  </div>
</div>

<%@ include file="/views/base-footer.jsp" %>
