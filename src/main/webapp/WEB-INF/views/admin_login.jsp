<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Connexion Administration - The Scholarly Curator</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;900&display=swap" rel="stylesheet">
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen p-6">
    <div class="w-full max-w-md bg-white rounded-3xl shadow-xl border border-gray-100 p-10">
        <div class="text-center mb-8">
            <div class="w-16 h-16 bg-purple-700 text-white rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg">
                <i class="fas fa-lock text-2xl"></i>
            </div>
            <h1 class="text-2xl font-black text-gray-900">Administration</h1>
            <p class="text-gray-400 font-medium">Connectez-vous pour gérer l'application.</p>
        </div>

        <!-- Système de Notifications Toast -->
        <div id="toastContainer" class="fixed top-8 right-8 z-[100] flex flex-col gap-3"></div>

        <script>
            function showToast(message, type = 'error') {
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
                <c:if test="${not empty error}">
                    showToast("${error}", 'error');
                </c:if>
            });
        </script>

        <form action="login" method="POST" class="space-y-6">
            <div>
                <label class="block text-xs font-black uppercase tracking-widest text-gray-400 mb-2">Utilisateur</label>
                <input type="text" name="username" required 
                       class="w-full px-5 py-4 bg-gray-50 border border-gray-100 rounded-xl focus:ring-2 focus:ring-purple-100 focus:border-purple-300 outline-none transition-all font-medium">
            </div>
            <div>
                <label class="block text-xs font-black uppercase tracking-widest text-gray-400 mb-2">Mot de passe</label>
                <input type="password" name="password" required 
                       class="w-full px-5 py-4 bg-gray-50 border border-gray-100 rounded-xl focus:ring-2 focus:ring-purple-100 focus:border-purple-300 outline-none transition-all font-medium">
            </div>
            
            <button type="submit" 
                    class="w-full py-4 bg-purple-700 text-white font-black rounded-xl hover:bg-purple-800 transition-all shadow-lg shadow-purple-100">
                Se connecter
            </button>
        </form>

        <div class="mt-10 pt-6 border-t border-gray-50 text-center">
            <a href="examen" class="text-purple-600 font-bold text-sm hover:underline">
                <i class="fas fa-arrow-left mr-1"></i> Retour au portail étudiant
            </a>
        </div>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/js/all.min.js"></script>
</body>
</html>
