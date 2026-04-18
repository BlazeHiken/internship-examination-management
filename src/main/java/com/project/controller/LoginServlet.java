package com.project.controller;

import com.project.dao.UserDAO;
import com.project.model.User;

import com.project.dao.AuditDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Handles user login.
 * GET  /login → forward to login.jsp
 * POST /login → authenticate → create session → redirect by role
 *
 * Enforces single-session: if user is already logged in elsewhere,
 * the previous session is invalidated (force logout) and a new login is allowed.
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();
    private AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // If redirected due to session conflict, show login page (don't auto-redirect)
        String error = request.getParameter("error");
        if ("session_conflict".equals(error)) {
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // If user already has an active session, redirect to dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            redirectToDashboard(response, user.getRole());
            return;
        }

        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            // Authenticate against database
            User user = userDAO.authenticate(email, password);

            if (user == null) {
                // Invalid credentials
                request.setAttribute("error", "Invalid email or password.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // Single-session enforcement:
            // If user is already logged in elsewhere, force-logout the old session
            if (userDAO.isAlreadyLoggedIn(user.getUserId())) {
                userDAO.forceLogout(user.getUserId());
            }

            // Mark user as logged in
            userDAO.setLoggedIn(user.getUserId(), true);

            // Invalidate any existing session to prevent cross-tab conflicts
            HttpSession existingSession = request.getSession(false);
            if (existingSession != null) {
                existingSession.invalidate();
            }

            // Create fresh session
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("role", user.getRole());
            session.setMaxInactiveInterval(30 * 60); // 30 minutes timeout

            // Log login action and track session
            try {
                auditDAO.logAction(user.getUserId(), "LOGIN_SUCCESS",
                    request.getRemoteAddr(), request.getHeader("User-Agent"));
                auditDAO.trackSession(session.getId(), user.getUserId(),
                    request.getRemoteAddr(), request.getHeader("User-Agent"));
            } catch (SQLException ex) {
                // Audit should never block login
                ex.printStackTrace();
            }

            // Redirect based on role
            redirectToDashboard(response, user.getRole());

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "A system error occurred. Please try again.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    /**
     * Redirects to the appropriate dashboard based on user role.
     */
    private void redirectToDashboard(HttpServletResponse response, String role) throws IOException {
        if ("ADMIN".equals(role)) {
            response.sendRedirect("admin/dashboard");
        } else {
            response.sendRedirect("student/dashboard");
        }
    }
}
