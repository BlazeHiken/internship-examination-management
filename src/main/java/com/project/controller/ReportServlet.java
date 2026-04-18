package com.project.controller;

import com.project.dao.ReportDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Admin reports dashboard.
 * GET /admin/reports → overview + application + exam analytics
 */
@WebServlet("/admin/reports")
public class ReportServlet extends HttpServlet {

    private ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Overview stats
            Map<String, Integer> overview = reportDAO.getOverviewStats();
            request.setAttribute("overview", overview);

            // Application breakdown by status
            Map<String, Integer> appsByStatus = reportDAO.getApplicationsByStatus();
            request.setAttribute("appsByStatus", appsByStatus);

            // Applications by company
            List<Map<String, Object>> appsByCompany = reportDAO.getApplicationsByCompany();
            request.setAttribute("appsByCompany", appsByCompany);

            // Exam performance
            List<Map<String, Object>> examPerformance = reportDAO.getExamPerformance();
            request.setAttribute("examPerformance", examPerformance);

            // Top performers
            List<Map<String, Object>> topPerformers = reportDAO.getTopPerformers();
            request.setAttribute("topPerformers", topPerformers);

            // Placement report
            List<Map<String, Object>> placements = reportDAO.getPlacementReport();
            request.setAttribute("placements", placements);

            // Recent activity
            List<Map<String, Object>> recentActivity = reportDAO.getRecentActivity();
            request.setAttribute("recentActivity", recentActivity);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load report data.");
        }

        request.getRequestDispatcher("/admin/reports.jsp").forward(request, response);
    }
}
