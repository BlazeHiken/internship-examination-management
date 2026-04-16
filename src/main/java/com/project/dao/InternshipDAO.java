package com.project.dao;

import com.project.model.Internship;
import com.project.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the 'internships' table.
 * Handles listing, eligibility-based filtering, and CRUD operations.
 * Queries JOIN with 'companies' to get company info for display.
 */
public class InternshipDAO {

    /**
     * Gets all internships (with company info via JOIN).
     * Used by admin to see all internships.
     */
    public List<Internship> getAll() throws SQLException {
        String sql = "SELECT i.*, c.company_name, c.location, c.eligibility_cgpa " +
                     "FROM internships i JOIN companies c ON i.company_id = c.company_id " +
                     "ORDER BY i.deadline ASC";
        return executeQuery(sql, null);
    }

    /**
     * Gets internships eligible for a student based on their CGPA.
     * Only shows internships where:
     *   - company's eligibility_cgpa <= student's CGPA
     *   - deadline has not passed
     */
    public List<Internship> getEligible(double studentCgpa) throws SQLException {
        String sql = "SELECT i.*, c.company_name, c.location, c.eligibility_cgpa " +
                     "FROM internships i JOIN companies c ON i.company_id = c.company_id " +
                     "WHERE c.eligibility_cgpa <= ? AND i.deadline >= CURDATE() " +
                     "ORDER BY i.deadline ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Internship> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDouble(1, studentCgpa);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapInternship(rs));
            }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets a single internship by internship_id (with company info).
     */
    public Internship getById(int internshipId) throws SQLException {
        String sql = "SELECT i.*, c.company_name, c.location, c.eligibility_cgpa " +
                     "FROM internships i JOIN companies c ON i.company_id = c.company_id " +
                     "WHERE i.internship_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, internshipId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapInternship(rs);
            }
            return null;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Adds a new internship. Returns the generated internship_id.
     */
    public int add(Internship internship) throws SQLException {
        String sql = "INSERT INTO internships (company_id, role, stipend, deadline) VALUES (?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, internship.getCompanyId());
            ps.setString(2, internship.getRole());
            ps.setDouble(3, internship.getStipend());
            ps.setDate(4, internship.getDeadline());
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
            throw new SQLException("Failed to get generated internship_id");
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Updates an existing internship.
     */
    public boolean update(Internship internship) throws SQLException {
        String sql = "UPDATE internships SET company_id = ?, role = ?, stipend = ?, deadline = ? " +
                     "WHERE internship_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, internship.getCompanyId());
            ps.setString(2, internship.getRole());
            ps.setDouble(3, internship.getStipend());
            ps.setDate(4, internship.getDeadline());
            ps.setInt(5, internship.getInternshipId());
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Deletes an internship by internship_id.
     */
    public boolean delete(int internshipId) throws SQLException {
        String sql = "DELETE FROM internships WHERE internship_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, internshipId);
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Helper: executes a query with no parameters and returns list of internships.
     */
    private List<Internship> executeQuery(String sql, Void unused) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Internship> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapInternship(rs));
            }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Helper: maps a ResultSet row to an Internship object.
     */
    private Internship mapInternship(ResultSet rs) throws SQLException {
        Internship i = new Internship();
        i.setInternshipId(rs.getInt("internship_id"));
        i.setCompanyId(rs.getInt("company_id"));
        i.setRole(rs.getString("role"));
        i.setStipend(rs.getDouble("stipend"));
        i.setDeadline(rs.getDate("deadline"));
        i.setCreatedAt(rs.getTimestamp("created_at"));
        i.setCompanyName(rs.getString("company_name"));
        i.setCompanyLocation(rs.getString("location"));
        i.setEligibilityCgpa(rs.getDouble("eligibility_cgpa"));
        return i;
    }
}
