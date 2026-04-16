<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.*, java.util.List" %>
<%
    Exam exam = (Exam) request.getAttribute("exam");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    Integer marksUsed = (Integer) request.getAttribute("marksUsed");
    Integer marksRemaining = (Integer) request.getAttribute("marksRemaining");
    int used = marksUsed != null ? marksUsed : 0;
    int remaining = marksRemaining != null ? marksRemaining : exam.getTotalMarks();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Questions - <%= exam.getExamName() %></title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #0f0c29, #302b63, #24243e); min-height: 100vh; color: #fff; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 16px 40px; background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255,255,255,0.08); }
        .navbar .brand { font-size: 20px; font-weight: 700; color: #ff6b81; }
        .navbar .nav-links { display: flex; gap: 24px; align-items: center; }
        .navbar .nav-links a { color: rgba(255,255,255,0.7); text-decoration: none; font-size: 14px; }
        .btn-logout { padding: 8px 20px; background: rgba(255,71,87,0.2); border: 1px solid rgba(255,71,87,0.4); border-radius: 6px; color: #ff6b81; text-decoration: none; font-size: 13px; }
        .main-content { padding: 40px; max-width: 900px; margin: 0 auto; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .page-header h1 { font-size: 24px; font-weight: 700; }
        .exam-info { font-size: 14px; color: rgba(255,255,255,0.5); margin-bottom: 24px; }
        .message { text-align: center; margin-bottom: 16px; padding: 10px; border-radius: 8px; font-size: 14px; }
        .message.success { background: rgba(46,213,115,0.15); color: #7bed9f; border: 1px solid rgba(46,213,115,0.3); }
        .message.error { background: rgba(255,71,87,0.15); color: #ff6b81; border: 1px solid rgba(255,71,87,0.3); }

        .marks-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 24px; padding: 12px 16px; background: rgba(255,255,255,0.04); border-radius: 8px; border: 1px solid rgba(255,255,255,0.08); }
        .marks-progress { flex: 1; height: 8px; background: rgba(255,255,255,0.1); border-radius: 4px; overflow: hidden; }
        .marks-progress .fill { height: 100%; border-radius: 4px; transition: width 0.3s; }
        .marks-progress .fill.ok { background: linear-gradient(90deg, #6c63ff, #4834d4); }
        .marks-progress .fill.full { background: linear-gradient(90deg, #2ecc71, #27ae60); }
        .marks-label { font-size: 13px; color: rgba(255,255,255,0.6); white-space: nowrap; }

        /* Existing questions list */
        .question-item { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.08); border-radius: 10px; padding: 16px 20px; margin-bottom: 12px; }
        .question-item .q-header { display: flex; justify-content: space-between; margin-bottom: 8px; }
        .question-item .q-num { font-size: 13px; color: rgba(255,255,255,0.5); }
        .question-item .q-meta { font-size: 12px; color: rgba(255,255,255,0.4); }
        .question-item .q-text { font-size: 15px; margin-bottom: 8px; }
        .option-display { font-size: 13px; color: rgba(255,255,255,0.6); padding-left: 16px; }
        .option-display .correct-opt { color: #7bed9f; font-weight: 600; }

        /* Add question form */
        .add-form { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.15); border-radius: 12px; padding: 28px; margin-top: 30px; }
        .add-form h2 { font-size: 18px; margin-bottom: 20px; color: #ff6b81; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; color: rgba(255,255,255,0.7); margin-bottom: 6px; font-size: 14px; }
        .form-group input, .form-group textarea, .form-group select {
            width: 100%; padding: 10px 14px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15);
            border-radius: 8px; color: #fff; font-size: 14px; outline: none;
        }
        .form-group textarea { min-height: 80px; resize: vertical; }
        .form-group select option { background: #24243e; }
        .form-group input:focus, .form-group textarea:focus, .form-group select:focus { border-color: #ff6b81; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .mcq-options { display: none; }
        .mcq-options.visible { display: block; }
        .option-input { display: flex; gap: 8px; align-items: center; margin-bottom: 8px; }
        .option-input input[type="text"] { flex: 1; }
        .option-input input[type="radio"] { accent-color: #ff6b81; }
        .btn-add-q { padding: 10px 24px; background: linear-gradient(135deg, #ff6b81, #ee5a6f); border: none; border-radius: 8px; color: #fff; font-size: 14px; font-weight: 600; cursor: pointer; }
        .btn-back { display: inline-block; padding: 8px 16px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 6px; color: rgba(255,255,255,0.7); text-decoration: none; font-size: 13px; }
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
        <div class="page-header"><h1><%= exam.getExamName() %> — Questions</h1></div>
        <div class="exam-info">Duration: <%= exam.getDuration() %> min | Total Marks: <%= exam.getTotalMarks() %> | Questions: <%= questions != null ? questions.size() : 0 %></div>

        <!-- Marks progress bar -->
        <% double marksPct = exam.getTotalMarks() > 0 ? ((double) used / exam.getTotalMarks()) * 100 : 0; %>
        <div class="marks-bar">
            <span class="marks-label">Marks: <%= used %> / <%= exam.getTotalMarks() %> used</span>
            <div class="marks-progress">
                <div class="fill <%= remaining <= 0 ? "full" : "ok" %>" style="width: <%= marksPct %>%"></div>
            </div>
            <span class="marks-label"><%= remaining %> remaining</span>
        </div>

        <% if ("true".equals(request.getParameter("created"))) { %>
            <div class="message success">Exam created! Now add questions below.</div>
        <% } %>
        <% if ("true".equals(request.getParameter("questionAdded"))) { %>
            <div class="message success">Question added successfully!</div>
        <% } %>
        <% if ("marks_exceeded".equals(request.getParameter("error"))) { %>
            <div class="message error">Cannot add question: marks would exceed the exam's total marks (<%= exam.getTotalMarks() %>). Only <%= remaining %> marks remaining.</div>
        <% } %>

        <!-- Existing questions -->
        <% if (questions != null && !questions.isEmpty()) {
            int qNum = 1;
            for (Question q : questions) { %>
                <div class="question-item">
                    <div class="q-header">
                        <span class="q-num">Q<%= qNum++ %></span>
                        <span class="q-meta"><%= q.getType() %> | <%= q.getMarks() %> marks</span>
                    </div>
                    <div class="q-text"><%= q.getQuestionText() %></div>
                    <% if ("MCQ".equals(q.getType()) && q.getOptions() != null) { %>
                        <div class="option-display">
                            <% for (Option opt : q.getOptions()) { %>
                                <div class="<%= opt.isCorrect() ? "correct-opt" : "" %>">
                                    • <%= opt.getOptionText() %> <%= opt.isCorrect() ? "✓" : "" %>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
        <%  }
        } %>

        <!-- Add question form (only if marks remaining) -->
        <% if (remaining > 0) { %>
        <div class="add-form">
            <h2>Add Question (<%= remaining %> marks remaining)</h2>
            <form action="exams" method="POST">
                <input type="hidden" name="action" value="addQuestion">
                <input type="hidden" name="examId" value="<%= exam.getExamId() %>">

                <div class="form-group">
                    <label for="questionText">Question Text</label>
                    <textarea id="questionText" name="questionText" placeholder="Enter the question..." required></textarea>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="type">Type</label>
                        <select id="type" name="type" onchange="toggleOptions(this.value)" required>
                            <option value="MCQ">MCQ</option>
                            <option value="SUBJECTIVE">Subjective</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="marks">Marks (max <%= remaining %>)</label>
                        <input type="number" id="marks" name="marks" placeholder="e.g., 5" min="1" max="<%= remaining %>" required>
                    </div>
                </div>

                <div class="mcq-options visible" id="mcqOptions">
                    <label style="color: rgba(255,255,255,0.7); font-size: 14px; margin-bottom: 8px; display: block;">Options (select correct answer):</label>
                    <% for (int i = 1; i <= 4; i++) { %>
                        <div class="option-input">
                            <input type="radio" name="correctOption" value="<%= i %>" <%= i == 1 ? "checked" : "" %>>
                            <input type="text" name="option<%= i %>" placeholder="Option <%= i %>" <%= i <= 2 ? "required" : "" %>>
                        </div>
                    <% } %>
                </div>

                <button type="submit" class="btn-add-q">Add Question</button>
            </form>
        </div>
        <% } else { %>
            <div style="text-align: center; padding: 30px; margin-top: 30px; background: rgba(46,213,115,0.08); border: 1px solid rgba(46,213,115,0.2); border-radius: 12px;">
                <span style="font-size: 24px;">✅</span>
                <p style="margin-top: 8px; color: #7bed9f; font-weight: 600;">All marks allocated! (<%= used %>/<%= exam.getTotalMarks() %>)</p>
            </div>
        <% } %>
    </div>

    <script>
        function toggleOptions(type) {
            var mcqDiv = document.getElementById('mcqOptions');
            var opt1 = document.querySelector('input[name="option1"]');
            var opt2 = document.querySelector('input[name="option2"]');
            if (type === 'MCQ') {
                mcqDiv.classList.add('visible');
                if (opt1) opt1.required = true;
                if (opt2) opt2.required = true;
            } else {
                mcqDiv.classList.remove('visible');
                if (opt1) opt1.required = false;
                if (opt2) opt2.required = false;
            }
        }
    </script>
</body>
</html>
