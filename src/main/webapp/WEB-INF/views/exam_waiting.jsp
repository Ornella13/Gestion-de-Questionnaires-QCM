<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<%
    Map<String, Object> sessionInfo = (Map<String, Object>) session.getAttribute("activeSessionInfo");
    String title = (sessionInfo != null) ? (String) sessionInfo.get("title") : "Examen";
    String startDate = (sessionInfo != null) ? (String) sessionInfo.get("date") : "";
    String startTime = (sessionInfo != null) ? (String) sessionInfo.get("time") : "";
    String targetISO = startDate + "T" + startTime + ":00";
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Salle d'attente - <%= title %></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-slate-50 min-h-screen flex flex-col items-center justify-center p-6 text-slate-800">
    
    <div class="max-w-xl w-full bg-white rounded-2xl shadow-xl shadow-slate-200/50 p-8 md:p-12 text-center border border-slate-100">
        <div class="inline-flex items-center justify-center p-3 bg-blue-50 text-blue-600 rounded-full mb-6">
            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
        </div>
        
        <h1 class="text-3xl font-bold text-slate-900 mb-2">Bientôt prêt !</h1>
        <p class="text-slate-500 mb-8 max-w-sm mx-auto">L'examen <strong><%= title %></strong> n'a pas encore commencé. Veuillez patienter dans cette salle.</p>
        
        <div class="grid grid-cols-4 gap-3 mb-10">
            <div class="bg-slate-50 rounded-xl p-3 border border-slate-100">
                <div id="days" class="text-2xl md:text-3xl font-bold text-blue-600">00</div>
                <div class="text-[10px] uppercase tracking-wider text-slate-400 font-semibold mt-1">Jours</div>
            </div>
            <div class="bg-slate-50 rounded-xl p-3 border border-slate-100">
                <div id="hours" class="text-2xl md:text-3xl font-bold text-blue-600">00</div>
                <div class="text-[10px] uppercase tracking-wider text-slate-400 font-semibold mt-1">Heures</div>
            </div>
            <div class="bg-slate-50 rounded-xl p-3 border border-slate-100">
                <div id="minutes" class="text-2xl md:text-3xl font-bold text-blue-600">00</div>
                <div class="text-[10px] uppercase tracking-wider text-slate-400 font-semibold mt-1">Minutes</div>
            </div>
            <div class="bg-slate-50 rounded-xl p-3 border border-slate-100">
                <div id="seconds" class="text-2xl md:text-3xl font-bold text-blue-600">00</div>
                <div class="text-[10px] uppercase tracking-wider text-slate-400 font-semibold mt-1">Secondes</div>
            </div>
        </div>
        
        <div class="flex flex-col space-y-4">
            <div class="flex items-center justify-center space-x-2 text-sm text-slate-400 italic">
                <span class="flex h-2 w-2 rounded-full bg-green-500 animate-pulse"></span>
                <span></span>
            </div>
            <div class="text-xs text-slate-300">
                
            </div>
        </div>
    </div>
    
    <div class="mt-8 text-slate-400 text-sm">
        Scholarly Curator &copy; 2026
    </div>

    <script>
        const targetDate = new Date("<%= targetISO %>");
        
        function updateCountdown() {
            const now = new Date();
            const diff = targetDate - now;
            
            if (diff <= 0) {
                // Redirection automatique
                window.location.reload();
                return;
            }
            
            const days = Math.floor(diff / (1000 * 60 * 60 * 24));
            const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((diff % (1000 * 60)) / 1000);
            
            document.getElementById('days').innerText = String(days).padStart(2, '0');
            document.getElementById('hours').innerText = String(hours).padStart(2, '0');
            document.getElementById('minutes').innerText = String(minutes).padStart(2, '0');
            document.getElementById('seconds').innerText = String(seconds).padStart(2, '0');
        }
        
        // Mettre à jour toutes les secondes
        setInterval(updateCountdown, 1000);
        updateCountdown();
    </script>
</body>
</html>
