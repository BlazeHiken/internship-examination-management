package com.project.model;

import java.sql.Timestamp;

/**
 * POJO representing a row in the 'applications' table.
 * Maps to: application_id, student_id, internship_id, status, applied_date
 * Also carries joined fields for display (student name, company, role).
 */
public class Application {

    private int applicationId;
    private int studentId;
    private int internshipId;
    private String status;       // APPLIED, SHORTLISTED, REJECTED, SELECTED
    private Timestamp appliedDate;

    // Joined fields for display
    private String studentName;
    private String studentEmail;
    private String studentCourse;
    private double studentCgpa;
    private String companyName;
    private String internshipRole;

    // Default constructor
    public Application() {}

    // Constructor for applying
    public Application(int studentId, int internshipId) {
        this.studentId = studentId;
        this.internshipId = internshipId;
        this.status = "APPLIED";
    }

    // --- Getters and Setters ---

    public int getApplicationId() { return applicationId; }
    public void setApplicationId(int applicationId) { this.applicationId = applicationId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getInternshipId() { return internshipId; }
    public void setInternshipId(int internshipId) { this.internshipId = internshipId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getAppliedDate() { return appliedDate; }
    public void setAppliedDate(Timestamp appliedDate) { this.appliedDate = appliedDate; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }

    public String getStudentCourse() { return studentCourse; }
    public void setStudentCourse(String studentCourse) { this.studentCourse = studentCourse; }

    public double getStudentCgpa() { return studentCgpa; }
    public void setStudentCgpa(double studentCgpa) { this.studentCgpa = studentCgpa; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getInternshipRole() { return internshipRole; }
    public void setInternshipRole(String internshipRole) { this.internshipRole = internshipRole; }
}
