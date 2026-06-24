package com.schoarly.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;

import com.schoarly.models.Question;
import com.schoarly.models.Student;
import com.schoarly.models.ExamResult;
import com.schoarly.services.DatabaseService;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DatabaseService dbService = new DatabaseService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Récupération des données réelles depuis le service DB
        List<Student> allStudents = dbService.getAllStudents();
        List<Question> allQuestions = dbService.getAllQuestions();
        List<ExamResult> allResults = dbService.getRankedResults();
        
        // 2. Calcul des statistiques réelles dynamiquement
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalStudents", String.format("%,d", allStudents.size()));
        stats.put("activeQuizzes", String.valueOf(allQuestions.size()));
        
        // Calcul du taux de réussite moyen (ex: 92%)
        double avgAccuracy = 0;
        if (!allResults.isEmpty()) {
            avgAccuracy = allResults.stream()
                .mapToInt(ExamResult::getScore)
                .average()
                .orElse(0.0) * 10; // Converti en pourcentage (score / 10 * 100)
        }
        stats.put("accuracy", String.format("%.1f%%", avgAccuracy));
        
        // 3. Sélection des éléments récents (les 5 derniers)
        // Pour les étudiants
        List<Student> recentStudents = allStudents.size() > 5 
            ? allStudents.subList(allStudents.size() - 5, allStudents.size()) 
            : allStudents;
            
        // Pour les questions
        List<Question> recentQuestions = allQuestions.size() > 2 
            ? allQuestions.subList(0, 2) 
            : allQuestions;

        // 4. Passage des données à la JSP
        request.setAttribute("stats", stats);
        request.setAttribute("questions", recentQuestions);
        request.setAttribute("students", recentStudents);
        request.setAttribute("page", "dashboard");
        
        // Redirection vers la vue
        request.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(request, response);
    }
}