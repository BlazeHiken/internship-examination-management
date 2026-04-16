package com.project.dao;

import com.project.model.ExamAttempt;
import com.project.model.Answer;
import com.project.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the 'exam_attempts' and 'answers' tables.
 * Handles attempt lifecycle: start → save answers → submit → evaluate.
 */
public class ExamAttemptDAO {

    /**
     * Starts an exam attempt. Returns the generated attempt_id.
     * Throws exception if student already has an attempt (UNIQUE constraint).
     */
    public int startAttempt(int userId, int examId) throws SQLException {
        String sql = "INSERT INTO exam_attempts (user_id, exam_id) VALUES (?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, userId);
            ps.setInt(2, examId);
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
            throw new SQLException("Failed to get generated attempt_id");
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets an active (IN_PROGRESS) attempt for a user + exam.
     * Returns null if no active attempt exists.
     */
    public ExamAttempt getActiveAttempt(int userId, int examId) throws SQLException {
        String sql = "SELECT * FROM exam_attempts WHERE user_id = ? AND exam_id = ? AND status = 'IN_PROGRESS'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, examId);
            rs = ps.executeQuery();
            if (rs.next()) return mapAttempt(rs);
            return null;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets an attempt by attempt_id.
     */
    public ExamAttempt getById(int attemptId) throws SQLException {
        String sql = "SELECT * FROM exam_attempts WHERE attempt_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, attemptId);
            rs = ps.executeQuery();
            if (rs.next()) return mapAttempt(rs);
            return null;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Checks if user has already completed (submitted) this exam.
     */
    public boolean hasCompleted(int userId, int examId) throws SQLException {
        String sql = "SELECT 1 FROM exam_attempts WHERE user_id = ? AND exam_id = ? AND status IN ('SUBMITTED','AUTO_SUBMITTED')";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, examId);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Saves or updates an answer for a question in an attempt.
     * Uses INSERT ... ON DUPLICATE KEY UPDATE for upsert.
     */
    public void saveAnswer(int attemptId, int questionId, Integer selectedOption, String descriptiveAnswer) throws SQLException {
        String sql = "INSERT INTO answers (attempt_id, question_id, selected_option, descriptive_answer) " +
                     "VALUES (?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE selected_option = ?, descriptive_answer = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, attemptId);
            ps.setInt(2, questionId);
            if (selectedOption != null && selectedOption > 0) {
                ps.setInt(3, selectedOption);
                ps.setInt(5, selectedOption);
            } else {
                ps.setNull(3, Types.INTEGER);
                ps.setNull(5, Types.INTEGER);
            }
            ps.setString(4, descriptiveAnswer);
            ps.setString(6, descriptiveAnswer);
            ps.executeUpdate();
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Submits an exam attempt:
     * 1. Auto-evaluates MCQ answers
     * 2. Updates attempt status and end_time
     * All in a single transaction.
     */
    public void submitAttempt(int attemptId, String status) throws SQLException {
        // Auto-evaluate MCQ: set marks_awarded = question.marks WHERE selected_option is correct
        String evaluateMcq = "UPDATE answers a " +
                "JOIN questions q ON a.question_id = q.question_id " +
                "JOIN options o ON a.selected_option = o.option_id " +
                "SET a.marks_awarded = CASE WHEN o.is_correct = TRUE THEN q.marks ELSE 0 END " +
                "WHERE a.attempt_id = ? AND q.type = 'MCQ'";

        String updateAttempt = "UPDATE exam_attempts SET status = ?, end_time = NOW() WHERE attempt_id = ?";

        Connection conn = null;
        PreparedStatement psEval = null;
        PreparedStatement psUpdate = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Auto-evaluate MCQs
            psEval = conn.prepareStatement(evaluateMcq);
            psEval.setInt(1, attemptId);
            psEval.executeUpdate();

            // Update attempt status
            psUpdate = conn.prepareStatement(updateAttempt);
            psUpdate.setString(1, status);
            psUpdate.setInt(2, attemptId);
            psUpdate.executeUpdate();

            conn.commit();

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (psEval != null) psEval.close();
            if (psUpdate != null) psUpdate.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                DBConnection.closeConnection(conn);
            }
        }
    }

    /**
     * Gets all answers for an attempt with question details.
     * Used for result display and admin evaluation.
     */
    public List<Answer> getAnswers(int attemptId) throws SQLException {
        String sql = "SELECT a.*, q.question_text, q.type AS question_type, q.marks AS question_marks, " +
                     "o.option_text AS selected_option_text, o.is_correct " +
                     "FROM answers a " +
                     "JOIN questions q ON a.question_id = q.question_id " +
                     "LEFT JOIN options o ON a.selected_option = o.option_id " +
                     "WHERE a.attempt_id = ? ORDER BY a.question_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Answer> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, attemptId);
            rs = ps.executeQuery();

            while (rs.next()) {
                Answer ans = new Answer();
                ans.setAnswerId(rs.getInt("answer_id"));
                ans.setAttemptId(rs.getInt("attempt_id"));
                ans.setQuestionId(rs.getInt("question_id"));
                ans.setSelectedOption(rs.getInt("selected_option"));
                ans.setDescriptiveAnswer(rs.getString("descriptive_answer"));
                ans.setMarksAwarded(rs.getDouble("marks_awarded"));
                ans.setQuestionText(rs.getString("question_text"));
                ans.setQuestionType(rs.getString("question_type"));
                ans.setQuestionMarks(rs.getInt("question_marks"));
                ans.setSelectedOptionText(rs.getString("selected_option_text"));
                ans.setCorrect(rs.getBoolean("is_correct"));
                list.add(ans);
            }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets total score for an attempt.
     */
    public double getTotalScore(int attemptId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(marks_awarded), 0) FROM answers WHERE attempt_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, attemptId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble(1);
            return 0;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Updates marks for a subjective answer (admin evaluation).
     */
    public boolean updateMarks(int answerId, double marks) throws SQLException {
        String sql = "UPDATE answers SET marks_awarded = ? WHERE answer_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDouble(1, marks);
            ps.setInt(2, answerId);
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets all attempts for an exam (admin view with student names and scores).
     */
    public List<ExamAttempt> getAttemptsByExam(int examId) throws SQLException {
        String sql = "SELECT ea.*, u.name AS student_name, " +
                     "COALESCE((SELECT SUM(marks_awarded) FROM answers WHERE attempt_id = ea.attempt_id), 0) AS total_score, " +
                     "e.total_marks AS total_possible " +
                     "FROM exam_attempts ea " +
                     "JOIN users u ON ea.user_id = u.user_id " +
                     "JOIN exams e ON ea.exam_id = e.exam_id " +
                     "WHERE ea.exam_id = ? ORDER BY total_score DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<ExamAttempt> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, examId);
            rs = ps.executeQuery();

            while (rs.next()) {
                ExamAttempt a = mapAttempt(rs);
                a.setStudentName(rs.getString("student_name"));
                a.setTotalScore(rs.getDouble("total_score"));
                a.setTotalPossible(rs.getInt("total_possible"));
                list.add(a);
            }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Checks if an attempt has any subjective answers that haven't been graded yet.
     * Returns true if there are ungraded subjective answers.
     */
    public boolean hasUngradedSubjective(int attemptId) throws SQLException {
        String sql = "SELECT 1 FROM answers a " +
                     "JOIN questions q ON a.question_id = q.question_id " +
                     "WHERE a.attempt_id = ? AND q.type = 'SUBJECTIVE' AND a.marks_awarded = 0 " +
                     "AND a.descriptive_answer IS NOT NULL AND a.descriptive_answer != ''";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, attemptId);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Checks if an exam has any subjective questions at all.
     */
    public boolean hasSubjectiveQuestions(int examId) throws SQLException {
        String sql = "SELECT 1 FROM questions WHERE exam_id = ? AND type = 'SUBJECTIVE'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, examId);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets all completed attempts by a user (for exam history).
     * Includes exam name and scores.
     */
    public List<ExamAttempt> getAttemptsByUser(int userId) throws SQLException {
        String sql = "SELECT ea.*, e.exam_name, e.total_marks AS total_possible, " +
                     "COALESCE((SELECT SUM(marks_awarded) FROM answers WHERE attempt_id = ea.attempt_id), 0) AS total_score " +
                     "FROM exam_attempts ea " +
                     "JOIN exams e ON ea.exam_id = e.exam_id " +
                     "WHERE ea.user_id = ? AND ea.status IN ('SUBMITTED','AUTO_SUBMITTED') " +
                     "ORDER BY ea.end_time DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<ExamAttempt> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            while (rs.next()) {
                ExamAttempt a = mapAttempt(rs);
                a.setExamName(rs.getString("exam_name"));
                a.setTotalScore(rs.getDouble("total_score"));
                a.setTotalPossible(rs.getInt("total_possible"));
                list.add(a);
            }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    private ExamAttempt mapAttempt(ResultSet rs) throws SQLException {
        ExamAttempt a = new ExamAttempt();
        a.setAttemptId(rs.getInt("attempt_id"));
        a.setUserId(rs.getInt("user_id"));
        a.setExamId(rs.getInt("exam_id"));
        a.setStartTime(rs.getTimestamp("start_time"));
        a.setEndTime(rs.getTimestamp("end_time"));
        a.setStatus(rs.getString("status"));
        return a;
    }
}
