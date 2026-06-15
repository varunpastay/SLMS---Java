package com.slms.servlet.admin;

import com.slms.dao.ActivityLogDAO;
import com.slms.dao.ActivityLogDAOImpl;
import com.slms.dto.ActivityLogDTO;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/activity-log")
public class ActivityLogServlet extends HttpServlet {

    private ActivityLogDAO activityLogDAO;

    @Override
    public void init() {
        activityLogDAO = new ActivityLogDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireRole(req, resp, "ADMIN")) return;

        try {
            int limit = 200;
            String limitStr = req.getParameter("limit");
            if (limitStr != null) {
                try { limit = Integer.parseInt(limitStr); } catch (NumberFormatException ignored) {}
            }
            List<ActivityLogDTO> logs = activityLogDAO.findRecent(limit);
            req.setAttribute("logs", logs);
            req.setAttribute("limit", limit);
            req.getRequestDispatcher("/views/admin/activityLog.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
