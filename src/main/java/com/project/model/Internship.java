package com.project.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * POJO representing a row in the 'internships' table.
 * Maps to: internship_id, company_id, role, stipend, deadline, created_at
 * Also carries company info (company_name, location) for display via JOINs.
 */
public class Internship {

    private int internshipId;
    private int companyId;
    private String role;
    private double stipend;
    private Date deadline;
    private Timestamp createdAt;

    // Joined fields from companies table (for display convenience)
    private String companyName;
    private String companyLocation;
    private double eligibilityCgpa;

    // Default constructor
    public Internship() {}

    // Parameterized constructor
    public Internship(int companyId, String role, double stipend, Date deadline) {
        this.companyId = companyId;
        this.role = role;
        this.stipend = stipend;
        this.deadline = deadline;
    }

    // --- Getters and Setters ---

    public int getInternshipId() {
        return internshipId;
    }

    public void setInternshipId(int internshipId) {
        this.internshipId = internshipId;
    }

    public int getCompanyId() {
        return companyId;
    }

    public void setCompanyId(int companyId) {
        this.companyId = companyId;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public double getStipend() {
        return stipend;
    }

    public void setStipend(double stipend) {
        this.stipend = stipend;
    }

    public Date getDeadline() {
        return deadline;
    }

    public void setDeadline(Date deadline) {
        this.deadline = deadline;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getCompanyLocation() {
        return companyLocation;
    }

    public void setCompanyLocation(String companyLocation) {
        this.companyLocation = companyLocation;
    }

    public double getEligibilityCgpa() {
        return eligibilityCgpa;
    }

    public void setEligibilityCgpa(double eligibilityCgpa) {
        this.eligibilityCgpa = eligibilityCgpa;
    }
}
