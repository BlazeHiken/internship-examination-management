<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.*, java.util.List" %>
<%
    List<Exam> exams = (List<Exam>) request.getAttribute("exams");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Exams - Admin</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #0f0c29, #302b63, #24243e); min-height: 100vh; color: #fff; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 16px 40px; background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255,255,255,0.08); }
        .navbar .brand { font-size: 20px; font-weight: 700; color: #ff6b81; }
        .navbar .nav-links { display: flex; gap: 24px; align-items: center; }
        .navbar .nav-links a { color: rgba(255,255,255,0.7); text-decoration: none; font-size: 14px; }
        .navbar .nav-links a:hover { color: #fff; }
        .navbar .nav-links a.active { color: #ff6b81; font-weight: 600; }
        .btn-logout { padding: 8px 20px; background: rgba(255,71,87,0.2); border: 1px solid rgba(255,71,87,0.4); border-radius: 6px; color: #ff6b81; text-decoration: none; font-size: 13px; }
        .main-content { padding: 40px; max-width: 1200px; margin: 0 auto; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .page-header h1 { font-size: 28px; font-weight: 700; }
        .btn-add { padding: 10px 24px; background: linear-gradient(135deg, #ff6b81, #ee5a6f); border: none; border-radius: 8px; color: #fff; font-size: 14px; font-weight: 600; text-decoration: none; }
        .message { text-align: center; margin-bottom: 16px; padding: 10px; border-radius: 8px; font-size: 14px; }
        .message.success { background: rgba(46,213,115,0.15); color: #7bed9f; border: 1px solid rgba(46,213,115,0.3); }
        .message.error { background: rgba(255,71,87,0.15); color: #ff6b81; border: 1px solid rgba(255,71,87,0.3); }
        .data-table { width: 100%; border-collapse: collapse; background: rgba(255,255,255,0.05); border-radius: 12px; overflow: hidden; }
        .data-table th, .data-table td { padding: 14px 20px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.06); }
        .data-table th { background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.6); font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }
        .data-table td { font-size: 14px; color: rgba(255,255,255,0.85); }
        .data-table tr:hover { background: rgba(255,255,255,0.03); }
        .actions { display: flex; gap: 8px; }
        .btn-sm { padding: 6px 12px; border: none; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer; text-decoration: none; }
        .btn-questions { background: rgba(108,99,255,0.2); color: #a29bfe; border: 1px solid rgba(108,99,255,0.3); }
        .btn-attempts { background: rgba(46,213,115,0.2); color: #7bed9f; border: 1px solid rgba(46,213,115,0.3); }
        .btn-delete { background: rgba(255,71,87,0.2); color: #ff6b81; border: 1px solid rgba(255,71,87,0.3); }
        .empty-state { text-align: center; padding: 60px 20px; color: rgba(255,255,255,0.4); }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="brand">IEM Admin</div>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/companies">Companies</a>
            <a href="<%= request.getContextPath() %>/admin/internships">Internships</a>
            <a href="<%= request.getContextPath() %>/admin/applications">Applications</a>
            <a href="<%= request.getContextPath() %>/admin/exams" class="active">Exams</a>
            <a href="<%= request.getContextPath() %>/admin/reports">Reports</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>
    <div class="main-content">
        <div class="page-header">
            <h1>Manage Exams</h1>
            <a href="exams?action=add" class="btn-add">+ Create Exam</a>
        </div>
        <% if ("true".equals(request.getParameter("deleted"))) { %>
            <div class="message success">Exam deleted successfully!</div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="message error"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (exams != null && !exams.isEmpty()) { %>
            <table class="data-table">
                <thead><tr><th>ID</th><th>Exam Name</th><th>Duration</th><th>Marks</th><th>Start</th><th>End</th><th>Actions</th></tr></thead>
                <tbody>
                    <% for (Exam e : exams) { %>
                        <tr>
                            <td><%= e.getExamId() %></td>
                            <td><%= e.getExamName() %></td>
                            <td><%= e.getDuration() %> min</td>
                            <td><%= e.getTotalMarks() %></td>
                            <td><%= e.getStartTime().toString().substring(0, 16) %></td>
                            <td><%= e.getEndTime().toString().substring(0, 16) %></td>
                            <td class="actions">
                                <a href="exams?action=questions&examId=<%= e.getExamId() %>" class="btn-sm btn-questions">Questions</a>
                                <a href="exams?action=attempts&examId=<%= e.getExamId() %>" class="btn-sm btn-attempts">Results</a>
                                <form action="exams" method="POST" style="margin:0;display:inline;" onsubmit="return confirm('Delete this exam?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="examId" value="<%= e.getExamId() %>">
                                    <button type="submit" class="btn-sm btn-delete">Delete</button>
                                </form>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="empty-state"><p>No exams created yet.</p></div>
        <% } %>
    </div>
</body>
</html>
