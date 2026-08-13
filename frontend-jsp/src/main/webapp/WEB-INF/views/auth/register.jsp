<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inscription - MITANDRINA</title>
    
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
    <link rel="stylesheet" href="/assets/css/custom.css?v=ca1a4a0f">
</head>
<body class="flex items-center justify-center p-4">
    
    <!-- Back Link -->
    <a href="${pageContext.request.contextPath}/" class="fixed top-6 left-6 flex items-center gap-2 text-gray-500 hover:text-primary-600 font-medium transition-colors">
        <i class="bi bi-arrow-left"></i>
        Retour à l'accueil
    </a>
    
    <!-- Auth Card -->
    <div class="w-full max-w-lg animate-fade-in-up py-8">
        <div class="bg-white/80 backdrop-blur-xl rounded-2xl shadow-2xl border border-gray-100/50 p-8 transition-all hover:shadow-green-500/10">
            
            <!-- Header -->
            <div class="text-center mb-8">
                <a href="${pageContext.request.contextPath}/" class="inline-flex items-center gap-2 text-2xl font-bold text-gray-900 mb-2 hover:opacity-90 transition-opacity">
                    <i class="bi bi-shield-shaded text-danger-600"></i>
                    <span>MITANDRINA</span>
                </a>
                <h1 class="text-2xl font-bold text-gray-900 mb-1">Créer un compte</h1>
                <p class="text-gray-500 text-sm">Rejoignez la plateforme d'alerte et de protection</p>
            </div>
            
            <!-- Alert Error -->
            <c:if test="${not empty error}">
                <div class="flex items-center gap-3 p-4 mb-6 rounded-xl bg-danger-50 border border-red-200 text-red-700">
                    <i class="bi bi-exclamation-triangle-fill text-lg"></i>
                    <span class="text-sm">${error}</span>
                </div>
            </c:if>
            
            <!-- Form -->
            <form action="${pageContext.request.contextPath}/auth/register" method="post" class="needs-validation" novalidate>
                
                <div class="row">
                    <!-- First Name -->
                    <div class="col-md-6 mb-4">
                        <label for="firstName" class="form-label">Prénom</label>
                        <div class="input-group">
                            <i class="bi bi-person input-icon"></i>
                            <input 
                                type="text" 
                                class="form-control" 
                                id="firstName" 
                                name="firstName" 
                                placeholder="Votre prénom"
                                value="${param.firstName}"
                                required
                            >
                        </div>
                        <div class="invalid-feedback">
                            Veuillez entrer votre prénom.
                        </div>
                    </div>
                    
                    <!-- Last Name -->
                    <div class="col-md-6 mb-4">
                        <label for="lastName" class="form-label">Nom</label>
                        <div class="input-group">
                            <i class="bi bi-person-fill input-icon"></i>
                            <input 
                                type="text" 
                                class="form-control" 
                                id="lastName" 
                                name="lastName" 
                                placeholder="Votre nom"
                                value="${param.lastName}"
                                required
                            >
                        </div>
                        <div class="invalid-feedback">
                            Veuillez entrer votre nom.
                        </div>
                    </div>
                </div>
                
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
                
                <!-- Phone Number -->
                <div class="mb-4">
                    <label for="phoneNumber" class="form-label">Numéro de téléphone</label>
                    <div class="input-group">
                        <i class="bi bi-telephone input-icon"></i>
                        <input 
                            type="tel" 
                            class="form-control" 
                            id="phoneNumber" 
                            name="phoneNumber" 
                            placeholder="+261 34 00 000 00"
                            value="${param.phoneNumber}"
                            required
                        >
                    </div>
                    <div class="invalid-feedback">
                        Veuillez entrer un numéro de téléphone valide.
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
                            placeholder="Créer un mot de passe fort"
                            required
                            autocomplete="new-password"
                        >
                        <button type="button" class="btn btn-link position-absolute end-0 top-50 translate-middle-y text-gray-400 hover:text-gray-600 px-3" onclick="togglePassword()" style="z-index: 10;">
                            <i class="bi bi-eye" id="toggleIcon"></i>
                        </button>
                    </div>
                    <div class="invalid-feedback">
                        Veuillez entrer un mot de passe.
                    </div>
                </div>
                
                <!-- Submit -->
                <button type="submit" class="btn btn-primary-green w-100 py-3 rounded-xl font-semibold text-white d-flex align-items-center justify-content-center gap-2 mt-4">
                    <i class="bi bi-person-plus-fill"></i>
                    Créer mon compte
                </button>
            </form>
            
            <!-- Footer -->
            <div class="text-center mt-6">
                <p class="text-gray-500 text-sm">
                    Vous avez déjà un compte? 
                    <a href="${pageContext.request.contextPath}/auth/login" class="text-primary-600 hover:text-primary-700 font-semibold text-decoration-none">
                        Se connecter
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
