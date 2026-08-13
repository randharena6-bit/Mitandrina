<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="${pageDescription != null ? pageDescription : 'MITANDRINA - Plateforme IA de prédiction et gestion des catastrophes naturelles'}">
    
    <title>${pageTitle != null ? pageTitle : 'MITANDRINA'}</title>
    
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Leaflet Maps -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    
    <!-- Tailwind Config MITANDRINA Light Theme -->
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
                            200: '#a7f3d0',
                            300: '#6ee7b7',
                            400: '#34d399',
                            500: '#10b981',
                            600: '#059669',
                            700: '#047857',
                            800: '#065f46',
                            900: '#064e3b',
                        },
                        danger: {
                            50: '#fef2f2',
                            100: '#fee2e2',
                            200: '#fecaca',
                            300: '#fca5a5',
                            400: '#f87171',
                            500: '#ef4444',
                            600: '#dc2626',
                            700: '#b91c1c',
                            800: '#991b1b',
                            900: '#7f1d1d',
                        },
                        warning: {
                            50: '#fffbeb',
                            100: '#fef3c7',
                            500: '#f59e0b',
                            600: '#d97706',
                            700: '#b45309',
                        },
                        info: {
                            50: '#eff6ff',
                            500: '#3b82f6',
                            600: '#2563eb',
                        },
                        success: {
                            50: '#ecfdf5',
                            500: '#10b981',
                        },
                        gray: {
                            50: '#f8fafc',
                            100: '#f1f5f9',
                            200: '#e2e8f0',
                            300: '#cbd5e1',
                            400: '#94a3b8',
                            500: '#64748b',
                            600: '#475569',
                            700: '#334155',
                            800: '#1e293b',
                            900: '#0f172a',
                        }
                    },
                    animation: {
                        'fade-in-up': 'fadeInUp 0.5s ease-out',
                        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
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
    
    <style type="text/tailwindcss">
        @layer base {
            body {
                @apply bg-gray-50 text-gray-800 font-sans antialiased;
            }
            
            h1, h2, h3, h4, h5, h6 {
                @apply text-gray-900;
            }
        }
        
        @layer components {
            .card-modern {
                @apply bg-white border border-gray-200 rounded-2xl shadow-sm transition-all duration-200;
            }
            
            .card-modern:hover {
                @apply shadow-md;
            }
            
            .btn-primary-green {
                @apply bg-primary-600 text-white font-semibold 
                       px-6 py-3 rounded-xl transition-all duration-200;
            }
            
            .btn-primary-green:hover {
                @apply bg-primary-700 shadow-lg shadow-primary-600/25 -translate-y-0.5;
            }
            
            .nav-link-modern {
                @apply text-gray-500 hover:text-primary-600 transition-colors relative py-2 font-medium;
            }
            
            .nav-link-modern::after {
                @apply content-[''] absolute bottom-0 left-0 w-0 h-0.5 bg-primary-500 transition-all duration-300;
            }
            
            .nav-link-modern:hover::after {
                @apply w-full;
            }
        }
    </style>
    
    <!-- Bootstrap Light Theme Overrides -->
    <style>
        .form-control, .form-select {
            background-color: #f8fafc !important;
            border: 2px solid #e2e8f0 !important;
            color: #1e293b !important;
            border-radius: 12px !important;
        }
        
        .form-control:focus, .form-select:focus {
            background-color: #ffffff !important;
            border-color: #059669 !important;
            box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.1) !important;
            color: #1e293b !important;
        }
        
        .form-control::placeholder {
            color: #94a3b8 !important;
        }
        
        .card {
            background-color: #ffffff !important;
            border: 1px solid #e2e8f0 !important;
            border-radius: 16px !important;
        }
        
        .modal-content {
            background-color: #ffffff !important;
            border: 1px solid #e2e8f0 !important;
        }
        
        .dropdown-menu {
            background-color: #ffffff !important;
            border: 1px solid #e2e8f0 !important;
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1) !important;
        }
        
        .dropdown-item {
            color: #1e293b !important;
        }
        
        .dropdown-item:hover {
            background-color: #ecfdf5 !important;
            color: #059669 !important;
        }
        
        .page-link {
            background-color: #ffffff !important;
            border-color: #e2e8f0 !important;
            color: #64748b !important;
        }
        
        .page-link:hover {
            background-color: #ecfdf5 !important;
            border-color: #059669 !important;
            color: #059669 !important;
        }
        
        .page-item.active .page-link {
            background-color: #059669 !important;
            border-color: #059669 !important;
            color: #ffffff !important;
        }
        
        .alert-danger {
            background: #fef2f2 !important;
            border-color: #fca5a5 !important;
            color: #991b1b !important;
        }
        
        .alert-warning {
            background: #fffbeb !important;
            border-color: #fcd34d !important;
            color: #92400e !important;
        }
        
        .alert-info {
            background: #eff6ff !important;
            border-color: #93c5fd !important;
            color: #1e40af !important;
        }
        
        .alert-success {
            background: #ecfdf5 !important;
            border-color: #86efac !important;
            color: #166534 !important;
        }
        
        .table {
            --bs-table-bg: transparent;
            --bs-table-color: #1e293b;
            --bs-table-border-color: #e2e8f0;
        }
        
        .table thead th {
            background: #f8fafc !important;
            color: #475569 !important;
            font-weight: 600;
        }
    </style>
    
    <jsp:invoke fragment="extraHead"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/custom.css">
    <link rel="stylesheet" href="/assets/css/custom.css?v=27a984f3">
</head>
<body class="min-h-screen">
    
    <!-- Emergency Banner -->
    <jsp:invoke fragment="emergencyBanner"/>
    
    <!-- Navigation -->
    <nav class="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-100">
        <div class="container mx-auto px-4">
            <div class="flex items-center justify-between h-16">
                <!-- Brand -->
                <a href="/" class="flex items-center gap-2 text-xl font-bold tracking-tight hover:opacity-90 transition-opacity text-gray-900">
                    <i class="bi bi-shield-shaded text-danger-600 text-2xl"></i>
                    <span class="hidden sm:inline">MITANDRINA</span>
                </a>
                
                <!-- Navigation Links -->
                <div class="hidden md:flex items-center gap-8">
                    <a href="#features" class="nav-link-modern text-sm">Fonctionnalités</a>
                    <a href="#map-section" class="nav-link-modern text-sm">Carte temps réel</a>
                    <a href="#how-it-works" class="nav-link-modern text-sm">Comment ça marche</a>
                </div>
                
                <!-- Actions -->
                <div class="flex items-center gap-3">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <a href="/dashboard" class="btn-primary-green py-2 px-4 text-sm flex items-center gap-2">
                                <i class="bi bi-grid-1x2-fill"></i>
                                Dashboard
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="/auth/login" class="text-gray-500 hover:text-primary-600 text-sm font-medium transition-colors px-3 py-2">
                                Connexion
                            </a>
                            <a href="/auth/register" class="btn-primary-green py-2 px-4 text-sm">
                                S'inscrire
                            </a>
                        </c:otherwise>
                    </c:choose>
                    
                    <!-- Mobile Menu Button -->
                    <button class="md:hidden p-2 text-gray-500 hover:text-primary-600" type="button" data-bs-toggle="offcanvas" data-bs-target="#mobileMenu">
                        <i class="bi bi-list text-xl"></i>
                    </button>
                </div>
            </div>
        </div>
    </nav>
    
    <!-- Mobile Offcanvas Menu -->
    <div class="offcanvas offcanvas-end" tabindex="-1" id="mobileMenu" style="background: #ffffff; border-left: 1px solid #e2e8f0;">
        <div class="offcanvas-header border-b border-gray-100">
            <h5 class="offcanvas-title font-bold text-gray-900 flex items-center gap-2">
                <i class="bi bi-shield-shaded text-danger-600"></i>
                MITANDRINA
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
        </div>
        <div class="offcanvas-body">
            <div class="flex flex-col gap-4">
                <a href="#features" class="text-gray-600 hover:text-primary-600 py-2 font-medium">Fonctionnalités</a>
                <a href="#map-section" class="text-gray-600 hover:text-primary-600 py-2 font-medium">Carte temps réel</a>
                <a href="#how-it-works" class="text-gray-600 hover:text-primary-600 py-2 font-medium">Comment ça marche</a>
                <hr class="border-gray-100">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <a href="/dashboard" class="btn-primary-green text-center text-sm py-3">
                            <i class="bi bi-grid-1x2-fill me-2"></i>Dashboard
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="/auth/login" class="btn btn-outline-secondary w-100 py-2">
                            Connexion
                        </a>
                        <a href="/auth/register" class="btn-primary-green text-center text-sm py-3">
                            S'inscrire
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
    
    <!-- Main Content -->
    <main class="pt-16">
        <jsp:invoke fragment="content"/>
    </main>
    
    <!-- Footer -->
    <footer class="border-t border-gray-100 mt-20 bg-white">
        <div class="container mx-auto px-4 py-12">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
                <!-- Brand -->
                <div class="md:col-span-1">
                    <div class="flex items-center gap-2 mb-4">
                        <i class="bi bi-shield-shaded text-danger-600 text-2xl"></i>
                        <span class="font-bold text-lg text-gray-900">MITANDRINA</span>
                    </div>
                    <p class="text-gray-500 text-sm">Protection par l'intelligence artificielle</p>
                </div>
                
                <!-- Links -->
                <div>
                    <h4 class="font-semibold mb-4 text-gray-900">Navigation</h4>
                    <div class="flex flex-col gap-2">
                        <a href="/map" class="text-gray-500 hover:text-primary-600 text-sm transition-colors">Carte des risques</a>
                        <a href="/cyclone-map" class="text-gray-500 hover:text-primary-600 text-sm transition-colors">Carte des cyclones</a>
                        <a href="/alerts" class="text-gray-500 hover:text-primary-600 text-sm transition-colors">Alertes</a>
                        <a href="/evacuation" class="text-gray-500 hover:text-primary-600 text-sm transition-colors">Évacuation</a>
                    </div>
                </div>
                
                <div>
                    <h4 class="font-semibold mb-4 text-gray-900">Ressources</h4>
                    <div class="flex flex-col gap-2">
                        <a href="#" class="text-gray-500 hover:text-primary-600 text-sm transition-colors">Guide d'utilisation</a>
                        <a href="#" class="text-gray-500 hover:text-primary-600 text-sm transition-colors">API Documentation</a>
                        <a href="#" class="text-gray-500 hover:text-primary-600 text-sm transition-colors">Open Source</a>
                    </div>
                </div>
                
                <div>
                    <h4 class="font-semibold mb-4 text-gray-900">Légal</h4>
                    <div class="flex flex-col gap-2">
                        <a href="#" class="text-gray-500 hover:text-primary-600 text-sm transition-colors">Mentions légales</a>
                        <a href="#" class="text-gray-500 hover:text-primary-600 text-sm transition-colors">Confidentialité</a>
                    </div>
                </div>
            </div>
            
            <div class="border-t border-gray-100 mt-8 pt-8 text-center">
                <p class="text-gray-400 text-sm">&copy; 2024 MITANDRINA. Tous droits réservés.</p>
                <p class="text-gray-300 text-xs mt-2">Built with FastAPI + Node.js + Java/JSP + Tailwind + Bootstrap</p>
            </div>
        </div>
    </footer>
    
    <!-- Scripts -->
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Leaflet -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    
    <!-- Main JS -->
    <script src="/assets/js/main.js"></script>
    
    <jsp:invoke fragment="extraScripts"/>
</body>
</html>
