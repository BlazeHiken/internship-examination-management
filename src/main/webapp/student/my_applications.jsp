<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.User" %>
<%@ page import="com.project.model.Application" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    List<Application> applications = (List<Application>) request.getAttribute("applications");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Applications - Internship & Exam Management</title>
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
        .navbar .brand { font-size: 20px; font-weight: 700; color: #6c63ff; }
        .navbar .nav-links { display: flex; gap: 24px; align-items: center; }
        .navbar .nav-links a { color: rgba(255,255,255,0.7); text-decoration: none; font-size: 14px; transition: color 0.3s; }
        .navbar .nav-links a:hover { color: #fff; }
        .navbar .nav-links a.active { color: #6c63ff; font-weight: 600; }
        .btn-logout {
            padding: 8px 20px; background: rgba(255,71,87,0.2); border: 1px solid rgba(255,71,87,0.4);
            border-radius: 6px; color: #ff6b81; text-decoration: none; font-size: 13px;
        }

        .main-content { padding: 40px; max-width: 1100px; margin: 0 auto; }
        .page-header { margin-bottom: 30px; }
        .page-header h1 { font-size: 28px; font-weight: 700; }

        .message { text-align: center; margin-bottom: 16px; padding: 10px; border-radius: 8px; font-size: 14px; }
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

        /* Status badges */
        .status-badge {
            padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.5px;
        }
        .status-APPLIED { background: rgba(108,99,255,0.2); color: #a29bfe; border: 1px solid rgba(108,99,255,0.3); }
        .status-SHORTLISTED { background: rgba(253,203,110,0.2); color: #feca57; border: 1px solid rgba(253,203,110,0.3); }
        .status-SELECTED { background: rgba(46,213,115,0.2); color: #7bed9f; border: 1px solid rgba(46,213,115,0.3); }
        .status-REJECTED { background: rgba(255,71,87,0.2); color: #ff6b81; border: 1px solid rgba(255,71,87,0.3); }

        .empty-state { text-align: center; padding: 60px 20px; color: rgba(255,255,255,0.4); }
        .empty-state .icon { font-size: 48px; margin-bottom: 16px; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="brand">IEM System</div>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/student/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/student/internships">Internships</a>
            <a href="<%= request.getContextPath() %>/student/applications" class="active">My Applications</a>
            <a href="<%= request.getContextPath() %>/student/exams">Exams</a>
            <a href="<%= request.getContextPath() %>/student/profile">Profile</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="main-content">
        <div class="page-header">
            <h1>My Applications</h1>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="message error"><%= request.getAttribute("error") %></div>
        <% } %>

        <% if (applications != null && !applications.isEmpty()) { %>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Company</th>
                        <th>Role</th>
                        <th>Applied On</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% int count = 1;
                       for (Application app : applications) { %>
                        <tr>
                            <td><%= count++ %></td>
                            <td><%= app.getCompanyName() %></td>
                            <td><%= app.getInternshipRole() %></td>
                            <td><%= app.getAppliedDate() != null ? app.getAppliedDate().toString().substring(0, 10) : "" %></td>
                            <td><span class="status-badge status-<%= app.getStatus() %>"><%= app.getStatus() %></span></td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="empty-state">
                <div class="icon">📋</div>
                <p>You haven't applied for any internships yet.</p>
                <p><a href="<%= request.getContextPath() %>/student/internships" style="color: #6c63ff;">Browse available internships</a></p>
            </div>
        <% } %>
    </div>
</body>
</html>
