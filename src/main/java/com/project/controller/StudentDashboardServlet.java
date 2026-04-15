package com.project.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Student dashboard controller.
 * GET /student/dashboard → forward to student/dashboard.jsp
 * Protected by AuthFilter and RoleFilter.
 */
@WebServlet("/student/dashboard")
public class StudentDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/student/dashboard.jsp").forward(request, response);
    }
}
