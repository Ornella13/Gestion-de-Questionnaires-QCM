<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Login - The Scholarly Curator</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen">
    <div class="w-full max-w-md bg-white rounded-2xl shadow-xl border border-gray-100 overflow-hidden">
        <div class="h-1 bg-purple-700"></div>
        <div class="p-10">
            <div class="text-center mb-10">
                <div class="w-12 h-12 bg-purple-700 rounded-xl flex items-center justify-center mx-auto mb-4 text-white">
                    <i class="fas fa-book-open text-2xl"></i>
                </div>
                <h1 class="text-2xl font-black text-gray-900">The Scholarly Curator</h1>
                <p class="text-gray-500 text-sm">Editorial Management Portal</p>
            </div>

            <form  action="${pageContext.request.contextPath}/login" method="POST" class="space-y-6">
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">Email / ID</label>
                    <input type="text" name="username" class="w-full bg-gray-50 border-none rounded-xl py-3 px-4 focus:ring-2 focus:ring-purple-200 outline-none" placeholder="Votre identifiant">
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">Password</label>
                    <input type="password" name="password" class="w-full bg-gray-50 border-none rounded-xl py-3 px-4 focus:ring-2 focus:ring-purple-200 outline-none" placeholder="••••••••">
                </div>
                <button type="submit" class="w-full bg-purple-700 text-white font-bold py-4 rounded-xl shadow-lg hover:bg-purple-800 transition-all">
                    Login <i class="fas fa-sign-in-alt ml-2"></i>
                </button>
            </form>
        </div>
    </div>
</body>
</html>