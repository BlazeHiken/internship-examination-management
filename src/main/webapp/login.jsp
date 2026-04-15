<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Internship & Exam Management</title>
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
        }

        .login-container {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px;
            padding: 40px;
            width: 400px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }

        .login-container h2 {
            color: #fff;
            text-align: center;
            margin-bottom: 8px;
            font-size: 28px;
            font-weight: 600;
        }

        .login-container p.subtitle {
            color: rgba(255, 255, 255, 0.5);
            text-align: center;
            margin-bottom: 30px;
            font-size: 14px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            color: rgba(255, 255, 255, 0.7);
            margin-bottom: 6px;
            font-size: 14px;
        }

        .form-group input {
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

        .form-group input:focus {
            border-color: #6c63ff;
            box-shadow: 0 0 0 3px rgba(108, 99, 255, 0.2);
        }

        .form-group input::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }

        .btn-login {
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

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(108, 99, 255, 0.4);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .message {
            text-align: center;
            margin-bottom: 16px;
            padding: 10px;
            border-radius: 8px;
            font-size: 14px;
        }

        .message.error {
            background: rgba(255, 71, 87, 0.15);
            color: #ff6b81;
            border: 1px solid rgba(255, 71, 87, 0.3);
        }

        .message.success {
            background: rgba(46, 213, 115, 0.15);
            color: #7bed9f;
            border: 1px solid rgba(46, 213, 115, 0.3);
        }

        .register-link {
            text-align: center;
            margin-top: 20px;
            color: rgba(255, 255, 255, 0.5);
            font-size: 14px;
        }

        .register-link a {
            color: #6c63ff;
            text-decoration: none;
            font-weight: 600;
            transition: color 0.3s;
        }

        .register-link a:hover {
            color: #a29bfe;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>Welcome Back</h2>
        <p class="subtitle">Sign in to your account</p>

        <!-- Error message -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="message error"><%= request.getAttribute("error") %></div>
        <% } %>

        <!-- Success message (after registration) -->
        <% if ("true".equals(request.getParameter("registered"))) { %>
            <div class="message success">Registration successful! Please log in.</div>
        <% } %>

        <form action="login" method="POST">
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" placeholder="Enter your email" required>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Enter your password" required>
            </div>

            <button type="submit" class="btn-login">Sign In</button>
        </form>

        <div class="register-link">
            Don't have an account? <a href="register">Register here</a>
        </div>
    </div>
</body>
</html>
