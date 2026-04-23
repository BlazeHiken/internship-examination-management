package com.project.dao;

import com.project.util.DBConnection;

import java.sql.*;
import java.util.*;

/**
 * DAO for generating admin reports and analytics.
 * Provides data for 5 specific reports:
 * R1: Students selected per company
 * R2: Internship-wise application count
 * R3: Exam rank list
 * R4: Question-wise performance analysis
 * R5: Suspicious activity logs (handled by AuditDAO)
 */
public class ReportDAO {

    // ==================== REPORT 1: Students Selected Per Company ====================

    /**
     * Gets students who have been selected, grouped by company.
     * Returns: student_name, email, course, cgpa, company_name, role, stipend
     */
    public List<Map<String, Object>> getSelectedStudentsPerCompany() throws SQLException {
        String sql = "SELECT c.company_name, u.name AS student_name, u.email, " +
                     "s.course, s.cgpa, i.role, i.stipend " +
                     "FROM applications a " +
                     "JOIN students s ON a.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "JOIN internships i ON a.internship_id = i.internship_id " +
                     "JOIN companies c ON i.company_id = c.company_id " +
                     "WHERE a.status = 'SELECTED' " +
                     "ORDER BY c.company_name, u.name";
        return executeMapQuery(sql);
    }

    /**
     * Gets count of selected students per company (for summary).
     */
    public List<Map<String, Object>> getSelectionCountPerCompany() throws SQLException {
        String sql = "SELECT c.company_name, COUNT(a.application_id) AS selected_count " +
                     "FROM applications a " +
                     "JOIN internships i ON a.internship_id = i.internship_id " +
                     "JOIN companies c ON i.company_id = c.company_id " +
                     "WHERE a.status = 'SELECTED' " +
                     "GROUP BY c.company_id, c.company_name " +
                     "ORDER BY selected_count DESC";
        return executeMapQuery(sql);
    }

    // ==================== REPORT 2: Internship-wise Application Count ====================

    /**
     * Gets application counts per internship with status breakdown.
     * Returns: company_name, role, stipend, deadline, total_apps, applied, shortlisted, selected, rejected
     */
    public List<Map<String, Object>> getInternshipApplicationCounts() throws SQLException {
        String sql = "SELECT c.company_name, i.role, i.stipend, i.deadline, " +
                     "COUNT(a.application_id) AS total_apps, " +
                     "SUM(CASE WHEN a.status='APPLIED' THEN 1 ELSE 0 END) AS applied, " +
                     "SUM(CASE WHEN a.status='SHORTLISTED' THEN 1 ELSE 0 END) AS shortlisted, " +
                     "SUM(CASE WHEN a.status='SELECTED' THEN 1 ELSE 0 END) AS selected, " +
                     "SUM(CASE WHEN a.status='REJECTED' THEN 1 ELSE 0 END) AS rejected " +
                     "FROM internships i " +
                     "JOIN companies c ON i.company_id = c.company_id " +
                     "LEFT JOIN applications a ON i.internship_id = a.internship_id " +
                     "GROUP BY i.internship_id, c.company_name, i.role, i.stipend, i.deadline " +
                     "ORDER BY total_apps DESC";
        return executeMapQuery(sql);
    }

    // ==================== REPORT 3: Exam Rank List ====================

    /**
     * Gets all exams for the rank list dropdown/section headers.
     */
    public List<Map<String, Object>> getExamList() throws SQLException {
        String sql = "SELECT exam_id, exam_name, total_marks, duration, start_time, end_time " +
                     "FROM exams ORDER BY exam_id DESC";
        return executeMapQuery(sql);
    }

    /**
     * Gets ranked students for a specific exam by total score.
     * Returns: rank, student_name, email, total_score, total_marks, percentage
     */
    public List<Map<String, Object>> getExamRankList(int examId) throws SQLException {
        String sql = "SELECT u.name AS student_name, u.email, " +
                     "COALESCE(SUM(ans.marks_awarded), 0) AS total_score, " +
                     "e.total_marks, " +
                     "ROUND(COALESCE(SUM(ans.marks_awarded), 0) / e.total_marks * 100, 1) AS percentage " +
                     "FROM exam_attempts ea " +
                     "JOIN users u ON ea.user_id = u.user_id " +
                     "JOIN exams e ON ea.exam_id = e.exam_id " +
                     "LEFT JOIN answers ans ON ea.attempt_id = ans.attempt_id " +
                     "WHERE ea.exam_id = ? AND ea.status IN ('SUBMITTED','AUTO_SUBMITTED') " +
                     "GROUP BY ea.attempt_id, u.name, u.email, e.total_marks " +
                     "ORDER BY total_score DESC";
        return executeParamMapQuery(sql, examId);
    }

    // ==================== REPORT 4: Question-wise Performance Analysis ====================

    /**
     * Gets performance analysis for each question in an exam.
     * For MCQ: correct count, incorrect count, accuracy %
     * For Subjective: avg marks, max marks, min marks
     */
    public List<Map<String, Object>> getQuestionPerformance(int examId) throws SQLException {
        String sql = "SELECT q.question_id, q.question_text, q.type, q.marks, " +
                     "COUNT(a.answer_id) AS attempts, " +
                     "CASE WHEN q.type = 'MCQ' THEN " +
                     "  SUM(CASE WHEN a.marks_awarded = q.marks THEN 1 ELSE 0 END) " +
                     "ELSE NULL END AS correct_count, " +
                     "CASE WHEN q.type = 'MCQ' THEN " +
                     "  SUM(CASE WHEN a.marks_awarded = 0 THEN 1 ELSE 0 END) " +
                     "ELSE NULL END AS incorrect_count, " +
                     "CASE WHEN q.type = 'MCQ' THEN " +
                     "  ROUND(SUM(CASE WHEN a.marks_awarded = q.marks THEN 1 ELSE 0 END) / COUNT(a.answer_id) * 100, 1) " +
                     "ELSE NULL END AS accuracy, " +
                     "ROUND(AVG(a.marks_awarded), 1) AS avg_marks, " +
                     "MAX(a.marks_awarded) AS max_marks, " +
                     "MIN(a.marks_awarded) AS min_marks " +
                     "FROM questions q " +
                     "LEFT JOIN answers a ON q.question_id = a.question_id " +
                     "WHERE q.exam_id = ? " +
                     "GROUP BY q.question_id, q.question_text, q.type, q.marks " +
                     "ORDER BY q.question_id";
        return executeParamMapQuery(sql, examId);
    }

    // ==================== HELPERS ====================

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

    /**
     * Executes a parameterized query with a single int parameter.
     */
    private List<Map<String, Object>> executeParamMapQuery(String sql, int param) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Map<String, Object>> results = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, param);
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
