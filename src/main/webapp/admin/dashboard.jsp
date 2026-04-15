<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Internship & Exam Management</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
            min-height: 100vh;
            color: #fff;
        }

        /* Top navigation bar */
        .navbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 40px;
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }

        .navbar .brand {
            font-size: 20px;
            font-weight: 700;
            color: #ff6b81;
        }

        .navbar .nav-links {
            display: flex;
            gap: 24px;
            align-items: center;
        }

        .navbar .nav-links a {
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            font-size: 14px;
            transition: color 0.3s;
        }

        .navbar .nav-links a:hover {
            color: #fff;
        }

        .navbar .nav-links a.active {
            color: #ff6b81;
            font-weight: 600;
        }

        .btn-logout {
            padding: 8px 20px;
            background: rgba(255, 71, 87, 0.2);
            border: 1px solid rgba(255, 71, 87, 0.4);
            border-radius: 6px;
            color: #ff6b81;
            text-decoration: none;
            font-size: 13px;
            transition: background 0.3s;
        }

        .btn-logout:hover {
            background: rgba(255, 71, 87, 0.35);
        }

        /* Main content */
        .main-content {
            padding: 40px;
            max-width: 1200px;
            margin: 0 auto;
        }

        .welcome-section {
            margin-bottom: 40px;
        }

        .welcome-section h1 {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .welcome-section .role-badge {
            display: inline-block;
            padding: 4px 12px;
            background: rgba(255, 107, 129, 0.2);
            border: 1px solid rgba(255, 107, 129, 0.4);
            border-radius: 20px;
            color: #ff6b81;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 8px;
        }

        .welcome-section p {
            color: rgba(255, 255, 255, 0.5);
            font-size: 16px;
        }

        /* Dashboard cards */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 24px;
        }

        .card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 28px;
            transition: transform 0.3s, box-shadow 0.3s;
            cursor: pointer;
            text-decoration: none;
            display: block;
            color: #fff;
        }

        .card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 40px rgba(255, 107, 129, 0.15);
            border-color: rgba(255, 107, 129, 0.3);
        }

        .card .card-icon {
            font-size: 36px;
            margin-bottom: 16px;
        }

        .card h3 {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .card p {
            color: rgba(255, 255, 255, 0.5);
            font-size: 14px;
            line-height: 1.5;
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <nav class="navbar">
        <div class="brand">IEM Admin</div>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/dashboard" class="active">Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/companies">Companies</a>
            <a href="<%= request.getContextPath() %>/admin/internships">Internships</a>
            <a href="<%= request.getContextPath() %>/admin/applications">Applications</a>
            <a href="<%= request.getContextPath() %>/admin/exams">Exams</a>
            <a href="<%= request.getContextPath() %>/admin/reports">Reports</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <div class="welcome-section">
            <span class="role-badge">Administrator</span>
            <h1>Welcome, <%= user.getName() %></h1>
            <p>Manage internships, applications, exams, and generate reports.</p>
        </div>

        <div class="cards-grid">
            <a href="<%= request.getContextPath() %>/admin/companies" class="card">
                <div class="card-icon">🏭</div>
                <h3>Manage Companies</h3>
                <p>Add, edit, or remove partner companies and set eligibility criteria.</p>
            </a>

            <a href="<%= request.getContextPath() %>/admin/internships" class="card">
                <div class="card-icon">📌</div>
                <h3>Manage Internships</h3>
                <p>Post new internship listings, set deadlines and stipend details.</p>
            </a>

            <a href="<%= request.getContextPath() %>/admin/applications" class="card">
                <div class="card-icon">📑</div>
                <h3>Process Applications</h3>
                <p>Review, shortlist, reject or select student applications.</p>
            </a>

            <a href="<%= request.getContextPath() %>/admin/exams" class="card">
                <div class="card-icon">📝</div>
                <h3>Manage Exams</h3>
                <p>Create exams, add questions, and evaluate subjective answers.</p>
            </a>

            <a href="<%= request.getContextPath() %>/admin/reports" class="card">
                <div class="card-icon">📊</div>
                <h3>Reports & Analytics</h3>
                <p>View application stats, exam rankings, and selection reports.</p>
            </a>

            <a href="<%= request.getContextPath() %>/admin/audit" class="card">
                <div class="card-icon">🔒</div>
                <h3>Audit Logs</h3>
                <p>Monitor user activity, suspicious actions, and session tracking.</p>
            </a>
        </div>
    </div>
</body>
</html>
