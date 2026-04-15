package com.project.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Role-based access filter.
 * Ensures students cannot access /admin/* and admins cannot access /student/*.
 * Runs AFTER AuthFilter (so session is guaranteed to exist).
 */
@WebFilter(urlPatterns = {"/student/*", "/admin/*"})
public class RoleFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No initialization needed
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(false);

        // AuthFilter should have already checked this, but be safe
        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");
        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();

        // Student trying to access admin pages
        if (uri.startsWith(contextPath + "/admin") && !"ADMIN".equals(role)) {
            response.sendRedirect(contextPath + "/student/dashboard");
            return;
        }

        // Admin trying to access student pages
        if (uri.startsWith(contextPath + "/student") && !"STUDENT".equals(role)) {
            response.sendRedirect(contextPath + "/admin/dashboard");
            return;
        }

        // Role is valid for this URL — continue
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }
}
