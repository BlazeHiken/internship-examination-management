package com.project.filter;

import com.project.dao.AuditDAO;
import com.project.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Audit filter that logs key user actions to audit_logs table.
 * Intercepts POST requests on important endpoints and logs the action.
 * GET requests are not logged to avoid noise.
 */
@WebFilter(urlPatterns = {"/*"})
public class AuditFilter implements Filter {

    private AuditDAO auditDAO = new AuditDAO();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Only log POST actions (state-changing operations)
        if ("POST".equalsIgnoreCase(req.getMethod()) && user != null) {
            String uri = req.getRequestURI();
            String contextPath = req.getContextPath();
            String path = uri.substring(contextPath.length());
            String action = resolveAction(path, req);

            if (action != null) {
                try {
                    String ip = req.getRemoteAddr();
                    String ua = req.getHeader("User-Agent");
                    auditDAO.logAction(user.getUserId(), action, ip, ua);
                } catch (Exception e) {
                    // Audit logging should never block the request
                    e.printStackTrace();
                }
            }
        }

        // Also track session activity for logged-in users
        if (user != null && session != null) {
            try {
                auditDAO.trackSession(
                    session.getId(), user.getUserId(),
                    req.getRemoteAddr(), req.getHeader("User-Agent")
                );
            } catch (Exception e) {
                // Silent fail — don't block requests for tracking errors
            }
        }

        chain.doFilter(request, response);
    }

    /**
     * Maps request paths to human-readable action descriptions.
     */
    private String resolveAction(String path, HttpServletRequest req) {
        if (path.contains("/login")) return "LOGIN_ATTEMPT";
        if (path.contains("/register")) return "REGISTRATION";
        if (path.contains("/student/apply")) return "APPLIED_FOR_INTERNSHIP";
        if (path.contains("/student/profile")) return "PROFILE_UPDATE";
        if (path.contains("/student/exam")) {
            String action = req.getParameter("action");
            if ("submit".equals(action) || "autosubmit".equals(action)) return "EXAM_SUBMITTED";
            return "EXAM_ANSWER_SAVED";
        }
        if (path.contains("/admin/applications")) return "APPLICATION_STATUS_CHANGED";
        if (path.contains("/admin/companies")) return "COMPANY_MODIFIED";
        if (path.contains("/admin/internships")) return "INTERNSHIP_MODIFIED";
        if (path.contains("/admin/exams")) {
            String action = req.getParameter("action");
            if ("add".equals(action)) return "EXAM_CREATED";
            if ("delete".equals(action)) return "EXAM_DELETED";
            if ("addQuestion".equals(action)) return "QUESTION_ADDED";
            if ("evaluate".equals(action)) return "SUBJECTIVE_GRADED";
            return null;
        }
        return null; // Don't log unrecognized actions
    }

    @Override
    public void destroy() {}
}
