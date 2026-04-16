package com.project.model;

import java.util.List;

/**
 * POJO representing a row in the 'questions' table.
 * Maps to: question_id, exam_id, question_text, type, marks
 * Carries a list of Options for MCQ type questions.
 */
public class Question {

    private int questionId;
    private int examId;
    private String questionText;
    private String type;            // "MCQ" or "SUBJECTIVE"
    private int marks;

    // Associated options (loaded for MCQ questions)
    private List<Option> options;

    // For exam-taking: track if this question is marked for review
    private boolean markedForReview;

    // For exam-taking: the student's selected answer
    private int selectedOptionId;
    private String descriptiveAnswer;

    // Default constructor
    public Question() {}

    // --- Getters and Setters ---

    public int getQuestionId() { return questionId; }
    public void setQuestionId(int questionId) { this.questionId = questionId; }

    public int getExamId() { return examId; }
    public void setExamId(int examId) { this.examId = examId; }

    public String getQuestionText() { return questionText; }
    public void setQuestionText(String questionText) { this.questionText = questionText; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public int getMarks() { return marks; }
    public void setMarks(int marks) { this.marks = marks; }

    public List<Option> getOptions() { return options; }
    public void setOptions(List<Option> options) { this.options = options; }

    public boolean isMarkedForReview() { return markedForReview; }
    public void setMarkedForReview(boolean markedForReview) { this.markedForReview = markedForReview; }

    public int getSelectedOptionId() { return selectedOptionId; }
    public void setSelectedOptionId(int selectedOptionId) { this.selectedOptionId = selectedOptionId; }

    public String getDescriptiveAnswer() { return descriptiveAnswer; }
    public void setDescriptiveAnswer(String descriptiveAnswer) { this.descriptiveAnswer = descriptiveAnswer; }
}
