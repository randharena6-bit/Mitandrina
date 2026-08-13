<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion - MITANDRINA</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'system-ui', 'sans-serif'],
                    },
                    colors: {
                        primary: {
                            50: '#ecfdf5',
                            100: '#d1fae5',
                            500: '#10b981',
                            600: '#059669',
                            700: '#047857',
                        },
                        danger: {
                            50: '#fef2f2',
                            500: '#ef4444',
                            600: '#dc2626',
                            700: '#b91c1c',
                        }
                    },
                    animation: {
                        'fade-in-up': 'fadeInUp 0.5s ease-out',
                    },
                    keyframes: {
                        fadeInUp: {
                            from: { opacity: '0', transform: 'translateY(20px)' },
                            to: { opacity: '1', transform: 'translateY(0)' },
                        },
                    }
                }
            }
        }
    </script>
    
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 50%, #ecfdf5 100%);
            min-height: 100vh;
        }
        
        .form-control {
            background: #f8fafc !important;
            border: 2px solid #e2e8f0 !important;
            color: #1e293b !important;
            padding: 0.875rem 1rem 0.875rem 2.75rem !important;
            border-radius: 12px !important;
            transition: all 0.2s ease !important;
        }
        
        .form-control:focus {
            background: #ffffff !important;
            border-color: #059669 !important;
            box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.1) !important;
        }
        
        .form-control::placeholder {
            color: #94a3b8 !important;
        }
        
        .form-label {
            display: block;
            color: #475569;
            font-size: 0.875rem;
            font-weight: 500;
            margin-bottom: 0.5rem;
            padding-left: 0.25rem;
        }
        
        .input-group {
            position: relative;
        }
        
        .input-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            z-index: 10;
            pointer-events: none;
        }
        
        .input-group:focus-within .input-icon {
            color: #059669;
        }
        
        .form-check-input:checked {
            background-color: #059669;
            border-color: #059669;
        }
        
        .form-check-input:focus {
            box-shadow: 0 0 0 0.25rem rgba(5, 150, 105, 0.25);
        }
        
        .btn-primary-green {
            background: #059669;
            border: none;
            color: white;
            transition: all 0.2s ease;
        }
        
        .btn-primary-green:hover {
            background: #047857;
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(5, 150, 105, 0.3);
            color: white;
        }
    </style>
    <link rel="stylesheet" href="/assets/css/custom.css?v=cf6cde8f">
</head>
<body class="flex items-center justify-center p-4">
    
    <!-- Back Link -->
    <a href="${pageContext.request.contextPath}/" class="fixed top-6 left-6 flex items-center gap-2 text-gray-500 hover:text-primary-600 font-medium transition-colors">
        <i class="bi bi-arrow-left"></i>
        Retour à l'accueil
    </a>
    
    <!-- Auth Card -->
    <div class="w-full max-w-md animate-fade-in-up">
        <div class="bg-white/80 backdrop-blur-xl rounded-2xl shadow-2xl border border-gray-100/50 p-8 transition-all hover:shadow-green-500/10">
            
            <!-- Header -->
            <div class="text-center mb-8">
                <a href="${pageContext.request.contextPath}/" class="inline-flex items-center gap-2 text-2xl font-bold text-gray-900 mb-2 hover:opacity-90 transition-opacity">
                    <i class="bi bi-shield-shaded text-danger-600"></i>
                    <span>MITANDRINA</span>
                </a>
                <h1 class="text-2xl font-bold text-gray-900 mb-1">Connexion</h1>
                <p class="text-gray-500 text-sm">Accédez à votre espace sécurisé</p>
            </div>
            
            <!-- Alert Error -->
            <c:if test="${not empty error}">
                <div class="flex items-center gap-3 p-4 mb-6 rounded-xl bg-danger-50 border border-red-200 text-red-700">
                    <i class="bi bi-exclamation-triangle-fill text-lg"></i>
                    <span class="text-sm">${error}</span>
                </div>
            </c:if>
            
            <!-- Form -->
            <form action="login" method="post" class="needs-validation" novalidate>
                
                <!-- Email -->
                <div class="mb-4">
                    <label for="email" class="form-label">Adresse email</label>
                    <div class="input-group">
                        <i class="bi bi-envelope input-icon"></i>
                        <input 
                            type="email" 
                            class="form-control" 
                            id="email" 
                            name="email" 
                            placeholder="nom@exemple.com"
                            value="${param.email}"
                            required
                            autocomplete="email"
                        >
                    </div>
                    <div class="invalid-feedback">
                        Veuillez entrer une adresse email valide.
                    </div>
                </div>
                
                <!-- Password -->
                <div class="mb-4">
                    <label for="password" class="form-label">Mot de passe</label>
                    <div class="input-group">
                        <i class="bi bi-lock input-icon"></i>
                        <input 
                            type="password" 
                            class="form-control" 
                            id="password" 
                            name="password" 
                            placeholder="Votre mot de passe"
                            required
                            autocomplete="current-password"
                        >
                        <button type="button" class="btn btn-link position-absolute end-0 top-50 translate-middle-y text-gray-400 hover:text-gray-600 px-3" onclick="togglePassword()" style="z-index: 10;">
                            <i class="bi bi-eye" id="toggleIcon"></i>
                        </button>
                    </div>
                    <div class="invalid-feedback">
                        Veuillez entrer votre mot de passe.
                    </div>
                </div>
                
                <!-- Options -->
                <div class="d-flex justify-content-between align-items-center mb-6">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="remember" name="remember" value="true">
                        <label class="form-check-label text-gray-600 text-sm" for="remember">
                            Se souvenir de moi
                        </label>
                    </div>
                    <a href="${pageContext.request.contextPath}/auth/forgot-password" class="text-primary-600 hover:text-primary-700 text-sm font-medium text-decoration-none">
                        Mot de passe oublié?
                    </a>
                </div>
                
                <!-- Submit -->
                <button type="submit" class="btn btn-primary-green w-100 py-3 rounded-xl font-semibold text-white d-flex align-items-center justify-content-center gap-2">
                    <i class="bi bi-box-arrow-in-right"></i>
                    Se connecter
                </button>
            </form>
            
            <!-- Divider -->
            <div class="relative my-6">
                <div class="absolute inset-0 flex items-center">
                    <div class="w-full border-t border-gray-200"></div>
                </div>
                <div class="relative flex justify-center text-sm">
                    <span class="px-4 bg-white text-gray-500">ou continuer avec</span>
                </div>
            </div>
            
            <!-- Social Login -->
            <div class="grid grid-cols-3 gap-3 mb-6">
                <button type="button" class="flex items-center justify-center p-3 rounded-xl border border-gray-200 hover:border-primary-500 hover:text-primary-600 transition-all bg-gray-50 hover:bg-white">
                    <i class="bi bi-google text-lg"></i>
                </button>
                <button type="button" class="flex items-center justify-center p-3 rounded-xl border border-gray-200 hover:border-primary-500 hover:text-primary-600 transition-all bg-gray-50 hover:bg-white">
                    <i class="bi bi-microsoft text-lg"></i>
                </button>
                <button type="button" class="flex items-center justify-center p-3 rounded-xl border border-gray-200 hover:border-primary-500 hover:text-primary-600 transition-all bg-gray-50 hover:bg-white">
                    <i class="bi bi-github text-lg"></i>
                </button>
            </div>
            
            <!-- Footer -->
            <div class="text-center">
                <p class="text-gray-500 text-sm">
                    Pas encore de compte? 
                    <a href="${pageContext.request.contextPath}/auth/register" class="text-primary-600 hover:text-primary-700 font-semibold text-decoration-none">
                        S'inscrire gratuitement
                    </a>
                </p>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Toggle password visibility
        function togglePassword() {
            const input = document.getElementById('password');
            const icon = document.getElementById('toggleIcon');
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('bi-eye');
                icon.classList.add('bi-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('bi-eye-slash');
                icon.classList.add('bi-eye');
            }
        }
        
        // Bootstrap form validation
        (function () {
            'use strict'
            
            var forms = document.querySelectorAll('.needs-validation')
            
            Array.prototype.slice.call(forms)
                .forEach(function (form) {
                    form.addEventListener('submit', function (event) {
                        if (!form.checkValidity()) {
                            event.preventDefault()
                            event.stopPropagation()
                        }
                        
                        form.classList.add('was-validated')
                    }, false)
                })
        })()
    </script>
</body>
</html>
