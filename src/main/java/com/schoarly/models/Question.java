package com.schoarly.models;

public class Question {
    private int id; // num_quest
    private String text; // question
    private String r1, r2, r3, r4; // reponse1 à 4
    private int correctIndex; // bonne_reponse_index
    private String category; // module
    private int optionsCount;

    public Question() {}

    public Question(int id, String text, String r1, String r2, String r3, String r4, int correctIndex) {
        this.id = id;
        this.text = text;
        this.r1 = r1;
        this.r2 = r2;
        this.r3 = r3;
        this.r4 = r4;
        this.correctIndex = correctIndex;
    }

    public Question(int id, String text, String r1, String r2, String r3, String r4, int correctIndex, String category, int optionsCount) {
        this(id, text, r1, r2, r3, r4, correctIndex);
        this.category = category;
        this.optionsCount = optionsCount;
    }

    // Getters et Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
    public String getR1() { return r1; }
    public void setR1(String r1) { this.r1 = r1; }
    public String getR2() { return r2; }
    public void setR2(String r2) { this.r2 = r2; }
    public String getR3() { return r3; }
    public void setR3(String r3) { this.r3 = r3; }
    public String getR4() { return r4; }
    public void setR4(String r4) { this.r4 = r4; }
    public int getCorrectIndex() { return correctIndex; }
    public void setCorrectIndex(int correctIndex) { this.correctIndex = correctIndex; }
    public String getCategory() { return category; }
    public String getModule() { return category; }
    public void setCategory(String category) { this.category = category; }
    public int getOptionsCount() { return optionsCount; }
    public void setOptionsCount(int optionsCount) { this.optionsCount = optionsCount; }
    
    /**
     * Retourne les options sous forme de tableau pour faciliter le rendu JSP
     */
    public String[] getOptions() {
        return new String[] { r1, r2, r3, r4 };
    }
    
    // UI convenience
    public String getLastModified() { return "Recently"; }
}
