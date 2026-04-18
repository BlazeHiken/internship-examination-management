package com.project.dao;

import com.project.util.DBConnection;

import java.sql.*;
import java.util.*;

/**
 * DAO for generating admin reports and analytics.
 * All methods return aggregated data for the reports dashboard.
 */
public class ReportDAO {

    // ==================== OVERVIEW STATS ====================

    /**
     * Gets total counts for dashboard overview cards.
     * Returns a map: students, companies, internships, applications, exams
     */
    public Map<String, Integer> getOverviewStats() throws SQLException {
        Map<String, Integer> stats = new LinkedHashMap<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            stats.put("students", getCount(conn, "SELECT COUNT(*) FROM students"));
            stats.put("companies", getCount(conn, "SELECT COUNT(*) FROM companies"));
            stats.put("internships", getCount(conn, "SELECT COUNT(*) FROM internships"));
            stats.put("applications", getCount(conn, "SELECT COUNT(*) FROM applications"));
            stats.put("exams", getCount(conn, "SELECT COUNT(*) FROM exams"));
            stats.put("examAttempts", getCount(conn, "SELECT COUNT(*) FROM exam_attempts WHERE status IN ('SUBMITTED','AUTO_SUBMITTED')"));

            return stats;
        } finally {
            DBConnection.closeConnection(conn);
        }
    }

    // ==================== APPLICATION STATS ====================

    /**
     * Gets application counts grouped by status.
     * Returns: {APPLIED: n, SHORTLISTED: n, SELECTED: n, REJECTED: n}
     */
    public Map<String, Integer> getApplicationsByStatus() throws SQLException {
        String sql = "SELECT status, COUNT(*) AS cnt FROM applications GROUP BY status ORDER BY FIELD(status,'APPLIED','SHORTLISTED','SELECTED','REJECTED')";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Map<String, Integer> map = new LinkedHashMap<>();

        // Initialize all statuses to 0
        map.put("APPLIED", 0);
        map.put("SHORTLISTED", 0);
        map.put("SELECTED", 0);
        map.put("REJECTED", 0);

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                map.put(rs.getString("status"), rs.getInt("cnt"));
            }
            return map;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets application counts per company.
     * Returns list of: [company_name, total_apps, selected, rejected]
     */
    public List<Map<String, Object>> getApplicationsByCompany() throws SQLException {
        String sql = "SELECT c.company_name, " +
                     "COUNT(a.application_id) AS total, " +
                     "SUM(CASE WHEN a.status='SELECTED' THEN 1 ELSE 0 END) AS selected, " +
                     "SUM(CASE WHEN a.status='REJECTED' THEN 1 ELSE 0 END) AS rejected " +
                     "FROM companies c " +
                     "JOIN internships i ON c.company_id = i.company_id " +
                     "JOIN applications a ON i.internship_id = a.internship_id " +
                     "GROUP BY c.company_id, c.company_name " +
                     "ORDER BY total DESC";
        return executeMapQuery(sql);
    }

    // ==================== EXAM STATS ====================

    /**
     * Gets exam performance stats: exam name, attempts, avg score, highest score.
     */
    public List<Map<String, Object>> getExamPerformance() throws SQLException {
        String sql = "SELECT e.exam_name, e.total_marks, " +
                     "COUNT(ea.attempt_id) AS attempts, " +
                     "ROUND(AVG(COALESCE((SELECT SUM(marks_awarded) FROM answers WHERE attempt_id = ea.attempt_id), 0)), 1) AS avg_score, " +
                     "ROUND(MAX(COALESCE((SELECT SUM(marks_awarded) FROM answers WHERE attempt_id = ea.attempt_id), 0)), 1) AS highest " +
                     "FROM exams e " +
                     "LEFT JOIN exam_attempts ea ON e.exam_id = ea.exam_id AND ea.status IN ('SUBMITTED','AUTO_SUBMITTED') " +
                     "GROUP BY e.exam_id, e.exam_name, e.total_marks " +
                     "ORDER BY e.exam_id DESC";
        return executeMapQuery(sql);
    }

    // ==================== TOP PERFORMERS ====================

    /**
     * Gets top 10 students by average scaled exam score (0-10 scale).
     * Each exam's score is scaled to 10 (score / total_marks * 10) before averaging,
     * so exams with different total marks are fairly compared.
     */
    public List<Map<String, Object>> getTopPerformers() throws SQLException {
        String sql = "SELECT u.name, u.email, " +
                     "COUNT(ea.attempt_id) AS exams_taken, " +
                     "ROUND(AVG(" +
                     "  COALESCE((SELECT SUM(marks_awarded) FROM answers WHERE attempt_id = ea.attempt_id), 0) " +
                     "  / e.total_marks * 10" +
                     "), 1) AS avg_score " +
                     "FROM users u " +
                     "JOIN exam_attempts ea ON u.user_id = ea.user_id AND ea.status IN ('SUBMITTED','AUTO_SUBMITTED') " +
                     "JOIN exams e ON ea.exam_id = e.exam_id " +
                     "WHERE u.role = 'STUDENT' AND e.total_marks > 0 " +
                     "GROUP BY u.user_id, u.name, u.email " +
                     "ORDER BY avg_score DESC LIMIT 10";
        return executeMapQuery(sql);
    }

    // ==================== PLACEMENT REPORT ====================

    /**
     * Gets list of selected students with their company + role details.
     */
    public List<Map<String, Object>> getPlacementReport() throws SQLException {
        String sql = "SELECT u.name AS student_name, u.email, s.course, s.cgpa, " +
                     "c.company_name, i.role, i.stipend " +
                     "FROM applications a " +
                     "JOIN students s ON a.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "JOIN internships i ON a.internship_id = i.internship_id " +
                     "JOIN companies c ON i.company_id = c.company_id " +
                     "WHERE a.status = 'SELECTED' " +
                     "ORDER BY c.company_name, u.name";
        return executeMapQuery(sql);
    }

    // ==================== RECENT ACTIVITY ====================

    /**
     * Gets the most recent application activity (last 20).
     */
    public List<Map<String, Object>> getRecentActivity() throws SQLException {
        String sql = "SELECT al.action, al.log_time, u.name AS student_name, " +
                     "c.company_name, i.role " +
                     "FROM application_logs al " +
                     "JOIN applications a ON al.application_id = a.application_id " +
                     "JOIN students s ON a.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "JOIN internships i ON a.internship_id = i.internship_id " +
                     "JOIN companies c ON i.company_id = c.company_id " +
                     "ORDER BY al.log_time DESC LIMIT 20";
        return executeMapQuery(sql);
    }

    // ==================== HELPERS ====================

    private int getCount(Connection conn, String sql) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
            return 0;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        }
    }

    /**
     * Generic helper: executes a query and returns results as List of Maps.
     */
    private List<Map<String, Object>> executeMapQuery(String sql) throws SQLException {
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
