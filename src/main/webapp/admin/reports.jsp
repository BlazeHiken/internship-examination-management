<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // Report 1
    List<Map<String, Object>> selectionCounts = (List<Map<String, Object>>) request.getAttribute("selectionCounts");
    List<Map<String, Object>> selectedStudents = (List<Map<String, Object>>) request.getAttribute("selectedStudents");
    // Report 2
    List<Map<String, Object>> internshipApps = (List<Map<String, Object>>) request.getAttribute("internshipApps");
    // Report 3
    List<Map<String, Object>> examList = (List<Map<String, Object>>) request.getAttribute("examList");
    Map<Integer, List<Map<String, Object>>> rankLists = (Map<Integer, List<Map<String, Object>>>) request.getAttribute("rankLists");
    // Report 4
    Map<Integer, List<Map<String, Object>>> questionPerformance = (Map<Integer, List<Map<String, Object>>>) request.getAttribute("questionPerformance");
    // Report 5
    List<Map<String, Object>> suspiciousLogs = (List<Map<String, Object>>) request.getAttribute("suspiciousLogs");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports - Admin</title>
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

        .main-content { padding: 30px 40px; max-width: 1300px; margin: 0 auto; }
        .page-title { font-size: 28px; font-weight: 700; margin-bottom: 8px; }
        .page-subtitle { font-size: 14px; color: rgba(255,255,255,0.4); margin-bottom: 28px; }

        /* Report tabs */
        .report-tabs { display: flex; gap: 4px; margin-bottom: 24px; background: rgba(255,255,255,0.04); border-radius: 10px; padding: 4px; overflow-x: auto; }
        .report-tab { padding: 10px 20px; border-radius: 8px; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.3s; color: rgba(255,255,255,0.5); border: none; background: none; white-space: nowrap; }
        .report-tab:hover { color: rgba(255,255,255,0.8); }
        .report-tab.active { background: rgba(255,107,129,0.2); color: #ff6b81; }
        .report-section { display: none; }
        .report-section.active { display: block; }

        /* Report header */
        .report-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 1px solid rgba(255,255,255,0.08); }
        .report-header h2 { font-size: 20px; font-weight: 600; }
        .report-header .report-id { font-size: 12px; color: rgba(255,255,255,0.3); padding: 4px 10px; background: rgba(255,255,255,0.05); border-radius: 6px; }

        /* Tables */
        .data-table { width: 100%; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 10px; overflow: hidden; margin-bottom: 24px; }
        .data-table th, .data-table td { padding: 12px 16px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .data-table th { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.5); font-size: 11px; text-transform: uppercase; letter-spacing: 1px; }
        .data-table td { font-size: 13px; color: rgba(255,255,255,0.8); }
        .data-table tr:hover { background: rgba(255,255,255,0.03); }

        /* Company group header */
        .company-group { margin-bottom: 20px; }
        .company-group-header { display: flex; justify-content: space-between; align-items: center; padding: 12px 16px; background: rgba(108,99,255,0.1); border: 1px solid rgba(108,99,255,0.2); border-radius: 8px; margin-bottom: 10px; }
        .company-group-header h3 { font-size: 15px; color: #a29bfe; }
        .company-group-header .count { padding: 3px 10px; background: rgba(108,99,255,0.2); border-radius: 12px; font-size: 12px; color: #a29bfe; font-weight: 600; }

        /* Status badges */
        .status-cell { font-weight: 600; }
        .status-cell.applied { color: #a29bfe; }
        .status-cell.shortlisted { color: #feca57; }
        .status-cell.selected { color: #7bed9f; }
        .status-cell.rejected { color: #ff6b81; }

        /* Score bar */
        .score-bar { width: 80px; height: 6px; background: rgba(255,255,255,0.1); border-radius: 3px; overflow: hidden; display: inline-block; vertical-align: middle; margin-right: 6px; }
        .score-bar .fill { height: 100%; border-radius: 3px; }
        .fill-green { background: linear-gradient(90deg, #2ecc71, #27ae60); }
        .fill-blue { background: linear-gradient(90deg, #6c63ff, #4834d4); }
        .fill-yellow { background: linear-gradient(90deg, #f39c12, #e67e22); }
        .fill-red { background: linear-gradient(90deg, #e74c3c, #c0392b); }

        /* Rank badges */
        .rank { display: inline-flex; align-items: center; justify-content: center; width: 26px; height: 26px; border-radius: 50%; font-size: 12px; font-weight: 700; }
        .rank-1 { background: rgba(255,215,0,0.2); color: #ffd700; }
        .rank-2 { background: rgba(192,192,192,0.2); color: #c0c0c0; }
        .rank-3 { background: rgba(205,127,50,0.2); color: #cd7f32; }
        .rank-other { background: rgba(255,255,255,0.05); color: rgba(255,255,255,0.4); }

        /* Accuracy bar */
        .accuracy-bar { display: flex; height: 18px; border-radius: 4px; overflow: hidden; width: 120px; }
        .accuracy-correct { background: rgba(46,213,115,0.5); }
        .accuracy-incorrect { background: rgba(255,71,87,0.5); }

        /* Exam section header */
        .exam-section { margin-bottom: 28px; }
        .exam-section-header { padding: 12px 16px; background: rgba(255,107,129,0.08); border: 1px solid rgba(255,107,129,0.15); border-radius: 8px; margin-bottom: 12px; }
        .exam-section-header h3 { font-size: 15px; color: #ff6b81; margin-bottom: 2px; }
        .exam-section-header .meta { font-size: 12px; color: rgba(255,255,255,0.4); }

        /* Suspicious log badges */
        .severity-high { padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; background: rgba(255,71,87,0.15); color: #ff6b81; }
        .severity-medium { padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; background: rgba(253,203,110,0.15); color: #feca57; }
        .severity-low { padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.5); }

        /* Question type badge */
        .type-badge { padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; }
        .type-MCQ { background: rgba(108,99,255,0.15); color: #a29bfe; }
        .type-SUBJECTIVE { background: rgba(253,203,110,0.15); color: #feca57; }

        .empty-msg { text-align: center; padding: 30px; color: rgba(255,255,255,0.3); font-size: 14px; }

        .summary-cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 12px; margin-bottom: 20px; }
        .summary-card { background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08); border-radius: 10px; padding: 16px; text-align: center; }
        .summary-card .val { font-size: 28px; font-weight: 700; background: linear-gradient(135deg, #6c63ff, #a29bfe); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .summary-card .lbl { font-size: 11px; color: rgba(255,255,255,0.4); text-transform: uppercase; letter-spacing: 1px; margin-top: 4px; }
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
            <a href="<%= request.getContextPath() %>/admin/exams">Exams</a>
            <a href="<%= request.getContextPath() %>/admin/reports" class="active">Reports</a>
            <a href="<%= request.getContextPath() %>/admin/audit">Audit</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="main-content">
        <h1 class="page-title">Reports</h1>
        <p class="page-subtitle">Generated reports for internship, examination, and security analysis</p>

        <!-- Report tabs -->
        <div class="report-tabs">
            <button class="report-tab active" onclick="showReport(1)">R1: Selected Per Company</button>
            <button class="report-tab" onclick="showReport(2)">R2: Internship Applications</button>
            <button class="report-tab" onclick="showReport(3)">R3: Exam Rank List</button>
            <button class="report-tab" onclick="showReport(4)">R4: Question Analysis</button>
            <button class="report-tab" onclick="showReport(5)">R5: Suspicious Activity</button>
        </div>

        <!-- ==================== REPORT 1 ==================== -->
        <div class="report-section active" id="report-1">
            <div class="report-header">
                <h2>Students Selected Per Company</h2>
                <span class="report-id">Report 1</span>
            </div>

            <!-- Summary cards -->
            <% if (selectionCounts != null && !selectionCounts.isEmpty()) { %>
                <div class="summary-cards">
                    <% for (Map<String, Object> sc : selectionCounts) { %>
                        <div class="summary-card">
                            <div class="val"><%= sc.get("selected_count") %></div>
                            <div class="lbl"><%= sc.get("company_name") %></div>
                        </div>
                    <% } %>
                </div>
            <% } %>

            <!-- Detailed list grouped by company -->
            <% if (selectedStudents != null && !selectedStudents.isEmpty()) {
                String currentCompany = "";
                for (Map<String, Object> row : selectedStudents) {
                    String company = String.valueOf(row.get("company_name"));
                    if (!company.equals(currentCompany)) {
                        if (!currentCompany.isEmpty()) { %>
                            </tbody></table></div>
                        <% }
                        currentCompany = company;
                    %>
                    <div class="company-group">
                        <div class="company-group-header">
                            <h3><%= company %></h3>
                        </div>
                        <table class="data-table">
                            <thead><tr><th>Student Name</th><th>Email</th><th>Course</th><th>CGPA</th><th>Role</th><th>Stipend</th></tr></thead>
                            <tbody>
                    <% } %>
                        <tr>
                            <td><%= row.get("student_name") %></td>
                            <td><%= row.get("email") %></td>
                            <td><%= row.get("course") %></td>
                            <td><%= row.get("cgpa") %></td>
                            <td><%= row.get("role") %></td>
                            <td><%= row.get("stipend") != null ? "₹" + row.get("stipend") : "—" %></td>
                        </tr>
                <% }
                // Close last group
                if (!currentCompany.isEmpty()) { %>
                    </tbody></table></div>
                <% }
            } else { %>
                <div class="empty-msg">No students have been selected yet.</div>
            <% } %>
        </div>

        <!-- ==================== REPORT 2 ==================== -->
        <div class="report-section" id="report-2">
            <div class="report-header">
                <h2>Internship-wise Application Count</h2>
                <span class="report-id">Report 2</span>
            </div>

            <% if (internshipApps != null && !internshipApps.isEmpty()) { %>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Company</th>
                            <th>Role</th>
                            <th>Stipend</th>
                            <th>Deadline</th>
                            <th>Total</th>
                            <th>Applied</th>
                            <th>Shortlisted</th>
                            <th>Selected</th>
                            <th>Rejected</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> row : internshipApps) {
                            Object totalObj = row.get("total_apps");
                            long total = totalObj != null ? ((Number) totalObj).longValue() : 0;
                        %>
                        <tr>
                            <td><%= row.get("company_name") %></td>
                            <td><%= row.get("role") %></td>
                            <td><%= row.get("stipend") != null ? "₹" + row.get("stipend") : "—" %></td>
                            <td><%= row.get("deadline") %></td>
                            <td><strong><%= total %></strong></td>
                            <td class="status-cell applied"><%= row.get("applied") %></td>
                            <td class="status-cell shortlisted"><%= row.get("shortlisted") %></td>
                            <td class="status-cell selected"><%= row.get("selected") %></td>
                            <td class="status-cell rejected"><%= row.get("rejected") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="empty-msg">No internship data available.</div>
            <% } %>
        </div>

        <!-- ==================== REPORT 3 ==================== -->
        <div class="report-section" id="report-3">
            <div class="report-header">
                <h2>Exam Rank List</h2>
                <span class="report-id">Report 3</span>
            </div>

            <% if (examList != null && !examList.isEmpty()) {
                for (Map<String, Object> exam : examList) {
                    int examId = ((Number) exam.get("exam_id")).intValue();
                    List<Map<String, Object>> ranks = rankLists != null ? rankLists.get(examId) : null;
            %>
                <div class="exam-section">
                    <div class="exam-section-header">
                        <h3><%= exam.get("exam_name") %></h3>
                        <span class="meta">Total Marks: <%= exam.get("total_marks") %> | Duration: <%= exam.get("duration") %> min</span>
                    </div>
                    <% if (ranks != null && !ranks.isEmpty()) { %>
                        <table class="data-table">
                            <thead><tr><th>Rank</th><th>Student</th><th>Email</th><th>Score</th><th>Percentage</th></tr></thead>
                            <tbody>
                                <% int rank = 1; for (Map<String, Object> r : ranks) {
                                    Object pctObj = r.get("percentage");
                                    double pct = pctObj != null ? ((Number) pctObj).doubleValue() : 0;
                                    String fillClass = pct >= 75 ? "fill-green" : pct >= 50 ? "fill-blue" : pct >= 35 ? "fill-yellow" : "fill-red";
                                %>
                                <tr>
                                    <td><span class="rank <%= rank <= 3 ? "rank-" + rank : "rank-other" %>"><%= rank %></span></td>
                                    <td><%= r.get("student_name") %></td>
                                    <td><%= r.get("email") %></td>
                                    <td><%= r.get("total_score") %> / <%= r.get("total_marks") %></td>
                                    <td>
                                        <div class="score-bar"><div class="fill <%= fillClass %>" style="width: <%= pct %>%"></div></div>
                                        <%= pct %>%
                                    </td>
                                </tr>
                                <% rank++; } %>
                            </tbody>
                        </table>
                    <% } else { %>
                        <div class="empty-msg">No attempts for this exam yet.</div>
                    <% } %>
                </div>
            <% }
            } else { %>
                <div class="empty-msg">No exams created yet.</div>
            <% } %>
        </div>

        <!-- ==================== REPORT 4 ==================== -->
        <div class="report-section" id="report-4">
            <div class="report-header">
                <h2>Question-wise Performance Analysis</h2>
                <span class="report-id">Report 4</span>
            </div>

            <% if (examList != null && !examList.isEmpty()) {
                for (Map<String, Object> exam : examList) {
                    int examId = ((Number) exam.get("exam_id")).intValue();
                    List<Map<String, Object>> qPerf = questionPerformance != null ? questionPerformance.get(examId) : null;
            %>
                <div class="exam-section">
                    <div class="exam-section-header">
                        <h3><%= exam.get("exam_name") %></h3>
                        <span class="meta">Total Marks: <%= exam.get("total_marks") %></span>
                    </div>
                    <% if (qPerf != null && !qPerf.isEmpty()) { %>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Q#</th>
                                    <th>Question</th>
                                    <th>Type</th>
                                    <th>Marks</th>
                                    <th>Attempts</th>
                                    <th>Correct / Incorrect</th>
                                    <th>Accuracy</th>
                                    <th>Avg Marks</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% int qNum = 1; for (Map<String, Object> q : qPerf) {
                                    boolean isMcq = "MCQ".equals(q.get("type"));
                                    Object correctObj = q.get("correct_count");
                                    Object incorrectObj = q.get("incorrect_count");
                                    Object accuracyObj = q.get("accuracy");
                                    Object attemptsObj = q.get("attempts");
                                    long attempts = attemptsObj != null ? ((Number) attemptsObj).longValue() : 0;
                                    long correct = correctObj != null ? ((Number) correctObj).longValue() : 0;
                                    long incorrect = incorrectObj != null ? ((Number) incorrectObj).longValue() : 0;
                                    double accuracy = accuracyObj != null ? ((Number) accuracyObj).doubleValue() : 0;
                                    double correctPct = attempts > 0 ? ((double) correct / attempts) * 100 : 0;
                                    double incorrectPct = attempts > 0 ? ((double) incorrect / attempts) * 100 : 0;
                                    // Truncate question text for display
                                    String qText = String.valueOf(q.get("question_text"));
                                    if (qText.length() > 80) qText = qText.substring(0, 80) + "...";
                                %>
                                <tr>
                                    <td><%= qNum++ %></td>
                                    <td title="<%= q.get("question_text") %>"><%= qText %></td>
                                    <td><span class="type-badge type-<%= q.get("type") %>"><%= q.get("type") %></span></td>
                                    <td><%= q.get("marks") %></td>
                                    <td><%= attempts %></td>
                                    <td>
                                        <% if (isMcq) { %>
                                            <div class="accuracy-bar">
                                                <div class="accuracy-correct" style="width: <%= correctPct %>%" title="<%= correct %> correct"></div>
                                                <div class="accuracy-incorrect" style="width: <%= incorrectPct %>%" title="<%= incorrect %> incorrect"></div>
                                            </div>
                                            <span style="font-size: 11px; color: rgba(255,255,255,0.4);"><%= correct %>✓ / <%= incorrect %>✗</span>
                                        <% } else { %>
                                            <span style="color: rgba(255,255,255,0.3);">N/A</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if (isMcq) { %>
                                            <span style="color: <%= accuracy >= 70 ? "#7bed9f" : accuracy >= 40 ? "#feca57" : "#ff6b81" %>; font-weight: 600;">
                                                <%= accuracy %>%
                                            </span>
                                        <% } else { %>
                                            <span style="color: rgba(255,255,255,0.3);">—</span>
                                        <% } %>
                                    </td>
                                    <td><%= q.get("avg_marks") != null ? q.get("avg_marks") : "0" %> / <%= q.get("marks") %></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    <% } else { %>
                        <div class="empty-msg">No questions in this exam.</div>
                    <% } %>
                </div>
            <% }
            } else { %>
                <div class="empty-msg">No exams created yet.</div>
            <% } %>
        </div>

        <!-- ==================== REPORT 5 ==================== -->
        <div class="report-section" id="report-5">
            <div class="report-header">
                <h2>Suspicious Activity Logs</h2>
                <span class="report-id">Report 5</span>
            </div>

            <% if (suspiciousLogs != null && !suspiciousLogs.isEmpty()) { %>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>User</th>
                            <th>Role</th>
                            <th>Action</th>
                            <th>Severity</th>
                            <th>IP Address</th>
                            <th>Time</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> log : suspiciousLogs) {
                            String action = String.valueOf(log.get("action"));
                            String severity = "medium";
                            if (action.contains("TAB_SWITCH") || action.contains("AUTO_SUBMITTED")) severity = "high";
                            else if (action.contains("LOGIN_ATTEMPT")) severity = "medium";
                        %>
                        <tr>
                            <td><%= log.get("log_id") %></td>
                            <td><%= log.get("user_name") %></td>
                            <td><%= log.get("role") != null ? log.get("role") : "—" %></td>
                            <td><%= action %></td>
                            <td><span class="severity-<%= severity %>"><%= severity.toUpperCase() %></span></td>
                            <td><%= log.get("ip_address") %></td>
                            <td><%= log.get("log_time") != null ? log.get("log_time").toString().substring(0, 19) : "—" %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="empty-msg">No suspicious activity detected.</div>
            <% } %>
        </div>
    </div>

    <script>
        function showReport(num) {
            // Hide all sections
            document.querySelectorAll('.report-section').forEach(function(s) { s.classList.remove('active'); });
            document.querySelectorAll('.report-tab').forEach(function(t) { t.classList.remove('active'); });
            // Show selected
            document.getElementById('report-' + num).classList.add('active');
            document.querySelectorAll('.report-tab')[num - 1].classList.add('active');
        }
    </script>
</body>
</html>
