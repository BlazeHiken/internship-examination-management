package com.project.dao;

import com.project.model.User;
import com.project.model.Student;
import com.project.util.DBConnection;

import java.sql.*;

/**
 * DAO for the 'users' and 'students' tables.
 * Handles authentication, registration, login state, and session enforcement.
 */
public class UserDAO {

    /**
     * Authenticates a user by email and password.
     * Returns the User object if credentials match, null otherwise.
     */
    public User authenticate(String email, String password) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapUser(rs);
            }
            return null;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Registers a new user. Returns the generated user_id.
     * Does NOT auto-commit — caller must manage the connection/transaction
     * if also inserting into 'students' table.
     */
    public int register(User user, Connection conn) throws SQLException {
        String sql = "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)";
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getRole());
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
            throw new SQLException("Failed to get generated user_id");
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        }
    }

    /**
     * Registers a student record linked to a user_id.
     * Uses the same connection for transactional registration.
     */
    public void registerStudent(Student student, Connection conn) throws SQLException {
        String sql = "INSERT INTO students (user_id, course, cgpa, phone) VALUES (?, ?, ?, ?)";
        PreparedStatement ps = null;

        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, student.getUserId());
            ps.setString(2, student.getCourse());
            ps.setDouble(3, student.getCgpa());
            ps.setString(4, student.getPhone());
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
        }
    }

    /**
     * Full registration flow: inserts into 'users' + 'students' (if student role)
     * within a single transaction using commit() and rollback().
     */
    public boolean registerFull(User user, Student student) throws SQLException {
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);  // Start transaction

            // Insert into users table
            int userId = register(user, conn);

            // If student role, also insert into students table
            if ("STUDENT".equals(user.getRole()) && student != null) {
                student.setUserId(userId);
                registerStudent(student, conn);
            }

            conn.commit();  // Commit transaction
            return true;

        } catch (SQLException e) {
            // Rollback on any failure
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            throw e;  // Re-throw so servlet can handle it
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                DBConnection.closeConnection(conn);
            }
        }
    }

    /**
     * Checks if a user with the given email already exists.
     */
    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Sets the is_logged_in flag and last_login timestamp for a user.
     * Used during login (true) and logout (false).
     */
    public void setLoggedIn(int userId, boolean loggedIn) throws SQLException {
        String sql;
        if (loggedIn) {
            sql = "UPDATE users SET is_logged_in = TRUE, last_login = CURRENT_TIMESTAMP WHERE user_id = ?";
        } else {
            sql = "UPDATE users SET is_logged_in = FALSE WHERE user_id = ?";
        }

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Checks if a user is currently logged in (for single-session enforcement).
     * Returns true if is_logged_in = TRUE in the database.
     */
    public boolean isAlreadyLoggedIn(int userId) throws SQLException {
        String sql = "SELECT is_logged_in FROM users WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getBoolean("is_logged_in");
            }
            return false;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Forces logout for a user (resets is_logged_in flag).
     * Used when admin needs to force-logout or on duplicate login detection.
     */
    public void forceLogout(int userId) throws SQLException {
        setLoggedIn(userId, false);
    }

    /**
     * Gets user by user_id.
     */
    public User getUserById(int userId) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapUser(rs);
            }
            return null;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Helper: maps a ResultSet row to a User object.
     */
    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setName(rs.getString("name"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setRole(rs.getString("role"));
        user.setLoggedIn(rs.getBoolean("is_logged_in"));
        user.setLastLogin(rs.getTimestamp("last_login"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }
}
