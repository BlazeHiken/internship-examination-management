<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Internship & Exam Management</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .register-container {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px;
            padding: 40px;
            width: 450px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }

        .register-container h2 {
            color: #fff;
            text-align: center;
            margin-bottom: 8px;
            font-size: 28px;
            font-weight: 600;
        }

        .register-container p.subtitle {
            color: rgba(255, 255, 255, 0.5);
            text-align: center;
            margin-bottom: 30px;
            font-size: 14px;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            color: rgba(255, 255, 255, 0.7);
            margin-bottom: 6px;
            font-size: 14px;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px 16px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 8px;
            color: #fff;
            font-size: 15px;
            transition: border-color 0.3s, box-shadow 0.3s;
            outline: none;
        }

        .form-group select option {
            background: #24243e;
            color: #fff;
        }

        .form-group input:focus,
        .form-group select:focus {
            border-color: #6c63ff;
            box-shadow: 0 0 0 3px rgba(108, 99, 255, 0.2);
        }

        .form-group input::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }

        /* Student-specific fields — hidden by default, shown via JS */
        .student-fields {
            display: none;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            padding-top: 18px;
            margin-top: 10px;
        }

        .student-fields.visible {
            display: block;
        }

        .student-fields-label {
            color: rgba(255, 255, 255, 0.4);
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 14px;
        }

        .btn-register {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #6c63ff, #4834d4);
            border: none;
            border-radius: 8px;
            color: #fff;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            margin-top: 10px;
        }

        .btn-register:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(108, 99, 255, 0.4);
        }

        .btn-register:active {
            transform: translateY(0);
        }

        .message.error {
            text-align: center;
            margin-bottom: 16px;
            padding: 10px;
            border-radius: 8px;
            font-size: 14px;
            background: rgba(255, 71, 87, 0.15);
            color: #ff6b81;
            border: 1px solid rgba(255, 71, 87, 0.3);
        }

        .login-link {
            text-align: center;
            margin-top: 20px;
            color: rgba(255, 255, 255, 0.5);
            font-size: 14px;
        }

        .login-link a {
            color: #6c63ff;
            text-decoration: none;
            font-weight: 600;
            transition: color 0.3s;
        }

        .login-link a:hover {
            color: #a29bfe;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <h2>Create Account</h2>
        <p class="subtitle">Join the internship management system</p>

        <!-- Error message -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="message error"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="register" method="POST">
            <div class="form-group">
                <label for="name">Full Name</label>
                <input type="text" id="name" name="name" placeholder="Enter your full name"
                       value="<%= request.getAttribute("name") != null ? request.getAttribute("name") : "" %>" required>
            </div>

            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" placeholder="Enter your email"
                       value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>" required>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Minimum 6 characters" required>
            </div>

            <div class="form-group">
                <label for="role">Role</label>
                <select id="role" name="role" required onchange="toggleStudentFields()">
                    <option value="">-- Select Role --</option>
                    <option value="STUDENT" <%= "STUDENT".equals(request.getAttribute("role")) ? "selected" : "" %>>Student</option>
                    <option value="ADMIN" <%= "ADMIN".equals(request.getAttribute("role")) ? "selected" : "" %>>Admin</option>
                </select>
            </div>

            <!-- Student-specific fields (shown only when role = STUDENT) -->
            <div class="student-fields" id="studentFields">
                <div class="student-fields-label">Student Details</div>

                <div class="form-group">
                    <label for="course">Course</label>
                    <input type="text" id="course" name="course" placeholder="e.g., B.Tech CSE"
                           value="<%= request.getAttribute("course") != null ? request.getAttribute("course") : "" %>">
                </div>

                <div class="form-group">
                    <label for="cgpa">CGPA (0 - 10)</label>
                    <input type="number" id="cgpa" name="cgpa" placeholder="e.g., 8.5" step="0.01" min="0" max="10">
                </div>

                <div class="form-group">
                    <label for="phone">Phone Number</label>
                    <input type="text" id="phone" name="phone" placeholder="10-15 digit number"
                           value="<%= request.getAttribute("phone") != null ? request.getAttribute("phone") : "" %>">
                </div>
            </div>

            <button type="submit" class="btn-register">Create Account</button>
        </form>

        <div class="login-link">
            Already have an account? <a href="login">Sign in</a>
        </div>
    </div>

    <script>
        // Toggle student-specific fields based on role selection
        function toggleStudentFields() {
            var role = document.getElementById('role').value;
            var studentFields = document.getElementById('studentFields');
            if (role === 'STUDENT') {
                studentFields.classList.add('visible');
            } else {
                studentFields.classList.remove('visible');
            }
        }

        // On page load, check if student fields should be shown (when form is re-displayed after error)
        window.onload = function() {
            toggleStudentFields();
        };
    </script>
</body>
</html>
