package com.project.controller;

import com.project.dao.ApplicationDAO;
import com.project.dao.StudentDAO;
import com.project.model.Application;
import com.project.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Student view of their applications.
 * GET /student/applications → list all applications for this student
 */
@WebServlet("/student/applications")
public class MyApplicationsServlet extends HttpServlet {

    private ApplicationDAO applicationDAO = new ApplicationDAO();
    private StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");

        try {
            int studentId = studentDAO.getStudentId(user.getUserId());

            if (studentId == -1) {
                request.setAttribute("error", "Student profile not found.");
            } else {
                List<Application> applications = applicationDAO.getByStudent(studentId);
                request.setAttribute("applications", applications);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load applications.");
        }

        request.getRequestDispatcher("/student/my_applications.jsp").forward(request, response);
    }
}
