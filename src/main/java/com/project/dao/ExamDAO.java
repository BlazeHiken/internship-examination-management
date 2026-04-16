package com.project.dao;

import com.project.model.Exam;
import com.project.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the 'exams' table.
 * Handles CRUD and availability queries.
 */
public class ExamDAO {

    /**
     * Gets all exams ordered by start_time descending.
     */
    public List<Exam> getAll() throws SQLException {
        String sql = "SELECT * FROM exams ORDER BY start_time DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Exam> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) { list.add(mapExam(rs)); }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets exams available for a student to take.
     * Available = current time is between start_time and end_time,
     * AND the student hasn't already attempted it.
     */
    public List<Exam> getAvailable(int userId) throws SQLException {
        String sql = "SELECT e.* FROM exams e " +
                     "WHERE NOW() BETWEEN e.start_time AND e.end_time " +
                     "AND e.exam_id NOT IN (SELECT exam_id FROM exam_attempts WHERE user_id = ? AND status != 'IN_PROGRESS') " +
                     "ORDER BY e.start_time ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Exam> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) { list.add(mapExam(rs)); }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets a single exam by exam_id.
     */
    public Exam getById(int examId) throws SQLException {
        String sql = "SELECT * FROM exams WHERE exam_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, examId);
            rs = ps.executeQuery();
            if (rs.next()) return mapExam(rs);
            return null;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Adds a new exam. Returns the generated exam_id.
     */
    public int add(Exam exam) throws SQLException {
        String sql = "INSERT INTO exams (exam_name, duration, start_time, end_time, total_marks) VALUES (?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, exam.getExamName());
            ps.setInt(2, exam.getDuration());
            ps.setTimestamp(3, exam.getStartTime());
            ps.setTimestamp(4, exam.getEndTime());
            ps.setInt(5, exam.getTotalMarks());
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
            throw new SQLException("Failed to get generated exam_id");
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Deletes an exam and all associated data (cascades via FK).
     */
    public boolean delete(int examId) throws SQLException {
        String sql = "DELETE FROM exams WHERE exam_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, examId);
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    private Exam mapExam(ResultSet rs) throws SQLException {
        Exam e = new Exam();
        e.setExamId(rs.getInt("exam_id"));
        e.setExamName(rs.getString("exam_name"));
        e.setDuration(rs.getInt("duration"));
        e.setStartTime(rs.getTimestamp("start_time"));
        e.setEndTime(rs.getTimestamp("end_time"));
        e.setTotalMarks(rs.getInt("total_marks"));
        return e;
    }
}
