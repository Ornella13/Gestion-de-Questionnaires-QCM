<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Exam Session - The Scholarly Curator</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body class="bg-white text-slate-900">
    <div class="fixed top-0 left-0 w-full h-1.5 bg-slate-100 z-50">
        <div class="bg-purple-600 h-full transition-all duration-500" style="width: 100%"></div>
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
            <c:if test="${not empty sessionScope.errorMessage}">
                showToast("${sessionScope.errorMessage}", 'error');
                <c:remove var="errorMessage" scope="session" />
            </c:if>
        });
    </script>

    <div class="max-w-5xl mx-auto px-6 pt-12">
        <header class="flex justify-between items-center mb-16">
            <div class="flex items-center gap-4">
                <div class="w-10 h-10 bg-slate-900 text-white rounded-xl flex items-center justify-center font-black">SC</div>
                <div>
                    <h1 class="text-sm font-black uppercase tracking-widest">Examen en cours</h1>
                    <p class="text-xs text-slate-400 font-bold">Session d'Évaluation • ${totalQuestions} Questions</p>
                </div>
            </div>

            <!-- Minuteur -->
            <div id="timerContainer" class="flex items-center gap-3 px-6 py-3 bg-red-50 text-red-600 rounded-2xl border border-red-100">
                <i class="fas fa-clock text-lg"></i>
                <span id="countdown" class="text-xl font-black tabular-nums">--:--</span>
            </div>
        </header>

        <div class="max-w-4xl mx-auto">
            <form action="${pageContext.request.contextPath}/examen" method="POST" id="examForm">
                <input type="hidden" name="action" value="finish">
                
                <div class="space-y-12">
                    <c:forEach var="q" items="${examQuestions}" varStatus="qStatus">
                        <div class="bg-gray-50/50 p-8 rounded-[2.5rem] border border-gray-100">
                            <div class="flex items-start gap-6 mb-8">
                                <span class="bg-purple-600 text-white w-10 h-10 shrink-0 rounded-2xl flex items-center justify-center font-black text-sm shadow-lg shadow-purple-200">
                                    ${qStatus.index + 1}
                                </span>
                                <div>
                                    <span class="text-[10px] font-black uppercase tracking-[0.2em] text-purple-400 mb-2 block"><c:out value="${q.module}"/></span>
                                    <h2 class="text-xl font-bold text-slate-800 leading-relaxed"><c:out value="${q.text}"/></h2>
                                </div>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <c:forEach var="opt" items="${q.options}" varStatus="oStatus">
                                    <c:set var="currentLetter" value="${oStatus.index == 0 ? 'A' : (oStatus.index == 1 ? 'B' : (oStatus.index == 2 ? 'C' : 'D'))}" />
                                    <div class="group flex items-center p-5 bg-white border-2 border-transparent rounded-2xl cursor-pointer hover:border-purple-200 hover:shadow-md transition-all">
                                        <input type="radio" name="answer_${qStatus.index}" value="${oStatus.index}" class="hidden peer">
                                        
                                        <div class="w-6 h-6 rounded-full border-2 border-slate-200 flex items-center justify-center mr-4 peer-checked:bg-purple-600 peer-checked:border-purple-600 transition-all shrink-0">
                                            <div class="w-1.5 h-1.5 bg-white rounded-full"></div>
                                        </div>
                                        <span class="text-sm font-bold text-slate-600 peer-checked:text-purple-900">
                                            <span class="opacity-40 mr-1">${currentLetter}.</span>
                                            <c:set var="cleanOpt" value="${fn:trim(opt)}" />
                                            <c:choose>
                                                <c:when test="${not empty cleanOpt && fn:toLowerCase(cleanOpt) != fn:toLowerCase(currentLetter) && fn:toLowerCase(cleanOpt) != fn:toLowerCase(currentLetter.concat('.'))}">
                                                    <c:set var="prefix1" value="${currentLetter.concat('. ')}" />
                                                    <c:set var="prefix2" value="${currentLetter.concat('.')}" />
                                                    <c:set var="displayVal" value="${cleanOpt}" />
                                                    
                                                    <c:if test="${fn:startsWith(fn:toUpperCase(cleanOpt), prefix1)}">
                                                        <c:set var="displayVal" value="${fn:substring(cleanOpt, fn:length(prefix1), fn:length(cleanOpt))}" />
                                                    </c:if>
                                                    <c:if test="${fn:startsWith(fn:toUpperCase(cleanOpt), prefix2) && displayVal == cleanOpt}">
                                                        <c:set var="displayVal" value="${fn:substring(cleanOpt, fn:length(prefix2), fn:length(cleanOpt))}" />
                                                    </c:if>
                                                    
                                                    <c:out value="${displayVal}" />
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="italic text-gray-300 font-normal">Réponse non définie</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                        <script>
                                            // Ajout du clic sur le parent pour la radio
                                            document.currentScript.parentElement.onclick = function() {
                                                this.querySelector('input').click();
                                            };
                                        </script>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="flex justify-center items-center py-16 mt-12 border-t">
                    <button type="button" id="submitBtn" onclick="showConfirmModal()" 
                            class="bg-purple-900 text-white px-16 py-5 rounded-[2rem] font-black shadow-2xl shadow-purple-900/20 hover:bg-black transition-all transform hover:-translate-y-1 flex items-center gap-4">
                        <span id="btnText">Terminer l'examen</span> <i class="fas fa-paper-plane" id="btnIcon"></i>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal de Confirmation Personnalisé -->
    <div id="confirmModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-[110] hidden items-center justify-center p-6">
        <div class="bg-white rounded-[2.5rem] p-10 max-w-sm w-full shadow-2xl transform transition-all scale-95 opacity-0 duration-300" id="modalContent">
            <div class="w-16 h-16 bg-purple-100 text-purple-600 rounded-2xl flex items-center justify-center mx-auto mb-6 text-2xl">
                <i class="fas fa-question-circle"></i>
            </div>
            <h3 class="text-xl font-black text-slate-800 text-center mb-3">Soumettre l'examen ?</h3>
            <p class="text-slate-500 text-center text-sm mb-8 leading-relaxed">
                Êtes-vous sûr de vouloir terminer ? Vous ne pourrez plus modifier vos réponses après cette action.
            </p>
            <div class="flex flex-col gap-3">
                <button onclick="submitExam()" class="w-full py-4 bg-purple-900 text-white font-black rounded-2xl shadow-lg shadow-purple-900/20 hover:bg-black transition-all">
                    Oui, j'ai terminé
                </button>
                <button onclick="hideConfirmModal()" class="w-full py-4 bg-slate-100 text-slate-400 font-bold rounded-2xl hover:bg-slate-200 transition-all">
                    Continuer à réfléchir
                </button>
            </div>
        </div>
    </div>

    <!-- Overlay de chargement -->
    <div id="loadingOverlay" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-[100] hidden flex-col items-center justify-center text-white">
        <div class="w-16 h-16 border-4 border-purple-500 border-t-transparent rounded-full animate-spin mb-6"></div>
        <h2 class="text-2xl font-black mb-2">Envoi en cours...</h2>
        <p class="text-purple-200">Veuillez ne pas fermer cette page.</p>
    </div>

    <script>
        function showConfirmModal() {
            const modal = document.getElementById('confirmModal');
            const content = document.getElementById('modalContent');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
            setTimeout(() => {
                content.classList.remove('scale-95', 'opacity-0');
                content.classList.add('scale-100', 'opacity-100');
            }, 10);
        }

        function hideConfirmModal() {
            const modal = document.getElementById('confirmModal');
            const content = document.getElementById('modalContent');
            content.classList.remove('scale-100', 'opacity-100');
            content.classList.add('scale-95', 'opacity-0');
            setTimeout(() => {
                modal.classList.add('hidden');
                modal.classList.remove('flex');
            }, 300);
        }

        function submitExam() {
            hideConfirmModal();
            // Afficher l'overlay
            document.getElementById('loadingOverlay').classList.remove('hidden');
            document.getElementById('loadingOverlay').classList.add('flex');
            
            // Désactiver le bouton
            const btn = document.getElementById('submitBtn');
            btn.disabled = true;
            btn.classList.add('opacity-50', 'cursor-not-allowed');
            document.getElementById('btnText').innerText = "Envoi...";
            
            setTimeout(() => {
                document.getElementById('examForm').submit();
            }, 500);
        }

        // Timer de l'examen
        let timeLeft = ${remainingTime != null ? remainingTime : 0};
        
        function updateTimer() {
            if (timeLeft <= 0) {
                document.getElementById('countdown').innerText = "00:00";
                showToast("Temps écoulé ! Soumission automatique...", 'error');
                setTimeout(() => submitExam(), 2000);
                return;
            }

            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            document.getElementById('countdown').innerText = 
                `\${String(minutes).padStart(2, '0')}:\${String(seconds).padStart(2, '0')}`;
            
            if (timeLeft <= 60) {
                document.getElementById('timerContainer').classList.add('animate-pulse');
            }
            
            timeLeft--;
        }

        if (timeLeft > 0) {
            updateTimer();
            setInterval(updateTimer, 1000);
        } else if (timeLeft <= 0 && ${remainingTime != null}) {
            submitExam();
        }
    </script>
</body>
</html>
