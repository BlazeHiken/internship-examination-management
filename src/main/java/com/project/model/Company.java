package com.project.model;

import java.sql.Timestamp;

/**
 * POJO representing a row in the 'companies' table.
 * Maps to: company_id, company_name, location, eligibility_cgpa, created_at
 */
public class Company {

    private int companyId;
    private String companyName;
    private String location;
    private double eligibilityCgpa;
    private Timestamp createdAt;

    // Default constructor
    public Company() {}

    // Parameterized constructor
    public Company(String companyName, String location, double eligibilityCgpa) {
        this.companyName = companyName;
        this.location = location;
        this.eligibilityCgpa = eligibilityCgpa;
    }

    // --- Getters and Setters ---

    public int getCompanyId() {
        return companyId;
    }

    public void setCompanyId(int companyId) {
        this.companyId = companyId;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public double getEligibilityCgpa() {
        return eligibilityCgpa;
    }

    public void setEligibilityCgpa(double eligibilityCgpa) {
        this.eligibilityCgpa = eligibilityCgpa;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
