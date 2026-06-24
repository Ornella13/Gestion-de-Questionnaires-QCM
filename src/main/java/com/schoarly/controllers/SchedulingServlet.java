package com.schoarly.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.scholarly.utils.DatabaseManager;

@WebServlet("/scheduling")
public class SchedulingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        com.schoarly.services.DatabaseService db = new com.schoarly.services.DatabaseService();
        db.refreshSessionsStatus();
        request.setAttribute("sessions", getAllSessions());
        request.setAttribute("page", "scheduling");
        request.getRequestDispatcher("/WEB-INF/views/scheduling.jsp").forward(request, response);
    }

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String id = request.getParameter("id");
        String title = request.getParameter("title");
        String level = request.getParameter("level");
        String date = request.getParameter("date");
        String time = request.getParameter("time");
        String duration = request.getParameter("duration");
        String group = request.getParameter("group");

        try (Connection conn = DatabaseManager.getConnection()) {
            if ("add".equals(action) || "update".equals(action)) {
                // Validation: au moins 10 questions pour ce niveau
                String checkSql = "SELECT COUNT(*) FROM qcm WHERE module LIKE ? OR TRIM(module) = ?";
                try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                    String trimmedLevel = (level != null) ? level.trim() : "";
                    checkPs.setString(1, "%" + trimmedLevel + "%");
                    checkPs.setString(2, trimmedLevel);
                    try (ResultSet rs = checkPs.executeQuery()) {
                        if (rs.next() && rs.getInt(1) < 10) {
                            request.getSession().setAttribute("errorMessage", "Impossible de planifier : Il n'y a que " + rs.getInt(1) + " questions pour le niveau " + level + ". Il en faut au moins 10.");
                            response.sendRedirect(request.getContextPath() + "/scheduling");
                            return;
                        }
                    }
                }
            }

            if ("add".equals(action)) {
                String sql = "INSERT INTO sessions (title, level, date, time, duration, students, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, title);
                    pstmt.setString(2, level);
                    pstmt.setString(3, date);
                    pstmt.setString(4, time);
                    pstmt.setInt(5, Integer.parseInt(duration));
                    pstmt.setString(6, group);
                    pstmt.setString(7, "En attente");
                    pstmt.executeUpdate();
                    request.getSession().setAttribute("successMessage", "Session planifiée avec succès !");
                }
            } else if ("update".equals(action)) {
                String sql = "UPDATE sessions SET title = ?, level = ?, date = ?, time = ?, duration = ?, students = ? WHERE id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, title);
                    pstmt.setString(2, level);
                    pstmt.setString(3, date);
                    pstmt.setString(4, time);
                    pstmt.setInt(5, Integer.parseInt(duration));
                    pstmt.setString(6, group);
                    pstmt.setInt(7, Integer.parseInt(id));
                    pstmt.executeUpdate();
                    request.getSession().setAttribute("successMessage", "Session mise à jour avec succès !");
                }
            } else if ("delete".equals(action)) {
                String sql = "DELETE FROM sessions WHERE id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, Integer.parseInt(id));
                    pstmt.executeUpdate();
                    request.getSession().setAttribute("successMessage", "Session supprimée !");
                }
            }
        } catch (SQLException | NumberFormatException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            String userFriendlyMsg = "Une erreur est survenue lors de l'opération.";
            
            if (msg.contains("no such table: sessions")) {
                userFriendlyMsg = "Erreur système : La table des sessions est manquante. Elle sera créée au prochain redémarrage.";
            } else if (msg.contains("NumberFormatException")) {
                userFriendlyMsg = "Erreur : ID de session invalide.";
            } else {
                userFriendlyMsg = "Erreur : " + (msg.isEmpty() ? "Erreur inconnue" : msg);
            }
            
            request.getSession().setAttribute("errorMessage", userFriendlyMsg);
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/scheduling");
    }

    private List<Map<String, String>> getAllSessions() {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT * FROM sessions";
        try (Connection conn = DatabaseManager.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, String> s = new HashMap<>();
                s.put("id", String.valueOf(rs.getInt("id")));
                s.put("title", rs.getString("title"));
                s.put("level", rs.getString("level"));
                s.put("date", rs.getString("date"));
                s.put("time", rs.getString("time"));
                s.put("duration", String.valueOf(rs.getInt("duration")));
                s.put("students", rs.getString("students"));
                s.put("status", rs.getString("status"));
                list.add(s);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
