<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Banque de Questions - The Scholarly Curator</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;900&display=swap" rel="stylesheet">
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-gray-50 text-gray-900">
    <div class="flex min-h-screen">
        <c:set var="page" value="questions" scope="request"/>
        <%@ include file="../fragments/sidebar.jspf" %>

        <main class="flex-1 ml-64 p-8 flex flex-col gap-8">
            <header class="flex justify-between items-end w-full">
                <div>
                    <h2 class="text-3xl font-black tracking-tight text-purple-900">Banque de questions</h2>
                    <p class="text-gray-500 font-medium">Gérez votre inventaire de QCM et filtrez par niveau.</p>
                </div>
                <div class="flex gap-4">
                    <div class="relative">
                        <input type="text" id="searchInput" placeholder="Rechercher une question..." 
                               class="pl-10 pr-4 py-3 bg-white border border-gray-100 rounded-2xl shadow-sm outline-none text-sm w-64 focus:border-purple-300 transition-all">
                        <i class="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-400"></i>
                    </div>
                    
                    <button onclick="openModal()" class="bg-purple-700 text-white px-6 py-3 rounded-2xl font-bold shadow-lg hover:bg-purple-800 transition-all transform hover:-translate-y-0.5 flex items-center gap-2">
                        <i class="fas fa-plus"></i>
                        <span>Nouvelle Question</span>
                    </button>
                </div>
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

                // Initialisation différée pour s'assurer que le script tourne après le DOM
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

           <div id="statsContainer" class="grid grid-cols-2 md:grid-cols-6 gap-4 w-full">
			    <c:forEach var="level" items="${fn:split('L1,L2,L3,M1,M2', ',')}">
			        <div onclick="filterByLevel('${level}')" 
			             class="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 cursor-pointer hover:border-purple-300 hover:shadow-md transition-all group text-center">
			            <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-1 group-hover:text-purple-500">${level}</p>
			            <h3 class="text-xl font-black text-purple-900 count-badge" data-level-count="${level}">0</h3>
			            <span class="text-[10px] font-medium text-gray-400 block">questions</span>
			        </div>
			    </c:forEach>
			    <div onclick="filterByLevel('all')" class="bg-purple-700 p-4 rounded-2xl shadow-lg border border-purple-600 cursor-pointer hover:bg-purple-800 transition-all text-center">
			        <p class="text-[10px] font-black uppercase tracking-widest text-purple-200 mb-1">TOTAL</p>
			        <h3 class="text-xl font-black text-white" id="totalCountDisplay">0</h3>
			        <span class="text-[10px] font-medium text-purple-300 block">inscrites</span>
			    </div>
			</div>

            <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden w-full">
                <table class="w-full text-left" id="questionsTable">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400">ID</th>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400">Niveau/Module</th>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400 w-1/2">Énoncé</th>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400 text-center">Options</th>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-50">
                        <c:forEach var="q" items="${questions}">
                            <tr class="hover:bg-purple-50/30 transition-colors question-row" data-level="${q.module}">
                                <td class="px-6 py-4 font-mono text-xs text-gray-400">#${q.id}</td>
                                <td class="px-6 py-4">
                                    <span class="px-3 py-1 bg-purple-100 text-purple-700 rounded-full text-[10px] font-black uppercase tracking-widest">
                                        ${q.module}
                                    </span>
                                </td>
                                <td class="px-6 py-4 font-bold text-gray-800 question-text">${q.text}</td>
                                <td class="px-6 py-4 text-center">
                                    <span class="text-xs font-bold text-gray-500 bg-gray-100 px-2 py-1 rounded">
                                        ${q.optionsCount} choix
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <div class="flex justify-end gap-2">
                                        <button onclick="openEditModal('${q.id}', '${q.module}', `${q.text}`, `${q.r1}`, `${q.r2}`, `${q.r3}`, `${q.r4}`, '${q.correctIndex}', '${q.optionsCount}')" 
                                                class="text-gray-300 hover:text-purple-700 transition-colors">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button onclick="confirmDeleteQuestion('${q.id}')" 
                                                class="text-gray-300 hover:text-red-600 transition-colors">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <c:if test="${empty questions}">
                    <div class="p-20 text-center text-gray-400">Aucune question trouvée.</div>
                </c:if>
            </div>
        </main>
    </div>

    <!-- Modal de Gestion Question -->
    <div id="addQuestionModal" class="fixed inset-0 z-50 overflow-y-auto" style="display: none;">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm" onclick="closeModal()"></div>
            <div class="relative w-full max-w-2xl bg-white rounded-2xl shadow-2xl overflow-hidden">
                <div class="p-8">
                    <h2 id="modalTitle" class="text-2xl font-black text-slate-900 mb-6">Gestion QCM</h2>
                    <form action="questions" method="POST" class="space-y-4">
                        <input type="hidden" name="action" id="modalAction" value="add">
                        <input type="hidden" name="id" id="questionId">

                        <div>
                            <label class="block text-xs font-bold uppercase text-slate-400 mb-2">Énoncé de la question</label>
                            <textarea name="statement" id="questionText" rows="3" required class="w-full p-4 bg-slate-50 border rounded-xl outline-none focus:border-purple-500"></textarea>
                        </div>

                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-bold uppercase text-slate-400 mb-2">Nombre d'options</label>
                                <select name="optionsCount" id="optionsCount" onchange="updateOptionsVisibility()" class="w-full p-3 bg-slate-50 border rounded-xl outline-none font-bold">
                                    <option value="2">2 options</option>
                                    <option value="3">3 options</option>
                                    <option value="4" selected>4 options</option>
                                </select>
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase text-slate-400 mb-2">Niveau académique</label>
                                <select name="module" id="questionCategory" class="w-full p-3 bg-slate-50 border rounded-xl outline-none font-bold">
                                    <option value="L1">L1</option>
                                    <option value="L2">L2</option>
                                    <option value="L3">L3</option>
                                    <option value="M1">M1</option>
                                    <option value="M2">M2</option>
                                </select>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 p-4 bg-gray-50 rounded-xl" id="optionsGrid">
                            <c:forEach var="i" begin="1" end="4">
                                <div id="optionContainer${i}">
                                    <label class="block text-[10px] font-bold uppercase text-slate-400 mb-1">Option ${i}</label>
                                    <div class="flex items-center gap-2">
                                        <input type="text" name="option${i}" id="inputOption${i}" class="flex-1 bg-white border border-gray-200 rounded-lg px-4 py-2 text-sm outline-none">
                                        <input type="radio" name="correctOption" value="${i}" id="radioOption${i}" title="Cochez si c'est la bonne réponse">
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="flex justify-end gap-4 pt-4 border-t">
                            <button type="button" onclick="closeModal()" class="px-6 py-2 text-slate-500 font-bold">Annuler</button>
                            <button type="submit" id="submitBtn" class="px-8 py-2 bg-purple-700 text-white font-bold rounded-lg shadow-lg hover:bg-purple-800 transition-all">Enregistrer</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal de Confirmation de Suppression -->
    <div id="confirmDeleteModal" class="fixed inset-0 z-[60] overflow-y-auto" style="display: none;">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm" onclick="closeConfirmModal()"></div>
            <div class="relative w-full max-w-sm bg-white rounded-2xl shadow-2xl p-8 text-center">
                <div class="w-16 h-16 bg-red-50 text-red-500 rounded-full flex items-center justify-center mx-auto mb-6">
                    <i class="fas fa-exclamation-triangle text-2xl"></i>
                </div>
                <h3 class="text-xl font-black text-slate-900 mb-2">Confirmation</h3>
                <p class="text-sm text-slate-500 mb-8">Voulez-vous vraiment supprimer cette question ? Cette action est irréversible.</p>
                <div class="flex gap-3">
                    <button onclick="closeConfirmModal()" class="flex-1 px-4 py-3 bg-slate-50 text-slate-400 font-bold rounded-xl hover:bg-slate-100 transition-colors">Annuler</button>
                    <form action="questions" method="POST" class="flex-1">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" id="deleteTargetId">
                        <button type="submit" class="w-full px-4 py-3 bg-red-500 text-white font-bold rounded-xl shadow-lg hover:bg-red-600 transition-all">Supprimer</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        // --- 1. RECHERCHE EN TEMPS RÉEL ---
        document.getElementById('searchInput').addEventListener('input', function(e) {
            const query = e.target.value.toLowerCase();
            const rows = document.querySelectorAll('.question-row');
            rows.forEach(row => {
                const text = row.querySelector('.question-text').innerText.toLowerCase();
                const level = row.getAttribute('data-level').toLowerCase();
                row.style.display = (text.includes(query) || level.includes(query)) ? '' : 'none';
            });
        });

        // --- 2. STATISTIQUES ET FILTRAGE ---
        function updateStatistics() {
            const rows = document.querySelectorAll('.question-row');
            const counts = { 'L1': 0, 'L2': 0, 'L3': 0, 'M1': 0, 'M2': 0 };
            rows.forEach(row => {
                const level = row.getAttribute('data-level');
                if (counts.hasOwnProperty(level)) counts[level]++;
            });

            document.querySelectorAll('.count-badge').forEach(badge => {
                const level = badge.getAttribute('data-level-count');
                badge.innerText = counts[level] || 0;
            });
            document.getElementById('totalCountDisplay').innerText = rows.length;
        }

        function filterByLevel(level) {
            const rows = document.querySelectorAll('.question-row');
            rows.forEach(row => {
                row.style.display = (level === 'all' || row.getAttribute('data-level') === level) ? '' : 'none';
            });
        }

        // --- 3. GESTION DES MODALES ---
        function updateOptionsVisibility() {
            const count = parseInt(document.getElementById('optionsCount').value);
            for (let i = 1; i <= 4; i++) {
                const container = document.getElementById('optionContainer' + i);
                container.style.display = (i <= count) ? 'block' : 'none';
            }
        }

        function openModal() {
            document.getElementById('modalTitle').innerText = "Nouvelle Question";
            document.getElementById('modalAction').value = "add";
            document.getElementById('questionId').value = "";
            document.getElementById('questionText').value = "";
            document.getElementById('optionsCount').value = "4";
            for(let i=1; i<=4; i++) {
                document.getElementById('inputOption'+i).value = "";
            }
            updateOptionsVisibility();
            document.getElementById('addQuestionModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function openEditModal(id, category, text, r1, r2, r3, r4, correct, count) {
            document.getElementById('modalTitle').innerText = "Modifier la question";
            document.getElementById('modalAction').value = "update";
            document.getElementById('questionId').value = id;
            document.getElementById('questionText').value = text;
            document.getElementById('questionCategory').value = category;
            document.getElementById('optionsCount').value = count || "4";
            document.getElementById('inputOption1').value = r1 || "";
            document.getElementById('inputOption2').value = r2 || "";
            document.getElementById('inputOption3').value = r3 || "";
            document.getElementById('inputOption4').value = r4 || "";
            if (correct) {
                const radio = document.getElementById('radioOption' + correct);
                if (radio) radio.checked = true;
            }
            updateOptionsVisibility();
            document.getElementById('addQuestionModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeModal() {
            document.getElementById('addQuestionModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        function confirmDeleteQuestion(id) {
            document.getElementById('deleteTargetId').value = id;
            document.getElementById('confirmDeleteModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeConfirmModal() {
            document.getElementById('confirmDeleteModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        window.onload = updateStatistics;
    </script>
</body>
</html>
