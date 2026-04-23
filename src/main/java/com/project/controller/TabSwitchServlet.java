package com.project.controller;

import com.project.dao.AuditDAO;
import com.project.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Handles tab-switch AJAX requests from the exam page.
 * Logs each tab switch to audit_logs as suspicious activity.
 * POST /student/tabswitch → log TAB_SWITCH event
 */
@WebServlet("/student/tabswitch")
public class TabSwitchServlet extends HttpServlet {

    private AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.setStatus(401);
            return;
        }

        String attemptId = request.getParameter("attemptId");
        String examName = request.getParameter("examName");
        String count = request.getParameter("count");

        try {
            String action = "TAB_SWITCH (Exam: " + (examName != null ? examName : "Unknown") + ", switch #" + count + ")";
            auditDAO.logAction(user.getUserId(), action,
                request.getRemoteAddr(), request.getHeader("User-Agent"));
        } catch (Exception e) {
            // Silent fail — never block the exam
            e.printStackTrace();
        }

        response.setStatus(200);
        response.getWriter().write("logged");
    }
}
