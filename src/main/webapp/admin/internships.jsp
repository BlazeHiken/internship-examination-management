<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.User" %>
<%@ page import="com.project.model.Internship" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    List<Internship> internships = (List<Internship>) request.getAttribute("internships");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Internships - Admin</title>
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
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .page-header h1 { font-size: 28px; font-weight: 700; }

        .btn-add {
            padding: 10px 24px; background: linear-gradient(135deg, #ff6b81, #ee5a6f);
            border: none; border-radius: 8px; color: #fff; font-size: 14px; font-weight: 600;
            text-decoration: none; transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn-add:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(255,107,129,0.4); }

        .message { text-align: center; margin-bottom: 16px; padding: 10px; border-radius: 8px; font-size: 14px; }
        .message.success { background: rgba(46,213,115,0.15); color: #7bed9f; border: 1px solid rgba(46,213,115,0.3); }
        .message.error { background: rgba(255,71,87,0.15); color: #ff6b81; border: 1px solid rgba(255,71,87,0.3); }

        .data-table {
            width: 100%; border-collapse: collapse;
            background: rgba(255,255,255,0.05); border-radius: 12px; overflow: hidden;
        }
        .data-table th, .data-table td {
            padding: 14px 20px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.06);
        }
        .data-table th {
            background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.6);
            font-size: 12px; text-transform: uppercase; letter-spacing: 1px;
        }
        .data-table td { font-size: 14px; color: rgba(255,255,255,0.85); }
        .data-table tr:hover { background: rgba(255,255,255,0.03); }

        .status-active { color: #7bed9f; }
        .status-expired { color: #ff6b81; }

        .actions { display: flex; gap: 8px; }
        .btn-edit, .btn-delete {
            padding: 6px 14px; border: none; border-radius: 6px; font-size: 12px;
            font-weight: 600; cursor: pointer; text-decoration: none; transition: opacity 0.3s;
        }
        .btn-edit { background: rgba(108,99,255,0.2); color: #a29bfe; border: 1px solid rgba(108,99,255,0.3); }
        .btn-delete { background: rgba(255,71,87,0.2); color: #ff6b81; border: 1px solid rgba(255,71,87,0.3); }

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
            <a href="<%= request.getContextPath() %>/admin/internships" class="active">Internships</a>
            <a href="<%= request.getContextPath() %>/admin/applications">Applications</a>
            <a href="<%= request.getContextPath() %>/admin/exams">Exams</a>
            <a href="<%= request.getContextPath() %>/admin/reports">Reports</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="main-content">
        <div class="page-header">
            <h1>Manage Internships</h1>
            <a href="internships?action=add" class="btn-add">+ Post Internship</a>
        </div>

        <% if ("true".equals(request.getParameter("added"))) { %>
            <div class="message success">Internship posted successfully!</div>
        <% } %>
        <% if ("true".equals(request.getParameter("updated"))) { %>
            <div class="message success">Internship updated successfully!</div>
        <% } %>
        <% if ("true".equals(request.getParameter("deleted"))) { %>
            <div class="message success">Internship deleted successfully!</div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="message error"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (internships != null && !internships.isEmpty()) { %>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Company</th>
                        <th>Role</th>
                        <th>Stipend</th>
                        <th>Deadline</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Internship i : internships) {
                        boolean isExpired = i.getDeadline() != null && i.getDeadline().before(new java.util.Date());
                    %>
                        <tr>
                            <td><%= i.getInternshipId() %></td>
                            <td><%= i.getCompanyName() %></td>
                            <td><%= i.getRole() %></td>
                            <td>&#8377; <%= String.format("%.0f", i.getStipend()) %></td>
                            <td><%= i.getDeadline() %></td>
                            <td>
                                <% if (isExpired) { %>
                                    <span class="status-expired">Expired</span>
                                <% } else { %>
                                    <span class="status-active">Active</span>
                                <% } %>
                            </td>
                            <td class="actions">
                                <a href="internships?action=edit&id=<%= i.getInternshipId() %>" class="btn-edit">Edit</a>
                                <form action="internships" method="POST" style="margin:0;" onsubmit="return confirm('Delete this internship and all its applications?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= i.getInternshipId() %>">
                                    <button type="submit" class="btn-delete">Delete</button>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="empty-state">
                <div class="icon">📌</div>
                <p>No internships posted yet. Click "+ Post Internship" to get started.</p>
            </div>
        <% } %>
    </div>
</body>
</html>
