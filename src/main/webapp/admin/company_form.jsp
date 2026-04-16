<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.Company" %>
<%
    Company company = (Company) request.getAttribute("company");
    boolean isEdit = (company != null && company.getCompanyId() > 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEdit ? "Edit" : "Add" %> Company - Admin</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
            min-height: 100vh; color: #fff;
        }
        .navbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 16px 40px; background: rgba(255,255,255,0.05);
            backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255,255,255,0.08);
        }
        .navbar .brand { font-size: 20px; font-weight: 700; color: #ff6b81; }
        .navbar .nav-links { display: flex; gap: 24px; align-items: center; }
        .navbar .nav-links a { color: rgba(255,255,255,0.7); text-decoration: none; font-size: 14px; }
        .navbar .nav-links a:hover { color: #fff; }
        .navbar .nav-links a.active { color: #ff6b81; font-weight: 600; }
        .btn-logout {
            padding: 8px 20px; background: rgba(255,71,87,0.2); border: 1px solid rgba(255,71,87,0.4);
            border-radius: 6px; color: #ff6b81; text-decoration: none; font-size: 13px;
        }

        .main-content { padding: 40px; max-width: 600px; margin: 0 auto; }
        .page-title { font-size: 28px; font-weight: 700; margin-bottom: 24px; }

        .form-card {
            background: rgba(255,255,255,0.05); backdrop-filter: blur(10px);
            border: 1px solid rgba(255,255,255,0.1); border-radius: 12px; padding: 32px;
        }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; color: rgba(255,255,255,0.7); margin-bottom: 6px; font-size: 14px; }
        .form-group input {
            width: 100%; padding: 12px 16px; background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; color: #fff;
            font-size: 15px; outline: none; transition: border-color 0.3s, box-shadow 0.3s;
        }
        .form-group input:focus { border-color: #ff6b81; box-shadow: 0 0 0 3px rgba(255,107,129,0.2); }
        .form-group input::placeholder { color: rgba(255,255,255,0.3); }

        .btn-row { display: flex; gap: 12px; margin-top: 10px; }
        .btn-submit {
            flex: 1; padding: 12px; background: linear-gradient(135deg, #ff6b81, #ee5a6f);
            border: none; border-radius: 8px; color: #fff; font-size: 16px; font-weight: 600;
            cursor: pointer; transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn-submit:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(255,107,129,0.4); }
        .btn-cancel {
            flex: 1; padding: 12px; background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; color: rgba(255,255,255,0.7);
            font-size: 16px; font-weight: 600; cursor: pointer; text-decoration: none; text-align: center;
            transition: background 0.3s;
        }
        .btn-cancel:hover { background: rgba(255,255,255,0.12); }

        .message.error {
            text-align: center; margin-bottom: 16px; padding: 10px; border-radius: 8px;
            font-size: 14px; background: rgba(255,71,87,0.15); color: #ff6b81; border: 1px solid rgba(255,71,87,0.3);
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="brand">IEM Admin</div>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/companies" class="active">Companies</a>
            <a href="<%= request.getContextPath() %>/admin/internships">Internships</a>
            <a href="<%= request.getContextPath() %>/admin/applications">Applications</a>
            <a href="<%= request.getContextPath() %>/admin/exams">Exams</a>
            <a href="<%= request.getContextPath() %>/admin/reports">Reports</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="main-content">
        <h1 class="page-title"><%= isEdit ? "Edit Company" : "Add Company" %></h1>

        <% if (request.getAttribute("error") != null) { %>
            <div class="message error"><%= request.getAttribute("error") %></div>
        <% } %>

        <div class="form-card">
            <form action="companies" method="POST">
                <input type="hidden" name="action" value="<%= isEdit ? "edit" : "add" %>">
                <% if (isEdit) { %>
                    <input type="hidden" name="companyId" value="<%= company.getCompanyId() %>">
                <% } %>

                <div class="form-group">
                    <label for="companyName">Company Name</label>
                    <input type="text" id="companyName" name="companyName" placeholder="e.g., Google India"
                           value="<%= company != null ? company.getCompanyName() : "" %>" required>
                </div>

                <div class="form-group">
                    <label for="location">Location</label>
                    <input type="text" id="location" name="location" placeholder="e.g., Bangalore"
                           value="<%= company != null ? company.getLocation() : "" %>" required>
                </div>

                <div class="form-group">
                    <label for="eligibilityCgpa">Minimum Eligibility CGPA (0-10)</label>
                    <input type="number" id="eligibilityCgpa" name="eligibilityCgpa" placeholder="e.g., 7.00"
                           step="0.01" min="0" max="10"
                           value="<%= company != null ? String.format("%.2f", company.getEligibilityCgpa()) : "" %>" required>
                </div>

                <div class="btn-row">
                    <button type="submit" class="btn-submit"><%= isEdit ? "Update" : "Add" %> Company</button>
                    <a href="companies" class="btn-cancel">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
