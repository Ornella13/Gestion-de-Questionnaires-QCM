<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Étudiants - The Scholarly Curator</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;900&display=swap" rel="stylesheet">
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-gray-50 text-gray-900">
    <div class="flex min-h-screen">
    <c:set var="page" value="students" scope="request"/>
        <%@ include file="../fragments/sidebar.jspf" %>

        <main class="flex-1 ml-64 p-8 flex flex-col gap-8">
            <header class="flex justify-between items-end w-full">
                <div>
                    <h2 class="text-3xl font-black tracking-tight text-purple-900">Gestion des étudiants</h2>
                    <p class="text-gray-500 font-medium">Gérez les inscriptions et filtrez par niveau.</p>
                </div>
                <div class="flex gap-4">
                    <div class="relative">
					    <input type="text" id="searchInput" name="search" placeholder="Rechercher..." 
					           value="${searchQuery}" 
					           class="pl-10 pr-4 py-3 bg-white border border-gray-100 rounded-2xl shadow-sm outline-none text-sm w-64">
					    <i class="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-400"></i>
					</div>
                    
                    <button onclick="openModal()" class="bg-purple-700 text-white px-6 py-3 rounded-2xl font-bold shadow-lg hover:bg-purple-800 transition-all transform hover:-translate-y-0.5 flex items-center gap-2">
                        <i class="fas fa-user-plus"></i>
                        <span>Ajouter un élève</span>
                    </button>
                </div>
            </header>

            <!-- Statistiques par niveau -->
            <div id="statsContainer" class="grid grid-cols-2 md:grid-cols-6 gap-4 w-full">
                <c:forEach var="level" items="${fn:split('L1,L2,L3,M1,M2', ',')}">
                    <div onclick="filterByLevel('${level}')" 
                         class="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 cursor-pointer hover:border-purple-300 hover:shadow-md transition-all group text-center">
                        <p class="text-[10px] font-black uppercase tracking-widest text-gray-400 mb-1 group-hover:text-purple-500">${level}</p>
                        <h3 class="text-xl font-black text-purple-900">
                            <c:out value="${statsByLevel[level] != null ? statsByLevel[level] : '0'}" />
                        </h3>
                        <span class="text-[10px] font-medium text-gray-400 block">étudiants</span>
                    </div>
                </c:forEach>
                <div onclick="filterByLevel('all')" class="bg-purple-700 p-4 rounded-2xl shadow-lg border border-purple-600 cursor-pointer hover:bg-purple-800 transition-all text-center">
                    <p class="text-[10px] font-black uppercase tracking-widest text-purple-200 mb-1">TOTAL</p>
                    <h3 class="text-xl font-black text-white">${totalStudents}</h3>
                    <span class="text-[10px] font-medium text-purple-300 block">inscrits</span>
                </div>
            </div>

            <!-- Système de Notifications Toast -->
            <div id="toastContainer" class="fixed top-8 right-8 z-[100] flex flex-col gap-3"></div>

            <script>
                function showToast(message, type = 'success') {
                    const container = document.getElementById('toastContainer');
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
                    
                    // Animation d'entrée
                    setTimeout(() => {
                        toast.classList.remove('translate-x-full');
                    }, 10);

                    // Auto-suppression après 5s
                    setTimeout(() => {
                        toast.classList.add('translate-x-[150%]');
                        setTimeout(() => toast.remove(), 300);
                    }, 5000);
                }

                // Affichage des messages du serveur via Toasts
                <c:if test="${not empty sessionScope.successMessage}">
                    showToast("${sessionScope.successMessage}", 'success');
                    <c:remove var="successMessage" scope="session" />
                </c:if>
                <c:if test="${not empty sessionScope.errorMessage}">
                    showToast("${sessionScope.errorMessage}", 'error');
                    <c:remove var="errorMessage" scope="session" />
                </c:if>
            </script>

            <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden w-full">
                <table class="w-full text-left" id="studentsTable">
                    <thead class="bg-gray-50 border-b border-gray-100">
                        <tr>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400">ID</th>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400">Nom</th>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400">Prenom</th>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400">Email</th>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400">Niveau</th>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-50">
                        <c:forEach var="s" items="${students}">
                            <tr class="hover:bg-purple-50/30 transition-colors student-row" data-level="${s.niveau}">
                                <td class="px-6 py-4 font-mono text-xs text-gray-400">${s.numEtudiant}</td>
                                <td class="px-6 py-4 font-bold text-gray-800">${s.nom}</td>
                                <td class="px-6 py-4 font-bold text-gray-800">${s.prenom}</td>
                                <td class="px-6 py-4 text-gray-500">${s.email}</td>
                                <td class="px-6 py-4">
                                    <span class="px-3 py-1 bg-purple-100 text-purple-700 rounded-full text-[10px] font-black uppercase tracking-widest">
                                        ${s.niveau}
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <div class="flex justify-end gap-2">
                                        <button onclick="openEditModal('${s.numEtudiant}', '${s.nom}','${s.prenom}', '${s.email}', '${s.niveau}')" 
                                        class="text-gray-300 hover:text-purple-700 transition-colors">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button onclick="confirmDelete('${s.numEtudiant}', '${s.nom} ${s.prenom}')" 
                                                class="text-gray-300 hover:text-red-600 transition-colors">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty students}">
                            <tr>
                                <td colspan="6" class="px-6 py-12 text-center text-gray-400 font-medium">
                                    Aucun étudiant trouvé.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <!-- Modal for Adding/Editing Student -->
    <div id="addStudentModal" class="fixed inset-0 z-50 overflow-y-auto" style="display: none;">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm" onclick="closeModal()"></div>
            <div class="relative w-full max-w-lg bg-white rounded-2xl shadow-2xl overflow-hidden">
                <div class="relative h-1.5 bg-gradient-to-r from-purple-700 to-purple-500"></div>
                <div class="p-8">
                    <h2 id="modalTitle" class="text-2xl font-black text-slate-900 mb-2">Ajouter un élève</h2>
                    <p id="modalSubtitle" class="text-sm text-slate-500 mb-6">Inscrivez un nouvel étudiant dans le système.</p>
                    
                    <form action="${pageContext.request.contextPath}/students" method="POST" class="space-y-6">
                        <input type="hidden" name="action" id="modalAction" value="add">
                        <input type="hidden" name="oldId" id="studentOldId" value="">
                        
                        <div>
                            <label class="block text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">Niveau Académique</label>
                            <select name="niveau" id="studentLevel" onchange="autoGenerateMatricule(this.value)" class="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none font-bold">
                                <option value="" disabled selected>Choisissez le niveau...</option>
                                <option value="L1">L1 (900+)</option>
                                <option value="L2">L2 (700-899)</option>
                                <option value="L3">L3 (500-699)</option>
                                <option value="M1">M1 (100-299)</option>
                                <option value="M2">M2 (300-499)</option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">Numero Matricule</label>
                            <input type="text" name="id" id="studentId" required 
                                   placeholder="Généré auto ou tapez..."
                                   oninput="detectLevel(this.value)"
                                   class="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none font-mono font-bold uppercase">
                        </div>

                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">Nom</label>
                                <input type="text" name="nom" id="studentName" required class="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none">
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">Prenom</label>
                                <input type="text" name="prenom" id="studentPrenom" required class="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none">
                            </div>
                        </div>

                        <div>
                            <label class="block text-xs font-bold uppercase tracking-widest text-slate-400 mb-2">Email</label>
                            <input type="email" name="email" id="studentEmail" required class="w-full p-4 bg-slate-50 border border-slate-100 rounded-xl outline-none">
                        </div>

                        <div class="flex justify-end gap-4 pt-4">
                            <button type="button" onclick="closeModal()" class="px-6 py-2 text-slate-400 font-bold hover:text-slate-600 transition-colors">Annuler</button>
                            <button type="submit" id="submitBtn" class="px-8 py-3 bg-purple-700 text-white font-bold rounded-xl shadow-lg hover:bg-purple-800 transition-all transform active:scale-95">Enregistrer</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal de Confirmation de Suppression -->
    <div id="confirmModal" class="fixed inset-0 z-[60] overflow-y-auto" style="display: none;">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm" onclick="closeConfirmModal()"></div>
            <div class="relative w-full max-w-sm bg-white rounded-2xl shadow-2xl overflow-hidden p-8 text-center">
                <div class="w-16 h-16 bg-red-50 text-red-500 rounded-full flex items-center justify-center mx-auto mb-6">
                    <i class="fas fa-exclamation-triangle text-2xl"></i>
                </div>
                <h3 class="text-xl font-black text-slate-900 mb-2">Confirmation</h3>
                <p class="text-sm text-slate-500 mb-8">
                    Voulez-vous vraiment supprimer l'étudiant <span id="deleteStudentInfo" class="font-bold text-slate-900"></span> ? Cette action est irréversible.
                </p>
                <div class="flex gap-3">
                    <button onclick="closeConfirmModal()" class="flex-1 px-4 py-3 bg-slate-50 text-slate-400 font-bold rounded-xl hover:bg-slate-100 transition-colors">
                        Annuler
                    </button>
                    <form id="deleteForm" action="${pageContext.request.contextPath}/students" method="POST" class="flex-1">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" id="deleteTargetId">
                        <button type="submit" class="w-full px-4 py-3 bg-red-500 text-white font-bold rounded-xl shadow-lg shadow-red-200 hover:bg-red-600 transition-all transform active:scale-95">
                            Supprimer
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        function confirmDelete(id, name) {
            document.getElementById('deleteTargetId').value = id;
            document.getElementById('deleteStudentInfo').innerText = name;
            document.getElementById('confirmModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeConfirmModal() {
            document.getElementById('confirmModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        // --- 1. FONCTION DE RECHERCHE AUTOMATIQUE (LIVE SEARCH) ---
        document.getElementById('searchInput').addEventListener('input', function(e) {
            const query = e.target.value;
            const contextPath = "${pageContext.request.contextPath}";

            fetch(contextPath + "/students?search=" + encodeURIComponent(query))
                .then(response => response.text())
                .then(html => {
                    const parser = new DOMParser();
                    const doc = parser.parseFromString(html, 'text/html');
                    
                    const newTableBody = doc.querySelector('#studentsTable tbody').innerHTML;
                    document.querySelector('#studentsTable tbody').innerHTML = newTableBody;
                    
                    const newStats = doc.querySelector('#statsContainer').innerHTML;
                    document.querySelector('#statsContainer').innerHTML = newStats;
                })
                .catch(err => console.error("Erreur Live Search:", err));
        });

        // --- 2. DÉTECTION DU NIVEAU BASÉE SUR LE MATRICULE ---
        function detectLevel(matricule) {
            if (!matricule) return;
            let num = "";
            for (let char of matricule) {
                if (char >= '0' && char <= '9') num += char;
                else break;
            }
            if (num !== "") {
                const val = parseInt(num);
                const select = document.getElementById('studentLevel');
                if (val >= 900) select.value = "L1";
                else if (val >= 700) select.value = "L2";
                else if (val >= 500) select.value = "L3";
                else if (val >= 300) select.value = "M2";
                else if (val >= 100) select.value = "M1";
            }
        }

        // --- 3. GÉNÉRATION AUTOMATIQUE DU MATRICULE ---
        async function autoGenerateMatricule(level) {
            if (!level) return;
            try {
                const response = await fetch(`${pageContext.request.contextPath}/students?getNextIdForLevel=` + level);
                if (response.ok) {
                    const nextId = await response.text();
                    document.getElementById('studentId').value = nextId;
                }
            } catch (err) {
                console.error("Erreur génération matricule:", err);
            }
        }

        // --- 4. GESTION DES MODALES ---
        function openModal() {
            const modal = document.getElementById('addStudentModal');
            document.getElementById('modalTitle').innerText = "Ajouter un élève";
            document.getElementById('modalSubtitle').innerText = "Inscrivez un nouvel étudiant dans le système.";
            document.getElementById('modalAction').value = "add";
            document.getElementById('studentOldId').value = "";
            
            const idInput = document.getElementById('studentId');
            idInput.value = "";
            idInput.readOnly = false;
            idInput.classList.remove('bg-gray-100');
            
            document.getElementById('studentName').value = "";
            document.getElementById('studentPrenom').value = "";
            document.getElementById('studentEmail').value = "";
            document.getElementById('studentLevel').value = "";
            document.getElementById('submitBtn').innerText = "Enregistrer";
            
            modal.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function openEditModal(id, nom, prenom, email, level) {
            const modal = document.getElementById('addStudentModal');
            document.getElementById('modalTitle').innerText = "Modifier l'élève";
            document.getElementById('modalSubtitle').innerText = "Mettez à jour les informations de l'étudiant.";
            document.getElementById('modalAction').value = "update";
            document.getElementById('studentOldId').value = id;
            
            const idInput = document.getElementById('studentId');
            idInput.value = id;
            idInput.readOnly = true;
            idInput.classList.add('bg-gray-100');
            
            document.getElementById('studentName').value = nom;
            document.getElementById('studentPrenom').value = prenom;
            document.getElementById('studentEmail').value = email;
            document.getElementById('studentLevel').value = level;
            document.getElementById('submitBtn').innerText = "Enregistrer les modifications";
            
            modal.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }

        function closeModal() {
            document.getElementById('addStudentModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        function filterByLevel(level) {
            const rows = document.querySelectorAll('.student-row');
            rows.forEach(row => {
                if (level === 'all' || row.getAttribute('data-level') === level) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }
    </script>
</body>
</html>
