<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.*, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    List<Exam> exams = (List<Exam>) request.getAttribute("exams");
    List<ExamAttempt> completedExams = (List<ExamAttempt>) request.getAttribute("completedExams");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Online Exams - Student</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #0f0c29, #302b63, #24243e); min-height: 100vh; color: #fff; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 16px 40px; background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255,255,255,0.08); }
        .navbar .brand { font-size: 20px; font-weight: 700; color: #6c63ff; }
        .navbar .nav-links { display: flex; gap: 24px; align-items: center; }
        .navbar .nav-links a { color: rgba(255,255,255,0.7); text-decoration: none; font-size: 14px; }
        .navbar .nav-links a:hover { color: #fff; }
        .navbar .nav-links a.active { color: #6c63ff; font-weight: 600; }
        .btn-logout { padding: 8px 20px; background: rgba(255,71,87,0.2); border: 1px solid rgba(255,71,87,0.4); border-radius: 6px; color: #ff6b81; text-decoration: none; font-size: 13px; }
        .main-content { padding: 40px; max-width: 1100px; margin: 0 auto; }
        .section-title { font-size: 28px; font-weight: 700; margin-bottom: 24px; }
        .section-subtitle { font-size: 20px; font-weight: 600; margin-top: 40px; margin-bottom: 20px; color: rgba(255,255,255,0.7); border-bottom: 1px solid rgba(255,255,255,0.08); padding-bottom: 10px; }
        .message { text-align: center; margin-bottom: 16px; padding: 10px; border-radius: 8px; font-size: 14px; }
        .message.error { background: rgba(255,71,87,0.15); color: #ff6b81; border: 1px solid rgba(255,71,87,0.3); }

        /* Exam cards */
        .exams-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px; }
        .exam-card { background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border: 1px solid rgba(255,255,255,0.1); border-radius: 12px; padding: 24px; transition: transform 0.3s, box-shadow 0.3s; }
        .exam-card:hover { transform: translateY(-3px); box-shadow: 0 8px 30px rgba(108,99,255,0.12); }
        .exam-card h3 { font-size: 18px; margin-bottom: 16px; color: #6c63ff; }
        .exam-detail { display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 8px; }
        .exam-detail .label { color: rgba(255,255,255,0.5); }
        .exam-detail .value { color: rgba(255,255,255,0.85); }
        .btn-start { display: block; width: 100%; padding: 10px; background: linear-gradient(135deg, #6c63ff, #4834d4); border: none; border-radius: 8px; color: #fff; font-size: 14px; font-weight: 600; cursor: pointer; text-decoration: none; text-align: center; margin-top: 16px; transition: transform 0.2s; }
        .btn-start:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(108,99,255,0.4); }

        /* History table */
        .data-table { width: 100%; border-collapse: collapse; background: rgba(255,255,255,0.05); border-radius: 12px; overflow: hidden; }
        .data-table th, .data-table td { padding: 14px 20px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.06); }
        .data-table th { background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.6); font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }
        .data-table td { font-size: 14px; color: rgba(255,255,255,0.85); }
        .data-table tr:hover { background: rgba(255,255,255,0.03); }

        .status-badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; text-transform: uppercase; }
        .status-SUBMITTED, .status-AUTO_SUBMITTED { background: rgba(46,213,115,0.2); color: #7bed9f; border: 1px solid rgba(46,213,115,0.3); }
        .status-PENDING_EVALUATION { background: rgba(253,203,110,0.2); color: #feca57; border: 1px solid rgba(253,203,110,0.3); }

        .btn-view { padding: 6px 14px; background: rgba(108,99,255,0.2); color: #a29bfe; border: 1px solid rgba(108,99,255,0.3); border-radius: 6px; font-size: 12px; font-weight: 600; text-decoration: none; }

        .score-bar { width: 80px; height: 6px; background: rgba(255,255,255,0.1); border-radius: 3px; overflow: hidden; display: inline-block; vertical-align: middle; margin-right: 6px; }
        .score-bar .fill { height: 100%; background: linear-gradient(90deg, #6c63ff, #4834d4); border-radius: 3px; }

        .empty-state { text-align: center; padding: 40px 20px; color: rgba(255,255,255,0.4); font-size: 14px; }
        .empty-state .icon { font-size: 48px; margin-bottom: 16px; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="brand">IEM System</div>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/student/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/student/internships">Internships</a>
            <a href="<%= request.getContextPath() %>/student/applications">My Applications</a>
            <a href="<%= request.getContextPath() %>/student/exams" class="active">Exams</a>
            <a href="<%= request.getContextPath() %>/student/profile">Profile</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>
    <div class="main-content">
        <h1 class="section-title">Online Exams</h1>

        <% if (request.getAttribute("error") != null) { %>
            <div class="message error"><%= request.getAttribute("error") %></div>
        <% } %>

        <!-- Available Exams -->
        <% if (exams != null && !exams.isEmpty()) { %>
            <h2 class="section-subtitle">Available Exams</h2>
            <div class="exams-grid">
                <% for (Exam exam : exams) { %>
                    <div class="exam-card">
                        <h3><%= exam.getExamName() %></h3>
                        <div class="exam-detail"><span class="label">Duration</span><span class="value"><%= exam.getDuration() %> minutes</span></div>
                        <div class="exam-detail"><span class="label">Total Marks</span><span class="value"><%= exam.getTotalMarks() %></span></div>
                        <div class="exam-detail"><span class="label">Window Closes</span><span class="value"><%= exam.getEndTime().toString().substring(0, 16) %></span></div>
                        <a href="<%= request.getContextPath() %>/student/exam?examId=<%= exam.getExamId() %>" class="btn-start" onclick="return confirm('Start this exam? The timer will begin immediately.');">Start Exam</a>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <div class="empty-state">
                <div class="icon">📝</div>
                <p>No exams available right now.</p>
            </div>
        <% } %>

        <!-- Exam History -->
        <h2 class="section-subtitle">My Exam History</h2>
        <% if (completedExams != null && !completedExams.isEmpty()) { %>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Exam Name</th>
                        <th>Score</th>
                        <th>Progress</th>
                        <th>Status</th>
                        <th>Submitted</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% int count = 1; for (ExamAttempt ea : completedExams) {
                        boolean isPending = "PENDING_EVALUATION".equals(ea.getStatus());
                        double pct = ea.getTotalPossible() > 0 ? (ea.getTotalScore() / ea.getTotalPossible()) * 100 : 0;
                    %>
                        <tr>
                            <td><%= count++ %></td>
                            <td><%= ea.getExamName() %></td>
                            <td>
                                <% if (isPending) { %>
                                    <span style="color: #feca57;">Pending</span>
                                <% } else { %>
                                    <%= String.format("%.1f", ea.getTotalScore()) %> / <%= ea.getTotalPossible() %>
                                <% } %>
                            </td>
                            <td>
                                <% if (isPending) { %>
                                    <span style="color: rgba(255,255,255,0.3);">—</span>
                                <% } else { %>
                                    <div class="score-bar"><div class="fill" style="width: <%= pct %>%"></div></div> <%= String.format("%.0f", pct) %>%
                                <% } %>
                            </td>
                            <td><span class="status-badge status-<%= ea.getStatus() %>">
                                <%= isPending ? "PENDING" : ea.getStatus().replace("_", " ") %>
                            </span></td>
                            <td><%= ea.getEndTime() != null ? ea.getEndTime().toString().substring(0, 16) : "—" %></td>
                            <td>
                                <a href="<%= request.getContextPath() %>/student/exams?action=result&examId=<%= ea.getExamId() %>" class="btn-view">
                                    <%= isPending ? "View Status" : "View Result" %>
                                </a>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="empty-state">
                <p>You haven't taken any exams yet.</p>
            </div>
        <% } %>
    </div>
</body>
</html>
