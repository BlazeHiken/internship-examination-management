package com.project.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * Prevents browser from caching pages.
 * This ensures that pressing the browser "Back" button doesn't show
 * stale/cached pages — the browser MUST re-request from the server.
 *
 * Without this, a user can press Back after login and see the login page
 * (from cache), or press Back after logout and see the dashboard (from cache).
 */
@WebFilter(urlPatterns = {"/*"})
public class NoCacheFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No initialization needed
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletResponse response = (HttpServletResponse) res;

        // Tell the browser to NEVER cache any page
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0
        response.setDateHeader("Expires", 0); // Proxies

        chain.doFilter(req, response);
    }

    @Override
    public void destroy() {
        // No cleanup needed
    }
}
