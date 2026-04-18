package com.project.controller;

import com.project.dao.AuditDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Admin audit & security dashboard.
 * GET /admin/audit → audit logs + active sessions
 */
@WebServlet("/admin/audit")
public class AuditServlet extends HttpServlet {

    private AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Recent audit logs (last 50)
            List<Map<String, Object>> logs = auditDAO.getRecentLogs(50);
            request.setAttribute("auditLogs", logs);

            // Active sessions
            List<Map<String, Object>> sessions = auditDAO.getActiveSessions();
            request.setAttribute("activeSessions", sessions);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load audit data.");
        }

        request.getRequestDispatcher("/admin/audit.jsp").forward(request, response);
    }
}
