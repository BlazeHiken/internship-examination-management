<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal" %>
<%
    Map<String, Integer> overview = (Map<String, Integer>) request.getAttribute("overview");
    Map<String, Integer> appsByStatus = (Map<String, Integer>) request.getAttribute("appsByStatus");
    List<Map<String, Object>> appsByCompany = (List<Map<String, Object>>) request.getAttribute("appsByCompany");
    List<Map<String, Object>> examPerformance = (List<Map<String, Object>>) request.getAttribute("examPerformance");
    List<Map<String, Object>> topPerformers = (List<Map<String, Object>>) request.getAttribute("topPerformers");
    List<Map<String, Object>> placements = (List<Map<String, Object>>) request.getAttribute("placements");
    List<Map<String, Object>> recentActivity = (List<Map<String, Object>>) request.getAttribute("recentActivity");

    // Calculate total applications for bar widths
    int totalApps = 0;
    if (appsByStatus != null) {
        for (int v : appsByStatus.values()) totalApps += v;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports & Analytics - Admin</title>
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
        .page-title { font-size: 28px; font-weight: 700; margin-bottom: 24px; }

        /* Overview cards */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-bottom: 30px; }
        .stat-card { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.08); border-radius: 12px; padding: 20px; text-align: center; }
        .stat-card .stat-value { font-size: 36px; font-weight: 700; background: linear-gradient(135deg, #6c63ff, #a29bfe); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .stat-card .stat-label { font-size: 12px; color: rgba(255,255,255,0.5); text-transform: uppercase; letter-spacing: 1px; margin-top: 4px; }

        /* Section titles */
        .section { margin-bottom: 30px; }
        .section-header { font-size: 18px; font-weight: 600; margin-bottom: 16px; padding-bottom: 8px; border-bottom: 1px solid rgba(255,255,255,0.08); }

        /* Charts */
        .chart-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 24px; }
        .chart-card { background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08); border-radius: 12px; padding: 20px; }
        .chart-card h3 { font-size: 15px; color: rgba(255,255,255,0.7); margin-bottom: 16px; }

        /* Bar chart */
        .bar-chart { display: flex; flex-direction: column; gap: 10px; }
        .bar-item { display: flex; align-items: center; gap: 12px; }
        .bar-label { width: 100px; font-size: 13px; color: rgba(255,255,255,0.6); text-align: right; flex-shrink: 0; }
        .bar-track { flex: 1; height: 24px; background: rgba(255,255,255,0.06); border-radius: 4px; overflow: hidden; position: relative; }
        .bar-fill { height: 100%; border-radius: 4px; display: flex; align-items: center; padding-left: 8px; font-size: 12px; font-weight: 600; min-width: 30px; transition: width 0.6s ease; }
        .bar-fill.applied { background: linear-gradient(90deg, rgba(108,99,255,0.6), rgba(108,99,255,0.3)); color: #a29bfe; }
        .bar-fill.shortlisted { background: linear-gradient(90deg, rgba(253,203,110,0.6), rgba(253,203,110,0.3)); color: #feca57; }
        .bar-fill.selected { background: linear-gradient(90deg, rgba(46,213,115,0.6), rgba(46,213,115,0.3)); color: #7bed9f; }
        .bar-fill.rejected { background: linear-gradient(90deg, rgba(255,71,87,0.6), rgba(255,71,87,0.3)); color: #ff6b81; }

        /* Donut chart (CSS) */
        .donut-container { display: flex; align-items: center; gap: 24px; }
        .donut { width: 120px; height: 120px; border-radius: 50%; position: relative; }
        .donut-center { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: #1a1a3e; width: 70px; height: 70px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 700; }
        .donut-legend { display: flex; flex-direction: column; gap: 8px; }
        .legend-item { display: flex; align-items: center; gap: 8px; font-size: 13px; }
        .legend-dot { width: 10px; height: 10px; border-radius: 50%; }

        /* Tables */
        .data-table { width: 100%; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 10px; overflow: hidden; }
        .data-table th, .data-table td { padding: 12px 16px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .data-table th { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.5); font-size: 11px; text-transform: uppercase; letter-spacing: 1px; }
        .data-table td { font-size: 13px; color: rgba(255,255,255,0.8); }
        .data-table tr:hover { background: rgba(255,255,255,0.03); }

        .rank { display: inline-flex; align-items: center; justify-content: center; width: 24px; height: 24px; border-radius: 50%; font-size: 12px; font-weight: 700; }
        .rank-1 { background: rgba(255,215,0,0.2); color: #ffd700; }
        .rank-2 { background: rgba(192,192,192,0.2); color: #c0c0c0; }
        .rank-3 { background: rgba(205,127,50,0.2); color: #cd7f32; }

        .score-bar { width: 80px; height: 6px; background: rgba(255,255,255,0.1); border-radius: 3px; overflow: hidden; display: inline-block; vertical-align: middle; margin-right: 6px; }
        .score-bar .fill { height: 100%; background: linear-gradient(90deg, #6c63ff, #4834d4); border-radius: 3px; }

        /* Activity feed */
        .activity-feed { max-height: 300px; overflow-y: auto; }
        .activity-item { display: flex; gap: 12px; padding: 10px 0; border-bottom: 1px solid rgba(255,255,255,0.04); }
        .activity-dot { width: 8px; height: 8px; border-radius: 50%; background: #6c63ff; margin-top: 6px; flex-shrink: 0; }
        .activity-content { flex: 1; }
        .activity-text { font-size: 13px; color: rgba(255,255,255,0.7); }
        .activity-time { font-size: 11px; color: rgba(255,255,255,0.3); margin-top: 2px; }

        .empty-msg { text-align: center; padding: 20px; color: rgba(255,255,255,0.3); font-size: 14px; }

        @media (max-width: 900px) { .chart-row { grid-template-columns: 1fr; } }
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
        <h1 class="page-title">Reports & Analytics</h1>

        <!-- Overview Stats -->
        <% if (overview != null) { %>
        <div class="stats-grid">
            <div class="stat-card"><div class="stat-value"><%= overview.getOrDefault("students", 0) %></div><div class="stat-label">Students</div></div>
            <div class="stat-card"><div class="stat-value"><%= overview.getOrDefault("companies", 0) %></div><div class="stat-label">Companies</div></div>
            <div class="stat-card"><div class="stat-value"><%= overview.getOrDefault("internships", 0) %></div><div class="stat-label">Internships</div></div>
            <div class="stat-card"><div class="stat-value"><%= overview.getOrDefault("applications", 0) %></div><div class="stat-label">Applications</div></div>
            <div class="stat-card"><div class="stat-value"><%= overview.getOrDefault("exams", 0) %></div><div class="stat-label">Exams</div></div>
            <div class="stat-card"><div class="stat-value"><%= overview.getOrDefault("examAttempts", 0) %></div><div class="stat-label">Exam Attempts</div></div>
        </div>
        <% } %>

        <!-- Application Stats -->
        <div class="chart-row">
            <div class="chart-card">
                <h3>Applications by Status</h3>
                <% if (appsByStatus != null && totalApps > 0) { %>
                <div class="bar-chart">
                    <% for (Map.Entry<String, Integer> e : appsByStatus.entrySet()) {
                        int pct = (int) Math.round(((double) e.getValue() / totalApps) * 100);
                    %>
                    <div class="bar-item">
                        <span class="bar-label"><%= e.getKey() %></span>
                        <div class="bar-track">
                            <div class="bar-fill <%= e.getKey().toLowerCase() %>" style="width: <%= pct %>%"><%= e.getValue() %></div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } else { %><div class="empty-msg">No application data yet.</div><% } %>
            </div>

            <div class="chart-card">
                <h3>Applications by Company</h3>
                <% if (appsByCompany != null && !appsByCompany.isEmpty()) { %>
                <table class="data-table">
                    <thead><tr><th>Company</th><th>Total</th><th>Selected</th><th>Rejected</th></tr></thead>
                    <tbody>
                        <% for (Map<String, Object> row : appsByCompany) { %>
                        <tr>
                            <td><%= row.get("company_name") %></td>
                            <td><%= row.get("total") %></td>
                            <td style="color: #7bed9f;"><%= row.get("selected") %></td>
                            <td style="color: #ff6b81;"><%= row.get("rejected") %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } else { %><div class="empty-msg">No data yet.</div><% } %>
            </div>
        </div>

        <!-- Exam Performance -->
        <div class="section">
            <h2 class="section-header">Exam Performance</h2>
            <% if (examPerformance != null && !examPerformance.isEmpty()) { %>
            <table class="data-table">
                <thead><tr><th>Exam</th><th>Attempts</th><th>Avg Score</th><th>Highest</th><th>Total Marks</th></tr></thead>
                <tbody>
                    <% for (Map<String, Object> row : examPerformance) {
                        Object totalMarksObj = row.get("total_marks");
                        int totalMarks = totalMarksObj != null ? ((Number) totalMarksObj).intValue() : 100;
                        Object avgObj = row.get("avg_score");
                        double avg = avgObj != null ? ((Number) avgObj).doubleValue() : 0;
                        double avgPct = totalMarks > 0 ? (avg / totalMarks) * 100 : 0;
                    %>
                    <tr>
                        <td><%= row.get("exam_name") %></td>
                        <td><%= row.get("attempts") %></td>
                        <td>
                            <div class="score-bar"><div class="fill" style="width: <%= avgPct %>%"></div></div>
                            <%= String.format("%.1f", avg) %>
                        </td>
                        <td><%= row.get("highest") %></td>
                        <td><%= totalMarks %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } else { %><div class="empty-msg">No exam data yet.</div><% } %>
        </div>

        <!-- Top Performers + Placements -->
        <div class="chart-row">
            <div class="chart-card">
                <h3>Top Performers (by Avg Exam Score)</h3>
                <% if (topPerformers != null && !topPerformers.isEmpty()) { %>
                <table class="data-table">
                    <thead><tr><th>#</th><th>Student</th><th>Exams</th><th>Avg Score</th></tr></thead>
                    <tbody>
                        <% int rank = 1; for (Map<String, Object> row : topPerformers) { %>
                        <tr>
                            <td><span class="rank <%= rank <= 3 ? "rank-" + rank : "" %>"><%= rank %></span></td>
                            <td><%= row.get("name") %></td>
                            <td><%= row.get("exams_taken") %></td>
                            <td><%= row.get("avg_score") %></td>
                        </tr>
                        <% rank++; } %>
                    </tbody>
                </table>
                <% } else { %><div class="empty-msg">No data yet.</div><% } %>
            </div>

            <div class="chart-card">
                <h3>Recent Activity</h3>
                <% if (recentActivity != null && !recentActivity.isEmpty()) { %>
                <div class="activity-feed">
                    <% for (Map<String, Object> row : recentActivity) { %>
                    <div class="activity-item">
                        <div class="activity-dot"></div>
                        <div class="activity-content">
                            <div class="activity-text"><strong><%= row.get("student_name") %></strong> — <%= row.get("action") %> at <%= row.get("company_name") %> (<%= row.get("role") %>)</div>
                            <div class="activity-time"><%= row.get("log_time") %></div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } else { %><div class="empty-msg">No recent activity.</div><% } %>
            </div>
        </div>

        <!-- Placement Report -->
        <div class="section">
            <h2 class="section-header">Placement Report (Selected Students)</h2>
            <% if (placements != null && !placements.isEmpty()) { %>
            <table class="data-table">
                <thead><tr><th>Student</th><th>Email</th><th>Course</th><th>CGPA</th><th>Company</th><th>Role</th><th>Stipend</th></tr></thead>
                <tbody>
                    <% for (Map<String, Object> row : placements) { %>
                    <tr>
                        <td><%= row.get("student_name") %></td>
                        <td><%= row.get("email") %></td>
                        <td><%= row.get("course") %></td>
                        <td><%= row.get("cgpa") %></td>
                        <td><%= row.get("company_name") %></td>
                        <td><%= row.get("role") %></td>
                        <td>₹<%= row.get("stipend") %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } else { %><div class="empty-msg">No placements yet.</div><% } %>
        </div>
    </div>
</body>
</html>
