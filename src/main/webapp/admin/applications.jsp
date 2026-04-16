<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.User" %>
<%@ page import="com.project.model.Application" %>
<%@ page import="com.project.model.Internship" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    List<Application> applications = (List<Application>) request.getAttribute("applications");
    List<Internship> internships = (List<Internship>) request.getAttribute("internships");
    Internship filterInternship = (Internship) request.getAttribute("internship");
    String filterInternshipId = request.getParameter("internshipId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Applications - Admin</title>
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

        .main-content { padding: 40px; max-width: 1200px; margin: 0 auto; }

        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .page-header h1 { font-size: 28px; font-weight: 700; }

        /* Filter bar */
        .filter-bar {
            display: flex; gap: 12px; align-items: center; margin-bottom: 24px;
            padding: 16px 20px; background: rgba(255,255,255,0.05); border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.08);
        }
        .filter-bar label { color: rgba(255,255,255,0.6); font-size: 14px; }
        .filter-bar select {
            padding: 8px 14px; background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15); border-radius: 6px;
            color: #fff; font-size: 14px; outline: none; flex: 1;
        }
        .filter-bar select option { background: #24243e; color: #fff; }
        .filter-bar .btn-filter {
            padding: 8px 20px; background: linear-gradient(135deg, #ff6b81, #ee5a6f);
            border: none; border-radius: 6px; color: #fff; font-size: 13px; font-weight: 600;
            cursor: pointer;
        }
        .filter-bar .btn-clear {
            padding: 8px 16px; background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15); border-radius: 6px;
            color: rgba(255,255,255,0.7); font-size: 13px; text-decoration: none;
        }

        .message { text-align: center; margin-bottom: 16px; padding: 10px; border-radius: 8px; font-size: 14px; }
        .message.success { background: rgba(46,213,115,0.15); color: #7bed9f; border: 1px solid rgba(46,213,115,0.3); }
        .message.error { background: rgba(255,71,87,0.15); color: #ff6b81; border: 1px solid rgba(255,71,87,0.3); }

        .data-table {
            width: 100%; border-collapse: collapse;
            background: rgba(255,255,255,0.05); border-radius: 12px; overflow: hidden;
        }
        .data-table th, .data-table td {
            padding: 12px 16px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.06);
        }
        .data-table th {
            background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.6);
            font-size: 11px; text-transform: uppercase; letter-spacing: 1px;
        }
        .data-table td { font-size: 13px; color: rgba(255,255,255,0.85); }
        .data-table tr:hover { background: rgba(255,255,255,0.03); }

        .status-badge {
            padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.5px;
        }
        .status-APPLIED { background: rgba(108,99,255,0.2); color: #a29bfe; border: 1px solid rgba(108,99,255,0.3); }
        .status-SHORTLISTED { background: rgba(253,203,110,0.2); color: #feca57; border: 1px solid rgba(253,203,110,0.3); }
        .status-SELECTED { background: rgba(46,213,115,0.2); color: #7bed9f; border: 1px solid rgba(46,213,115,0.3); }
        .status-REJECTED { background: rgba(255,71,87,0.2); color: #ff6b81; border: 1px solid rgba(255,71,87,0.3); }

        /* Action buttons */
        .action-form { display: inline-block; margin: 0 2px; }
        .btn-action {
            padding: 4px 10px; border: none; border-radius: 4px; font-size: 11px;
            font-weight: 600; cursor: pointer; transition: opacity 0.3s;
        }
        .btn-shortlist { background: rgba(253,203,110,0.25); color: #feca57; border: 1px solid rgba(253,203,110,0.4); }
        .btn-select { background: rgba(46,213,115,0.25); color: #7bed9f; border: 1px solid rgba(46,213,115,0.4); }
        .btn-reject { background: rgba(255,71,87,0.25); color: #ff6b81; border: 1px solid rgba(255,71,87,0.4); }
        .btn-action:hover { opacity: 0.8; }

        .empty-state { text-align: center; padding: 60px 20px; color: rgba(255,255,255,0.4); }
        .empty-state .icon { font-size: 48px; margin-bottom: 16px; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="brand">IEM Admin</div>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/companies">Companies</a>
            <a href="<%= request.getContextPath() %>/admin/internships">Internships</a>
            <a href="<%= request.getContextPath() %>/admin/applications" class="active">Applications</a>
            <a href="<%= request.getContextPath() %>/admin/exams">Exams</a>
            <a href="<%= request.getContextPath() %>/admin/reports">Reports</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="main-content">
        <div class="page-header">
            <h1>
                <% if (filterInternship != null) { %>
                    Applications for <%= filterInternship.getCompanyName() %> — <%= filterInternship.getRole() %>
                <% } else { %>
                    All Applications
                <% } %>
            </h1>
        </div>

        <!-- Filter by internship -->
        <form class="filter-bar" action="applications" method="GET">
            <label>Filter by Internship:</label>
            <select name="internshipId">
                <option value="">-- All Internships --</option>
                <% if (internships != null) {
                    for (Internship i : internships) { %>
                        <option value="<%= i.getInternshipId() %>"
                            <%= (filterInternshipId != null && filterInternshipId.equals(String.valueOf(i.getInternshipId()))) ? "selected" : "" %>>
                            <%= i.getCompanyName() %> — <%= i.getRole() %>
                        </option>
                <%  }
                } %>
            </select>
            <button type="submit" class="btn-filter">Filter</button>
            <a href="applications" class="btn-clear">Clear</a>
        </form>

        <% if ("true".equals(request.getParameter("updated"))) { %>
            <div class="message success">Application status updated successfully!</div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="message error"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (applications != null && !applications.isEmpty()) { %>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Student</th>
                        <th>Email</th>
                        <th>Course</th>
                        <th>CGPA</th>
                        <% if (filterInternship == null) { %>
                            <th>Company</th>
                            <th>Role</th>
                        <% } %>
                        <th>Applied</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Application app : applications) { %>
                        <tr>
                            <td><%= app.getApplicationId() %></td>
                            <td><%= app.getStudentName() %></td>
                            <td><%= app.getStudentEmail() %></td>
                            <td><%= app.getStudentCourse() %></td>
                            <td><%= String.format("%.2f", app.getStudentCgpa()) %></td>
                            <% if (filterInternship == null) { %>
                                <td><%= app.getCompanyName() %></td>
                                <td><%= app.getInternshipRole() %></td>
                            <% } %>
                            <td><%= app.getAppliedDate() != null ? app.getAppliedDate().toString().substring(0, 10) : "" %></td>
                            <td><span class="status-badge status-<%= app.getStatus() %>"><%= app.getStatus() %></span></td>
                            <td>
                                <% if (!"SELECTED".equals(app.getStatus()) && !"REJECTED".equals(app.getStatus())) { %>
                                    <!-- Shortlist button -->
                                    <% if (!"SHORTLISTED".equals(app.getStatus())) { %>
                                    <form class="action-form" action="applications" method="POST">
                                        <input type="hidden" name="applicationId" value="<%= app.getApplicationId() %>">
                                        <input type="hidden" name="status" value="SHORTLISTED">
                                        <input type="hidden" name="internshipId" value="<%= filterInternshipId != null ? filterInternshipId : "" %>">
                                        <button type="submit" class="btn-action btn-shortlist">Shortlist</button>
                                    </form>
                                    <% } %>
                                    <!-- Select button -->
                                    <form class="action-form" action="applications" method="POST">
                                        <input type="hidden" name="applicationId" value="<%= app.getApplicationId() %>">
                                        <input type="hidden" name="status" value="SELECTED">
                                        <input type="hidden" name="internshipId" value="<%= filterInternshipId != null ? filterInternshipId : "" %>">
                                        <button type="submit" class="btn-action btn-select">Select</button>
                                    </form>
                                    <!-- Reject button -->
                                    <form class="action-form" action="applications" method="POST">
                                        <input type="hidden" name="applicationId" value="<%= app.getApplicationId() %>">
                                        <input type="hidden" name="status" value="REJECTED">
                                        <input type="hidden" name="internshipId" value="<%= filterInternshipId != null ? filterInternshipId : "" %>">
                                        <button type="submit" class="btn-action btn-reject">Reject</button>
                                    </form>
                                <% } else { %>
                                    <span style="color: rgba(255,255,255,0.3); font-size: 12px;">—</span>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="empty-state">
                <div class="icon">📑</div>
                <p>No applications found.</p>
            </div>
        <% } %>
    </div>
</body>
</html>
