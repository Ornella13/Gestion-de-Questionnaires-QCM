package com.schoarly.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;
import com.schoarly.models.ExamResult;
import com.schoarly.services.DatabaseService;

@WebServlet("/results")
public class ResultsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DatabaseService dbService = new DatabaseService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 1. Récupérer tous les résultats depuis la base
            List<ExamResult> rankedResults = dbService.getRankedResults();
            System.out.println("ResultsServlet: Fetched " + (rankedResults != null ? rankedResults.size() : "null") + " results from dbService.");
            
            // diagnostic log for the 'examen' table
            try (java.sql.Connection conn = com.scholarly.utils.DatabaseManager.getConnection();
                 java.sql.Statement st = conn.createStatement();
                 java.sql.ResultSet rs = st.executeQuery("SELECT * FROM examen")) {
                System.out.println("--- RAW EXAMEN TABLE CONTENT ---");
                while (rs.next()) {
                    System.out.println("Row: " + rs.getInt("num_exam") + " | Student: " + rs.getString("num_etudiant") + " | Note: " + rs.getInt("note"));
                }
                System.out.println("--- END RAW EXAMEN TABLE CONTENT ---");
            } catch (Exception e) {
                System.err.println("Diagnostic query failed: " + e.getMessage());
            }

            if (rankedResults == null) {
                System.err.println("ResultsServlet: rankedResults is NULL!");
                request.setAttribute("globalResults", new java.util.ArrayList<>());
                request.setAttribute("resultsByLevel", new java.util.HashMap<>());
                request.getRequestDispatcher("/WEB-INF/views/results.jsp").forward(request, response);
                return;
            }
            List<ExamResult> globalRanked = rankedResults.stream()
                .filter(r -> r != null)
                .sorted((r1, r2) -> Integer.compare(r2.getScore(), r1.getScore()))
                .collect(Collectors.toList());

            // 3. Grouper les résultats par niveau
            Map<String, List<ExamResult>> resultsByLevel = rankedResults.stream()
                .filter(r -> r != null)
                .collect(Collectors.groupingBy(
                    res -> (res != null && res.getLevel() != null) ? res.getLevel() : "L1",
                    TreeMap::new,
                    Collectors.toList()
                ));

            // 4. Envoyer les données à la JSP
            request.setAttribute("globalResults", globalRanked);
            request.setAttribute("resultsByLevel", resultsByLevel);
            request.setAttribute("page", "results");
            
            request.getRequestDispatcher("/WEB-INF/views/results.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.err.println("ERREUR ResultsServlet : " + e.getMessage());
            e.printStackTrace(); 
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erreur lors du chargement des résultats.");
        }
    }
}
