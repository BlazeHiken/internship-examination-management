package com.project.dao;

import com.project.model.Company;
import com.project.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for the 'companies' table.
 * Full CRUD operations for admin to manage partner companies.
 */
public class CompanyDAO {

    /**
     * Gets all companies, ordered by name.
     */
    public List<Company> getAll() throws SQLException {
        String sql = "SELECT * FROM companies ORDER BY company_name ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Company> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapCompany(rs));
            }
            return list;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Gets a single company by company_id.
     */
    public Company getById(int companyId) throws SQLException {
        String sql = "SELECT * FROM companies WHERE company_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, companyId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapCompany(rs);
            }
            return null;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Adds a new company. Returns the generated company_id.
     */
    public int add(Company company) throws SQLException {
        String sql = "INSERT INTO companies (company_name, location, eligibility_cgpa) VALUES (?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, company.getCompanyName());
            ps.setString(2, company.getLocation());
            ps.setDouble(3, company.getEligibilityCgpa());
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
            throw new SQLException("Failed to get generated company_id");
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Updates an existing company.
     */
    public boolean update(Company company) throws SQLException {
        String sql = "UPDATE companies SET company_name = ?, location = ?, eligibility_cgpa = ? WHERE company_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, company.getCompanyName());
            ps.setString(2, company.getLocation());
            ps.setDouble(3, company.getEligibilityCgpa());
            ps.setInt(4, company.getCompanyId());
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Deletes a company by company_id.
     * Cascades to internships and their applications due to FK constraints.
     */
    public boolean delete(int companyId) throws SQLException {
        String sql = "DELETE FROM companies WHERE company_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, companyId);
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) ps.close();
            DBConnection.closeConnection(conn);
        }
    }

    /**
     * Helper: maps a ResultSet row to a Company object.
     */
    private Company mapCompany(ResultSet rs) throws SQLException {
        Company c = new Company();
        c.setCompanyId(rs.getInt("company_id"));
        c.setCompanyName(rs.getString("company_name"));
        c.setLocation(rs.getString("location"));
        c.setEligibilityCgpa(rs.getDouble("eligibility_cgpa"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        return c;
    }
}
