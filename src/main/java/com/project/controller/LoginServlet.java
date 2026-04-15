package com.project.controller;

import com.project.dao.UserDAO;
import com.project.model.User;

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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

            // Create new session
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("role", user.getRole());
            session.setMaxInactiveInterval(30 * 60); // 30 minutes timeout

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
