<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="fr" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="${pageDescription != null ? pageDescription : 'MITANDRINA - Plateforme IA de prédiction et gestion des catastrophes naturelles'}">
    
    <title>${pageTitle != null ? pageTitle : 'MITANDRINA'} 🌪️</title>
    
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
    
    <!-- Tailwind Config MITANDRINA Theme -->
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['Inter', 'system-ui', 'sans-serif'],
                    },
                    colors: {
                        // Emergency Color Palette
                        danger: {
                            50: '#FEF2F2',
                            100: '#FEE2E2',
                            200: '#FECACA',
                            300: '#FCA5A5',
                            400: '#F87171',
                            500: '#EF4444',
                            600: '#DC2626',
                            700: '#B91C1C',
                            800: '#991B1B',
                            900: '#7F1D1D',
                        },
                        warning: {
                            50: '#FFFBEB',
                            100: '#FEF3C7',
                            500: '#F59E0B',
                            600: '#D97706',
                            700: '#B45309',
                        },
                        info: {
                            500: '#3B82F6',
                            600: '#2563EB',
                        },
                        success: {
                            500: '#10B981',
                        },
                        // Glassmorphism colors
                        glass: {
                            bg: 'rgba(30, 41, 59, 0.7)',
                            border: 'rgba(255, 255, 255, 0.1)',
                            light: 'rgba(255, 255, 255, 0.05)',
                        },
                        // Dark theme
                        dark: {
                            900: '#0F172A',
                            800: '#1E293B',
                            700: '#334155',
                        }
                    },
                    backdropBlur: {
                        glass: '12px',
                    },
                    animation: {
                        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
                        'float': 'float 20s ease-in-out infinite',
                        'slide-down': 'slideDown 0.5s ease',
                        'fade-in-up': 'fadeInUp 0.6s ease',
                    },
                    keyframes: {
                        float: {
                            '0%, 100%': { transform: 'translate(0, 0) scale(1)' },
                            '33%': { transform: 'translate(30px, -30px) scale(1.1)' },
                            '66%': { transform: 'translate(-20px, 20px) scale(0.9)' },
                        },
                        slideDown: {
                            from: { transform: 'translateY(-100%)' },
                            to: { transform: 'translateY(0)' },
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
    
    <!-- Custom Styles for Glassmorphism + Bootstrap Overrides -->
    <style type="text/tailwindcss">
        @layer base {
            body {
                @apply bg-dark-900 text-white font-sans antialiased;
            }
        }
        
        @layer components {
            .glass {
                @apply bg-glass-bg backdrop-blur-glass border border-glass-border rounded-xl;
            }
            
            .glass-card {
                @apply glass p-6 transition-all duration-300 hover:border-white/20;
            }
            
            .btn-emergency {
                @apply bg-gradient-to-r from-danger-600 to-danger-700 text-white font-semibold 
                       px-6 py-3 rounded-lg transition-all duration-200 
                       hover:shadow-[0_0_20px_rgba(220,38,38,0.5)] hover:-translate-y-0.5
                       focus:outline-none focus:ring-2 focus:ring-danger-500 focus:ring-offset-2 focus:ring-offset-dark-900;
            }
            
            .gradient-text {
                @apply bg-gradient-to-r from-danger-500 to-warning-500 bg-clip-text text-transparent;
            }
            
            .nav-link-glass {
                @apply text-gray-400 hover:text-white transition-colors relative py-2;
            }
            
            .nav-link-glass::after {
                @apply content-[''] absolute bottom-0 left-0 w-0 h-0.5 bg-danger-500 transition-all duration-300;
            }
            
            .nav-link-glass:hover::after {
                @apply w-full;
            }
        }
        
        @layer utilities {
            .text-shadow {
                text-shadow: 0 2px 4px rgba(0,0,0,0.3);
            }
            
            .animation-delay-2000 {
                animation-delay: 2s;
            }
            
            .animation-delay-4000 {
                animation-delay: 4s;
            }
        }
    </style>
    
    <!-- Bootstrap Dark Theme Overrides -->
    <style>
        /* Override Bootstrap for dark theme */
        .bg-dark { background-color: #0F172A !important; }
        .bg-dark-800 { background-color: #1E293B !important; }
        .text-white { color: #F9FAFB !important; }
        
        /* Form controls dark */
        .form-control, .form-select {
            background-color: rgba(255, 255, 255, 0.05) !important;
            border-color: rgba(255, 255, 255, 0.1) !important;
            color: white !important;
        }
        
        .form-control:focus, .form-select:focus {
            background-color: rgba(255, 255, 255, 0.1) !important;
            border-color: #DC2626 !important;
            box-shadow: 0 0 0 0.2rem rgba(220, 38, 38, 0.25) !important;
            color: white !important;
        }
        
        .form-control::placeholder {
            color: #64748B !important;
        }
        
        /* Card dark */
        .card {
            background-color: rgba(30, 41, 59, 0.7) !important;
            border-color: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(12px);
        }
        
        /* Modal dark */
        .modal-content {
            background-color: #1E293B !important;
            border-color: rgba(255, 255, 255, 0.1) !important;
        }
        
        /* Table dark */
        .table-dark {
            --bs-table-bg: transparent;
            --bs-table-color: white;
            --bs-table-border-color: rgba(255, 255, 255, 0.1);
        }
        
        /* Dropdown dark */
        .dropdown-menu {
            background-color: #1E293B !important;
            border-color: rgba(255, 255, 255, 0.1) !important;
        }
        
        .dropdown-item {
            color: #F9FAFB !important;
        }
        
        .dropdown-item:hover {
            background-color: rgba(255, 255, 255, 0.1) !important;
        }
        
        /* Pagination dark */
        .page-link {
            background-color: rgba(255, 255, 255, 0.05) !important;
            border-color: rgba(255, 255, 255, 0.1) !important;
            color: #F9FAFB !important;
        }
        
        .page-link:hover {
            background-color: rgba(255, 255, 255, 0.1) !important;
            border-color: rgba(255, 255, 255, 0.2) !important;
        }
        
        .page-item.active .page-link {
            background-color: #DC2626 !important;
            border-color: #DC2626 !important;
        }
        
        /* Alert overrides with glassmorphism */
        .alert-danger {
            background: linear-gradient(135deg, rgba(220, 38, 38, 0.3) 0%, rgba(220, 38, 38, 0.1) 100%) !important;
            border-color: #DC2626 !important;
            color: white !important;
        }
        
        .alert-warning {
            background: linear-gradient(135deg, rgba(245, 158, 11, 0.3) 0%, rgba(245, 158, 11, 0.1) 100%) !important;
            border-color: #F59E0B !important;
            color: white !important;
        }
        
        .alert-info {
            background: linear-gradient(135deg, rgba(59, 130, 246, 0.3) 0%, rgba(59, 130, 246, 0.1) 100%) !important;
            border-color: #3B82F6 !important;
            color: white !important;
        }
    </style>
    
    <!-- JSP-specific styles -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/tailwind-custom.css">
    
    <jsp:invoke fragment="extraHead"/>
</head>
<body class="min-h-screen bg-gradient-to-br from-dark-900 via-dark-800 to-dark-900">
    
    <!-- Emergency Banner -->
    <jsp:invoke fragment="emergencyBanner"/>
    
    <!-- Navigation -->
    <nav class="fixed top-0 left-0 right-0 z-50 glass">
        <div class="container mx-auto px-4">
            <div class="flex items-center justify-between h-16">
                <!-- Brand -->
                <a href="${pageContext.request.contextPath}/" class="flex items-center gap-2 text-xl font-bold tracking-tight hover:opacity-90 transition-opacity">
                    <span class="text-2xl">🌪️</span>
                    <span class="hidden sm:inline">MITANDRINA</span>
                </a>
                
                <!-- Navigation Links -->
                <div class="hidden md:flex items-center gap-8">
                    <a href="#features" class="nav-link-glass text-sm font-medium">Fonctionnalités</a>
                    <a href="#map-section" class="nav-link-glass text-sm font-medium">Carte temps réel</a>
                    <a href="#how-it-works" class="nav-link-glass text-sm font-medium">Comment ça marche</a>
                </div>
                
                <!-- Actions -->
                <div class="flex items-center gap-3">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <a href="${pageContext.request.contextPath}/dashboard" class="btn-emergency py-2 px-4 text-sm">
                                <i class="bi bi-speedometer2 me-2"></i>
                                Dashboard
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/auth/login" class="text-gray-300 hover:text-white text-sm font-medium transition-colors px-3 py-2">
                                Connexion
                            </a>
                            <a href="${pageContext.request.contextPath}/auth/register" class="btn-emergency py-2 px-4 text-sm">
                                S'inscrire
                            </a>
                        </c:otherwise>
                    </c:choose>
                    
                    <!-- Mobile Menu Button -->
                    <button class="md:hidden p-2 text-gray-300 hover:text-white" type="button" data-bs-toggle="offcanvas" data-bs-target="#mobileMenu">
                        <i class="bi bi-list text-xl"></i>
                    </button>
                </div>
            </div>
        </div>
    </nav>
    
    <!-- Mobile Offcanvas Menu -->
    <div class="offcanvas offcanvas-end bg-dark-800 border-glass-border" tabindex="-1" id="mobileMenu">
        <div class="offcanvas-header border-b border-white/10">
            <h5 class="offcanvas-title text-white font-bold">🌪️ MITANDRINA</h5>
            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="offcanvas"></button>
        </div>
        <div class="offcanvas-body">
            <div class="flex flex-col gap-4">
                <a href="#features" class="text-gray-300 hover:text-white py-2">Fonctionnalités</a>
                <a href="#map-section" class="text-gray-300 hover:text-white py-2">Carte temps réel</a>
                <a href="#how-it-works" class="text-gray-300 hover:text-white py-2">Comment ça marche</a>
                <hr class="border-white/10">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn-emergency text-center">
                            <i class="bi bi-speedometer2 me-2"></i>Dashboard
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/auth/login" class="btn btn-outline-light w-100">
                            Connexion
                        </a>
                        <a href="${pageContext.request.contextPath}/auth/register" class="btn-emergency text-center">
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
    <footer class="border-t border-white/10 mt-20">
        <div class="container mx-auto px-4 py-12">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
                <!-- Brand -->
                <div class="md:col-span-1">
                    <div class="flex items-center gap-2 mb-4">
                        <span class="text-2xl">🌪️</span>
                        <span class="font-bold text-lg">MITANDRINA</span>
                    </div>
                    <p class="text-gray-400 text-sm">Protection par l'intelligence artificielle</p>
                </div>
                
                <!-- Links -->
                <div>
                    <h4 class="font-semibold mb-4 text-white">Navigation</h4>
                    <div class="flex flex-col gap-2">
                        <a href="${pageContext.request.contextPath}/map" class="text-gray-400 hover:text-danger-400 text-sm transition-colors">Carte des risques</a>
                        <a href="${pageContext.request.contextPath}/alerts" class="text-gray-400 hover:text-danger-400 text-sm transition-colors">Alertes</a>
                        <a href="${pageContext.request.contextPath}/evacuation" class="text-gray-400 hover:text-danger-400 text-sm transition-colors">Évacuation</a>
                    </div>
                </div>
                
                <div>
                    <h4 class="font-semibold mb-4 text-white">Ressources</h4>
                    <div class="flex flex-col gap-2">
                        <a href="#" class="text-gray-400 hover:text-danger-400 text-sm transition-colors">Guide d'utilisation</a>
                        <a href="#" class="text-gray-400 hover:text-danger-400 text-sm transition-colors">API Documentation</a>
                        <a href="#" class="text-gray-400 hover:text-danger-400 text-sm transition-colors">Open Source</a>
                    </div>
                </div>
                
                <div>
                    <h4 class="font-semibold mb-4 text-white">Légal</h4>
                    <div class="flex flex-col gap-2">
                        <a href="#" class="text-gray-400 hover:text-danger-400 text-sm transition-colors">Mentions légales</a>
                        <a href="#" class="text-gray-400 hover:text-danger-400 text-sm transition-colors">Confidentialité</a>
                    </div>
                </div>
            </div>
            
            <div class="border-t border-white/10 mt-8 pt-8 text-center">
                <p class="text-gray-500 text-sm">&copy; 2024 MITANDRINA. Tous droits réservés.</p>
                <p class="text-gray-600 text-xs mt-2">Built with ❤️ using FastAPI + Node.js + Java/JSP + Tailwind + Bootstrap</p>
            </div>
        </div>
    </footer>
    
    <!-- Scripts -->
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Leaflet -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    
    <!-- Main JS -->
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    
    <jsp:invoke fragment="extraScripts"/>
</body>
</html>
