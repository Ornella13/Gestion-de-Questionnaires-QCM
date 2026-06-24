package com.schoarly.models;

public class Student {
    private String numEtudiant;
    private String nom;
    private String prenoms;
    private String niveau;
    private String adrEmail;

    public Student() {}

    public Student(String numEtudiant, String nom, String prenoms, String niveau, String adrEmail) {
        this.numEtudiant = numEtudiant;
        this.nom = nom;
        this.prenoms = prenoms;
        this.niveau = niveau;
        this.adrEmail = adrEmail;
    }

    // Getters standards pour JSP et Servlets
    public String getNumEtudiant() { return numEtudiant; }
    public String getNom() { return nom; }
    public String getPrenoms() { return prenoms; }
    public String getNiveau() { return niveau; }
    public String getAdrEmail() { return adrEmail; }
    
    // Alias pour compatibilité avec certains snippets existants
    public String getId() { return numEtudiant; }
    public String getName() { return nom; }
    public String getPrenom() { return prenoms; }
    public String getLevel() { return niveau; }
    public String getEmail() { return adrEmail; }
    
    // Setters
    public void setNumEtudiant(String v) { this.numEtudiant = v; }
    public void setNom(String v) { this.nom = v; }
    public void setPrenoms(String v) { this.prenoms = v; }
    public void setNiveau(String v) { this.niveau = v; }
    public void setAdrEmail(String v) { this.adrEmail = v; }
}