package com.project.controller;

import com.project.dao.ApplicationDAO;
import com.project.dao.InternshipDAO;
import com.project.model.Application;
import com.project.model.Internship;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Admin servlet for managing applications.
 * GET  /admin/applications                → list all applications (overview)
 * GET  /admin/applications?internshipId=X → list applications for a specific internship
 * POST /admin/applications                → update application status (shortlist/reject/select)
 */
@WebServlet("/admin/applications")
public class ApplicationManageServlet extends HttpServlet {

    private ApplicationDAO applicationDAO = new ApplicationDAO();
    private InternshipDAO internshipDAO = new InternshipDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String internshipIdStr = request.getParameter("internshipId");

        try {
            if (internshipIdStr != null && !internshipIdStr.isEmpty()) {
                // Filter by specific internship
                int internshipId = Integer.parseInt(internshipIdStr);
                Internship internship = internshipDAO.getById(internshipId);
                List<Application> applications = applicationDAO.getByInternship(internshipId);
                request.setAttribute("internship", internship);
                request.setAttribute("applications", applications);
            } else {
                // Show all applications
                List<Application> applications = applicationDAO.getAll();
                request.setAttribute("applications", applications);
            }

            // Also load all internships for the filter dropdown
            List<Internship> internships = internshipDAO.getAll();
            request.setAttribute("internships", internships);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load applications.");
        }

        request.getRequestDispatcher("/admin/applications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String applicationIdStr = request.getParameter("applicationId");
        String newStatus = request.getParameter("status");
        String internshipIdStr = request.getParameter("internshipId");

        try {
            int applicationId = Integer.parseInt(applicationIdStr);
            applicationDAO.updateStatus(applicationId, newStatus);

            // Redirect back with filter preserved
            String redirect = "applications?updated=true";
            if (internshipIdStr != null && !internshipIdStr.isEmpty()) {
                redirect += "&internshipId=" + internshipIdStr;
            }
            response.sendRedirect(redirect);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("applications?error=failed");
        }
    }
}
