package com.project.controller;

import com.project.dao.CompanyDAO;
import com.project.dao.InternshipDAO;
import com.project.model.Company;
import com.project.model.Internship;
import com.project.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.util.List;

/**
 * Admin servlet for managing internships.
 * GET  /admin/internships             → list all internships
 * GET  /admin/internships?action=add  → show add form (with company dropdown)
 * GET  /admin/internships?action=edit&id=X → show edit form
 * POST /admin/internships?action=add  → insert new internship
 * POST /admin/internships?action=edit → update internship
 * POST /admin/internships?action=delete → delete internship
 */
@WebServlet("/admin/internships")
public class InternshipServlet extends HttpServlet {

    private InternshipDAO internshipDAO = new InternshipDAO();
    private CompanyDAO companyDAO = new CompanyDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("add".equals(action)) {
                // Load company list for dropdown
                List<Company> companies = companyDAO.getAll();
                request.setAttribute("companies", companies);
                request.getRequestDispatcher("/admin/internship_form.jsp").forward(request, response);

            } else if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Internship internship = internshipDAO.getById(id);
                if (internship == null) {
                    response.sendRedirect("internships?error=notfound");
                    return;
                }
                List<Company> companies = companyDAO.getAll();
                request.setAttribute("internship", internship);
                request.setAttribute("companies", companies);
                request.getRequestDispatcher("/admin/internship_form.jsp").forward(request, response);

            } else {
                // Default: list all internships
                List<Internship> internships = internshipDAO.getAll();
                request.setAttribute("internships", internships);
                request.getRequestDispatcher("/admin/internships.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error occurred.");
            request.getRequestDispatcher("/admin/internships.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                internshipDAO.delete(id);
                response.sendRedirect("internships?deleted=true");
                return;
            }

            // Add or Edit — validate inputs
            String companyIdStr = request.getParameter("companyId");
            String role = request.getParameter("role");
            String stipendStr = request.getParameter("stipend");
            String deadlineStr = request.getParameter("deadline");

            StringBuilder errors = new StringBuilder();

            int companyId = 0;
            if (companyIdStr != null && !companyIdStr.isEmpty()) {
                companyId = Integer.parseInt(companyIdStr);
            } else {
                errors.append("Company is required. ");
            }

            if (!ValidationUtil.isNotEmpty(role)) {
                errors.append("Role is required. ");
            }

            double stipend = 0;
            if (stipendStr != null && !stipendStr.isEmpty()) {
                try {
                    stipend = Double.parseDouble(stipendStr);
                    if (!ValidationUtil.isValidStipend(stipend)) {
                        errors.append("Stipend cannot be negative. ");
                    }
                } catch (NumberFormatException e) {
                    errors.append("Invalid stipend format. ");
                }
            }

            Date deadline = null;
            if (deadlineStr != null && !deadlineStr.isEmpty()) {
                try {
                    deadline = Date.valueOf(deadlineStr);
                } catch (IllegalArgumentException e) {
                    errors.append("Invalid deadline format. ");
                }
            } else {
                errors.append("Deadline is required. ");
            }

            if (errors.length() > 0) {
                request.setAttribute("error", errors.toString().trim());
                List<Company> companies = companyDAO.getAll();
                request.setAttribute("companies", companies);
                // Preserve form values
                Internship internship = new Internship(companyId, role, stipend, deadline);
                if ("edit".equals(action)) {
                    internship.setInternshipId(Integer.parseInt(request.getParameter("internshipId")));
                }
                request.setAttribute("internship", internship);
                request.getRequestDispatcher("/admin/internship_form.jsp").forward(request, response);
                return;
            }

            if ("add".equals(action)) {
                Internship internship = new Internship(companyId, role, stipend, deadline);
                internshipDAO.add(internship);
                response.sendRedirect("internships?added=true");

            } else if ("edit".equals(action)) {
                int internshipId = Integer.parseInt(request.getParameter("internshipId"));
                Internship internship = new Internship(companyId, role, stipend, deadline);
                internship.setInternshipId(internshipId);
                internshipDAO.update(internship);
                response.sendRedirect("internships?updated=true");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to save internship.");
            try {
                request.setAttribute("companies", companyDAO.getAll());
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            request.getRequestDispatcher("/admin/internship_form.jsp").forward(request, response);
        }
    }
}
