package com.project.controller;

import com.project.dao.InternshipDAO;
import com.project.dao.StudentDAO;
import com.project.model.Internship;
import com.project.model.Student;
import com.project.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Lists internships available to the logged-in student.
 * GET /student/internships → fetch eligible internships based on CGPA → forward to JSP
 *
 * Eligibility logic: Only shows internships where the company's eligibility_cgpa
 * is <= the student's CGPA and the deadline hasn't passed.
 */
@WebServlet("/student/internships")
public class InternshipListServlet extends HttpServlet {

    private InternshipDAO internshipDAO = new InternshipDAO();
    private StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");

        try {
            // Get student record to know their CGPA
            Student student = studentDAO.getByUserId(user.getUserId());

            if (student == null) {
                request.setAttribute("error", "Student profile not found. Please complete your profile first.");
                request.getRequestDispatcher("/student/internships.jsp").forward(request, response);
                return;
            }

            // Fetch internships eligible for this student's CGPA
            List<Internship> internships = internshipDAO.getEligible(student.getCgpa());
            request.setAttribute("internships", internships);
            request.setAttribute("studentCgpa", student.getCgpa());

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load internships.");
        }

        request.getRequestDispatcher("/student/internships.jsp").forward(request, response);
    }
}
