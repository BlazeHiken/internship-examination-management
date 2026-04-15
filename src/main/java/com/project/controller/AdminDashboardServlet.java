package com.project.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Admin dashboard controller.
 * GET /admin/dashboard → forward to admin/dashboard.jsp
 * Protected by AuthFilter and RoleFilter.
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}
