<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Exam - Admin</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #0f0c29, #302b63, #24243e); min-height: 100vh; color: #fff; }
        .navbar { display: flex; justify-content: space-between; align-items: center; padding: 16px 40px; background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border-bottom: 1px solid rgba(255,255,255,0.08); }
        .navbar .brand { font-size: 20px; font-weight: 700; color: #ff6b81; }
        .navbar .nav-links { display: flex; gap: 24px; align-items: center; }
        .navbar .nav-links a { color: rgba(255,255,255,0.7); text-decoration: none; font-size: 14px; }
        .navbar .nav-links a.active { color: #ff6b81; font-weight: 600; }
        .btn-logout { padding: 8px 20px; background: rgba(255,71,87,0.2); border: 1px solid rgba(255,71,87,0.4); border-radius: 6px; color: #ff6b81; text-decoration: none; font-size: 13px; }
        .main-content { padding: 40px; max-width: 600px; margin: 0 auto; }
        .page-title { font-size: 28px; font-weight: 700; margin-bottom: 24px; }
        .form-card { background: rgba(255,255,255,0.05); backdrop-filter: blur(10px); border: 1px solid rgba(255,255,255,0.1); border-radius: 12px; padding: 32px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; color: rgba(255,255,255,0.7); margin-bottom: 6px; font-size: 14px; }
        .form-group input { width: 100%; padding: 12px 16px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; color: #fff; font-size: 15px; outline: none; }
        .form-group input:focus { border-color: #ff6b81; box-shadow: 0 0 0 3px rgba(255,107,129,0.2); }
        .form-group input::placeholder { color: rgba(255,255,255,0.3); }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .btn-row { display: flex; gap: 12px; margin-top: 10px; }
        .btn-submit { flex: 1; padding: 12px; background: linear-gradient(135deg, #ff6b81, #ee5a6f); border: none; border-radius: 8px; color: #fff; font-size: 16px; font-weight: 600; cursor: pointer; }
        .btn-cancel { flex: 1; padding: 12px; background: rgba(255,255,255,0.08); border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; color: rgba(255,255,255,0.7); font-size: 16px; font-weight: 600; text-decoration: none; text-align: center; }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="brand">IEM Admin</div>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a>
            <a href="<%= request.getContextPath() %>/admin/exams" class="active">Exams</a>
            <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        </div>
    </nav>
    <div class="main-content">
        <h1 class="page-title">Create Exam</h1>
        <div class="form-card">
            <form action="exams" method="POST">
                <input type="hidden" name="action" value="add">
                <div class="form-group">
                    <label for="examName">Exam Name</label>
                    <input type="text" id="examName" name="examName" placeholder="e.g., Java Fundamentals Test" required>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="duration">Duration (minutes)</label>
                        <input type="number" id="duration" name="duration" placeholder="e.g., 60" min="1" required>
                    </div>
                    <div class="form-group">
                        <label for="totalMarks">Total Marks</label>
                        <input type="number" id="totalMarks" name="totalMarks" placeholder="e.g., 100" min="1" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label for="startTime">Start Time</label>
                        <input type="datetime-local" id="startTime" name="startTime" required>
                    </div>
                    <div class="form-group">
                        <label for="endTime">End Time</label>
                        <input type="datetime-local" id="endTime" name="endTime" required>
                    </div>
                </div>
                <div class="btn-row">
                    <button type="submit" class="btn-submit">Create & Add Questions</button>
                    <a href="exams" class="btn-cancel">Cancel</a>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
