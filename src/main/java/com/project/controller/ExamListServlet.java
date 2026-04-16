package com.project.controller;

import com.project.dao.ExamDAO;
import com.project.dao.ExamAttemptDAO;
import com.project.model.Exam;
import com.project.model.ExamAttempt;
import com.project.model.Answer;
import com.project.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Student exam list, history, and result view.
 * GET /student/exams                        → list available exams + exam history
 * GET /student/exams?action=result&examId=X → view result (only if fully graded)
 */
@WebServlet("/student/exams")
public class ExamListServlet extends HttpServlet {

    private ExamDAO examDAO = new ExamDAO();
    private ExamAttemptDAO attemptDAO = new ExamAttemptDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        String action = request.getParameter("action");

        try {
            if ("result".equals(action)) {
                // Show exam result — but only if fully graded
                int examId = Integer.parseInt(request.getParameter("examId"));
                Exam exam = examDAO.getById(examId);

                // Find the student's completed attempt
                List<ExamAttempt> allAttempts = attemptDAO.getAttemptsByExam(examId);
                ExamAttempt attempt = null;
                for (ExamAttempt a : allAttempts) {
                    if (a.getUserId() == user.getUserId()) {
                        attempt = a;
                        break;
                    }
                }

                if (attempt == null) {
                    response.sendRedirect(request.getContextPath() + "/student/exams");
                    return;
                }

                // Check if there are ungraded subjective answers
                boolean hasSubjective = attemptDAO.hasSubjectiveQuestions(examId);
                boolean pendingEvaluation = false;
                if (hasSubjective) {
                    pendingEvaluation = attemptDAO.hasUngradedSubjective(attempt.getAttemptId());
                }

                request.setAttribute("exam", exam);
                request.setAttribute("attempt", attempt);
                request.setAttribute("pendingEvaluation", pendingEvaluation);

                if (!pendingEvaluation) {
                    // Fully graded — show detailed results
                    List<Answer> answers = attemptDAO.getAnswers(attempt.getAttemptId());
                    double totalScore = attemptDAO.getTotalScore(attempt.getAttemptId());
                    request.setAttribute("answers", answers);
                    request.setAttribute("totalScore", totalScore);
                }

                request.getRequestDispatcher("/student/exam_result.jsp").forward(request, response);

            } else {
                // List available exams + exam history
                List<Exam> exams = examDAO.getAvailable(user.getUserId());
                request.setAttribute("exams", exams);

                // Load completed exam history
                List<ExamAttempt> completedExams = attemptDAO.getAttemptsByUser(user.getUserId());

                // For each completed attempt, check if it's pending evaluation
                for (ExamAttempt a : completedExams) {
                    boolean hasSubjective = attemptDAO.hasSubjectiveQuestions(a.getExamId());
                    if (hasSubjective && attemptDAO.hasUngradedSubjective(a.getAttemptId())) {
                        a.setStatus("PENDING_EVALUATION");
                    }
                }

                request.setAttribute("completedExams", completedExams);
                request.getRequestDispatcher("/student/exams.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Failed to load exams.");
            request.getRequestDispatcher("/student/exams.jsp").forward(request, response);
        }
    }
}
