package com.slms.util;

import com.slms.dto.UserDTO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class SessionUtil {

    public static UserDTO getLoggedUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (UserDTO) session.getAttribute("loggedUser");
    }

    public static void setLoggedUser(HttpServletRequest req, UserDTO user) {
        req.getSession(true).setAttribute("loggedUser", user);
    }

    public static void invalidate(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null) session.invalidate();
    }

    public static boolean requireLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (getLoggedUser(req) == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    public static boolean requireRole(HttpServletRequest req, HttpServletResponse resp, String... roles) throws IOException {
        UserDTO user = getLoggedUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        for (String role : roles) {
            if (role.equalsIgnoreCase(user.getRole())) return true;
        }
        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
        return false;
    }

    private SessionUtil() {}
}
