package com.schoarly.models;

public class Examen {
    private int numExam;
    private String numEtudiant;
    private String anneeUniv;
    private int note;
    private String nomEtudiant;

    private String dateExamen;

    public Examen(int numExam, String numEtudiant, String anneeUniv, int note, String dateExamen) {
        this.numExam = numExam;
        this.numEtudiant = numEtudiant;
        this.anneeUniv = anneeUniv;
        this.note = note;
        this.dateExamen = dateExamen;
    }

    public Examen(int numExam, String numEtudiant, String anneeUniv, int note) {
        this(numExam, numEtudiant, anneeUniv, note, java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
    }

    public String getDateExamen() { return dateExamen; }
    public void setDateExamen(String dateExamen) { this.dateExamen = dateExamen; }

    public int getNumExam() { return numExam; }
    public String getNumEtudiant() { return numEtudiant; }
    public String getAnneeUniv() { return anneeUniv; }
    public int getNote() { return note; }
    public String getNomEtudiant() { return nomEtudiant; }
    public void setNomEtudiant(String nomEtudiant) { this.nomEtudiant = nomEtudiant; }
}
