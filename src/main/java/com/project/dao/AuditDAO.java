package com.project.dao;

import com.project.util.DBConnection;

import java.sql.*;
import java.util.*;

/**
 * DAO for the 'audit_logs' and 'session_tracking' tables.
 * Handles logging user activity and session management.
 */
public class AuditDAO {

    /**
     * Logs a user action to the audit_logs table.
     */
    public void logAction(int userId, String action, String ipAddress, String userAgent) throws SQLException {
        String sql = "INSERT INTO audit_logs (user_id, action, ip_address, user_agent) VALUES (?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, action);
            ps.setString(3, ipAddress);
            // Truncate user_agent to 255 chars
            ps.setString(4, userAgent != null && userAgent.length() > 255 ? userAgent.substring(0, 255) : userAgent);
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Tracks a user session (INSERT or UPDATE on duplicate).
     */
    public void trackSession(String sessionId, int userId, String ipAddress, String userAgent) throws SQLException {
        String sql = "INSERT INTO session_tracking (session_id, user_id, ip_address, user_agent, last_activity) " +
                     "VALUES (?, ?, ?, ?, NOW()) " +
                     "ON DUPLICATE KEY UPDATE ip_address = ?, last_activity = NOW()";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId);
            ps.setInt(2, userId);
            ps.setString(3, ipAddress);
            ps.setString(4, userAgent != null && userAgent.length() > 255 ? userAgent.substring(0, 255) : userAgent);
            ps.setString(5, ipAddress);
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Removes a session tracking entry on logout.
     */
    public void removeSession(String sessionId) throws SQLException {
        String sql = "DELETE FROM session_tracking WHERE session_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, sessionId);
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets recent audit logs for admin view.
     * Returns last 50 entries with user names.
     */
    public List<Map<String, Object>> getRecentLogs(int limit) throws SQLException {
        String sql = "SELECT al.log_id, al.action, al.ip_address, al.log_time, " +
                     "COALESCE(u.name, 'System') AS user_name, u.role " +
                     "FROM audit_logs al " +
                     "LEFT JOIN users u ON al.user_id = u.user_id " +
                     "ORDER BY al.log_time DESC LIMIT ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Map<String, Object>> results = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            ResultSetMetaData meta = rs.getMetaData();
            int cols = meta.getColumnCount();

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                for (int i = 1; i <= cols; i++) {
                    row.put(meta.getColumnLabel(i), rs.getObject(i));
                }
                results.add(row);
            }
            return results;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets active sessions for admin view.
     */
    public List<Map<String, Object>> getActiveSessions() throws SQLException {
        String sql = "SELECT st.session_id, st.ip_address, st.login_time, st.last_activity, " +
                     "u.name, u.email, u.role " +
                     "FROM session_tracking st " +
                     "JOIN users u ON st.user_id = u.user_id " +
                     "ORDER BY st.last_activity DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Map<String, Object>> results = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            ResultSetMetaData meta = rs.getMetaData();
            int cols = meta.getColumnCount();

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                for (int i = 1; i <= cols; i++) {
                    row.put(meta.getColumnLabel(i), rs.getObject(i));
                }
                results.add(row);
            }
            return results;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }
}
