<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Identification - Session d'Examen</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap" rel="stylesheet">
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-slate-50 flex items-center justify-center min-h-screen p-6">
    <div class="max-w-md w-full bg-white rounded-3xl shadow-2xl overflow-hidden">
        <div class="h-2 bg-purple-700"></div>

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
                <c:if test="${not empty sessionScope.errorMessage}">
                    showToast("${sessionScope.errorMessage}", 'error');
                    <c:remove var="errorMessage" scope="session" />
                </c:if>
            });
        </script>

        <div class="p-10 text-center">
            <h1 class="text-3xl font-black text-slate-900 mb-8">Votre Matricule</h1>
            <form action="${pageContext.request.contextPath}/examen" method="POST" class="space-y-6">
                <input type="hidden" name="action" value="start">
                <input type="text" name="studentId" placeholder="Ex: 942H-Tol" required 
                       class="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none font-bold text-center text-2xl uppercase focus:border-purple-300">
                <div class="bg-purple-50 p-4 rounded-xl text-[10px] text-purple-600 font-bold uppercase italic">
                    Détection automatique du niveau (L1, L2, L3, M1, M2) activée.
                </div>
                <button type="submit" class="w-full bg-purple-700 text-white py-4 rounded-2xl font-black shadow-lg hover:bg-purple-800 transition-all transform hover:-translate-y-1">
                    COMMENCER L'EXAMEN
                </button>
            </form>
        </div>
    </div>
</body>
</html>
