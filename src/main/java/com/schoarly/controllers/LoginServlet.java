package com.schoarly.controllers;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/admin_login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String user = request.getParameter("username");
        String pass = request.getParameter("password");

        // Simple vérification (à remplacer par une base de données plus tard)
        if ("admin".equals(user) && "admin123".equals(pass)) {
            HttpSession session = request.getSession();
            session.setAttribute("isAdmin", true);
            session.removeAttribute("selectedStudent"); // On s'assure qu'il n'est pas vu comme un étudiant
            response.sendRedirect("dashboard");
        } else {
            request.setAttribute("error", "Identifiants incorrects");
            doGet(request, response);
        }
    }
}