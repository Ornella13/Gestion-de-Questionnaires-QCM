package com.schoarly.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.schoarly.models.Question;
import com.schoarly.models.Student;
import com.schoarly.services.DatabaseService;
import com.schoarly.services.EmailService;

@WebServlet("/examen")
public class ExamServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DatabaseService dbService = new DatabaseService();
    private EmailService emailService = new EmailService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        if ("true".equals(request.getParameter("success"))) {
            request.setAttribute("finalScore", session.getAttribute("lastFinalScore"));
            request.setAttribute("studentId", session.getAttribute("lastStudentId"));
            request.getRequestDispatcher("/WEB-INF/views/exam_success.jsp").forward(request, response);
            return;
        }

        Student selectedStudent = (Student) session.getAttribute("selectedStudent");

        if (selectedStudent == null) {
            request.getRequestDispatcher("/WEB-INF/views/exam_auth.jsp").forward(request, response);
            return;
        }

        Map<String, Object> activeSession = dbService.getActiveSession(selectedStudent.getNiveau());
        if (activeSession == null) {
            request.getSession().setAttribute("errorMessage", "Aucun examen n'est planifié pour le niveau " + selectedStudent.getNiveau() + ".");
            request.getSession().removeAttribute("selectedStudent");
            response.sendRedirect(request.getContextPath() + "/examen");
            return;
        }

        // Vérifier si l'examen a déjà commencé
        try {
            String sDate = (String) activeSession.get("date");
            String sTime = (String) activeSession.get("time");
            java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            java.time.LocalDateTime start = java.time.LocalDateTime.parse(sDate + " " + sTime, formatter);
            java.time.LocalDateTime now = java.time.LocalDateTime.now();

            if (now.isBefore(start)) {
                // L'examen n'a pas encore commencé -> Salle d'attente
                session.setAttribute("activeSessionInfo", activeSession);
                request.getRequestDispatcher("/WEB-INF/views/exam_waiting.jsp").forward(request, response);
                return;
            }
        } catch (Exception e) {
            // En cas d'erreur de parsing, on continue par défaut
        }

        // Vérification de la validité temporelle de la session (Optionnel mais recommandé)
        // Si la session est passée (date < aujourd'hui), on pourrait la bloquer.
        // Pour l'instant, le filtrage par niveau résout le blocage inter-niveaux.

        @SuppressWarnings("unchecked")
        List<Question> examQuestions = (List<Question>) session.getAttribute("examQuestions");
        if (examQuestions == null) {
            // RÉCUPÉRATION DES QUESTIONS DU MÊME NIVEAU UNIQUEMENT
            List<Question> allByLevel = dbService.getQuestionsByLevel(selectedStudent.getNiveau());
            
            if (allByLevel.isEmpty()) { 
                request.getSession().setAttribute("errorMessage", "Erreur : Pas de questions pour votre niveau. Veuillez contacter l'administrateur.");
                request.getSession().removeAttribute("selectedStudent");
                response.sendRedirect(request.getContextPath() + "/examen");
                return;
            }
            
            Collections.shuffle(allByLevel);
            int count = Math.min(allByLevel.size(), 10);
            examQuestions = new ArrayList<>(allByLevel.subList(0, count));
            
            session.setAttribute("examQuestions", examQuestions);
            session.setAttribute("currentQuestionIndex", 0);
            session.setAttribute("userAnswers", new HashMap<Integer, Integer>());
            session.setAttribute("startTime", System.currentTimeMillis());
            session.setAttribute("duration", activeSession.get("duration"));
        }

        Integer currentIndex = (Integer) session.getAttribute("currentQuestionIndex");
        Long startTime = (Long) session.getAttribute("startTime");
        Integer duration = (Integer) session.getAttribute("duration");

        if (startTime != null && duration != null) {
            long remaining = (duration * 60 * 1000) - (System.currentTimeMillis() - startTime);
            request.setAttribute("remainingTime", Math.max(0, remaining / 1000)); // in seconds
            if (remaining <= 0) {
                request.setAttribute("timeOut", true);
            }
        } else {
            // Sécurité si session perdue partiellement
            request.setAttribute("remainingTime", 1800); // 30 min par défaut
        }

        request.setAttribute("examQuestions", examQuestions);
        request.setAttribute("totalQuestions", examQuestions.size());
        request.setAttribute("page", "exam");

        request.getRequestDispatcher("/WEB-INF/views/exam.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        Student student = (Student) session.getAttribute("selectedStudent");

        if ("start".equals(action)) {
            String studentId = request.getParameter("studentId");
            if (studentId != null) studentId = studentId.trim().toUpperCase();
            
            if (studentId == null || studentId.isEmpty()) {
                request.getSession().setAttribute("errorMessage", "Veuillez entrer un numéro matricule.");
                response.sendRedirect("examen");
                return;
            }

            Student found = dbService.getStudentById(studentId);
            
            if (found == null) {
                request.getSession().setAttribute("errorMessage", "Numéro matricule inexistant.");
                response.sendRedirect("examen");
                return;
            }
            
            // Vérifier s'il existe une planification d'examen en cours pour ce niveau
            Map<String, Object> activeSession = dbService.getActiveSession(found.getNiveau());
            if (activeSession == null) {
                request.getSession().setAttribute("errorMessage", "Aucun examen planifié pour ce niveau (" + found.getNiveau() + ").");
                response.sendRedirect("examen");
                return;
            }

            // Vérifier qu'un étudiant ne peut pas passer deux fois le même examen dans une même planification
            int sessionId = (int) activeSession.get("id");
            if (dbService.hasParticipated(studentId, sessionId)) {
                request.getSession().setAttribute("errorMessage", "Vous avez déjà participé à cet examen.");
                response.sendRedirect("examen");
                return;
            }
            
            session.setAttribute("selectedStudent", found);
            session.setAttribute("activeSessionInfo", activeSession);
            session.setAttribute("userAnswers", new HashMap<Integer, Integer>());
            session.removeAttribute("examQuestions"); // Force nouvelle génération
            session.removeAttribute("currentQuestionIndex");
            
            response.sendRedirect("examen");
            return;
        }

        @SuppressWarnings("unchecked")
        List<Question> examQuestions = (List<Question>) session.getAttribute("examQuestions");

        if (examQuestions == null) {
            response.sendRedirect("examen");
            return;
        }

        if ("finish".equals(action)) {
            // student and examQuestions are already defined at the start of doPost
            
            // Si l'étudiant est null (perte de session), on tente de le récupérer via d'autres moyens si possible
            // Mais pour l'instant on va surtout empêcher le crash
            if (student == null) {
                System.err.println("ERREUR ExamServlet: Student null lors de la soumission !");
                response.sendRedirect("examen");
                return;
            }

            if (examQuestions == null) {
                response.sendRedirect("examen");
                return;
            }

            int correctCount = 0;
            for (int i = 0; i < examQuestions.size(); i++) {
                String selectedAnswer = request.getParameter("answer_" + i);
                if (selectedAnswer != null) {
                    try {
                        int ans = Integer.parseInt(selectedAnswer);
                        if ((ans + 1) == examQuestions.get(i).getCorrectIndex()) {
                            correctCount++;
                        }
                    } catch (NumberFormatException e) {
                        System.err.println("Invalid answer format for q " + i);
                    }
                }
            }
            int score = (int) Math.round((double) correctCount / examQuestions.size() * 10);
            
            Map<String, Object> activeSessionInfo = (Map<String, Object>) session.getAttribute("activeSessionInfo");
            Integer sessId = null;
            String sessionDate = null;
            if (activeSessionInfo != null) {
                sessId = (Integer) activeSessionInfo.get("id");
                sessionDate = (String) activeSessionInfo.get("date");
            } else {
                // Fallback: Essayer de récupérer la session active pour le niveau de l'étudiant
                Map<String, Object> fallbackSession = dbService.getActiveSession(student.getNiveau());
                if (fallbackSession != null) {
                    sessId = (Integer) fallbackSession.get("id");
                    sessionDate = (String) fallbackSession.get("date");
                }
            }

            dbService.saveExamResult(student.getNumEtudiant(), score, sessId, sessionDate);
            
            String fullName = (student.getPrenoms() != null ? student.getPrenoms() : "") + " " + student.getNom();
            String recipient = student.getAdrEmail();
            if (recipient != null && !recipient.isEmpty()) {
                try {
                    emailService.sendResultEmail(recipient, fullName, score);
                } catch (Exception e) {
                    System.err.println("Mail error: " + e.getMessage());
                }
            }

            session.setAttribute("lastFinalScore", score);
            session.setAttribute("lastStudentId", student.getNumEtudiant());
            session.setAttribute("examFinished", true);
            
            // On ne vide la session QU'AVANT de rediriger vers le succès
            session.removeAttribute("examQuestions");
            session.removeAttribute("currentQuestionIndex");
            session.removeAttribute("userAnswers");
            session.removeAttribute("selectedStudent");
            session.removeAttribute("activeSessionInfo");
            
            response.sendRedirect("examen?success=true");
            return;
        }

        response.sendRedirect("examen");
    }

    private void renderQuestion(HttpServletRequest request, HttpServletResponse response, List<Question> questions, int index) 
            throws ServletException, IOException {
        // Obsolete but kept to avoid breaking structure if called elsewhere unintentionally
    }
}
