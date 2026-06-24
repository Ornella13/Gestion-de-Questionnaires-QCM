package com.schoarly.filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import com.schoarly.models.Student;

@WebFilter("/*")
public class AuthFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession();
        String path = request.getRequestURI().substring(request.getContextPath().length());

        // 1. Autoriser les ressources statiques et les pages d'accès public
        if (path.startsWith("/static") || path.contains(".") || path.equals("/login") || path.equals("/examen")) {
            chain.doFilter(req, res);
            return;
        }

        // 2. PRIVILÈGE ADMIN : S'il est connecté, accès TOTAL
        if (session.getAttribute("isAdmin") != null) {
            chain.doFilter(req, res);
            return;
        }

        // 3. VÉRIFICATION ÉTUDIANT
        Student student = (Student) session.getAttribute("selectedStudent");
        if (student == null) {
            response.sendRedirect(request.getContextPath() + "/examen");
            return;
        }

        // Bloquer l'admin (Dashboard, etc.) pour les étudiants en mode examen
        if (path.equals("/dashboard") || path.equals("/questions") || path.equals("/students")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Accès admin refusé.");
            return;
        }

        // Bloquer les résultats tant que l'examen n'est pas fini
        if (path.equals("/results") && session.getAttribute("examFinished") == null) {
            response.sendRedirect(request.getContextPath() + "/examen");
            return;
        }

        chain.doFilter(req, res);
    }
}