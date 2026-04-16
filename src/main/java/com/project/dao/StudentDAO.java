package com.project.dao;

import com.project.model.Student;
import com.project.util.DBConnection;

import java.sql.*;

/**
 * DAO for the 'students' table.
 * Handles profile retrieval, updates, and student lookups.
 */
public class StudentDAO {

    /**
     * Gets a student record by user_id (JOIN with users for name/email).
     * Returns null if not found.
     */
    public Student getByUserId(int userId) throws SQLException {
        String sql = "SELECT s.*, u.name, u.email FROM students s " +
                     "JOIN users u ON s.user_id = u.user_id WHERE s.user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapStudent(rs);
            }
            return null;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets a student record by student_id.
     */
    public Student getByStudentId(int studentId) throws SQLException {
        String sql = "SELECT s.*, u.name, u.email FROM students s " +
                     "JOIN users u ON s.user_id = u.user_id WHERE s.student_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, studentId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapStudent(rs);
            }
            return null;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Updates student profile (course, cgpa, phone) and user name.
     * Uses a transaction to update both tables atomically.
     */
    public boolean updateProfile(Student student) throws SQLException {
        String updateStudentSql = "UPDATE students SET course = ?, cgpa = ?, phone = ? WHERE student_id = ?";
        String updateUserSql = "UPDATE users SET name = ? WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement psStudent = null;
        PreparedStatement psUser = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Update students table
            psStudent = conn.prepareStatement(updateStudentSql);
            psStudent.setString(1, student.getCourse());
            psStudent.setDouble(2, student.getCgpa());
            psStudent.setString(3, student.getPhone());
            psStudent.setInt(4, student.getStudentId());
            psStudent.executeUpdate();

            // Update users table (name)
            psUser = conn.prepareStatement(updateUserSql);
            psUser.setString(1, student.getName());
            psUser.setInt(2, student.getUserId());
            psUser.executeUpdate();

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (psStudent != null) psStudent.close();
            if (psUser != null) psUser.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                DBConnection.closeConnection(conn);
            }
        }
    }

    /**
     * Gets the student_id for a given user_id.
     * Returns -1 if not found.
     */
    public int getStudentId(int userId) throws SQLException {
        String sql = "SELECT student_id FROM students WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("student_id");
            }
            return -1;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Helper: maps a ResultSet row to a Student object.
     */
    private Student mapStudent(ResultSet rs) throws SQLException {
        Student student = new Student();
        student.setStudentId(rs.getInt("student_id"));
        student.setUserId(rs.getInt("user_id"));
        student.setCourse(rs.getString("course"));
        student.setCgpa(rs.getDouble("cgpa"));
        student.setPhone(rs.getString("phone"));
        student.setName(rs.getString("name"));
        student.setEmail(rs.getString("email"));
        return student;
    }
}
