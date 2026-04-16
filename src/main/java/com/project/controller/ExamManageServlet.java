package com.project.controller;

import com.project.dao.ExamDAO;
import com.project.dao.QuestionDAO;
import com.project.dao.ExamAttemptDAO;
import com.project.model.*;
import com.project.util.ValidationUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Admin servlet for managing exams and questions.
 * GET  /admin/exams                    → list all exams
 * GET  /admin/exams?action=add         → show exam creation form
 * GET  /admin/exams?action=questions&examId=X → manage questions for an exam
 * GET  /admin/exams?action=attempts&examId=X  → view student attempts/scores
 * POST /admin/exams?action=add         → create exam
 * POST /admin/exams?action=delete      → delete exam
 * POST /admin/exams?action=addQuestion → add question with options
 * POST /admin/exams?action=evaluate    → grade a subjective answer
 */
@WebServlet("/admin/exams")
public class ExamManageServlet extends HttpServlet {

    private ExamDAO examDAO = new ExamDAO();
    private QuestionDAO questionDAO = new QuestionDAO();
    private ExamAttemptDAO attemptDAO = new ExamAttemptDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("add".equals(action)) {
                request.getRequestDispatcher("/admin/exam_form.jsp").forward(request, response);

            } else if ("questions".equals(action)) {
                int examId = Integer.parseInt(request.getParameter("examId"));
                Exam exam = examDAO.getById(examId);
                List<Question> questions = questionDAO.getByExam(examId);
                int marksUsed = questionDAO.getMarksSum(examId);
                request.setAttribute("exam", exam);
                request.setAttribute("questions", questions);
                request.setAttribute("marksUsed", marksUsed);
                request.setAttribute("marksRemaining", exam.getTotalMarks() - marksUsed);
                request.getRequestDispatcher("/admin/exam_questions.jsp").forward(request, response);

            } else if ("attempts".equals(action)) {
                int examId = Integer.parseInt(request.getParameter("examId"));
                Exam exam = examDAO.getById(examId);
                List<ExamAttempt> attempts = attemptDAO.getAttemptsByExam(examId);
                request.setAttribute("exam", exam);
                request.setAttribute("attempts", attempts);
                request.getRequestDispatcher("/admin/exam_attempts.jsp").forward(request, response);

            } else if ("evaluate".equals(action)) {
                int attemptId = Integer.parseInt(request.getParameter("attemptId"));
                ExamAttempt attempt = attemptDAO.getById(attemptId);
                Exam exam = examDAO.getById(attempt.getExamId());
                List<Answer> answers = attemptDAO.getAnswers(attemptId);
                double totalScore = attemptDAO.getTotalScore(attemptId);
                request.setAttribute("attempt", attempt);
                request.setAttribute("exam", exam);
                request.setAttribute("answers", answers);
                request.setAttribute("totalScore", totalScore);
                request.getRequestDispatcher("/admin/evaluate.jsp").forward(request, response);

            } else {
                // List all exams
                List<Exam> exams = examDAO.getAll();
                // Get question counts
                for (Exam e : exams) {
                    // We'll just display in JSP
                }
                request.setAttribute("exams", exams);
                request.getRequestDispatcher("/admin/exams.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error.");
            request.getRequestDispatcher("/admin/exams.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("add".equals(action)) {
                // Create exam
                String examName = request.getParameter("examName");
                int duration = Integer.parseInt(request.getParameter("duration"));
                String startTimeStr = request.getParameter("startTime");
                String endTimeStr = request.getParameter("endTime");
                int totalMarks = Integer.parseInt(request.getParameter("totalMarks"));

                Exam exam = new Exam();
                exam.setExamName(examName);
                exam.setDuration(duration);
                exam.setStartTime(Timestamp.valueOf(startTimeStr.replace("T", " ") + ":00"));
                exam.setEndTime(Timestamp.valueOf(endTimeStr.replace("T", " ") + ":00"));
                exam.setTotalMarks(totalMarks);

                int examId = examDAO.add(exam);
                response.sendRedirect("exams?action=questions&examId=" + examId + "&created=true");

            } else if ("delete".equals(action)) {
                int examId = Integer.parseInt(request.getParameter("examId"));
                examDAO.delete(examId);
                response.sendRedirect("exams?deleted=true");

            } else if ("addQuestion".equals(action)) {
                int examId = Integer.parseInt(request.getParameter("examId"));
                String questionText = request.getParameter("questionText");
                String type = request.getParameter("type");
                int marks = Integer.parseInt(request.getParameter("marks"));

                // Enforce total marks limit
                Exam exam = examDAO.getById(examId);
                int marksUsed = questionDAO.getMarksSum(examId);
                if (marksUsed + marks > exam.getTotalMarks()) {
                    response.sendRedirect("exams?action=questions&examId=" + examId + "&error=marks_exceeded");
                    return;
                }

                Question question = new Question();
                question.setExamId(examId);
                question.setQuestionText(questionText);
                question.setType(type);
                question.setMarks(marks);

                List<Option> options = null;
                if ("MCQ".equals(type)) {
                    options = new ArrayList<>();
                    String correctOption = request.getParameter("correctOption");

                    for (int i = 1; i <= 4; i++) {
                        String optText = request.getParameter("option" + i);
                        if (optText != null && !optText.trim().isEmpty()) {
                            Option opt = new Option();
                            opt.setOptionText(optText.trim());
                            opt.setCorrect(String.valueOf(i).equals(correctOption));
                            options.add(opt);
                        }
                    }
                }

                questionDAO.addWithOptions(question, options);
                response.sendRedirect("exams?action=questions&examId=" + examId + "&questionAdded=true");

            } else if ("evaluate".equals(action)) {
                int answerId = Integer.parseInt(request.getParameter("answerId"));
                double marksAwarded = Double.parseDouble(request.getParameter("marksAwarded"));
                int attemptId = Integer.parseInt(request.getParameter("attemptId"));

                attemptDAO.updateMarks(answerId, marksAwarded);
                response.sendRedirect("exams?action=evaluate&attemptId=" + attemptId + "&evaluated=true");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("exams?error=failed");
        }
    }
}
