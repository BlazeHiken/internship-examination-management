package com.project.model;

import java.sql.Timestamp;

/**
 * POJO representing a row in the 'exams' table.
 * Maps to: exam_id, exam_name, duration, start_time, end_time, total_marks
 */
public class Exam {

    private int examId;
    private String examName;
    private int duration;           // in minutes
    private Timestamp startTime;
    private Timestamp endTime;
    private int totalMarks;

    // Default constructor
    public Exam() {}

    // --- Getters and Setters ---

    public int getExamId() { return examId; }
    public void setExamId(int examId) { this.examId = examId; }

    public String getExamName() { return examName; }
    public void setExamName(String examName) { this.examName = examName; }

    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }

    public Timestamp getStartTime() { return startTime; }
    public void setStartTime(Timestamp startTime) { this.startTime = startTime; }

    public Timestamp getEndTime() { return endTime; }
    public void setEndTime(Timestamp endTime) { this.endTime = endTime; }

    public int getTotalMarks() { return totalMarks; }
    public void setTotalMarks(int totalMarks) { this.totalMarks = totalMarks; }
}
