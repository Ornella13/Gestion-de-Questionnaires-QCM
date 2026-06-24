package com.schoarly.controllers;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/add-question")
public class AddQuestionServlet extends HttpServlet {
    
    // Displays the form
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setAttribute("page", "questions"); // Keeps the "Question Bank" menu active
        request.getRequestDispatcher("/WEB-INF/views/ajouter-question.jsp").forward(request, response);
    }

    // Will handle the form submission later (when we connect MySQL)
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Logic to save to DB will go here
        response.sendRedirect("questions");
    }
}