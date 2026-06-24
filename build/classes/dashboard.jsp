

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <title>The Scholarly Curator - Dashboard</title>
    <link rel="stylesheet" href="css/tailwind.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
 	<script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

</head>
<body class="bg-gray-50 text-gray-900 font-sans">
    <div class="flex min-h-screen">
        <!-- Sidebar (Inclusion d'un fragment) -->
      <%@ include file="../fragments/sidebar.jspf" %>

        <main class="flex-1 ml-64 p-8">
            <header class="mb-8">
                <h2 class="text-3xl font-black tracking-tight">Overview</h2>
                <p class="text-gray-500">Welcome to your academic curation space.</p>
            </header>

            <!-- Stats Grid -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <p class="text-gray-400 text-xs font-bold uppercase">Total Students</p>
                    <h3 class="text-2xl font-black">${stats.totalStudents}</h3>
                </div>
                <!-- Autres stats... -->
            </div>

            <!-- Table des résultats récents -->
            <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <table class="w-full text-left">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400">Student</th>
                            <th class="px-6 py-4 text-xs font-bold uppercase text-gray-400">Score</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="result" items="${recentResults}">
                            <tr class="border-t border-gray-50">
                                <td class="px-6 py-4 font-medium">${result.studentName}</td>
                                <td class="px-6 py-4 font-bold text-purple-700">${result.score}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</body>
</html>