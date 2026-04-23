package com.project.controller;

import com.project.dao.ReportDAO;
import com.project.dao.AuditDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

/**
 * Admin reports dashboard with 5 specific reports.
 * GET /admin/reports → loads all 5 reports
 *
 * Report 1: Students selected per company
 * Report 2: Internship-wise application count
 * Report 3: Exam rank list
 * Report 4: Question-wise performance analysis
 * Report 5: Suspicious activity logs
 */
@WebServlet("/admin/reports")
public class ReportServlet extends HttpServlet {

    private ReportDAO reportDAO = new ReportDAO();
    private AuditDAO auditDAO = new AuditDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Report 1: Students selected per company
            request.setAttribute("selectionCounts", reportDAO.getSelectionCountPerCompany());
            request.setAttribute("selectedStudents", reportDAO.getSelectedStudentsPerCompany());

            // Report 2: Internship-wise application count
            request.setAttribute("internshipApps", reportDAO.getInternshipApplicationCounts());

            // Report 3: Exam rank list — load all exams, then rank list for each
            List<Map<String, Object>> exams = reportDAO.getExamList();
            request.setAttribute("examList", exams);
            // Load rank lists for each exam
            java.util.Map<Integer, List<Map<String, Object>>> rankLists = new java.util.LinkedHashMap<>();
            for (Map<String, Object> exam : exams) {
                int examId = ((Number) exam.get("exam_id")).intValue();
                rankLists.put(examId, reportDAO.getExamRankList(examId));
            }
            request.setAttribute("rankLists", rankLists);

            // Report 4: Question-wise performance — for each exam
            java.util.Map<Integer, List<Map<String, Object>>> questionPerf = new java.util.LinkedHashMap<>();
            for (Map<String, Object> exam : exams) {
                int examId = ((Number) exam.get("exam_id")).intValue();
                questionPerf.put(examId, reportDAO.getQuestionPerformance(examId));
            }
            request.setAttribute("questionPerformance", questionPerf);

            // Report 5: Suspicious activity logs
            request.setAttribute("suspiciousLogs", auditDAO.getSuspiciousLogs());

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load report data.");
        }

        request.getRequestDispatcher("/admin/reports.jsp").forward(request, response);
    }
}
