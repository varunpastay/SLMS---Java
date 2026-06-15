package com.slms.filter;

import com.slms.dto.UserDTO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Set;

@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final Set<String> PUBLIC_PATHS = Set.of(
        "/login", "/register", "/verify-otp", "/certificate/verify"
    );

    private static final Set<String> TEACHER_ONLY = Set.of(
        "/course/create", "/course/edit", "/course/delete",
        "/assignment/create", "/assignment/edit", "/assignment/delete",
        "/assignment/grade", "/quiz/create", "/quiz/edit", "/quiz/delete",
        "/material/add", "/material/delete", "/feedback/teacher"
    );

    private static final Set<String> ADMIN_ONLY = Set.of(
        "/admin"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String contextPath = req.getContextPath();
        String path = req.getRequestURI().substring(contextPath.length());

        // Always allow static resources
        if (path.startsWith("/static/") || path.startsWith("/favicon")) {
            chain.doFilter(request, response);
            return;
        }

        // Allow public pages without session
        for (String pub : PUBLIC_PATHS) {
            if (path.equals(pub) || path.startsWith(pub + "/")) {
                chain.doFilter(request, response);
                return;
            }
        }

        // Check session
        HttpSession session = req.getSession(false);
        UserDTO user = (session != null) ? (UserDTO) session.getAttribute("loggedUser") : null;

        if (user == null) {
            resp.sendRedirect(contextPath + "/login");
            return;
        }

        // Teacher-only access
        for (String teacherPath : TEACHER_ONLY) {
            if (path.startsWith(teacherPath)) {
                if (!"TEACHER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                    return;
                }
                break;
            }
        }

        // Admin-only access
        for (String adminPath : ADMIN_ONLY) {
            if (path.startsWith(adminPath)) {
                if (!"ADMIN".equals(user.getRole())) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
                    return;
                }
                break;
            }
        }

        chain.doFilter(request, response);
    }
}
