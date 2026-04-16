package com.project.controller;

import com.project.dao.CompanyDAO;
import com.project.model.Company;
import com.project.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Admin servlet for managing companies.
 * GET  /admin/companies          → list all companies
 * GET  /admin/companies?action=add    → show add form
 * GET  /admin/companies?action=edit&id=X → show edit form
 * POST /admin/companies?action=add    → insert new company
 * POST /admin/companies?action=edit   → update company
 * POST /admin/companies?action=delete → delete company
 */
@WebServlet("/admin/companies")
public class CompanyServlet extends HttpServlet {

    private CompanyDAO companyDAO = new CompanyDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("add".equals(action)) {
                // Show empty add form
                request.getRequestDispatcher("/admin/company_form.jsp").forward(request, response);

            } else if ("edit".equals(action)) {
                // Load company and show edit form
                int id = Integer.parseInt(request.getParameter("id"));
                Company company = companyDAO.getById(id);
                if (company == null) {
                    response.sendRedirect("companies?error=notfound");
                    return;
                }
                request.setAttribute("company", company);
                request.getRequestDispatcher("/admin/company_form.jsp").forward(request, response);

            } else {
                // Default: list all companies
                List<Company> companies = companyDAO.getAll();
                request.setAttribute("companies", companies);
                request.getRequestDispatcher("/admin/companies.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error occurred.");
            request.getRequestDispatcher("/admin/companies.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("delete".equals(action)) {
                // Delete company
                int id = Integer.parseInt(request.getParameter("id"));
                companyDAO.delete(id);
                response.sendRedirect("companies?deleted=true");
                return;
            }

            // Add or Edit — validate inputs
            String companyName = request.getParameter("companyName");
            String location = request.getParameter("location");
            String cgpaStr = request.getParameter("eligibilityCgpa");

            StringBuilder errors = new StringBuilder();
            if (!ValidationUtil.isNotEmpty(companyName)) {
                errors.append("Company name is required. ");
            }
            if (!ValidationUtil.isNotEmpty(location)) {
                errors.append("Location is required. ");
            }

            double eligibilityCgpa = 0;
            if (cgpaStr != null && !cgpaStr.isEmpty()) {
                try {
                    eligibilityCgpa = Double.parseDouble(cgpaStr);
                    if (!ValidationUtil.isValidCGPA(eligibilityCgpa)) {
                        errors.append("Eligibility CGPA must be between 0 and 10. ");
                    }
                } catch (NumberFormatException e) {
                    errors.append("Invalid CGPA format. ");
                }
            } else {
                errors.append("Eligibility CGPA is required. ");
            }

            if (errors.length() > 0) {
                request.setAttribute("error", errors.toString().trim());
                // Preserve form values
                Company company = new Company(companyName, location, eligibilityCgpa);
                if ("edit".equals(action)) {
                    company.setCompanyId(Integer.parseInt(request.getParameter("companyId")));
                }
                request.setAttribute("company", company);
                request.getRequestDispatcher("/admin/company_form.jsp").forward(request, response);
                return;
            }

            if ("add".equals(action)) {
                Company company = new Company(companyName, location, eligibilityCgpa);
                companyDAO.add(company);
                response.sendRedirect("companies?added=true");

            } else if ("edit".equals(action)) {
                int companyId = Integer.parseInt(request.getParameter("companyId"));
                Company company = new Company(companyName, location, eligibilityCgpa);
                company.setCompanyId(companyId);
                companyDAO.update(company);
                response.sendRedirect("companies?updated=true");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to save company.");
            request.getRequestDispatcher("/admin/company_form.jsp").forward(request, response);
        }
    }
}
