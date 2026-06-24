package com.schoarly.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import com.schoarly.models.Student;
import com.schoarly.services.DatabaseService;
import com.scholarly.utils.DatabaseManager;

@WebServlet("/students")
public class StudentServle extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DatabaseService dbService = new DatabaseService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // API interne pour générer le matricule en temps réel (AJAX)
        String levelParam = request.getParameter("getNextIdForLevel");
        if (levelParam != null && !levelParam.isEmpty()) {
            try (Connection conn = DatabaseManager.getConnection()) {
                String nextId = generateNextId(conn, levelParam);
                response.setContentType("text/plain");
                response.getWriter().write(nextId);
            } catch (SQLException e) {
                response.sendError(500, e.getMessage());
            }
            return;
        }

        String search = request.getParameter("search");
        List<Student> students = (search != null && !search.trim().isEmpty()) 
                                ? dbService.searchStudents(search.trim()) 
                                : dbService.getAllStudents();

        Map<String, Long> statsByLevel = students.stream()
            .collect(Collectors.groupingBy(Student::getNiveau, Collectors.counting()));

        request.setAttribute("students", students);
        request.setAttribute("statsByLevel", statsByLevel);
        request.setAttribute("totalStudents", students.size());
        request.setAttribute("searchQuery", search);
        request.getRequestDispatcher("/WEB-INF/views/students.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String id = request.getParameter("id"); // Le matricule (potentiellement nouveau)
        String oldId = request.getParameter("oldId"); // L'ancien matricule
        String nom = request.getParameter("nom");
        String prenom = request.getParameter("prenom");
        String email = request.getParameter("email");
        String niveau = request.getParameter("niveau");

        try {
            if ("add".equals(action)) {
                Student newStudent = new Student(id, nom, prenom, niveau, email);
                dbService.createStudent(newStudent);
                request.getSession().setAttribute("successMessage", "Étudiant " + id + " inscrit avec succès !");
            } else if ("update".equals(action)) {
                String targetId = (oldId != null && !oldId.trim().isEmpty()) ? oldId : id;
                Student existingStudent = dbService.getStudentById(targetId);
                if (existingStudent != null) {
                    // Si le niveau a changé, on recalcule le matricule
                    if (!existingStudent.getNiveau().equals(niveau)) {
                        try (Connection conn = DatabaseManager.getConnection()) {
                            String newId = generateNextId(conn, niveau);
                            Student updatedStudent = new Student(newId, nom, prenom, niveau, email);
                            dbService.updateStudentWithNewId(targetId, updatedStudent);
                            request.getSession().setAttribute("successMessage", "Étudiant mis à jour. Nouveau matricule : " + newId);
                        }
                    } else {
                        // Niveau inchangé, update classique
                        dbService.updateStudent(new Student(targetId, nom, prenom, niveau, email));
                        request.getSession().setAttribute("successMessage", "Mise à jour de " + targetId + " réussie !");
                    }
                } else {
                    request.getSession().setAttribute("errorMessage", "Étudiant introuvable (" + targetId + ").");
                }
            } else if ("delete".equals(action)) {
                dbService.deleteStudent(id);
                request.getSession().setAttribute("successMessage", "Étudiant " + id + " supprimé !");
            }
        } catch (Exception e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            String userFriendlyMsg = "Une erreur est survenue lors de l'opération.";
            
            if (msg.contains("UNIQUE constraint failed: etudiant.num_etudiant") || msg.contains("PRIMARY KEY")) {
                userFriendlyMsg = "Le matricule " + id + " existe déjà.";
            } else if (msg.contains("UNIQUE constraint failed: etudiant.adr_email")) {
                userFriendlyMsg = "L'adresse email " + email + " est déjà utilisée.";
            } else if (msg.contains("CHECK constraint failed")) {
                userFriendlyMsg = "Données invalides (vérifiez le niveau).";
            } else {
                userFriendlyMsg = "Erreur : " + (msg.isEmpty() ? "Erreur inconnue" : msg);
            }
            
            request.getSession().setAttribute("errorMessage", userFriendlyMsg);
        }
        response.sendRedirect(request.getContextPath() + "/students");
    }

    private String generateNextId(Connection conn, String level) throws SQLException {
        int base = 900; int limit = 9999;
        switch (level) {
            case "M1": base = 100; limit = 299; break;
            case "M2": base = 300; limit = 499; break;
            case "L3": base = 500; limit = 699; break;
            case "L2": base = 700; limit = 899; break;
            default:   base = 900; limit = 9999; break; // L1
        }
        
        String sql = "SELECT num_etudiant FROM etudiant WHERE num_etudiant LIKE '%H-Tol'";
        int maxNum = base - 1;
        try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                String fullVal = rs.getString(1);
                // Extraire la partie numérique du début
                String numericPart = "";
                for (char c : fullVal.toCharArray()) {
                    if (Character.isDigit(c)) numericPart += c;
                    else break;
                }
                
                if (!numericPart.isEmpty()) {
                    try {
                        int num = Integer.parseInt(numericPart);
                        if (num >= base && num <= limit && num > maxNum) {
                            maxNum = num;
                        }
                    } catch(NumberFormatException e) { /* ignore non-numeric IDs */ }
                }
            }
        }
        return (maxNum + 1) + "H-Tol";
    }
}
