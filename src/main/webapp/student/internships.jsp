<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.User" %>
<%@ page import="com.project.model.Internship" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    List<Internship> internships = (List<Internship>) request.getAttribute("internships");
    Double studentCgpa = (Double) request.getAttribute("studentCgpa");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Available Internships - Internship & Exam Management</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
            min-height: 100vh;
            color: #fff;
        }

        /* Navbar */
        .navbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 16px 40px; background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }
        .navbar .brand { font-size: 20px; font-weight: 700; color: #6c63ff; }
        .navbar .nav-links { display: flex; gap: 24px; align-items: center; }
        .navbar .nav-links a {
            color: rgba(255, 255, 255, 0.7); text-decoration: none; font-size: 14px; transition: color 0.3s;
        }
        .navbar .nav-links a:hover { color: #fff; }
        .navbar .nav-links a.active { color: #6c63ff; font-weight: 600; }
        .btn-logout {
            padding: 8px 20px; background: rgba(255, 71, 87, 0.2); border: 1px solid rgba(255, 71, 87, 0.4);
            border-radius: 6px; color: #ff6b81; text-decoration: none; font-size: 13px; transition: background 0.3s;
        }
        .btn-logout:hover { background: rgba(255, 71, 87, 0.35); }

        /* Main content */
        .main-content { padding: 40px; max-width: 1100px; margin: 0 auto; }

        .page-header {
            display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;
        }
        .page-header h1 { font-size: 28px; font-weight: 700; }
        .cgpa-badge {
            padding: 6px 16px; background: rgba(108, 99, 255, 0.2); border: 1px solid rgba(108, 99, 255, 0.4);
            border-radius: 20px; font-size: 13px; color: #a29bfe;
        }

        .message { text-align: center; margin-bottom: 16px; padding: 10px; border-radius: 8px; font-size: 14px; }
        .message.error {
            background: rgba(255, 71, 87, 0.15); color: #ff6b81; border: 1px solid rgba(255, 71, 87, 0.3);
        }
        .message.success {
            background: rgba(46, 213, 115, 0.15); color: #7bed9f; border: 1px solid rgba(46, 213, 115, 0.3);
        }

        /* Internship cards grid */
        .internships-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px;
        }

        .internship-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 24px;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .internship-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 30px rgba(108, 99, 255, 0.12);
            border-color: rgba(108, 99, 255, 0.25);
        }

        .internship-card .company-name {
            font-size: 18px; font-weight: 600; margin-bottom: 4px;
        }
        .internship-card .role-name {
            color: #6c63ff; font-size: 15px; font-weight: 500; margin-bottom: 16px;
        }

        .internship-card .details {
            display: flex; flex-direction: column; gap: 8px; margin-bottom: 20px;
        }
        .internship-card .detail-row {
            display: flex; justify-content: space-between; font-size: 13px;
        }
        .internship-card .detail-label {
            color: rgba(255, 255, 255, 0.5);
        }
        .internship-card .detail-value {
            color: rgba(255, 255, 255, 0.85); font-weight: 500;
        }

        .btn-apply {
            width: 100%; padding: 10px;
            background: linear-gradient(135deg, #6c63ff, #4834d4);
            border: none; border-radius: 8px; color: #fff; font-size: 14px;
            font-weight: 600; cursor: pointer; transition: transform 0.2s, box-shadow 0.2s;
            text-decoration: none; display: block; text-align: center;
        }
        .btn-apply:hover {
            transform: translateY(-2px); box-shadow: 0 4px 15px rgba(108, 99, 255, 0.4);
        }

        .empty-state {
            text-align: center; padding: 60px 20px;
            color: rgba(255, 255, 255, 0.4); font-size: 16px;
        }
        .empty-state .icon { font-size: 48px; margin-bottom: 16px; }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <nav class="navbar">
        <div class="brand">IEM System</div>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/student/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/student/internships" class="active">Internships</a>
            <a href="<%= request.getContextPath() %>/student/applications">My Applications</a>
            <a href="<%= request.getContextPath() %>/student/exams">Exams</a>
            <a href="<%= request.getContextPath() %>/student/profile">Profile</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="main-content">
        <div class="page-header">
            <h1>Available Internships</h1>
            <% if (studentCgpa != null) { %>
                <span class="cgpa-badge">Your CGPA: <%= String.format("%.2f", studentCgpa) %></span>
            <% } %>
        </div>

        <!-- Messages -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="message error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if ("true".equals(request.getParameter("applied"))) { %>
            <div class="message success">Application submitted successfully!</div>
        <% } %>
        <% if ("duplicate".equals(request.getParameter("error"))) { %>
            <div class="message error">You have already applied for this internship.</div>
        <% } %>
        <% if ("deadline".equals(request.getParameter("error"))) { %>
            <div class="message error">The application deadline has passed.</div>
        <% } %>

        <% if (internships != null && !internships.isEmpty()) { %>
            <div class="internships-grid">
                <% for (Internship internship : internships) { %>
                    <div class="internship-card">
                        <div class="company-name"><%= internship.getCompanyName() %></div>
                        <div class="role-name"><%= internship.getRole() %></div>

                        <div class="details">
                            <div class="detail-row">
                                <span class="detail-label">Location</span>
                                <span class="detail-value"><%= internship.getCompanyLocation() %></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label">Stipend</span>
                                <span class="detail-value">&#8377; <%= String.format("%.0f", internship.getStipend()) %>/month</span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label">Min CGPA</span>
                                <span class="detail-value"><%= String.format("%.2f", internship.getEligibilityCgpa()) %></span>
                            </div>
                            <div class="detail-row">
                                <span class="detail-label">Deadline</span>
                                <span class="detail-value"><%= internship.getDeadline() %></span>
                            </div>
                        </div>

                        <form action="<%= request.getContextPath() %>/student/apply" method="POST" style="margin:0;">
                            <input type="hidden" name="internshipId" value="<%= internship.getInternshipId() %>">
                            <button type="submit" class="btn-apply">Apply Now</button>
                        </form>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <div class="icon">📭</div>
                <p>No internships available matching your eligibility right now.</p>
                <p>Check back later or update your profile.</p>
            </div>
        <% } %>
    </div>
</body>
</html>
