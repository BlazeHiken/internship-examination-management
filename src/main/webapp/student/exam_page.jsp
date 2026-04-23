<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.project.model.*, java.util.List" %>
<%
    Exam exam = (Exam) request.getAttribute("exam");
    ExamAttempt attempt = (ExamAttempt) request.getAttribute("attempt");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    int currentIndex = (Integer) request.getAttribute("currentIndex");
    long remainingSeconds = (Long) request.getAttribute("remainingSeconds");
    Question currentQ = questions.get(currentIndex);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam: <%= exam.getExamName() %></title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #0f0c29, #302b63, #24243e); min-height: 100vh; color: #fff; }

        /* Top bar with timer */
        .exam-top-bar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 12px 30px; background: rgba(255,255,255,0.05); backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(255,255,255,0.08); position: sticky; top: 0; z-index: 100;
        }
        .exam-top-bar .exam-title { font-size: 16px; font-weight: 600; }
        .timer {
            padding: 8px 20px; border-radius: 8px; font-size: 18px; font-weight: 700; font-family: 'Courier New', monospace;
            background: rgba(108,99,255,0.2); border: 1px solid rgba(108,99,255,0.4); color: #a29bfe;
        }
        .timer.warning { background: rgba(255,71,87,0.2); border-color: rgba(255,71,87,0.4); color: #ff6b81; animation: pulse 1s infinite; }
        @keyframes pulse { 0%,100% { opacity: 1; } 50% { opacity: 0.6; } }

        .exam-layout { display: flex; min-height: calc(100vh - 57px); }

        /* Question panel (left) */
        .question-panel { flex: 1; padding: 30px 40px; }
        .question-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .question-number { font-size: 14px; color: rgba(255,255,255,0.5); }
        .question-marks { padding: 4px 12px; background: rgba(108,99,255,0.2); border-radius: 12px; font-size: 12px; color: #a29bfe; }
        .question-text { font-size: 18px; line-height: 1.6; margin-bottom: 28px; padding: 20px; background: rgba(255,255,255,0.05); border-radius: 10px; border: 1px solid rgba(255,255,255,0.08); }

        /* MCQ options */
        .options-list { display: flex; flex-direction: column; gap: 12px; margin-bottom: 28px; }
        .option-item { display: flex; align-items: center; gap: 12px; padding: 14px 18px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); border-radius: 10px; cursor: pointer; transition: all 0.2s; }
        .option-item:hover { border-color: rgba(108,99,255,0.4); background: rgba(108,99,255,0.08); }
        .option-item input[type="radio"] { accent-color: #6c63ff; width: 18px; height: 18px; }
        .option-item label { cursor: pointer; font-size: 15px; flex: 1; }
        .option-item.selected { border-color: #6c63ff; background: rgba(108,99,255,0.15); }

        /* Subjective textarea */
        .subjective-area { width: 100%; min-height: 150px; padding: 16px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 10px; color: #fff; font-size: 15px; resize: vertical; outline: none; margin-bottom: 28px; }
        .subjective-area:focus { border-color: #6c63ff; }

        /* Navigation buttons */
        .nav-buttons { display: flex; gap: 12px; }
        .btn-nav {
            padding: 10px 24px; border: none; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; transition: transform 0.2s;
        }
        .btn-prev { background: rgba(255,255,255,0.1); color: rgba(255,255,255,0.7); border: 1px solid rgba(255,255,255,0.15); }
        .btn-next { background: linear-gradient(135deg, #6c63ff, #4834d4); color: #fff; }
        .btn-submit-exam { background: linear-gradient(135deg, #2ecc71, #27ae60); color: #fff; margin-left: auto; }
        .btn-nav:hover { transform: translateY(-2px); }
        .btn-nav:disabled { opacity: 0.4; cursor: not-allowed; transform: none; }

        /* Question navigator (right sidebar) */
        .nav-sidebar { width: 240px; padding: 20px; background: rgba(255,255,255,0.03); border-left: 1px solid rgba(255,255,255,0.06); }
        .nav-sidebar h4 { font-size: 13px; color: rgba(255,255,255,0.5); text-transform: uppercase; letter-spacing: 1px; margin-bottom: 16px; }
        .question-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px; }
        .q-btn {
            width: 100%; aspect-ratio: 1; border: 1px solid rgba(255,255,255,0.15); border-radius: 6px;
            background: rgba(255,255,255,0.05); color: rgba(255,255,255,0.6); font-size: 13px; font-weight: 600;
            cursor: pointer; transition: all 0.2s; display: flex; align-items: center; justify-content: center;
        }
        .q-btn.current { border-color: #6c63ff; background: rgba(108,99,255,0.3); color: #fff; }
        .q-btn.answered { background: rgba(46,213,115,0.2); border-color: rgba(46,213,115,0.4); color: #7bed9f; }
        .q-btn:hover { border-color: #6c63ff; }

        /* Tab switch warning */
        .tab-warning {
            display: none; position: fixed; top: 0; left: 0; right: 0;
            padding: 12px; background: rgba(255,71,87,0.9); color: #fff; text-align: center;
            font-weight: 600; z-index: 1000;
        }
    </style>
</head>
<body>
    <!-- Tab switch warning banner -->
    <div class="tab-warning" id="tabWarning">⚠️ Tab switch detected! This activity has been logged.</div>

    <!-- Top bar -->
    <div class="exam-top-bar">
        <span class="exam-title"><%= exam.getExamName() %></span>
        <span class="timer" id="timer">--:--</span>
    </div>

    <div class="exam-layout">
        <!-- Question panel -->
        <div class="question-panel">
            <div class="question-header">
                <span class="question-number">Question <%= currentIndex + 1 %> of <%= questions.size() %></span>
                <span class="question-marks"><%= currentQ.getMarks() %> marks | <%= currentQ.getType() %></span>
            </div>

            <div class="question-text"><%= currentQ.getQuestionText() %></div>

            <form id="examForm" action="<%= request.getContextPath() %>/student/exam" method="POST">
                <input type="hidden" name="examId" value="<%= exam.getExamId() %>">
                <input type="hidden" name="attemptId" value="<%= attempt.getAttemptId() %>">
                <input type="hidden" name="questionId" value="<%= currentQ.getQuestionId() %>">
                <input type="hidden" name="action" id="formAction" value="">
                <input type="hidden" name="nextIndex" id="nextIndex" value="<%= currentIndex %>">

                <% if ("MCQ".equals(currentQ.getType())) { %>
                    <div class="options-list">
                        <% if (currentQ.getOptions() != null) {
                            for (Option opt : currentQ.getOptions()) { %>
                                <div class="option-item <%= opt.getOptionId() == currentQ.getSelectedOptionId() ? "selected" : "" %>"
                                     onclick="selectOption(this, <%= opt.getOptionId() %>)">
                                    <input type="radio" name="selectedOption" value="<%= opt.getOptionId() %>"
                                           id="opt_<%= opt.getOptionId() %>"
                                           <%= opt.getOptionId() == currentQ.getSelectedOptionId() ? "checked" : "" %>>
                                    <label for="opt_<%= opt.getOptionId() %>"><%= opt.getOptionText() %></label>
                                </div>
                        <%  }
                        } %>
                    </div>
                <% } else { %>
                    <textarea class="subjective-area" name="descriptiveAnswer" placeholder="Type your answer here..."><%= currentQ.getDescriptiveAnswer() != null ? currentQ.getDescriptiveAnswer() : "" %></textarea>
                <% } %>

                <!-- Navigation -->
                <div class="nav-buttons">
                    <button type="button" class="btn-nav btn-prev" onclick="navigate(<%= currentIndex - 1 %>)" <%= currentIndex == 0 ? "disabled" : "" %>>← Previous</button>
                    <button type="button" class="btn-nav btn-next" onclick="navigate(<%= currentIndex + 1 %>)" <%= currentIndex == questions.size() - 1 ? "disabled" : "" %>>Next →</button>
                    <button type="button" class="btn-nav btn-submit-exam" onclick="submitExam()">Submit Exam</button>
                </div>
            </form>
        </div>

        <!-- Question navigator sidebar -->
        <div class="nav-sidebar">
            <h4>Questions</h4>
            <div class="question-grid">
                <% for (int i = 0; i < questions.size(); i++) {
                    Question q = questions.get(i);
                    boolean isAnswered = (q.getSelectedOptionId() > 0) || (q.getDescriptiveAnswer() != null && !q.getDescriptiveAnswer().isEmpty());
                    boolean isCurrent = (i == currentIndex);
                %>
                    <button class="q-btn <%= isCurrent ? "current" : "" %> <%= isAnswered ? "answered" : "" %>"
                            onclick="navigate(<%= i %>)"><%= i + 1 %></button>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        // --- Timer ---
        var remainingSeconds = <%= remainingSeconds %>;
        var timerEl = document.getElementById('timer');

        function updateTimer() {
            if (remainingSeconds <= 0) {
                // Auto-submit
                document.getElementById('formAction').value = 'autosubmit';
                document.getElementById('examForm').submit();
                return;
            }
            var mins = Math.floor(remainingSeconds / 60);
            var secs = remainingSeconds % 60;
            timerEl.textContent = String(mins).padStart(2, '0') + ':' + String(secs).padStart(2, '0');

            // Warning when < 5 minutes
            if (remainingSeconds <= 300) {
                timerEl.classList.add('warning');
            }
            remainingSeconds--;
        }
        updateTimer();
        setInterval(updateTimer, 1000);

        // --- Navigation ---
        function navigate(index) {
            document.getElementById('nextIndex').value = index;
            document.getElementById('formAction').value = '';
            document.getElementById('examForm').submit();
        }

        function submitExam() {
            if (confirm('Are you sure you want to submit? You cannot change your answers after submission.')) {
                document.getElementById('formAction').value = 'submit';
                document.getElementById('examForm').submit();
            }
        }

        // --- MCQ option selection ---
        function selectOption(el, optionId) {
            document.querySelectorAll('.option-item').forEach(function(item) { item.classList.remove('selected'); });
            el.classList.add('selected');
            el.querySelector('input[type="radio"]').checked = true;
        }

        // --- Anti-cheat: Tab switch detection ---
        var tabSwitchCount = 0;
        document.addEventListener('visibilitychange', function() {
            if (document.hidden) {
                tabSwitchCount++;
                var warning = document.getElementById('tabWarning');
                warning.style.display = 'block';
                setTimeout(function() { warning.style.display = 'none'; }, 3000);

                // Log to server via AJAX
                var xhr = new XMLHttpRequest();
                xhr.open('POST', '<%= request.getContextPath() %>/student/tabswitch', true);
                xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
                xhr.send('attemptId=<%= attempt.getAttemptId() %>&examName=<%= java.net.URLEncoder.encode(exam.getExamName(), "UTF-8") %>&count=' + tabSwitchCount);
            }
        });
    </script>
</body>
</html>
