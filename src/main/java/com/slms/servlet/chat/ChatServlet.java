package com.slms.servlet.chat;

import com.slms.dao.*;
import com.slms.dto.*;
import com.slms.util.SessionUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/chat")
public class ChatServlet extends HttpServlet {

    private ChatDAO chatDAO;
    private UserDAO userDAO;

    @Override
    public void init() {
        chatDAO = new ChatDAOImpl();
        userDAO = new UserDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        UserDTO me = SessionUtil.getLoggedUser(req);

        try {
            String withParam = req.getParameter("with");
            String ajaxParam = req.getParameter("ajax");

            if (withParam != null) {
                int otherId = Integer.parseInt(withParam);
                UserDTO other = userDAO.findById(otherId);
                if (other == null) { resp.sendError(404); return; }

                chatDAO.markAsRead(otherId, me.getId());
                List<ChatMessageDTO> messages = chatDAO.findConversation(me.getId(), otherId);

                if ("1".equals(ajaxParam)) {
                    // Return JSON for polling
                    resp.setContentType("application/json;charset=UTF-8");
                    ObjectMapper mapper = new ObjectMapper();
                    mapper.registerModule(new JavaTimeModule());
                    mapper.disable(com.fasterxml.jackson.databind.SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
                    mapper.writeValue(resp.getOutputStream(), messages);
                    return;
                }

                req.setAttribute("other", other);
                req.setAttribute("messages", messages);
            }

            List<UserDTO> partners = chatDAO.findConversationPartners(me.getId());
            List<UserDTO> allUsers = userDAO.findAll();
            allUsers.removeIf(u -> u.getId() == me.getId());
            req.setAttribute("partners", partners);
            req.setAttribute("allUsers", allUsers);
            req.getRequestDispatcher("/views/chat/chatRoom.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        UserDTO me = SessionUtil.getLoggedUser(req);

        try {
            int receiverId = Integer.parseInt(req.getParameter("receiverId"));
            String message = req.getParameter("message");
            if (message == null || message.isBlank()) {
                resp.sendRedirect(req.getContextPath() + "/chat?with=" + receiverId);
                return;
            }

            ChatMessageDTO msg = new ChatMessageDTO();
            msg.setSenderId(me.getId());
            msg.setReceiverId(receiverId);
            msg.setMessage(message.trim());
            chatDAO.save(msg);

            // Check if AJAX request
            String accept = req.getHeader("Accept");
            if (accept != null && accept.contains("application/json")) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"status\":\"ok\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/chat?with=" + receiverId);
            }
        } catch (Exception e) { throw new ServletException(e); }
    }
}
