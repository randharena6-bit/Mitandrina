<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="fr" class="dark">
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
            darkMode: 'class',
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'system-ui', 'sans-serif'],
                    },
                    colors: {
                        danger: {
                            50: '#FEF2F2',
                            100: '#FEE2E2',
                            500: '#EF4444',
                            600: '#DC2626',
                            700: '#B91C1C',
                        },
                        dark: {
                            900: '#0F172A',
                            800: '#1E293B',
                            700: '#334155',
                        }
                    },
                    animation: {
                        'float': 'float 20s ease-in-out infinite',
                        'fade-in-up': 'fadeInUp 0.6s ease',
                    },
                    keyframes: {
                        float: {
                            '0%, 100%': { transform: 'translate(0, 0) scale(1)' },
                            '33%': { transform: 'translate(30px, -30px) scale(1.1)' },
                            '66%': { transform: 'translate(-20px, 20px) scale(0.9)' },
                        },
                        fadeInUp: {
                            from: { opacity: '0', transform: 'translateY(30px)' },
                            to: { opacity: '1', transform: 'translateY(0)' },
                        },
                    }
                }
            }
        }
    </script>
    
    <!-- Bootstrap Dark Overrides -->
    <style>
        body {
            font-family: 'Inter', sans-serif;
        }
        
        .form-control {
            background: rgba(255, 255, 255, 0.05) !important;
            border: 1px solid rgba(255, 255, 255, 0.1) !important;
            color: white !important;
        }
        
        .form-control:focus {
            background: rgba(255, 255, 255, 0.1) !important;
            border-color: #DC2626 !important;
            box-shadow: 0 0 0 0.2rem rgba(220, 38, 38, 0.25) !important;
            color: white !important;
        }
        
        .form-control::placeholder {
            color: #64748B !important;
        }
        
        .form-floating > label {
            color: #94A3B8;
        }
        
        .form-floating > .form-control:focus ~ label,
        .form-floating > .form-control:not(:placeholder-shown) ~ label {
            color: #DC2626;
        }
        
        .form-check-input:checked {
            background-color: #DC2626;
            border-color: #DC2626;
        }
        
        .form-check-input:focus {
            box-shadow: 0 0 0 0.25rem rgba(220, 38, 38, 0.25);
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center bg-gradient-to-br from-dark-900 via-dark-800 to-dark-900 relative overflow-hidden">
    
    <!-- Background Effects -->
    <div class="fixed inset-0 pointer-events-none">
        <div class="absolute -top-40 -right-40 w-96 h-96 bg-danger-600/30 rounded-full blur-[100px] animate-float"></div>
        <div class="absolute -bottom-20 -left-20 w-72 h-72 bg-blue-500/20 rounded-full blur-[100px] animate-float" style="animation-delay: -10s;"></div>
        <div class="absolute inset-0 opacity-20" style="background-image: linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px); background-size: 50px 50px;"></div>
    </div>
    
    <!-- Auth Card -->
    <div class="w-full max-w-md px-4 relative z-10">
        <div class="bg-dark-800/70 backdrop-blur-xl border border-white/10 rounded-2xl p-8 shadow-2xl animate-fade-in-up">
            
            <!-- Header -->
            <div class="text-center mb-8">
                <a href="${pageContext.request.contextPath}/" class="inline-flex items-center gap-2 text-xl font-bold text-white mb-6 hover:opacity-90 transition-opacity">
                    <span class="text-2xl">🌪️</span>
                    <span>MITANDRINA</span>
                </a>
                <h1 class="text-3xl font-bold text-white mb-2">Connexion</h1>
                <p class="text-gray-400">Accédez à votre tableau de bord de sécurité</p>
            </div>
            
            <!-- Alert Error -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger d-flex align-items-center gap-2 mb-4 py-2 px-3 rounded-lg" role="alert">
                    <i class="bi bi-exclamation-triangle-fill text-danger"></i>
                    <span class="small">${error}</span>
                </div>
            </c:if>
            
            <!-- Form -->
            <form action="${pageContext.request.contextPath}/auth/login" method="post" class="needs-validation" novalidate>
                
                <!-- Email -->
                <div class="form-floating mb-3">
                    <input 
                        type="email" 
                        class="form-control rounded-lg" 
                        id="email" 
                        name="email" 
                        placeholder="nom@exemple.com"
                        value="${param.email}"
                        required
                        autocomplete="email"
                    >
                    <label for="email">
                        <i class="bi bi-envelope me-1"></i>Adresse email
                    </label>
                    <div class="invalid-feedback">
                        Veuillez entrer une adresse email valide.
                    </div>
                </div>
                
                <!-- Password -->
                <div class="form-floating mb-4">
                    <input 
                        type="password" 
                        class="form-control rounded-lg" 
                        id="password" 
                        name="password" 
                        placeholder="Mot de passe"
                        required
                        autocomplete="current-password"
                    >
                    <label for="password">
                        <i class="bi bi-lock me-1"></i>Mot de passe
                    </label>
                    <button type="button" class="btn btn-link position-absolute end-0 top-50 translate-middle-y text-gray-400 hover:text-white" onclick="togglePassword()" style="z-index: 10;">
                        <i class="bi bi-eye" id="toggleIcon"></i>
                    </button>
                    <div class="invalid-feedback">
                        Veuillez entrer votre mot de passe.
                    </div>
                </div>
                
                <!-- Options -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="remember" name="remember" value="true">
                        <label class="form-check-label text-gray-400 text-sm" for="remember">
                            Se souvenir de moi
                        </label>
                    </div>
                    <a href="${pageContext.request.contextPath}/auth/forgot-password" class="text-danger-500 hover:text-danger-400 text-sm text-decoration-none">
                        Mot de passe oublié?
                    </a>
                </div>
                
                <!-- Submit -->
                <button type="submit" class="btn w-100 py-3 rounded-lg font-semibold text-white transition-all duration-200 hover:shadow-lg hover:-translate-y-0.5" style="background: linear-gradient(135deg, #DC2626 0%, #B91C1C 100%);">
                    <i class="bi bi-box-arrow-in-right me-2"></i>
                    Se connecter
                </button>
            </form>
            
            <!-- Footer -->
            <div class="mt-6 pt-6 border-t border-white/10 text-center">
                <p class="text-gray-400 text-sm mb-3">Pas encore de compte?</p>
                <a href="${pageContext.request.contextPath}/auth/register" class="btn btn-outline-light w-100 py-2 rounded-lg border-white/20 hover:bg-white/10 transition-all">
                    Créer un compte gratuitement
                </a>
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
