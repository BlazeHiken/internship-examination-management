<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.User" %>
<%@ page import="com.project.model.Student" %>
<%
    User user = (User) session.getAttribute("user");
    Student student = (Student) request.getAttribute("student");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - Internship & Exam Management</title>
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
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 40px;
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
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
        .main-content { padding: 40px; max-width: 700px; margin: 0 auto; }

        .page-title {
            font-size: 28px; font-weight: 700; margin-bottom: 24px;
        }

        /* Profile card */
        .profile-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 32px;
        }

        .form-group { margin-bottom: 20px; }
        .form-group label {
            display: block; color: rgba(255, 255, 255, 0.7); margin-bottom: 6px; font-size: 14px;
        }
        .form-group input {
            width: 100%; padding: 12px 16px;
            background: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 8px; color: #fff; font-size: 15px;
            transition: border-color 0.3s, box-shadow 0.3s; outline: none;
        }
        .form-group input:focus {
            border-color: #6c63ff; box-shadow: 0 0 0 3px rgba(108, 99, 255, 0.2);
        }
        .form-group input::placeholder { color: rgba(255, 255, 255, 0.3); }
        .form-group input[readonly] {
            opacity: 0.5; cursor: not-allowed;
        }

        .form-row {
            display: grid; grid-template-columns: 1fr 1fr; gap: 16px;
        }

        .btn-save {
            width: 100%; padding: 12px;
            background: linear-gradient(135deg, #6c63ff, #4834d4);
            border: none; border-radius: 8px; color: #fff; font-size: 16px;
            font-weight: 600; cursor: pointer; transition: transform 0.2s, box-shadow 0.2s;
            margin-top: 10px;
        }
        .btn-save:hover {
            transform: translateY(-2px); box-shadow: 0 6px 20px rgba(108, 99, 255, 0.4);
        }

        .message { text-align: center; margin-bottom: 16px; padding: 10px; border-radius: 8px; font-size: 14px; }
        .message.error {
            background: rgba(255, 71, 87, 0.15); color: #ff6b81; border: 1px solid rgba(255, 71, 87, 0.3);
        }
        .message.success {
            background: rgba(46, 213, 115, 0.15); color: #7bed9f; border: 1px solid rgba(46, 213, 115, 0.3);
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <nav class="navbar">
        <div class="brand">IEM System</div>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/student/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/student/internships">Internships</a>
            <a href="<%= request.getContextPath() %>/student/applications">My Applications</a>
            <a href="<%= request.getContextPath() %>/student/exams">Exams</a>
            <a href="<%= request.getContextPath() %>/student/profile" class="active">Profile</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="main-content">
        <h1 class="page-title">My Profile</h1>

        <!-- Messages -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="message error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if ("true".equals(request.getParameter("updated"))) { %>
            <div class="message success">Profile updated successfully!</div>
        <% } %>

        <% if (student != null) { %>
        <div class="profile-card">
            <form action="<%= request.getContextPath() %>/student/profile" method="POST">
                <div class="form-group">
                    <label for="email">Email (cannot be changed)</label>
                    <input type="email" id="email" value="<%= student.getEmail() %>" readonly>
                </div>

                <div class="form-group">
                    <label for="name">Full Name</label>
                    <input type="text" id="name" name="name" value="<%= student.getName() %>" required>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="course">Course</label>
                        <input type="text" id="course" name="course" value="<%= student.getCourse() %>" required>
                    </div>
                    <div class="form-group">
                        <label for="cgpa">CGPA</label>
                        <input type="number" id="cgpa" name="cgpa" value="<%= student.getCgpa() %>"
                               step="0.01" min="0" max="10">
                    </div>
                </div>

                <div class="form-group">
                    <label for="phone">Phone Number</label>
                    <input type="text" id="phone" name="phone" value="<%= student.getPhone() != null ? student.getPhone() : "" %>">
                </div>

                <button type="submit" class="btn-save">Save Changes</button>
            </form>
        </div>
        <% } %>
    </div>
</body>
</html>
