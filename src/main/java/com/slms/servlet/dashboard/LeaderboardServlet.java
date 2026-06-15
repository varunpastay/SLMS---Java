package com.slms.servlet.dashboard;

import com.slms.dao.LeaderboardDAO;
import com.slms.dao.LeaderboardDAOImpl;
import com.slms.dto.LeaderboardEntryDTO;
import com.slms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/leaderboard")
public class LeaderboardServlet extends HttpServlet {

    private LeaderboardDAO leaderboardDAO;

    @Override
    public void init() {
        leaderboardDAO = new LeaderboardDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;
        try {
            List<LeaderboardEntryDTO> entries = leaderboardDAO.getLeaderboard(50);
            req.setAttribute("entries", entries);
            req.getRequestDispatcher("/views/leaderboard/leaderboard.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }
}
