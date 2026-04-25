<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    List<Map<String, Object>> auditLogs = (List<Map<String, Object>>) request.getAttribute("auditLogs");
    List<Map<String, Object>> activeSessions = (List<Map<String, Object>>) request.getAttribute("activeSessions");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit & Security - Admin</title>
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

        .section { margin-bottom: 30px; }
        .section-header { font-size: 18px; font-weight: 600; margin-bottom: 16px; padding-bottom: 8px; border-bottom: 1px solid rgba(255,255,255,0.08); display: flex; justify-content: space-between; align-items: center; }
        .badge-count { padding: 4px 12px; background: rgba(108,99,255,0.2); border-radius: 12px; font-size: 12px; color: #a29bfe; }

        /* Active sessions */
        .sessions-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 16px; margin-bottom: 24px; }
        .session-card { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.08); border-radius: 10px; padding: 16px; }
        .session-card .user-info { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
        .session-card .user-name { font-size: 15px; font-weight: 600; }
        .session-card .role-badge { padding: 2px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; text-transform: uppercase; }
        .role-ADMIN { background: rgba(255,107,129,0.2); color: #ff6b81; }
        .role-STUDENT { background: rgba(108,99,255,0.2); color: #a29bfe; }
        .session-detail { display: flex; justify-content: space-between; font-size: 12px; margin-bottom: 4px; }
        .session-detail .label { color: rgba(255,255,255,0.4); }
        .session-detail .value { color: rgba(255,255,255,0.7); }
        .pulse-dot { width: 8px; height: 8px; border-radius: 50%; background: #2ecc71; display: inline-block; animation: pulseGreen 2s infinite; margin-right: 6px; }
        @keyframes pulseGreen { 0%,100% { opacity: 1; } 50% { opacity: 0.4; } }

        /* Audit log table */
        .data-table { width: 100%; border-collapse: collapse; background: rgba(255,255,255,0.03); border-radius: 10px; overflow: hidden; }
        .data-table th, .data-table td { padding: 10px 16px; text-align: left; border-bottom: 1px solid rgba(255,255,255,0.05); }
        .data-table th { background: rgba(255,255,255,0.06); color: rgba(255,255,255,0.5); font-size: 11px; text-transform: uppercase; letter-spacing: 1px; }
        .data-table td { font-size: 13px; color: rgba(255,255,255,0.8); }
        .data-table tr:hover { background: rgba(255,255,255,0.03); }

        /* Action badges */
        .action-badge { padding: 3px 10px; border-radius: 6px; font-size: 11px; font-weight: 600; }
        .action-LOGIN_SUCCESS { background: rgba(46,213,115,0.15); color: #7bed9f; }
        .action-LOGOUT { background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.5); }
        .action-LOGIN_ATTEMPT { background: rgba(108,99,255,0.15); color: #a29bfe; }
        .action-REGISTRATION { background: rgba(253,203,110,0.15); color: #feca57; }
        .action-APPLIED_FOR_INTERNSHIP { background: rgba(108,99,255,0.15); color: #a29bfe; }
        .action-PROFILE_UPDATE { background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.6); }
        .action-EXAM_SUBMITTED { background: rgba(46,213,115,0.15); color: #7bed9f; }
        .action-APPLICATION_STATUS_CHANGED { background: rgba(253,203,110,0.15); color: #feca57; }
        .action-COMPANY_MODIFIED { background: rgba(255,107,129,0.15); color: #ff6b81; }
        .action-INTERNSHIP_MODIFIED { background: rgba(255,107,129,0.15); color: #ff6b81; }
        .action-EXAM_CREATED { background: rgba(108,99,255,0.15); color: #a29bfe; }
        .action-QUESTION_ADDED { background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.6); }
        .action-SUBJECTIVE_GRADED { background: rgba(46,213,115,0.15); color: #7bed9f; }
        .action-EXAM_ANSWER_SAVED { background: rgba(255,255,255,0.05); color: rgba(255,255,255,0.4); }

        .empty-msg { text-align: center; padding: 30px; color: rgba(255,255,255,0.3); font-size: 14px; }

        /* Search bar */
        .search-bar { display: flex; gap: 12px; align-items: center; margin-bottom: 16px; }
        .search-input {
            flex: 1; padding: 10px 16px; background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15); border-radius: 8px;
            color: #fff; font-size: 14px; outline: none; transition: border-color 0.3s;
        }
        .search-input:focus { border-color: #6c63ff; box-shadow: 0 0 0 3px rgba(108,99,255,0.15); }
        .search-input::placeholder { color: rgba(255,255,255,0.3); }
        .search-count { font-size: 12px; color: rgba(255,255,255,0.4); padding: 6px 14px; background: rgba(255,255,255,0.05); border-radius: 6px; white-space: nowrap; }
        .row-hidden { display: none; }

        /* Pagination */
        .pagination { display: flex; justify-content: center; align-items: center; gap: 8px; margin-top: 16px; }
        .page-btn {
            padding: 6px 14px; border: 1px solid rgba(255,255,255,0.15); border-radius: 6px;
            background: rgba(255,255,255,0.05); color: rgba(255,255,255,0.6); font-size: 13px;
            cursor: pointer; transition: all 0.2s;
        }
        .page-btn:hover { border-color: #6c63ff; color: #fff; }
        .page-btn.active { background: rgba(108,99,255,0.3); border-color: #6c63ff; color: #fff; font-weight: 600; }
        .page-btn:disabled { opacity: 0.3; cursor: not-allowed; }
        .page-info { font-size: 12px; color: rgba(255,255,255,0.4); }
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
            <a href="<%= request.getContextPath() %>/admin/reports">Reports</a>
            <a href="<%= request.getContextPath() %>/admin/audit" class="active">Audit</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="main-content">
        <h1 class="page-title">Audit & Security</h1>

        <!-- Active Sessions -->
        <div class="section">
            <div class="section-header">
                <span>Active Sessions</span>
                <span class="badge-count"><%= activeSessions != null ? activeSessions.size() : 0 %> online</span>
            </div>
            <% if (activeSessions != null && !activeSessions.isEmpty()) { %>
                <div class="sessions-grid">
                    <% for (Map<String, Object> s : activeSessions) { %>
                        <div class="session-card">
                            <div class="user-info">
                                <span class="user-name"><span class="pulse-dot"></span><%= s.get("name") %></span>
                                <span class="role-badge role-<%= s.get("role") %>"><%= s.get("role") %></span>
                            </div>
                            <div class="session-detail"><span class="label">Email</span><span class="value"><%= s.get("email") %></span></div>
                            <div class="session-detail"><span class="label">IP Address</span><span class="value"><%= s.get("ip_address") %></span></div>
                            <div class="session-detail"><span class="label">Login Time</span><span class="value"><%= s.get("login_time") != null ? s.get("login_time").toString().substring(0, 16) : "—" %></span></div>
                            <div class="session-detail"><span class="label">Last Activity</span><span class="value"><%= s.get("last_activity") != null ? s.get("last_activity").toString().substring(0, 16) : "—" %></span></div>
                        </div>
                    <% } %>
                </div>
            <% } else { %>
                <div class="empty-msg">No active sessions.</div>
            <% } %>
        </div>

        <!-- Audit Logs -->
        <div class="section">
            <div class="section-header">
                <span>Audit Logs</span>
                <span class="badge-count">Last 50 entries</span>
            </div>
            <% if (auditLogs != null && !auditLogs.isEmpty()) { %>
                <!-- Search bar -->
                <div class="search-bar">
                    <input type="text" class="search-input" id="auditSearch" placeholder="🔍 Search by user, action, or IP..." onkeyup="filterAndPaginate()">
                    <span class="search-count" id="auditCount"><%= auditLogs.size() %> entries</span>
                </div>

                <table class="data-table" id="auditTable">
                    <thead><tr><th>ID</th><th>User</th><th>Role</th><th>Action</th><th>IP Address</th><th>Time</th></tr></thead>
                    <tbody>
                        <% for (Map<String, Object> log : auditLogs) {
                            String actionClass = "action-" + log.get("action");
                        %>
                        <tr>
                            <td><%= log.get("log_id") %></td>
                            <td><%= log.get("user_name") %></td>
                            <td><%= log.get("role") != null ? log.get("role") : "—" %></td>
                            <td><span class="action-badge <%= actionClass %>"><%= log.get("action") %></span></td>
                            <td><%= log.get("ip_address") %></td>
                            <td><%= log.get("log_time") != null ? log.get("log_time").toString().substring(0, 19) : "—" %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>

                <!-- Pagination controls -->
                <div class="pagination" id="auditPagination"></div>
            <% } else { %>
                <div class="empty-msg">No audit logs recorded yet.</div>
            <% } %>
        </div>
    </div>

    <script>
        var ROWS_PER_PAGE = 10;
        var currentPage = 1;

        function getVisibleRows() {
            var table = document.getElementById('auditTable');
            if (!table) return [];
            var rows = table.querySelectorAll('tbody tr');
            var searchVal = document.getElementById('auditSearch').value.toLowerCase();
            var visible = [];
            rows.forEach(function(row) {
                var text = row.textContent.toLowerCase();
                if (text.indexOf(searchVal) > -1) {
                    visible.push(row);
                }
            });
            return visible;
        }

        function filterAndPaginate() {
            currentPage = 1;
            paginate();
        }

        function paginate() {
            var table = document.getElementById('auditTable');
            if (!table) return;
            var allRows = table.querySelectorAll('tbody tr');
            var visibleRows = getVisibleRows();
            var totalPages = Math.ceil(visibleRows.length / ROWS_PER_PAGE);
            if (currentPage > totalPages) currentPage = totalPages;
            if (currentPage < 1) currentPage = 1;

            // Hide all rows first
            allRows.forEach(function(row) { row.style.display = 'none'; });

            // Show only current page rows
            var start = (currentPage - 1) * ROWS_PER_PAGE;
            var end = start + ROWS_PER_PAGE;
            for (var i = start; i < end && i < visibleRows.length; i++) {
                visibleRows[i].style.display = '';
            }

            // Update count
            document.getElementById('auditCount').textContent = visibleRows.length + ' entries';

            // Build pagination buttons
            var pag = document.getElementById('auditPagination');
            pag.innerHTML = '';
            if (totalPages <= 1) return;

            // Prev
            var prevBtn = document.createElement('button');
            prevBtn.className = 'page-btn';
            prevBtn.textContent = '← Prev';
            prevBtn.disabled = currentPage === 1;
            prevBtn.onclick = function() { currentPage--; paginate(); };
            pag.appendChild(prevBtn);

            // Page numbers
            for (var p = 1; p <= totalPages; p++) {
                var btn = document.createElement('button');
                btn.className = 'page-btn' + (p === currentPage ? ' active' : '');
                btn.textContent = p;
                btn.onclick = (function(page) { return function() { currentPage = page; paginate(); }; })(p);
                pag.appendChild(btn);
            }

            // Next
            var nextBtn = document.createElement('button');
            nextBtn.className = 'page-btn';
            nextBtn.textContent = 'Next →';
            nextBtn.disabled = currentPage === totalPages;
            nextBtn.onclick = function() { currentPage++; paginate(); };
            pag.appendChild(nextBtn);

            // Page info
            var info = document.createElement('span');
            info.className = 'page-info';
            info.textContent = 'Page ' + currentPage + ' of ' + totalPages;
            pag.appendChild(info);
        }

        // Initialize pagination on load
        paginate();
    </script>
</body>
</html>
