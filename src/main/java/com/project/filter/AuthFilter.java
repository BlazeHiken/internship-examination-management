package com.project.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Authentication filter — blocks unauthenticated users from protected pages.
 * Applied to /student/* and /admin/* URL patterns.
 * Allows /login, /register, and static resources to pass through.
 */
@WebFilter(urlPatterns = {"/student/*", "/admin/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No initialization needed
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // Check for active session with user attribute
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            // No valid session — redirect to login
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // User is authenticated — continue the filter chain
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }
}
