package com.project.controller;

import com.project.dao.UserDAO;
import com.project.dao.AuditDAO;
import com.project.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Handles user logout.
 * GET /logout → log action → set is_logged_in = false → invalidate session → redirect to login
 */
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();
    private AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session != null) {
            // Get user from session to update DB flag
            User user = (User) session.getAttribute("user");
            if (user != null) {
                try {
                    // Log logout action
                    auditDAO.logAction(user.getUserId(), "LOGOUT",
                        request.getRemoteAddr(), request.getHeader("User-Agent"));
                    // Remove session tracking
                    auditDAO.removeSession(session.getId());
                    userDAO.setLoggedIn(user.getUserId(), false);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            // Invalidate the HTTP session
            session.invalidate();
        }

        // Redirect to login page
        response.sendRedirect("login");
    }
}
