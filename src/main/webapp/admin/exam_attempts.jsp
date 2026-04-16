<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.*, java.util.List" %>
<%
    Exam exam = (Exam) request.getAttribute("exam");
    List<ExamAttempt> attempts = (List<ExamAttempt>) request.getAttribute("attempts");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Results - <%= exam.getExamName() %></title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #0f0c29, #302b63, #24243e); min-height: 100vh; color: #fff; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 16px 40px; background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255,255,255,0.08); }
        .navbar .brand { font-size: 20px; font-weight: 700; color: #ff6b81; }
        .navbar .nav-links { display: flex; gap: 24px; align-items: center; }
        .navbar .nav-links a { color: rgba(255,255,255,0.7); text-decoration: none; font-size: 14px; }
        .btn-logout { padding: 8px 20px; background: rgba(255,71,87,0.2); border: 1px solid rgba(255,71,87,0.4); border-radius: 6px; color: #ff6b81; text-decoration: none; font-size: 13px; }
        .main-content { padding: 40px; max-width: 1000px; margin: 0 auto; }
        .page-header h1 { font-size: 24px; margin-bottom: 8px; }
        .exam-info { font-size: 14px; color: rgba(255,255,255,0.5); margin-bottom: 24px; }
        .data-table { width: 100%; border-collapse: collapse; background: rgba(255,255,255,0.05); border-radius: 12px; overflow: hidden; }
        .data-table th, .data-table td { padding: 14px 20px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.06); }
        .data-table th { background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.6); font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }
        .data-table td { font-size: 14px; color: rgba(255,255,255,0.85); }
        .data-table tr:hover { background: rgba(255,255,255,0.03); }
        .btn-evaluate { padding: 6px 14px; background: rgba(108,99,255,0.2); color: #a29bfe; border: 1px solid rgba(108,99,255,0.3); border-radius: 6px; font-size: 12px; font-weight: 600; text-decoration: none; }
        .score-bar { width: 100px; height: 6px; background: rgba(255,255,255,0.1); border-radius: 3px; overflow: hidden; display: inline-block; vertical-align: middle; margin-right: 8px; }
        .score-bar .fill { height: 100%; background: linear-gradient(90deg, #6c63ff, #4834d4); border-radius: 3px; }
        .status-badge { padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }
        .status-SUBMITTED { background: rgba(46,213,115,0.2); color: #7bed9f; }
        .status-AUTO_SUBMITTED { background: rgba(253,203,110,0.2); color: #feca57; }
        .status-IN_PROGRESS { background: rgba(108,99,255,0.2); color: #a29bfe; }
        .empty-state { text-align: center; padding: 60px 20px; color: rgba(255,255,255,0.4); }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="brand">IEM Admin</div>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/exams">← Back to Exams</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>
    <div class="main-content">
        <div class="page-header"><h1>Results: <%= exam.getExamName() %></h1></div>
        <div class="exam-info">Total Marks: <%= exam.getTotalMarks() %> | Duration: <%= exam.getDuration() %> min</div>
        <% if (attempts != null && !attempts.isEmpty()) { %>
            <table class="data-table">
                <thead><tr><th>#</th><th>Student</th><th>Score</th><th>Progress</th><th>Status</th><th>Submitted At</th><th>Action</th></tr></thead>
                <tbody>
                    <% int rank = 1; for (ExamAttempt a : attempts) {
                        double pct = a.getTotalPossible() > 0 ? (a.getTotalScore() / a.getTotalPossible()) * 100 : 0;
                    %>
                        <tr>
                            <td><%= rank++ %></td>
                            <td><%= a.getStudentName() %></td>
                            <td><%= String.format("%.1f", a.getTotalScore()) %> / <%= a.getTotalPossible() %></td>
                            <td><div class="score-bar"><div class="fill" style="width: <%= pct %>%"></div></div> <%= String.format("%.0f", pct) %>%</td>
                            <td><span class="status-badge status-<%= a.getStatus() %>"><%= a.getStatus() %></span></td>
                            <td><%= a.getEndTime() != null ? a.getEndTime().toString().substring(0, 16) : "—" %></td>
                            <td><a href="exams?action=evaluate&attemptId=<%= a.getAttemptId() %>" class="btn-evaluate">Review</a></td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="empty-state"><p>No students have attempted this exam yet.</p></div>
        <% } %>
    </div>
</body>
</html>
