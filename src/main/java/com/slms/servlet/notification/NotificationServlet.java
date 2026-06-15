package com.slms.servlet.notification;

import com.slms.dao.NotificationDAO;
import com.slms.dao.NotificationDAOImpl;
import com.slms.dto.NotificationDTO;
import com.slms.dto.UserDTO;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    private NotificationDAO notificationDAO;

    @Override
    public void init() {
        notificationDAO = new NotificationDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        UserDTO user = SessionUtil.getLoggedUser(req);

        try {
            String action = req.getParameter("action");

            if ("count".equals(action)) {
                int count = notificationDAO.countUnread(user.getId());
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"count\":" + count + "}");
                return;
            }

            List<NotificationDTO> notifications = notificationDAO.findByUser(user.getId());
            req.setAttribute("notifications", notifications);
            req.getRequestDispatcher("/views/notification/notificationList.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        UserDTO user = SessionUtil.getLoggedUser(req);

        try {
            String action = req.getParameter("action");
            if ("markAllRead".equals(action)) {
                notificationDAO.markAllRead(user.getId());
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                notificationDAO.delete(id);
            }
            resp.sendRedirect(req.getContextPath() + "/notifications");
        } catch (Exception e) { throw new ServletException(e); }
    }
}
