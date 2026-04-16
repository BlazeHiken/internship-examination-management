<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.*, java.util.List" %>
<%
    Exam exam = (Exam) request.getAttribute("exam");
    ExamAttempt attempt = (ExamAttempt) request.getAttribute("attempt");
    List<Answer> answers = (List<Answer>) request.getAttribute("answers");
    Double totalScore = (Double) request.getAttribute("totalScore");
    Boolean pendingEvaluation = (Boolean) request.getAttribute("pendingEvaluation");
    boolean isPending = (pendingEvaluation != null && pendingEvaluation);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Result - <%= exam != null ? exam.getExamName() : "" %></title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #0f0c29, #302b63, #24243e); min-height: 100vh; color: #fff; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 16px 40px; background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255,255,255,0.08); }
        .navbar .brand { font-size: 20px; font-weight: 700; color: #6c63ff; }
        .navbar .nav-links { display: flex; gap: 24px; align-items: center; }
        .navbar .nav-links a { color: rgba(255,255,255,0.7); text-decoration: none; font-size: 14px; }
        .navbar .nav-links a:hover { color: #fff; }
        .btn-logout { padding: 8px 20px; background: rgba(255,71,87,0.2); border: 1px solid rgba(255,71,87,0.4); border-radius: 6px; color: #ff6b81; text-decoration: none; font-size: 13px; }
        .main-content { padding: 40px; max-width: 900px; margin: 0 auto; }
        .result-header { text-align: center; margin-bottom: 40px; }
        .result-header h1 { font-size: 28px; margin-bottom: 16px; }

        .score-card { display: inline-block; padding: 24px 40px; background: rgba(255,255,255,0.05); border-radius: 16px; border: 1px solid rgba(255,255,255,0.1); }
        .score-big { font-size: 48px; font-weight: 700; color: #6c63ff; }
        .score-total { font-size: 20px; color: rgba(255,255,255,0.5); }
        .score-label { font-size: 14px; color: rgba(255,255,255,0.4); margin-top: 4px; }

        /* Pending state */
        .pending-card { display: inline-block; padding: 30px 50px; background: rgba(253,203,110,0.08); border-radius: 16px; border: 1px solid rgba(253,203,110,0.25); }
        .pending-icon { font-size: 48px; margin-bottom: 12px; }
        .pending-text { font-size: 18px; color: #feca57; font-weight: 600; margin-bottom: 8px; }
        .pending-sub { font-size: 14px; color: rgba(255,255,255,0.5); }

        .status-badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-block; margin-top: 12px; }
        .status-SUBMITTED { background: rgba(46,213,115,0.2); color: #7bed9f; border: 1px solid rgba(46,213,115,0.3); }
        .status-AUTO_SUBMITTED { background: rgba(253,203,110,0.2); color: #feca57; border: 1px solid rgba(253,203,110,0.3); }

        .answers-list { margin-top: 30px; }
        .answer-card { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.08); border-radius: 10px; padding: 20px; margin-bottom: 16px; }
        .answer-card .q-header { display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 13px; color: rgba(255,255,255,0.5); }
        .answer-card .q-text { font-size: 15px; margin-bottom: 12px; line-height: 1.5; }
        .answer-card .your-answer { font-size: 14px; padding: 10px; background: rgba(255,255,255,0.04); border-radius: 6px; }
        .correct { color: #7bed9f; }
        .incorrect { color: #ff6b81; }
        .pending { color: #feca57; }
        .marks-badge { float: right; padding: 2px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; }
        .marks-full { background: rgba(46,213,115,0.2); color: #7bed9f; }
        .marks-zero { background: rgba(255,71,87,0.2); color: #ff6b81; }
        .marks-partial { background: rgba(253,203,110,0.2); color: #feca57; }

        .btn-back { display: inline-block; margin-top: 20px; padding: 10px 24px; background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; color: #fff; text-decoration: none; font-size: 14px; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="brand">IEM System</div>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/student/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/student/exams">Exams</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>
    <div class="main-content">
        <div class="result-header">
            <h1><%= exam.getExamName() %></h1>

            <% if (isPending) { %>
                <!-- Pending evaluation state -->
                <div class="pending-card">
                    <div class="pending-icon">⏳</div>
                    <div class="pending-text">Pending Evaluation</div>
                    <div class="pending-sub">Your exam has been submitted. Results will be available<br>once the examiner reviews all subjective answers.</div>
                </div>
            <% } else { %>
                <!-- Fully graded — show score -->
                <div class="score-card">
                    <div><span class="score-big"><%= String.format("%.1f", totalScore != null ? totalScore : 0) %></span> <span class="score-total">/ <%= exam.getTotalMarks() %></span></div>
                    <div class="score-label">Your Score</div>
                </div>
            <% } %>

            <% if (attempt != null) { %>
                <br><span class="status-badge status-<%= attempt.getStatus() %>"><%= attempt.getStatus().replace("_", " ") %></span>
            <% } %>
        </div>

        <% if (!isPending && answers != null && !answers.isEmpty()) { %>
            <div class="answers-list">
                <% int qNum = 1; for (Answer ans : answers) { %>
                    <div class="answer-card">
                        <div class="q-header">
                            <span>Question <%= qNum++ %> (<%= ans.getQuestionType() %>)</span>
                            <span class="marks-badge <%= ans.getMarksAwarded() == ans.getQuestionMarks() ? "marks-full" : ans.getMarksAwarded() > 0 ? "marks-partial" : "marks-zero" %>">
                                <%= String.format("%.1f", ans.getMarksAwarded()) %> / <%= ans.getQuestionMarks() %>
                            </span>
                        </div>
                        <div class="q-text"><%= ans.getQuestionText() %></div>
                        <div class="your-answer">
                            <% if ("MCQ".equals(ans.getQuestionType())) { %>
                                <strong>Your answer:</strong>
                                <% if (ans.getSelectedOptionText() != null) { %>
                                    <span class="<%= ans.isCorrect() ? "correct" : "incorrect" %>">
                                        <%= ans.getSelectedOptionText() %> <%= ans.isCorrect() ? "✓" : "✗" %>
                                    </span>
                                <% } else { %>
                                    <span class="incorrect">Not answered</span>
                                <% } %>
                            <% } else { %>
                                <strong>Your answer:</strong><br>
                                <%= ans.getDescriptiveAnswer() != null ? ans.getDescriptiveAnswer() : "<em>Not answered</em>" %>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
        <a href="<%= request.getContextPath() %>/student/exams" class="btn-back">← Back to Exams</a>
    </div>
</body>
</html>
