package com.project.model;

import java.sql.Timestamp;

/**
 * POJO representing a row in the 'exam_attempts' table.
 * Maps to: attempt_id, user_id, exam_id, start_time, end_time, status
 * Also carries computed fields: total_score, total_possible
 */
public class ExamAttempt {

    private int attemptId;
    private int userId;
    private int examId;
    private Timestamp startTime;
    private Timestamp endTime;
    private String status;          // IN_PROGRESS, SUBMITTED, AUTO_SUBMITTED

    // Computed/joined fields
    private String examName;
    private double totalScore;
    private int totalPossible;
    private String studentName;

    // Default constructor
    public ExamAttempt() {}

    // --- Getters and Setters ---

    public int getAttemptId() { return attemptId; }
    public void setAttemptId(int attemptId) { this.attemptId = attemptId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getExamId() { return examId; }
    public void setExamId(int examId) { this.examId = examId; }

    public Timestamp getStartTime() { return startTime; }
    public void setStartTime(Timestamp startTime) { this.startTime = startTime; }

    public Timestamp getEndTime() { return endTime; }
    public void setEndTime(Timestamp endTime) { this.endTime = endTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getExamName() { return examName; }
    public void setExamName(String examName) { this.examName = examName; }

    public double getTotalScore() { return totalScore; }
    public void setTotalScore(double totalScore) { this.totalScore = totalScore; }

    public int getTotalPossible() { return totalPossible; }
    public void setTotalPossible(int totalPossible) { this.totalPossible = totalPossible; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
}
