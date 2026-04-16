<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.*, java.util.List" %>
<%
    ExamAttempt attempt = (ExamAttempt) request.getAttribute("attempt");
    Exam exam = (Exam) request.getAttribute("exam");
    List<Answer> answers = (List<Answer>) request.getAttribute("answers");
    Double totalScore = (Double) request.getAttribute("totalScore");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Evaluate Answers - Admin</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #0f0c29, #302b63, #24243e); min-height: 100vh; color: #fff; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 16px 40px; background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255,255,255,0.08); }
        .navbar .brand { font-size: 20px; font-weight: 700; color: #ff6b81; }
        .navbar .nav-links { display: flex; gap: 24px; align-items: center; }
        .navbar .nav-links a { color: rgba(255,255,255,0.7); text-decoration: none; font-size: 14px; }
        .btn-logout { padding: 8px 20px; background: rgba(255,71,87,0.2); border: 1px solid rgba(255,71,87,0.4); border-radius: 6px; color: #ff6b81; text-decoration: none; font-size: 13px; }
        .main-content { padding: 40px; max-width: 900px; margin: 0 auto; }
        .page-header h1 { font-size: 24px; margin-bottom: 8px; }
        .attempt-info { font-size: 14px; color: rgba(255,255,255,0.5); margin-bottom: 24px; }
        .score-summary { display: inline-block; padding: 12px 24px; background: rgba(108,99,255,0.15); border-radius: 10px; border: 1px solid rgba(108,99,255,0.3); margin-bottom: 24px; font-size: 18px; font-weight: 600; }
        .message.success { text-align: center; margin-bottom: 16px; padding: 10px; border-radius: 8px; font-size: 14px; background: rgba(46,213,115,0.15); color: #7bed9f; border: 1px solid rgba(46,213,115,0.3); }

        .answer-card { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.08); border-radius: 10px; padding: 20px; margin-bottom: 16px; }
        .answer-card .q-header { display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 13px; color: rgba(255,255,255,0.5); }
        .answer-card .q-text { font-size: 15px; margin-bottom: 12px; line-height: 1.5; }
        .answer-card .student-answer { padding: 12px; background: rgba(255,255,255,0.04); border-radius: 6px; margin-bottom: 12px; font-size: 14px; }
        .correct { color: #7bed9f; }
        .incorrect { color: #ff6b81; }

        .eval-form { display: flex; gap: 8px; align-items: center; }
        .eval-form input[type="number"] { width: 80px; padding: 8px 12px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 6px; color: #fff; font-size: 14px; outline: none; }
        .eval-form input:focus { border-color: #ff6b81; }
        .btn-grade { padding: 8px 16px; background: linear-gradient(135deg, #ff6b81, #ee5a6f); border: none; border-radius: 6px; color: #fff; font-size: 13px; font-weight: 600; cursor: pointer; }
        .marks-info { font-size: 13px; color: rgba(255,255,255,0.4); }
        .current-marks { padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; background: rgba(108,99,255,0.2); color: #a29bfe; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="brand">IEM Admin</div>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/exams?action=attempts&examId=<%= exam.getExamId() %>">← Back to Results</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>
    <div class="main-content">
        <div class="page-header"><h1>Evaluate: <%= exam.getExamName() %></h1></div>
        <div class="attempt-info">Attempt ID: <%= attempt.getAttemptId() %> | Status: <%= attempt.getStatus() %></div>
        <div class="score-summary">Current Score: <%= String.format("%.1f", totalScore) %> / <%= exam.getTotalMarks() %></div>

        <% if ("true".equals(request.getParameter("evaluated"))) { %>
            <div class="message success">Marks updated successfully!</div>
        <% } %>

        <% if (answers != null) {
            int qNum = 1;
            for (Answer ans : answers) { %>
                <div class="answer-card">
                    <div class="q-header">
                        <span>Q<%= qNum++ %> (<%= ans.getQuestionType() %>)</span>
                        <span class="current-marks"><%= String.format("%.1f", ans.getMarksAwarded()) %> / <%= ans.getQuestionMarks() %></span>
                    </div>
                    <div class="q-text"><%= ans.getQuestionText() %></div>
                    <div class="student-answer">
                        <% if ("MCQ".equals(ans.getQuestionType())) { %>
                            <strong>Selected:</strong>
                            <% if (ans.getSelectedOptionText() != null) { %>
                                <span class="<%= ans.isCorrect() ? "correct" : "incorrect" %>">
                                    <%= ans.getSelectedOptionText() %> <%= ans.isCorrect() ? "✓ Correct" : "✗ Wrong" %>
                                </span>
                            <% } else { %>
                                <span class="incorrect">Not answered</span>
                            <% } %>
                        <% } else { %>
                            <strong>Answer:</strong><br>
                            <%= ans.getDescriptiveAnswer() != null ? ans.getDescriptiveAnswer() : "<em>Not answered</em>" %>
                        <% } %>
                    </div>

                    <% if ("SUBJECTIVE".equals(ans.getQuestionType())) { %>
                        <form class="eval-form" action="exams" method="POST">
                            <input type="hidden" name="action" value="evaluate">
                            <input type="hidden" name="answerId" value="<%= ans.getAnswerId() %>">
                            <input type="hidden" name="attemptId" value="<%= attempt.getAttemptId() %>">
                            <span class="marks-info">Award marks (max <%= ans.getQuestionMarks() %>):</span>
                            <input type="number" name="marksAwarded" value="<%= String.format("%.1f", ans.getMarksAwarded()) %>" min="0" max="<%= ans.getQuestionMarks() %>" step="0.5">
                            <button type="submit" class="btn-grade">Save</button>
                        </form>
                    <% } %>
                </div>
        <%  }
        } %>
    </div>
</body>
</html>
