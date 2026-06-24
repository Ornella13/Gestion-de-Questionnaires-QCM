package com.schoarly.models;

import java.time.LocalDateTime;

/**
 * Modèle pour stocker les résultats d'un examen.
 */
public class ExamResult {
    private String studentId;
    private String studentName;
    private int score; // Note finale sur 10
    private String level;
    private String dateTime;

    // Constructeur complet incluant le niveau
    public ExamResult(String studentId, String studentName, int score, String level, String dateTime) {
        this.studentId = studentId;
        this.studentName = studentName;
        this.score = score;
        this.level = level;
        this.dateTime = dateTime;
    }

    public ExamResult(String studentId, String studentName, int score, String level) {
        this(studentId, studentName, score, level, java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
    }

    // Getters
    public String getStudentId() { return studentId; }
    public String getStudentName() { return studentName; }
    public int getScore() { return score; }
    public String getLevel() { return level; }
    public String getDateTime() { return dateTime; }

    // Setters
    public void setStudentId(String studentId) { this.studentId = studentId; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public void setScore(int score) { this.score = score; }
    public void setLevel(String level) { this.level = level; }
    public void setDateTime(String dateTime) { this.dateTime = dateTime; }
}
