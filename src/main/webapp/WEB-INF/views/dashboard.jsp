<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>The Scholarly Curator - Dashboard</title>
    
    <!-- Chargement de Tailwind CSS via CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Chargement de FontAwesome pour les icônes -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;900&display=swap" rel="stylesheet">
    
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-gray-50 text-gray-900">
    <div class="flex min-h-screen">
        <!-- Inclusion de la barre latérale (Sidebar) -->
		<%@ include file="../fragments/sidebar.jspf"%>

        <!-- Contenu Principal -->
        <main class="flex-1 ml-64 p-8">
            
           
            <!--   <div class="mb-8 flex justify-between items-center">
               <!--  BARRE DE RECHERCHE
                 <div class="relative w-full max-w-md">
                    <span class="absolute inset-y-0 left-0 pl-4 flex items-center text-gray-400">
                        <i class="fas fa-search"></i>
                    </span>
                    <input type="text" 
                           placeholder="Rechercher des étudiants, des quiz ou des résultats..." 
                           class="w-full pl-11 pr-4 py-3 bg-white border border-gray-100 rounded-2xl shadow-sm focus:ring-2 focus:ring-purple-100 focus:border-purple-300 outline-none transition-all text-sm">
                </div>    
                
              Petit badge utilisateur à droite de la recherche 
                <div class="flex items-center gap-3 ml-4">
                    <div class="text-right hidden md:block">
                        <p class="text-xs font-black text-gray-900">Portail Administrateur</p>
                        <p class="text-[10px] text-gray-400 uppercase font-bold">Connecté</p>
                    </div>
                    <div class="w-10 h-10 rounded-xl bg-purple-700 flex items-center justify-center text-white shadow-lg">
                        <i class="fas fa-user-shield"></i>
                    </div>
                </div>
            </div>-->

            <!-- Système de Notifications Toast -->
            <div id="toastContainer" class="fixed top-8 right-8 z-[100] flex flex-col gap-3"></div>

            <script>
                function showToast(message, type = 'success') {
                    const container = document.getElementById('toastContainer');
                    if (!container) return;
                    const toast = document.createElement('div');
                    const bgColor = type === 'success' ? 'bg-white' : 'bg-red-50';
                    const iconColor = type === 'success' ? 'text-green-500' : 'text-red-500';
                    const icon = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
                    const borderColor = type === 'success' ? 'border-green-100' : 'border-red-100';

                    toast.className = `\${bgColor} border \${borderColor} shadow-xl rounded-2xl p-4 min-w-[300px] transform translate-x-full transition-all duration-300 flex items-center gap-4`;
                    toast.innerHTML = `
                        <div class="w-10 h-10 rounded-xl \${type === 'success' ? 'bg-green-50' : 'bg-red-100'} flex items-center justify-center shrink-0">
                            <i class="fas \${icon} \${iconColor} text-lg"></i>
                        </div>
                        <div class="flex-1">
                            <p class="text-sm font-bold text-slate-900">\${type === 'success' ? 'Succès' : 'Erreur'}</p>
                            <p class="text-xs text-slate-500">\${message}</p>
                        </div>
                        <button onclick="this.parentElement.remove()" class="text-slate-300 hover:text-slate-500 transition-colors">
                            <i class="fas fa-times"></i>
                        </button>
                    `;

                    container.appendChild(toast);
                    setTimeout(() => toast.classList.remove('translate-x-full'), 10);
                    setTimeout(() => {
                        toast.classList.add('translate-x-[150%]');
                        setTimeout(() => toast.remove(), 300);
                    }, 5000);
                }

                document.addEventListener('DOMContentLoaded', () => {
                    <c:if test="${not empty sessionScope.successMessage}">
                        showToast("${sessionScope.successMessage}", 'success');
                        <c:remove var="successMessage" scope="session" />
                    </c:if>
                    <c:if test="${not empty sessionScope.errorMessage}">
                        showToast("${sessionScope.errorMessage}", 'error');
                        <c:remove var="errorMessage" scope="session" />
                    </c:if>
                });
            </script>

            <!-- En-tête -->
            <header class="mb-10">
                <h2 class="text-3xl font-black tracking-tight text-purple-900">Vue d'ensemble</h2>
                <p class="text-gray-500 font-medium">Bienvenue dans votre espace de gestion académique.</p>
            </header>

            <!-- Cartes de Statistiques -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
                <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                    <div class="flex items-center justify-between mb-4">
                        <p class="text-gray-400 text-xs font-bold uppercase tracking-wider">Total Étudiants</p>
                        <i class="fas fa-users text-purple-200 text-xl"></i>
                    </div>
                    <h3 class="text-3xl font-black text-gray-900">${stats.totalStudents}</h3>
                </div>
                
                <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                    <div class="flex items-center justify-between mb-4">
                        <p class="text-gray-400 text-xs font-bold uppercase tracking-wider">Quiz Actifs</p>
                        <i class="fas fa-file-alt text-purple-200 text-xl"></i>
                    </div>
                    <h3 class="text-3xl font-black text-gray-900">${stats.activeQuizzes}</h3>
                </div>
                
                <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                    <div class="flex items-center justify-between mb-4">
                        <p class="text-gray-400 text-xs font-bold uppercase tracking-wider">Précision</p>
                        <i class="fas fa-chart-line text-purple-200 text-xl"></i>
                    </div>
                    <h3 class="text-3xl font-black text-gray-900">${stats.accuracy}</h3>
                </div>
            </div>

            <!-- Section Tableau des Étudiants -->
            <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
                <div class="px-6 py-4 border-b border-gray-50 flex justify-between items-center">
                    <h4 class="font-bold text-gray-800 text-lg">Étudiants Récents</h4>
                    <a href="students" class="text-purple-700 text-sm font-bold hover:underline">Voir tout</a>
                </div>
                <table class="w-full text-left">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400">Nom de l'étudiant</th>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400">Email</th>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400">Niveau</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-50">
                        <c:forEach var="student" items="${students}">
                            <tr class="hover:bg-purple-50/30 transition-colors">
                                <td class="px-6 py-4 font-bold text-gray-800">${student.name}</td>
                                <td class="px-6 py-4 text-gray-500">${student.email}</td>
                                <td class="px-6 py-4">
                                    <span class="px-3 py-1 bg-purple-100 text-purple-700 rounded-full text-[10px] font-black uppercase tracking-widest">
                                        ${student.level}
                                    </span>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</body>
</html>
