package com.project.model;

/**
 * POJO representing a row in the 'answers' table.
 * Maps to: answer_id, attempt_id, question_id, selected_option, descriptive_answer, marks_awarded
 * Also carries joined fields for evaluation display.
 */
public class Answer {

    private int answerId;
    private int attemptId;
    private int questionId;
    private int selectedOption;        // option_id for MCQ
    private String descriptiveAnswer;   // text for SUBJECTIVE
    private double marksAwarded;

    // Joined fields for display
    private String questionText;
    private String questionType;
    private int questionMarks;
    private String selectedOptionText;
    private boolean isCorrect;

    // Default constructor
    public Answer() {}

    // --- Getters and Setters ---

    public int getAnswerId() { return answerId; }
    public void setAnswerId(int answerId) { this.answerId = answerId; }

    public int getAttemptId() { return attemptId; }
    public void setAttemptId(int attemptId) { this.attemptId = attemptId; }

    public int getQuestionId() { return questionId; }
    public void setQuestionId(int questionId) { this.questionId = questionId; }

    public int getSelectedOption() { return selectedOption; }
    public void setSelectedOption(int selectedOption) { this.selectedOption = selectedOption; }

    public String getDescriptiveAnswer() { return descriptiveAnswer; }
    public void setDescriptiveAnswer(String descriptiveAnswer) { this.descriptiveAnswer = descriptiveAnswer; }

    public double getMarksAwarded() { return marksAwarded; }
    public void setMarksAwarded(double marksAwarded) { this.marksAwarded = marksAwarded; }

    public String getQuestionText() { return questionText; }
    public void setQuestionText(String questionText) { this.questionText = questionText; }

    public String getQuestionType() { return questionType; }
    public void setQuestionType(String questionType) { this.questionType = questionType; }

    public int getQuestionMarks() { return questionMarks; }
    public void setQuestionMarks(int questionMarks) { this.questionMarks = questionMarks; }

    public String getSelectedOptionText() { return selectedOptionText; }
    public void setSelectedOptionText(String selectedOptionText) { this.selectedOptionText = selectedOptionText; }

    public boolean isCorrect() { return isCorrect; }
    public void setCorrect(boolean correct) { isCorrect = correct; }
}
