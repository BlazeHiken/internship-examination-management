package com.project.dao;

import com.project.model.Question;
import com.project.model.Option;
import com.project.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the 'questions' and 'options' tables.
 * Handles question CRUD and option management.
 */
public class QuestionDAO {

    /**
     * Gets all questions for an exam, with options loaded for MCQ questions.
     */
    public List<Question> getByExam(int examId) throws SQLException {
        String sql = "SELECT * FROM questions WHERE exam_id = ? ORDER BY question_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Question> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, examId);
            rs = ps.executeQuery();

            while (rs.next()) {
                Question q = mapQuestion(rs);
                // Load options for MCQ questions
                if ("MCQ".equals(q.getType())) {
                    q.setOptions(getOptionsByQuestion(q.getQuestionId(), conn));
                }
                list.add(q);
            }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets a single question by question_id, with options if MCQ.
     */
    public Question getById(int questionId) throws SQLException {
        String sql = "SELECT * FROM questions WHERE question_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, questionId);
            rs = ps.executeQuery();

            if (rs.next()) {
                Question q = mapQuestion(rs);
                if ("MCQ".equals(q.getType())) {
                    q.setOptions(getOptionsByQuestion(q.getQuestionId(), conn));
                }
                return q;
            }
            return null;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Adds a question with its options (for MCQ) in a single transaction.
     * Returns the generated question_id.
     */
    public int addWithOptions(Question question, List<Option> options) throws SQLException {
        String insertQ = "INSERT INTO questions (exam_id, question_text, type, marks) VALUES (?, ?, ?, ?)";
        String insertO = "INSERT INTO options (question_id, option_text, is_correct) VALUES (?, ?, ?)";

        Connection conn = null;
        PreparedStatement psQ = null;
        PreparedStatement psO = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Insert question
            psQ = conn.prepareStatement(insertQ, Statement.RETURN_GENERATED_KEYS);
            psQ.setInt(1, question.getExamId());
            psQ.setString(2, question.getQuestionText());
            psQ.setString(3, question.getType());
            psQ.setInt(4, question.getMarks());
            psQ.executeUpdate();

            rs = psQ.getGeneratedKeys();
            int questionId = 0;
            if (rs.next()) questionId = rs.getInt(1);

            // Insert options for MCQ
            if ("MCQ".equals(question.getType()) && options != null) {
                psO = conn.prepareStatement(insertO);
                for (Option opt : options) {
                    psO.setInt(1, questionId);
                    psO.setString(2, opt.getOptionText());
                    psO.setBoolean(3, opt.isCorrect());
                    psO.addBatch();
                }
                psO.executeBatch();
            }

            conn.commit();
            return questionId;

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (rs != null) rs.close();
            if (psQ != null) psQ.close();
            if (psO != null) psO.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                DBConnection.closeConnection(conn);
            }
        }
    }

    /**
     * Gets options for a question (uses existing connection).
     */
    private List<Option> getOptionsByQuestion(int questionId, Connection conn) throws SQLException {
        String sql = "SELECT * FROM options WHERE question_id = ? ORDER BY option_id ASC";
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Option> list = new ArrayList<>();

        try {
            ps = conn.prepareStatement(sql);
            ps.setInt(1, questionId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Option o = new Option();
                o.setOptionId(rs.getInt("option_id"));
                o.setQuestionId(rs.getInt("question_id"));
                o.setOptionText(rs.getString("option_text"));
                o.setCorrect(rs.getBoolean("is_correct"));
                list.add(o);
            }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        }
    }

    /**
     * Gets the correct option_id for a MCQ question.
     * Returns -1 if not found.
     */
    public int getCorrectOptionId(int questionId) throws SQLException {
        String sql = "SELECT option_id FROM options WHERE question_id = ? AND is_correct = TRUE LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, questionId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("option_id");
            return -1;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets the count of questions for an exam.
     */
    public int getQuestionCount(int examId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM questions WHERE exam_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, examId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
            return 0;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets the sum of marks of all questions in an exam.
     * Used to enforce total_marks limit when adding new questions.
     */
    public int getMarksSum(int examId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(marks), 0) FROM questions WHERE exam_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, examId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
            return 0;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    private Question mapQuestion(ResultSet rs) throws SQLException {
        Question q = new Question();
        q.setQuestionId(rs.getInt("question_id"));
        q.setExamId(rs.getInt("exam_id"));
        q.setQuestionText(rs.getString("question_text"));
        q.setType(rs.getString("type"));
        q.setMarks(rs.getInt("marks"));
        return q;
    }
}
