<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Examen Terminé - The Scholarly Curator</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap" rel="stylesheet">
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-purple-900 flex items-center justify-center min-h-screen p-6">
    <div class="bg-white p-12 rounded-3xl shadow-2xl text-center max-w-md w-full animate-in fade-in zoom-in duration-500">
        <div class="w-20 h-20 bg-green-100 text-green-600 flex items-center justify-center rounded-full mx-auto mb-6">
            <i class="fas fa-check-circle text-4xl"></i>
        </div>
        <h1 class="text-2xl font-black text-gray-900 mb-2">Examen envoyé avec succès !</h1>
        <p class="text-gray-500 mb-6">Vos réponses ont été enregistrées pour le matricule <span class="font-bold text-purple-700">${studentId}</span></p>
        
        <div class="bg-gray-50 rounded-2xl p-6 mb-8 border border-gray-100">
            <h3 class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-2">Votre Score</h3>
            <div class="text-6xl font-black text-purple-900">
                ${finalScore}<span class="text-2xl text-gray-300">/10</span>
            </div>
        </div>
        
        <p class="text-sm text-gray-400 mb-10 italic">
            Votre performance a été enregistrée dans la base de données centrale.
        </p>
        
        <div class="space-y-3">
            <!-- Google Fonts <a href="${pageContext.request.contextPath}/results" 
               class="block w-full py-5 bg-purple-900 text-white font-black rounded-2xl hover:bg-black transition-all text-center shadow-xl shadow-purple-900/20 hover:-translate-y-1">
                Voir les classements <i class="fas fa-chevron-right ml-2 text-xs"></i>
            </a> -->
            <a href="${pageContext.request.contextPath}/login" 
               class="block w-full py-4 text-purple-700 font-bold hover:bg-purple-50 rounded-xl transition-all text-center">
                Retour à l'accueil
            </a>
        </div>
    </div>
</body>
</html>
