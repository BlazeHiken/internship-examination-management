package com.project.util;

/*
 * Java-side validation for constraints.
 *   - students.cgpa: 0–10 range
 *   - companies.eligibility_cgpa: 0–10 range
 *   - internships.stipend: >= 0
 *   - exams.duration: > 0
 *   - exams.total_marks: > 0
 *   - questions.marks: > 0
*/
public class ValidationUtil {

    /*
     * Validates CGPA is between 0.00 and 10.00 (inclusive).
     * Used for students.cgpa and companies.eligibility_cgpa.
     */
    public static boolean isValidCGPA(double cgpa) {
        return cgpa >= 0.0 && cgpa <= 10.0;
    }

    // Validates stipend is non-negative.
    public static boolean isValidStipend(double stipend) {
        return stipend >= 0;
    }

    // Validates exam duration is positive (in minutes).
    public static boolean isValidDuration(int duration) {
        return duration > 0;
    }

    // Validates total marks is positive.
    public static boolean isValidTotalMarks(int totalMarks) {
        return totalMarks > 0;
    }

    // Validates question marks is positive.
    public static boolean isValidQuestionMarks(int marks) {
        return marks > 0;
    }

    // Validates that a string is not null and not blank.
    public static boolean isNotEmpty(String value) {
        return value != null && !value.trim().isEmpty();
    }

    // Validates email format (basic check).
    public static boolean isValidEmail(String email) {
        if (email == null)
            return false;
        return email.matches("^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$");
    }

    // Validates phone number (10-15 digits).
    public static boolean isValidPhone(String phone) {
        if (phone == null)
            return false;
        return phone.matches("^\\d{10,15}$");
    }

    // Validates password strength (minimum 6 characters).
    public static boolean isValidPassword(String password) {
        return password != null && password.length() >= 6;
    }
}
