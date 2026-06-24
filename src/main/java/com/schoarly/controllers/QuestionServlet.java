package com.schoarly.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import com.schoarly.models.Question;
import com.schoarly.services.DatabaseService;

@WebServlet("/questions")
public class QuestionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DatabaseService dbService = new DatabaseService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("questions", dbService.getAllQuestions());
        request.getRequestDispatcher("/WEB-INF/views/questions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        try {
            if (!"delete".equals(action)) {
                String text = request.getParameter("statement");
                String module = request.getParameter("module");
                String r1 = request.getParameter("option1");
                String r2 = request.getParameter("option2");
                String r3 = request.getParameter("option3");
                String r4 = request.getParameter("option4");
                int correct = Integer.parseInt(request.getParameter("correctOption"));
                int count = Integer.parseInt(request.getParameter("optionsCount"));
                
                Question q = new Question(0, text, r1, r2, r3, r4, correct, module, count);

                if ("add".equals(action)) {
                    dbService.addQuestion(q);
                    request.getSession().setAttribute("successMessage", "Question ajoutée avec succès !");
                } else if ("update".equals(action)) {
                    String idStr = request.getParameter("id");
                    if (idStr == null || idStr.isEmpty()) {
                        throw new Exception("ID de question manquant pour la modification.");
                    }
                    q.setId(Integer.parseInt(idStr));
                    dbService.updateQuestion(q);
                    request.getSession().setAttribute("successMessage", "Question mise à jour avec succès !");
                }
            } else {
                String idStr = request.getParameter("id");
                if (idStr == null || idStr.isEmpty()) {
                    throw new Exception("ID de question manquant pour la suppression.");
                }
                int id = Integer.parseInt(idStr);
                dbService.deleteQuestion(id);
                request.getSession().setAttribute("successMessage", "Question supprimée !");
            }
        } catch (Exception e) {
            e.printStackTrace(); // Pour voir l'erreur dans la console XAMPP/Tomcat
            request.getSession().setAttribute("errorMessage", "Erreur lors de l'opération : " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/questions");
    }
}
