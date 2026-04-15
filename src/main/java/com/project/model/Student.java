package com.project.model;

/**
 * POJO representing a row in the 'students' table.
 * Linked to 'users' table via user_id (1:1 relationship).
 * Maps to: student_id, user_id, course, cgpa, phone
 */
public class Student {

    private int studentId;
    private int userId;
    private String course;
    private double cgpa;
    private String phone;

    // Also carry user info for convenience (populated via JOIN queries)
    private String name;
    private String email;

    // Default constructor
    public Student() {}

    // Constructor for registration
    public Student(int userId, String course, double cgpa, String phone) {
        this.userId = userId;
        this.course = course;
        this.cgpa = cgpa;
        this.phone = phone;
    }

    // --- Getters and Setters ---

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getCourse() {
        return course;
    }

    public void setCourse(String course) {
        this.course = course;
    }

    public double getCgpa() {
        return cgpa;
    }

    public void setCgpa(double cgpa) {
        this.cgpa = cgpa;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
