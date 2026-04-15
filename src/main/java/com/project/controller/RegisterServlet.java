package com.project.controller;

import com.project.dao.UserDAO;
import com.project.model.User;
import com.project.model.Student;
import com.project.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Handles user registration.
 * GET  /register → forward to register.jsp
 * POST /register → validate → insert user (+ student if role=STUDENT) → redirect to login
 *
 * Uses transactional registration: both 'users' and 'students' inserts
 * happen in one transaction via UserDAO.registerFull().
 */
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Common fields
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        // --- Validation ---
        StringBuilder errors = new StringBuilder();

        if (!ValidationUtil.isNotEmpty(name)) {
            errors.append("Name is required. ");
        }
        if (!ValidationUtil.isValidEmail(email)) {
            errors.append("Invalid email format. ");
        }
        if (!ValidationUtil.isValidPassword(password)) {
            errors.append("Password must be at least 6 characters. ");
        }
        if (role == null || (!"ADMIN".equals(role) && !"STUDENT".equals(role))) {
            errors.append("Invalid role selected. ");
        }

        // Student-specific fields
        String course = null;
        double cgpa = 0;
        String phone = null;

        if ("STUDENT".equals(role)) {
            course = request.getParameter("course");
            String cgpaStr = request.getParameter("cgpa");
            phone = request.getParameter("phone");

            if (!ValidationUtil.isNotEmpty(course)) {
                errors.append("Course is required for students. ");
            }
            if (cgpaStr != null && !cgpaStr.isEmpty()) {
                try {
                    cgpa = Double.parseDouble(cgpaStr);
                    if (!ValidationUtil.isValidCGPA(cgpa)) {
                        errors.append("CGPA must be between 0 and 10. ");
                    }
                } catch (NumberFormatException e) {
                    errors.append("Invalid CGPA format. ");
                }
            }
            if (!ValidationUtil.isValidPhone(phone)) {
                errors.append("Phone must be 10-15 digits. ");
            }
        }

        // If validation errors, return to form with error messages
        if (errors.length() > 0) {
            request.setAttribute("error", errors.toString().trim());
            // Preserve form values
            request.setAttribute("name", name);
            request.setAttribute("email", email);
            request.setAttribute("role", role);
            request.setAttribute("course", course);
            request.setAttribute("phone", phone);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        try {
            // Check if email already exists
            if (userDAO.emailExists(email)) {
                request.setAttribute("error", "An account with this email already exists.");
                request.setAttribute("name", name);
                request.setAttribute("email", email);
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            // Build User object
            User user = new User(name, email, password, role);

            // Build Student object if applicable
            Student student = null;
            if ("STUDENT".equals(role)) {
                student = new Student(0, course, cgpa, phone);
            }

            // Transactional registration (users + students in one transaction)
            userDAO.registerFull(user, student);

            // Redirect to login with success message
            response.sendRedirect("login?registered=true");

        } catch (SQLException e) {
            e.printStackTrace();
            // Check for duplicate entry (email or phone unique constraint)
            if (e.getMessage().contains("Duplicate entry")) {
                request.setAttribute("error", "Email or phone number already registered.");
            } else {
                request.setAttribute("error", "Registration failed. Please try again.");
            }
            request.setAttribute("name", name);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
}
