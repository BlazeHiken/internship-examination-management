package com.project.controller;

import com.project.dao.ExamDAO;
import com.project.dao.ExamAttemptDAO;
import com.project.dao.QuestionDAO;
import com.project.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Handles the exam-taking experience.
 * GET  /student/exam?examId=X              → start or resume exam, show exam page
 * POST /student/exam                       → save answer for current question
 * POST /student/exam?action=submit         → manual submit
 * POST /student/exam?action=autosubmit     → timer-triggered auto-submit
 */
@WebServlet("/student/exam")
public class ExamServlet extends HttpServlet {

    private ExamDAO examDAO = new ExamDAO();
    private ExamAttemptDAO attemptDAO = new ExamAttemptDAO();
    private QuestionDAO questionDAO = new QuestionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        int examId = Integer.parseInt(request.getParameter("examId"));

        try {
            Exam exam = examDAO.getById(examId);
            if (exam == null) {
                response.sendRedirect(request.getContextPath() + "/student/exams");
                return;
            }

            // Check if already completed
            if (attemptDAO.hasCompleted(user.getUserId(), examId)) {
                response.sendRedirect(request.getContextPath() + "/student/exams?action=result&examId=" + examId);
                return;
            }

            // Get or create attempt
            ExamAttempt attempt = attemptDAO.getActiveAttempt(user.getUserId(), examId);
            if (attempt == null) {
                int attemptId = attemptDAO.startAttempt(user.getUserId(), examId);
                attempt = attemptDAO.getById(attemptId);
            }

            // Load all questions with options
            List<Question> questions = questionDAO.getByExam(examId);

            // Load existing answers to mark answered questions
            List<Answer> existingAnswers = attemptDAO.getAnswers(attempt.getAttemptId());
            for (Question q : questions) {
                for (Answer a : existingAnswers) {
                    if (a.getQuestionId() == q.getQuestionId()) {
                        q.setSelectedOptionId(a.getSelectedOption());
                        q.setDescriptiveAnswer(a.getDescriptiveAnswer());
                        break;
                    }
                }
            }

            // Calculate remaining time in seconds
            long elapsedMs = System.currentTimeMillis() - attempt.getStartTime().getTime();
            long totalMs = exam.getDuration() * 60L * 1000L;
            long remainingSeconds = Math.max(0, (totalMs - elapsedMs) / 1000);

            // If time is up, auto-submit
            if (remainingSeconds <= 0) {
                attemptDAO.submitAttempt(attempt.getAttemptId(), "AUTO_SUBMITTED");
                response.sendRedirect(request.getContextPath() + "/student/exams?action=result&examId=" + examId);
                return;
            }

            // Determine current question index
            String qIndexStr = request.getParameter("q");
            int currentIndex = 0;
            if (qIndexStr != null) {
                try {
                    currentIndex = Integer.parseInt(qIndexStr);
                    if (currentIndex < 0) currentIndex = 0;
                    if (currentIndex >= questions.size()) currentIndex = questions.size() - 1;
                } catch (NumberFormatException e) {
                    currentIndex = 0;
                }
            }

            request.setAttribute("exam", exam);
            request.setAttribute("attempt", attempt);
            request.setAttribute("questions", questions);
            request.setAttribute("currentIndex", currentIndex);
            request.setAttribute("remainingSeconds", remainingSeconds);

            request.getRequestDispatcher("/student/exam_page.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/exams?error=failed");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        String action = request.getParameter("action");
        int examId = Integer.parseInt(request.getParameter("examId"));
        int attemptId = Integer.parseInt(request.getParameter("attemptId"));

        try {
            // Save current answer first
            String questionIdStr = request.getParameter("questionId");
            if (questionIdStr != null && !questionIdStr.isEmpty()) {
                int questionId = Integer.parseInt(questionIdStr);
                String selectedOptionStr = request.getParameter("selectedOption");
                String descriptiveAnswer = request.getParameter("descriptiveAnswer");

                Integer selectedOption = null;
                if (selectedOptionStr != null && !selectedOptionStr.isEmpty()) {
                    selectedOption = Integer.parseInt(selectedOptionStr);
                }

                attemptDAO.saveAnswer(attemptId, questionId, selectedOption, descriptiveAnswer);
            }

            // Check action
            if ("submit".equals(action) || "autosubmit".equals(action)) {
                String status = "autosubmit".equals(action) ? "AUTO_SUBMITTED" : "SUBMITTED";
                attemptDAO.submitAttempt(attemptId, status);
                response.sendRedirect(request.getContextPath() + "/student/exams?action=result&examId=" + examId);
                return;
            }

            // Navigate to next question
            String nextIndex = request.getParameter("nextIndex");
            if (nextIndex == null) nextIndex = "0";

            response.sendRedirect(request.getContextPath() + "/student/exam?examId=" + examId + "&q=" + nextIndex);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/exams?error=failed");
        }
    }
}
