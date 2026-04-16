package com.project.controller;

import com.project.dao.StudentDAO;
import com.project.dao.UserDAO;
import com.project.model.Student;
import com.project.model.User;
import com.project.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Handles student profile view and update.
 * GET  /student/profile → load student data → forward to profile.jsp
 * POST /student/profile → validate → update student + user → redirect with success
 */
@WebServlet("/student/profile")
public class ProfileServlet extends HttpServlet {

    private StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");

        try {
            Student student = studentDAO.getByUserId(user.getUserId());
            if (student == null) {
                request.setAttribute("error", "Student profile not found.");
            }
            request.setAttribute("student", student);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load profile.");
        }

        request.getRequestDispatcher("/student/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");

        String name = request.getParameter("name");
        String course = request.getParameter("course");
        String cgpaStr = request.getParameter("cgpa");
        String phone = request.getParameter("phone");

        // --- Validation ---
        StringBuilder errors = new StringBuilder();

        if (!ValidationUtil.isNotEmpty(name)) {
            errors.append("Name is required. ");
        }
        if (!ValidationUtil.isNotEmpty(course)) {
            errors.append("Course is required. ");
        }

        double cgpa = 0;
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

        try {
            Student student = studentDAO.getByUserId(user.getUserId());

            if (errors.length() > 0) {
                request.setAttribute("error", errors.toString().trim());
                request.setAttribute("student", student);
                request.getRequestDispatcher("/student/profile.jsp").forward(request, response);
                return;
            }

            // Update student object
            student.setName(name);
            student.setCourse(course);
            student.setCgpa(cgpa);
            student.setPhone(phone);

            studentDAO.updateProfile(student);

            // Also update the session user's name so navbar reflects changes
            user.setName(name);
            request.getSession().setAttribute("user", user);

            response.sendRedirect("profile?updated=true");

        } catch (SQLException e) {
            e.printStackTrace();
            if (e.getMessage().contains("Duplicate entry")) {
                request.setAttribute("error", "Phone number already in use by another student.");
            } else {
                request.setAttribute("error", "Failed to update profile.");
            }
            try {
                request.setAttribute("student", studentDAO.getByUserId(user.getUserId()));
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            request.getRequestDispatcher("/student/profile.jsp").forward(request, response);
        }
    }
}
