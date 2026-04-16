package com.project.controller;

import com.project.dao.ApplicationDAO;
import com.project.dao.StudentDAO;
import com.project.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Handles student applying for an internship.
 * POST /student/apply → validate (no duplicate, deadline check) → apply with transaction
 *
 * Constraints enforced:
 * - Cannot apply twice (UNIQUE constraint + DAO check)
 * - Cannot apply after deadline
 */
@WebServlet("/student/apply")
public class ApplyServlet extends HttpServlet {

    private ApplicationDAO applicationDAO = new ApplicationDAO();
    private StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        String internshipIdStr = request.getParameter("internshipId");

        try {
            int internshipId = Integer.parseInt(internshipIdStr);
            int studentId = studentDAO.getStudentId(user.getUserId());

            if (studentId == -1) {
                response.sendRedirect("internships?error=profile");
                return;
            }

            // Check if already applied
            if (applicationDAO.hasApplied(studentId, internshipId)) {
                response.sendRedirect("internships?error=duplicate");
                return;
            }

            // Check if deadline has passed
            if (applicationDAO.isDeadlinePassed(internshipId)) {
                response.sendRedirect("internships?error=deadline");
                return;
            }

            // Apply (transactional — inserts into applications + application_logs)
            applicationDAO.apply(studentId, internshipId);
            response.sendRedirect("internships?applied=true");

        } catch (SQLException e) {
            e.printStackTrace();
            // Duplicate entry from DB constraint (race condition safety net)
            if (e.getMessage().contains("Duplicate entry")) {
                response.sendRedirect("internships?error=duplicate");
            } else {
                response.sendRedirect("internships?error=failed");
            }
        }
    }
}
