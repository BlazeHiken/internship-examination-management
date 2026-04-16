package com.project.dao;

import com.project.model.Application;
import com.project.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the 'applications' and 'application_logs' tables.
 * Handles applying, duplicate checks, deadline checks, status updates,
 * and application log recording — all within transactions.
 */
public class ApplicationDAO {

    /**
     * Student applies for an internship.
     * Uses a transaction to insert into 'applications' + 'application_logs'.
     * Returns the generated application_id.
     *
     * Checks: duplicate application (UNIQUE constraint) and deadline.
     */
    public int apply(int studentId, int internshipId) throws SQLException {
        String insertApp = "INSERT INTO applications (student_id, internship_id) VALUES (?, ?)";
        String insertLog = "INSERT INTO application_logs (application_id, action) VALUES (?, ?)";

        Connection conn = null;
        PreparedStatement psApp = null;
        PreparedStatement psLog = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Insert application
            psApp = conn.prepareStatement(insertApp, Statement.RETURN_GENERATED_KEYS);
            psApp.setInt(1, studentId);
            psApp.setInt(2, internshipId);
            psApp.executeUpdate();

            rs = psApp.getGeneratedKeys();
            int applicationId = 0;
            if (rs.next()) {
                applicationId = rs.getInt(1);
            }

            // Log the application
            psLog = conn.prepareStatement(insertLog);
            psLog.setInt(1, applicationId);
            psLog.setString(2, "APPLIED");
            psLog.executeUpdate();

            conn.commit();
            return applicationId;

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (rs != null) rs.close();
            if (psApp != null) psApp.close();
            if (psLog != null) psLog.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                DBConnection.closeConnection(conn);
            }
        }
    }

    /**
     * Checks if a student has already applied for a specific internship.
     */
    public boolean hasApplied(int studentId, int internshipId) throws SQLException {
        String sql = "SELECT 1 FROM applications WHERE student_id = ? AND internship_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);
            ps.setInt(2, internshipId);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Checks if the internship deadline has passed.
     */
    public boolean isDeadlinePassed(int internshipId) throws SQLException {
        String sql = "SELECT 1 FROM internships WHERE internship_id = ? AND deadline < CURDATE()";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, internshipId);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Updates application status and logs the action.
     * Used by admin to shortlist/reject/select.
     */
    public boolean updateStatus(int applicationId, String newStatus) throws SQLException {
        String updateSql = "UPDATE applications SET status = ? WHERE application_id = ?";
        String insertLog = "INSERT INTO application_logs (application_id, action) VALUES (?, ?)";

        Connection conn = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psLog = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            psUpdate = conn.prepareStatement(updateSql);
            psUpdate.setString(1, newStatus);
            psUpdate.setInt(2, applicationId);
            int rows = psUpdate.executeUpdate();

            if (rows > 0) {
                psLog = conn.prepareStatement(insertLog);
                psLog.setInt(1, applicationId);
                psLog.setString(2, newStatus);
                psLog.executeUpdate();
            }

            conn.commit();
            return rows > 0;

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (psUpdate != null) psUpdate.close();
            if (psLog != null) psLog.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                DBConnection.closeConnection(conn);
            }
        }
    }

    /**
     * Gets all applications for a student (with company/role info).
     * Used for student "My Applications" page.
     */
    public List<Application> getByStudent(int studentId) throws SQLException {
        String sql = "SELECT a.*, c.company_name, i.role AS internship_role " +
                     "FROM applications a " +
                     "JOIN internships i ON a.internship_id = i.internship_id " +
                     "JOIN companies c ON i.company_id = c.company_id " +
                     "WHERE a.student_id = ? ORDER BY a.applied_date DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Application> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);
            rs = ps.executeQuery();

            while (rs.next()) {
                Application app = mapApplicationBasic(rs);
                app.setCompanyName(rs.getString("company_name"));
                app.setInternshipRole(rs.getString("internship_role"));
                list.add(app);
            }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets all applications for a specific internship (with student info).
     * Used by admin to manage applications.
     */
    public List<Application> getByInternship(int internshipId) throws SQLException {
        String sql = "SELECT a.*, u.name AS student_name, u.email AS student_email, " +
                     "s.course AS student_course, s.cgpa AS student_cgpa " +
                     "FROM applications a " +
                     "JOIN students s ON a.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "WHERE a.internship_id = ? ORDER BY a.applied_date ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Application> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, internshipId);
            rs = ps.executeQuery();

            while (rs.next()) {
                Application app = mapApplicationBasic(rs);
                app.setStudentName(rs.getString("student_name"));
                app.setStudentEmail(rs.getString("student_email"));
                app.setStudentCourse(rs.getString("student_course"));
                app.setStudentCgpa(rs.getDouble("student_cgpa"));
                list.add(app);
            }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets all applications across all internships (with student + internship info).
     * Used by admin for the main applications overview.
     */
    public List<Application> getAll() throws SQLException {
        String sql = "SELECT a.*, u.name AS student_name, u.email AS student_email, " +
                     "s.course AS student_course, s.cgpa AS student_cgpa, " +
                     "c.company_name, i.role AS internship_role " +
                     "FROM applications a " +
                     "JOIN students s ON a.student_id = s.student_id " +
                     "JOIN users u ON s.user_id = u.user_id " +
                     "JOIN internships i ON a.internship_id = i.internship_id " +
                     "JOIN companies c ON i.company_id = c.company_id " +
                     "ORDER BY a.applied_date DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Application> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Application app = mapApplicationBasic(rs);
                app.setStudentName(rs.getString("student_name"));
                app.setStudentEmail(rs.getString("student_email"));
                app.setStudentCourse(rs.getString("student_course"));
                app.setStudentCgpa(rs.getDouble("student_cgpa"));
                app.setCompanyName(rs.getString("company_name"));
                app.setInternshipRole(rs.getString("internship_role"));
                list.add(app);
            }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Helper: maps base application fields from ResultSet.
     */
    private Application mapApplicationBasic(ResultSet rs) throws SQLException {
        Application app = new Application();
        app.setApplicationId(rs.getInt("application_id"));
        app.setStudentId(rs.getInt("student_id"));
        app.setInternshipId(rs.getInt("internship_id"));
        app.setStatus(rs.getString("status"));
        app.setAppliedDate(rs.getTimestamp("applied_date"));
        return app;
    }
}
