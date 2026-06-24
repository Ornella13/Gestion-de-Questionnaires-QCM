<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <title>Statistiques & Résultats - The Scholarly Curator</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;900&display=swap" rel="stylesheet">
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-gray-50 text-gray-900">
    <div class="app-container flex min-h-screen">
        <%@ include file="../fragments/sidebar.jspf" %>

        <main class="flex-1 ml-64 p-8 flex flex-col gap-8">
            <header>
                <h2 class="text-2xl font-black tracking-tight text-purple-700">Tableau de bord des examens</h2>
                <p class="text-gray-500 text-sm font-medium">Sélectionnez un niveau pour voir le classement par mérite.</p>
            </header>

            <div class="flex flex-col gap-8">
                <!-- CLASSEMENT GLOBAL
                <div class="flex flex-col gap-3">
                    <h3 class="text-[10px] font-black tracking-[0.2em] uppercase text-gray-400 border-b border-gray-100 pb-2 flex items-center gap-2">
                        <i class="fas fa-globe-africa text-purple-600"></i> Ordre de Mérite Global
                    </h3>
                    <div class="grid grid-cols-1">
                        <div onclick="showLevel('Global', this)" 
                             class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center justify-between cursor-pointer hover:border-purple-300 hover:shadow-md transition-all group active-card">
                            <div class="flex items-center gap-4">
                                <div class="w-14 h-14 bg-yellow-50 text-yellow-600 rounded-2xl flex items-center justify-center shrink-0 group-hover:scale-110 transition-transform">
                                    <i class="fas fa-trophy text-2xl"></i>
                                </div>
                                <div>
                                    <h3 class="text-xl font-black text-slate-800">Tableau d'Honneur</h3>
                                    <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest mt-1">Tous les niveaux confondus</p>
                                </div>
                            </div>
                            <div class="text-right">
                                <span class="text-3xl font-black tracking-tighter text-slate-800">${fn:length(globalResults)}</span>
                                <p class="text-[10px] font-black text-purple-700 uppercase">Candidats</p>
                            </div>
                        </div>
                    </div>
                </div>-->

                <!-- CYCLE LICENCE -->
                <div class="flex flex-col gap-3">
                    <h3 class="text-[10px] font-black tracking-[0.2em] uppercase text-gray-400 border-b border-gray-100 pb-2">Cycle Licence</h3>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <c:forEach var="entry" items="${resultsByLevel}">
                            <c:if test="${fn:startsWith(entry.key, 'L')}">
                                <div onclick="showLevel('${entry.key}', this)" 
                                     class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 cursor-pointer hover:border-purple-300 hover:shadow-md transition-all group">
                                    <div class="flex justify-between items-center mb-4">
                                        <div class="w-10 h-10 bg-purple-50 text-purple-700 rounded-xl flex items-center justify-center shrink-0">
                                            <i class="fas fa-user-graduate text-sm"></i>
                                        </div>
                                        <span class="text-2xl font-black italic uppercase text-slate-100 group-hover:text-purple-100 transition-colors">${entry.key}</span>
                                    </div>
                                    <div>
                                        <h3 class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1">Participants</h3>
                                        <div class="flex items-baseline gap-1.5">
                                            <span class="text-2xl font-black text-slate-800">${fn:length(entry.value)}</span>
                                            <span class="text-[10px] font-bold text-purple-600">Étudiants</span>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>

                <!-- CYCLE MASTER -->
                <div class="flex flex-col gap-3">
                    <h3 class="text-[10px] font-black tracking-[0.2em] uppercase text-gray-400 border-b border-gray-100 pb-2">Cycle Master</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 w-1/2">
                        <c:forEach var="entry" items="${resultsByLevel}">
                            <c:if test="${fn:startsWith(entry.key, 'M')}">
                                <div onclick="showLevel('${entry.key}', this)" 
                                     class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 cursor-pointer hover:border-purple-300 hover:shadow-md transition-all group">
                                    <div class="flex justify-between items-center mb-4">
                                        <div class="w-10 h-10 bg-purple-50 text-purple-700 rounded-xl flex items-center justify-center shrink-0">
                                            <i class="fas fa-user-graduate text-sm"></i>
                                        </div>
                                        <span class="text-2xl font-black italic uppercase text-slate-100 group-hover:text-purple-100 transition-colors">${entry.key}</span>
                                    </div>
                                    <div>
                                        <h3 class="text-[10px] font-black text-gray-400 uppercase tracking-widest mb-1">Participants</h3>
                                        <div class="flex items-baseline gap-1.5">
                                            <span class="text-2xl font-black text-slate-800">${fn:length(entry.value)}</span>
                                            <span class="text-[10px] font-bold text-purple-600">Étudiants</span>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>
            </div>

            <!-- SECTION TABLEAUX DES RESULTATS -->
            <div id="results-container" class="mt-4">
                <!-- TABLEAU GLOBAL -->
                <div id="content-Global" class="tab-content hidden flex-col gap-4">
                    <div class="flex items-center gap-3 mb-4">
                        <div class="h-8 w-1 bg-yellow-400 rounded-full"></div>
                        <h3 class="text-lg font-black text-slate-800">Classement Général par Mérite</h3>
                    </div>

                    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden w-full">
                        <table class="w-full text-left">
                            <thead class="bg-gray-50 border-b border-gray-100">
                                <tr>
                                    <th class="px-5 py-4 text-[10px] font-black uppercase text-gray-400">Rang</th>
                                    <th class="px-5 py-4 text-[10px] font-black uppercase text-gray-400">Étudiant</th>
                                    <th class="px-5 py-4 text-[10px] font-black uppercase text-gray-400 text-center">Niveau</th>
                                    <th class="px-5 py-4 text-[10px] font-black uppercase text-gray-400 text-center">Note / 10</th>
                                    <th class="px-5 py-4 text-[10px] font-black uppercase text-gray-400 text-right">Date</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-50">
                                <c:forEach var="res" items="${globalResults}" varStatus="status">
                                    <tr class="hover:bg-slate-50/50 transition-colors">
                                        <td class="px-5 py-4">
                                            <div class="flex items-center gap-3">
                                                <span class="w-8 h-8 rounded-lg flex items-center justify-center font-black text-xs
                                                    ${status.index == 0 ? 'bg-yellow-50 text-yellow-600 border border-yellow-100' : 
                                                      status.index == 1 ? 'bg-slate-50 text-slate-500 border border-slate-100' : 
                                                      status.index == 2 ? 'bg-orange-50 text-orange-600 border border-orange-100' : 'bg-gray-50 text-gray-400'}">
                                                    ${status.index + 1}
                                                </span>
                                                <c:if test="${status.index == 0}"><i class="fas fa-crown text-yellow-400 text-[10px]"></i></c:if>
                                            </div>
                                        </td>
                                        <td class="px-5 py-4">
                                            <div class="font-bold text-slate-800 text-sm">${res.studentName}</div>
                                            <div class="text-[9px] text-gray-400 uppercase font-black tracking-widest mt-0.5">${res.studentId}</div>
                                        </td>
                                        <td class="px-5 py-4 text-center">
                                            <span class="italic uppercase font-black text-xs text-gray-400 tracking-tighter">${res.level}</span>
                                        </td>
                                        <td class="px-5 py-4 text-center">
                                            <div class="inline-flex items-baseline px-3 py-1 rounded-full font-black text-sm
                                                ${res.score >= 8 ? 'bg-green-50 text-green-600' : 
                                                  res.score >= 5 ? 'bg-blue-50 text-blue-600' : 'bg-red-50 text-red-600'}">
                                                ${res.score}<span class="opacity-30 ml-0.5 text-[10px]">/10</span>
                                            </div>
                                        </td>
                                        <td class="px-5 py-4 text-right font-black text-[10px] text-gray-400 uppercase">
                                            <c:choose>
                                                <c:when test="${res.dateTime != 'N/A' && fn:length(res.dateTime) >= 10}">
                                                    <c:catch var="parseEx">
                                                        <fmt:parseDate value="${res.dateTime}" pattern="yyyy-MM-dd HH:mm:ss" var="parsedDate" type="both" />
                                                        <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm" />
                                                    </c:catch>
                                                    <c:if test="${parseEx != null}">
                                                        ${res.dateTime}
                                                    </c:if>
                                                </c:when>
                                                <c:otherwise>Non disponible</c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <c:forEach var="entry" items="${resultsByLevel}">
                    <div id="content-${entry.key}" class="tab-content hidden flex-col gap-4">
                        <div class="flex items-center gap-3 mb-4">
                            <div class="h-8 w-1 bg-purple-600 rounded-full"></div>
                            <h3 class="text-lg font-black text-slate-800">Rang de Mérite : ${entry.key}</h3>
                        </div>

                        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden w-full">
                            <table class="w-full text-left">
                                <thead class="bg-gray-50 border-b border-gray-100">
                                    <tr>
                                        <th class="px-5 py-4 text-[10px] font-black uppercase text-gray-400">Rang</th>
                                        <th class="px-5 py-4 text-[10px] font-black uppercase text-gray-400">Étudiant</th>
                                        <th class="px-5 py-4 text-[10px] font-black uppercase text-gray-400 text-center">Note / 10</th>
                                        <th class="px-5 py-4 text-[10px] font-black uppercase text-gray-400 text-right">Date</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-50">
                                    <c:forEach var="res" items="${entry.value}" varStatus="status">
                                        <tr class="hover:bg-slate-50/50 transition-colors">
                                            <td class="px-5 py-4">
                                                <div class="flex items-center gap-3">
                                                    <span class="w-8 h-8 rounded-lg flex items-center justify-center font-black text-xs
                                                        ${status.index == 0 ? 'bg-yellow-50 text-yellow-600 border border-yellow-100' : 
                                                          status.index == 1 ? 'bg-slate-50 text-slate-500 border border-slate-100' : 
                                                          status.index == 2 ? 'bg-orange-50 text-orange-600 border border-orange-100' : 'bg-gray-50 text-gray-400'}">
                                                        ${status.index + 1}
                                                    </span>
                                                    <c:if test="${status.index == 0}"><i class="fas fa-crown text-yellow-400 text-[10px]"></i></c:if>
                                                </div>
                                            </td>
                                            <td class="px-5 py-4">
                                                <div class="font-bold text-slate-800 text-sm">${res.studentName}</div>
                                                <div class="text-[9px] text-gray-400 uppercase font-black tracking-widest mt-0.5">${res.studentId}</div>
                                            </td>
                                            <td class="px-5 py-4 text-center">
                                                <div class="inline-flex items-baseline px-3 py-1 rounded-full font-black text-sm
                                                    ${res.score >= 8 ? 'bg-green-50 text-green-600' : 
                                                      res.score >= 5 ? 'bg-blue-50 text-blue-600' : 'bg-red-50 text-red-600'}">
                                                    ${res.score}<span class="opacity-30 ml-0.5 text-[10px]">/10</span>
                                                </div>
                                            </td>
                                            <td class="px-5 py-4 text-right font-black text-[10px] text-gray-400 uppercase">
                                                <c:choose>
                                                    <c:when test="${res.dateTime != 'N/A' && fn:length(res.dateTime) >= 10}">
                                                        <c:catch var="parseExInner">
                                                            <fmt:parseDate value="${res.dateTime}" pattern="yyyy-MM-dd HH:mm:ss" var="parsedDate" type="both" />
                                                            <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm" />
                                                        </c:catch>
                                                        <c:if test="${parseExInner != null}">
                                                            ${res.dateTime}
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>Non disponible</c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty resultsByLevel}">
                    <div class="bg-white rounded-3xl border-2 border-dashed border-gray-100 p-20 text-center flex flex-col items-center">
                        <div class="w-16 h-16 bg-gray-50 rounded-full flex items-center justify-center text-gray-200 mb-4">
                            <i class="fas fa-database text-3xl"></i>
                        </div>
                        <p class="text-gray-400 font-black text-xs uppercase tracking-widest text-[10px]">Aucune donnée trouvée</p>
                    </div>
                </c:if>
            </div>
        </main>
    </div>

    <script>
        function showLevel(level, card) {
            document.querySelectorAll('.tab-content').forEach(el => {
                el.classList.add('hidden');
                el.classList.remove('flex');
            });
            document.querySelectorAll('[onclick*="showLevel"]').forEach(el => {
                el.classList.remove('border-purple-300', 'shadow-md', 'bg-purple-50');
            });
            
            const target = document.getElementById('content-' + level);
            if (target) {
                target.classList.remove('hidden');
                target.classList.add('flex');
                card.classList.add('border-purple-300', 'shadow-md');
                target.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            }
        }

        window.onload = () => {
             const globalCard = Array.from(document.querySelectorAll('[onclick*="showLevel"]'))
                .find(el => el.getAttribute('onclick').includes("'Global'"));
            if (globalCard) {
                globalCard.click();
            } else {
                const firstCard = document.querySelector('[onclick*="showLevel"]');
                if (firstCard) firstCard.click();
            }
        };
    </script>
</body>
</html>
