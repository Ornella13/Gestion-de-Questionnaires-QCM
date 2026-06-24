<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Scheduling - The Scholarly Curator</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;900&display=swap" rel="stylesheet">
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-gray-50 text-gray-900">
    <div class="flex min-h-screen">
        <%@ include file="../fragments/sidebar.jspf" %>

        <main class="flex-1 ml-64 p-8 flex flex-col gap-8">
            <header class="flex justify-between items-center w-full">
                <div>
                    <h2 class="text-3xl font-black tracking-tight text-purple-900">Planification des sessions</h2>
                    <p class="text-gray-500 font-medium">Planifiez et surveillez les sessions académiques à venir.</p>
                </div>
                <button onclick="openModal()" class="bg-purple-700 text-white px-6 py-3 rounded-2xl font-black shadow-lg hover:bg-purple-800 transition-all transform hover:-translate-y-0.5 flex items-center gap-2">
                    <i class="fas fa-calendar-plus"></i>
                    <span>Planifier une session</span>
                </button>
            </header>

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

            <div class="space-y-4 w-full">
                <c:forEach var="s" items="${sessions}">
                    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center justify-between hover:shadow-md transition-shadow">
                        <div class="flex items-center gap-6">
                            <div class="w-14 h-14 bg-purple-50 rounded-xl flex flex-col items-center justify-center text-purple-700 border border-purple-100">
                                <span class="text-[10px] font-black uppercase leading-none">Session</span>
                                <span class="text-xl font-black leading-tight">${s.date.substring(s.date.length() - 2)}</span>
                            </div>
                            
                            <div>
                                <h3 class="text-lg font-bold text-gray-900">${s.title}</h3>
                                <div class="flex items-center gap-4 text-sm text-gray-400 mt-1">
                                    <span><i class="fas fa-layer-group mr-1 text-purple-300"></i> ${s.level}</span>
                                    <span><i class="far fa-clock mr-1 text-purple-300"></i> ${s.date} à ${s.time} (${s.duration} min)</span>
                                </div>
                            </div>
                        </div>

                        <div class="flex items-center gap-6">
                            <span class="px-4 py-1.5 ${s.status == 'Confirmed' ? 'bg-green-100 text-green-700' : 'bg-amber-100 text-amber-700'} rounded-full text-[10px] font-black uppercase tracking-widest">
                                ${s.status == 'Pending' ? 'En attente' : s.status}
                            </span>
                            <div class="flex gap-2">
                                <button onclick="openEditModal('${s.id}', '${s.title.replace("'", "\\'")}', '${s.level}', '${s.date}', '${s.time}', '${s.duration}', '${s.students}')" class="w-10 h-10 rounded-lg bg-gray-50 text-gray-400 hover:text-purple-700 transition-colors">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button onclick="confirmDeleteSession('${s.id}')" class="w-10 h-10 rounded-lg bg-gray-50 text-gray-400 hover:text-red-600 transition-colors">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </main>
    </div>

    <!-- Modal for Scheduling Session -->
    <div id="scheduleModal" class="fixed inset-0 z-50 hidden overflow-y-auto">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm" onclick="closeModal()"></div>
            
            <div class="relative w-full max-w-lg bg-white rounded-2xl shadow-2xl overflow-hidden">
                <div class="relative h-1 bg-gradient-to-r from-purple-700 to-purple-500"></div>
                <div class="p-8">
                    <div class="flex justify-between items-center mb-8">
                        <div>
                            <h2 id="modalTitle" class="text-2xl font-black tracking-tight text-slate-900">Planifier une session</h2>
                            <p id="modalSubtitle" class="text-sm text-slate-500 mt-1">Planifiez une nouvelle session d'examen ou d'évaluation.</p>
                        </div>
                        <button onclick="closeModal()" class="w-10 h-10 rounded-full hover:bg-slate-100 flex items-center justify-center transition-colors">
                            <i class="fas fa-times text-slate-400"></i>
                        </button>
                    </div>

                    <form action="${pageContext.request.contextPath}/scheduling" method="POST" class="space-y-6">
                        <input type="hidden" name="action" id="modalAction" value="add">
                        <input type="hidden" name="id" id="sessionId">
                        
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">Titre de la session</label>
                                <input type="text" name="title" id="sessionTitle" required
                                       placeholder="ex: Examen Final"
                                       class="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl focus:ring-2 focus:ring-purple-100 focus:border-purple-300 outline-none transition-all font-medium">
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">Niveau</label>
                                <select name="level" id="sessionLevel" class="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none font-bold text-sm">
                                    <option value="L1">L1</option>
                                    <option value="L2">L2</option>
                                    <option value="L3">L3</option>
                                    <option value="M1">M1</option>
                                    <option value="M2">M2</option>
                                </select>
                            </div>
                        </div>

                        <div class="grid grid-cols-3 gap-4">
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">Date</label>
                                <input type="date" name="date" id="sessionDate" required
                                       class="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl focus:ring-2 focus:ring-purple-100 outline-none transition-all font-medium text-sm">
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">Heure</label>
                                <input type="time" name="time" id="sessionTime" required
                                       class="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl focus:ring-2 focus:ring-purple-100 outline-none transition-all font-medium text-sm">
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">Durée (min)</label>
                                <input type="number" name="duration" id="sessionDuration" required value="30" min="5" max="180"
                                       class="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl focus:ring-2 focus:ring-purple-100 outline-none transition-all font-medium text-sm">
                            </div>
                        </div>

                        <div>
                            <label class="block text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">Groupe Cible (Commentaire)</label>
                            <input type="text" name="group" id="sessionGroup" placeholder="Ex: Tous les étudiants" class="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none font-bold text-sm">
                        </div>

                        <div class="pt-6 flex justify-end space-x-4 border-t border-slate-100">
                            <button type="button" onclick="closeModal()" class="px-6 py-2.5 text-sm font-bold text-slate-500 hover:bg-slate-100 rounded-lg transition-colors">
                                Annuler
                            </button>
                            <button type="submit" id="submitBtn" class="px-8 py-2.5 bg-purple-700 text-white text-sm font-bold rounded-lg shadow-lg hover:bg-purple-800 active:scale-95 transition-all">
                                Planifier maintenant
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal de Confirmation de Suppression -->
    <div id="confirmDeleteModal" class="fixed inset-0 z-[60] hidden overflow-y-auto">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm" onclick="closeConfirmModal()"></div>
            <div class="relative w-full max-w-sm bg-white rounded-2xl shadow-2xl p-8 text-center">
                <div class="w-16 h-16 bg-red-50 text-red-500 rounded-full flex items-center justify-center mx-auto mb-6">
                    <i class="fas fa-exclamation-triangle text-2xl"></i>
                </div>
                <h3 class="text-xl font-black text-slate-900 mb-2">Confirmation</h3>
                <p class="text-sm text-slate-500 mb-8">Voulez-vous vraiment supprimer cette session ? Cette action est irréversible.</p>
                <div class="flex gap-3">
                    <button onclick="closeConfirmModal()" class="flex-1 px-4 py-3 bg-slate-50 text-slate-400 font-bold rounded-xl hover:bg-slate-100 transition-colors">Annuler</button>
                    <form action="${pageContext.request.contextPath}/scheduling" method="POST" class="flex-1">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" id="deleteTargetId">
                        <button type="submit" class="w-full px-4 py-3 bg-red-500 text-white font-bold rounded-xl shadow-lg hover:bg-red-600 transition-all">Supprimer</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        function openModal() {
            document.getElementById('modalTitle').innerText = "Planifier une session";
            document.getElementById('modalSubtitle').innerText = "Planifiez une nouvelle session d'examen ou d'évaluation.";
            document.getElementById('modalAction').value = "add";
            document.getElementById('sessionId').value = "";
            document.getElementById('sessionTitle').value = "";
            document.getElementById('sessionLevel').value = "L1";
            document.getElementById('sessionDate').value = "";
            document.getElementById('sessionTime').value = "";
            document.getElementById('sessionDuration').value = "30";
            document.getElementById('sessionGroup').value = "";
            document.getElementById('submitBtn').innerText = "Planifier maintenant";
            document.getElementById('scheduleModal').classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function openEditModal(id, title, level, date, time, duration, group) {
            document.getElementById('modalTitle').innerText = "Modifier la session";
            document.getElementById('modalSubtitle').innerText = "Mettez à jour les détails de la session.";
            document.getElementById('modalAction').value = "update";
            document.getElementById('sessionId').value = id;
            document.getElementById('sessionTitle').value = title;
            document.getElementById('sessionLevel').value = level;
            document.getElementById('sessionDate').value = date;
            document.getElementById('sessionTime').value = time;
            document.getElementById('sessionDuration').value = duration;
            document.getElementById('sessionGroup').value = group;
            document.getElementById('submitBtn').innerText = "Enregistrer les modifications";
            document.getElementById('scheduleModal').classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function closeModal() {
            document.getElementById('scheduleModal').classList.add('hidden');
            document.body.style.overflow = 'auto';
        }

        function confirmDeleteSession(id) {
            document.getElementById('deleteTargetId').value = id;
            document.getElementById('confirmDeleteModal').classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function closeConfirmModal() {
            document.getElementById('confirmDeleteModal').classList.add('hidden');
            document.body.style.overflow = 'auto';
        }
    </script>
</body>
</html>
