<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - MITANDRINA</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Leaflet Maps -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { 
                        sans: ['Inter', 'system-ui', 'sans-serif'] 
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
                        },
                        warning: { 
                            50: '#fffbeb',
                            500: '#f59e0b',
                            600: '#d97706' 
                        },
                        info: { 
                            50: '#eff6ff',
                            500: '#3b82f6',
                            600: '#2563eb' 
                        },
                        success: { 
                            50: '#ecfdf5',
                            500: '#10b981',
                            600: '#059669' 
                        },
                    }
                }
            }
        }
    </script>
    
    <style>
        body { 
            font-family: 'Inter', sans-serif;
            background: #f8fafc;
        }
        
        .sidebar { 
            width: 280px;
            background: #ffffff;
            border-right: 1px solid #e2e8f0;
        }
        
        @media (max-width: 768px) { 
            .sidebar { 
                transform: translateX(-100%); 
                position: fixed;
                z-index: 50;
                box-shadow: 4px 0 24px rgba(0,0,0,0.1);
            } 
            .sidebar.open { 
                transform: translateX(0); 
            } 
            .main-content { 
                margin-left: 0 !important; 
            } 
        }
        
        .nav-item {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem 1rem;
            border-radius: 10px;
            color: #64748b;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.9rem;
            transition: all 0.2s ease;
            margin-bottom: 0.25rem;
        }
        
        .nav-item:hover {
            background: #ecfdf5;
            color: #047857;
        }
        
        .nav-item.active {
            background: #ecfdf5;
            color: #047857;
            font-weight: 600;
        }
        
        .card-modern {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        
        .card-modern:hover {
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
            transform: translateY(-2px);
        }

        .animate-fade-in-up { animation: fadeInUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; opacity: 0; }
        .delay-100 { animation-delay: 100ms; }
        .delay-200 { animation-delay: 200ms; }
        .delay-300 { animation-delay: 300ms; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        
        .stat-icon-green { background: #ecfdf5; color: #047857; }
        .stat-icon-amber { background: #fffbeb; color: #d97706; }
        .stat-icon-blue { background: #eff6ff; color: #2563eb; }
        .stat-icon-red { background: #fef2f2; color: #dc2626; }
        .stat-icon-purple { background: #f5f3ff; color: #7c3aed; }
        .stat-icon-teal { background: #f0fdfa; color: #0d9488; }
        
        .btn-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: white;
            border: 1px solid #e2e8f0;
            color: #64748b;
            transition: all 0.2s ease;
        }
        
        .btn-icon:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
            color: #1e293b;
        }
        
        .alert-banner {
            background: linear-gradient(135deg, #fef2f2 0%, #fff1f2 100%);
            border: 1px solid rgba(220, 53, 69, 0.2);
        }
        
        .user-avatar {
            background: #059669;
        }

        .stat-trend-up { color: #059669; }
        .stat-trend-down { color: #dc2626; }

        .activity-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            border: 2px solid white;
            box-shadow: 0 0 0 2px #e2e8f0;
        }

        .progress-bar-slim {
            height: 4px;
            border-radius: 2px;
            background: #e2e8f0;
            overflow: hidden;
        }
        .progress-bar-slim > div {
            height: 100%;
            border-radius: 2px;
            transition: width 0.6s ease;
        }

        .status-pulse {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #10b981;
            animation: pulse-dot 2s ease-in-out infinite;
        }
        @keyframes pulse-dot {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.4; }
        }
    </style>
    <link rel="stylesheet" href="/assets/css/custom.css?v=162c54ff">
</head>
<body class="min-h-screen flex">
    
    <!-- Mobile Overlay -->
    <div class="fixed inset-0 bg-black/50 z-40 hidden md:hidden" id="sidebarOverlay" onclick="toggleSidebar()"></div>
    
    <!-- Sidebar -->
    <aside class="sidebar fixed top-0 left-0 bottom-0 z-50 transition-transform" id="sidebar">
        <div class="flex flex-col h-full">
            <!-- Brand -->
            <div class="p-6 border-b border-gray-100">
                <a href="./" class="flex items-center gap-2 text-xl font-bold text-gray-900">
                    <i class="bi bi-shield-shaded text-danger-600"></i>
                    <span class="hidden lg:inline">MITANDRINA</span>
                </a>
            </div>
            
            <!-- Navigation -->
            <nav class="flex-1 overflow-y-auto py-4 px-3">
                <div class="px-3 mb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">Principal</div>
                
                <a href="dashboard" class="nav-item active">
                    <i class="bi bi-grid-1x2-fill text-lg"></i>
                    <span>Tableau de bord</span>
                </a>
                
                <a href="./map" class="nav-item">
                    <i class="bi bi-map-fill text-lg"></i>
                    <span>Carte des risques</span>
                </a>
                
                <a href="./cyclone-map" class="nav-item">
                    <i class="bi bi-tornado text-lg"></i>
                    <span>Carte des cyclones</span>
                </a>
                
                <a href="./alerts" class="nav-item">
                    <i class="bi bi-bell-fill text-lg"></i>
                    <span>Alertes</span>
                    <c:if test="${unreadAlerts > 0}">
                        <span class="ml-auto bg-danger-600 text-white text-xs px-2 py-0.5 rounded-full font-semibold">${unreadAlerts}</span>
                    </c:if>
                </a>
                
                <a href="./incidents" class="nav-item">
                    <i class="bi bi-geo-alt-fill text-lg"></i>
                    <span>Incidents</span>
                </a>
                
                <a href="./evacuation" class="nav-item">
                    <i class="bi bi-car-front-fill text-lg"></i>
                    <span>Évacuation</span>
                </a>
                
                <c:if test="${sessionScope.user.role == 'administrateur'}">
                    <div class="px-3 mt-6 mb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">Administration</div>
                    
                    <a href="./admin/users" class="nav-item">
                        <i class="bi bi-people-fill text-lg"></i>
                        <span>Utilisateurs</span>
                    </a>
                    
                    <a href="./admin/teams" class="nav-item">
                        <i class="bi bi-building-fill text-lg"></i>
                        <span>Équipes</span>
                    </a>
                    
                    <a href="./admin/simulations" class="nav-item">
                        <i class="bi bi-magic text-lg"></i>
                        <span>Simulations</span>
                    </a>
                </c:if>
            </nav>
            
            <!-- User Card -->
            <div class="p-4 border-t border-gray-100">
                <div class="flex items-center gap-3 mb-3 p-3 bg-gray-50 rounded-xl">
                    <div class="w-10 h-10 rounded-full user-avatar flex items-center justify-center font-semibold text-white text-sm">
                        ${sessionScope.user.firstName.charAt(0)}${sessionScope.user.lastName.charAt(0)}
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-sm font-semibold text-gray-900 truncate">${sessionScope.user.firstName} ${sessionScope.user.lastName}</p>
                        <p class="text-xs text-gray-500 capitalize">${sessionScope.user.role}</p>
                    </div>
                </div>
                <a href="./auth/logout" class="flex items-center justify-center gap-2 w-full py-2.5 rounded-xl border border-gray-200 text-gray-600 font-medium hover:bg-primary-50 hover:border-primary-200 hover:text-primary-700 transition-all text-sm">
                    <i class="bi bi-box-arrow-right"></i>
                    Déconnexion
                </a>
            </div>
        </div>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content flex-1 ml-[280px]">
        <!-- Top Bar -->
        <header class="sticky top-0 z-30 bg-white/80 backdrop-blur-md border-b border-gray-100 h-16 flex items-center justify-between px-6">
            <div class="flex items-center gap-4">
                <button class="md:hidden btn-icon" onclick="toggleSidebar()">
                    <i class="bi bi-list text-xl"></i>
                </button>
                <div>
                    <h1 class="text-xl font-bold text-gray-900">Tableau de bord</h1>
                    <p class="text-xs text-gray-500">Bienvenue, ${sessionScope.user.firstName}</p>
                </div>
            </div>
            
            <div class="flex items-center gap-3">
                <!-- Last updated -->
                <div class="hidden sm:flex items-center gap-1.5 text-xs text-gray-400" id="last-updated">
                    <i class="bi bi-arrow-clockwise"></i>
                    <span>Mis à jour à l'instant</span>
                </div>
                
                <!-- Notifications -->
                <button class="btn-icon relative" id="notifications-btn">
                    <i class="bi bi-bell"></i>
                    <c:if test="${unreadNotifications > 0}">
                        <span class="absolute -top-0.5 -right-0.5 w-4 h-4 bg-danger-600 rounded-full border-2 border-white"></span>
                    </c:if>
                </button>
                
                <!-- Settings -->
                <button class="btn-icon">
                    <i class="bi bi-gear"></i>
                </button>
            </div>
        </header>
        
        <!-- Dashboard Content -->
        <div class="p-6">
            
            <!-- Emergency Alert Banner -->
            <c:if test="${not empty activeAlert}">
                <div class="alert-banner rounded-2xl p-4 mb-6 flex items-center gap-4 animate-fade-in-up">
                    <div class="w-12 h-12 rounded-xl bg-danger-600 flex items-center justify-center text-white text-xl flex-shrink-0">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                    </div>
                    <div class="flex-1 min-w-0">
                        <h4 class="font-bold text-gray-900 mb-0.5">${activeAlert.title}</h4>
                        <p class="text-gray-600 text-sm">${activeAlert.message}</p>
                    </div>
                    <a href="./evacuation?alert=${activeAlert.id}" 
                       class="hidden sm:flex items-center gap-2 px-4 py-2 bg-danger-600 text-white rounded-xl font-medium hover:bg-danger-700 transition-colors flex-shrink-0">
                        Voir l'évacuation
                        <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
            </c:if>
            
            <!-- Stats Grid -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-6 gap-4 mb-6 animate-fade-in-up">
                <!-- Alertes actives -->
                <div class="card-modern p-5 col-span-1">
                    <div class="flex items-center justify-between mb-3">
                        <div class="w-11 h-11 rounded-xl stat-icon-red flex items-center justify-center">
                            <i class="bi bi-exclamation-triangle-fill text-lg"></i>
                        </div>
                        <span class="text-xs font-semibold px-2 py-1 rounded-full bg-danger-50 text-danger-600 stat-trend-up">
                            <i class="bi bi-arrow-up"></i> 12%
                        </span>
                    </div>
                    <div class="text-3xl font-bold text-gray-900" id="stat-alerts">${activeAlertsCount}</div>
                    <div class="text-sm text-gray-500 mt-0.5">Alertes actives</div>
                    <div class="progress-bar-slim mt-3">
                        <div style="width: 70%; background: #dc2626;"></div>
                    </div>
                </div>
                
                <!-- Incidents aujourd'hui -->
                <div class="card-modern p-5 col-span-1">
                    <div class="flex items-center justify-between mb-3">
                        <div class="w-11 h-11 rounded-xl stat-icon-amber flex items-center justify-center">
                            <i class="bi bi-geo-alt-fill text-lg"></i>
                        </div>
                        <span class="text-xs font-semibold px-2 py-1 rounded-full bg-success-50 text-success-600 stat-trend-down">
                            <i class="bi bi-arrow-down"></i> 5%
                        </span>
                    </div>
                    <div class="text-3xl font-bold text-gray-900" id="stat-incidents">${todayIncidentsCount}</div>
                    <div class="text-sm text-gray-500 mt-0.5">Incidents aujourd'hui</div>
                    <div class="progress-bar-slim mt-3">
                        <div style="width: 40%; background: #d97706;"></div>
                    </div>
                </div>
                
                <!-- Zones surveillées -->
                <div class="card-modern p-5 col-span-1">
                    <div class="flex items-center justify-between mb-3">
                        <div class="w-11 h-11 rounded-xl stat-icon-blue flex items-center justify-center">
                            <i class="bi bi-satellite-fill text-lg"></i>
                        </div>
                        <span class="text-xs font-semibold px-2 py-1 rounded-full bg-success-50 text-success-600">
                            <i class="bi bi-check"></i> Actif
                        </span>
                    </div>
                    <div class="text-3xl font-bold text-gray-900">${monitoredZonesCount}</div>
                    <div class="text-sm text-gray-500 mt-0.5">Zones surveillées</div>
                    <div class="progress-bar-slim mt-3">
                        <div style="width: 85%; background: #2563eb;"></div>
                    </div>
                </div>
                
                <!-- Utilisateurs protégés -->
                <div class="card-modern p-5 col-span-1">
                    <div class="flex items-center justify-between mb-3">
                        <div class="w-11 h-11 rounded-xl stat-icon-green flex items-center justify-center">
                            <i class="bi bi-shield-check text-lg"></i>
                        </div>
                        <span class="text-xs font-semibold px-2 py-1 rounded-full bg-success-50 text-success-600 stat-trend-up">
                            <i class="bi bi-arrow-up"></i> 8%
                        </span>
                    </div>
                    <div class="text-3xl font-bold text-gray-900">${protectedUsersCount}</div>
                    <div class="text-sm text-gray-500 mt-0.5">Utilisateurs protégés</div>
                    <div class="progress-bar-slim mt-3">
                        <div style="width: 60%; background: #059669;"></div>
                    </div>
                </div>
                
                <!-- Prédictions IA -->
                <div class="card-modern p-5 col-span-1">
                    <div class="flex items-center justify-between mb-3">
                        <div class="w-11 h-11 rounded-xl stat-icon-purple flex items-center justify-center">
                            <i class="bi bi-cpu text-lg"></i>
                        </div>
                        <span class="text-xs font-semibold px-2 py-1 rounded-full bg-success-50 text-success-600 stat-trend-up">
                            <i class="bi bi-arrow-up"></i> 23%
                        </span>
                    </div>
                    <div class="text-3xl font-bold text-gray-900"><c:out value="${predictionCount}" default="0"/></div>
                    <div class="text-sm text-gray-500 mt-0.5">Prédictions IA</div>
                    <div class="progress-bar-slim mt-3">
                        <div style="width: 78%; background: #7c3aed;"></div>
                    </div>
                </div>
                
                <!-- Temps de réponse -->
                <div class="card-modern p-5 col-span-1">
                    <div class="flex items-center justify-between mb-3">
                        <div class="w-11 h-11 rounded-xl stat-icon-teal flex items-center justify-center">
                            <i class="bi bi-lightning-charge text-lg"></i>
                        </div>
                        <span class="text-xs font-semibold px-2 py-1 rounded-full bg-success-50 text-success-600 stat-trend-down">
                            <i class="bi bi-arrow-down"></i> 15%
                        </span>
                    </div>
                    <div class="text-3xl font-bold text-gray-900"><c:out value="${avgResponseTime}" default="0"/>s</div>
                    <div class="text-sm text-gray-500 mt-0.5">Temps de réponse</div>
                    <div class="progress-bar-slim mt-3">
                        <div style="width: 35%; background: #0d9488;"></div>
                    </div>
                </div>
            </div>
            
            <!-- Charts Row -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6 animate-fade-in-up delay-100">
                <!-- Risk Distribution -->
                <div class="card-modern p-5">
                    <div class="flex items-center justify-between mb-4">
                        <div>
                            <h3 class="font-semibold text-gray-900">Distribution des risques</h3>
                            <p class="text-xs text-gray-500">Répartition par type</p>
                        </div>
                        <div class="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center text-purple-600">
                            <i class="bi bi-pie-chart-fill"></i>
                        </div>
                    </div>
                    <div class="flex items-center justify-center" style="height: 180px;">
                        <canvas id="riskChart"></canvas>
                    </div>
                    <div class="grid grid-cols-3 gap-2 mt-4" id="risk-legend">
                        <div class="text-center">
                            <div class="text-xs text-gray-500">Inondations</div>
                            <div class="font-semibold text-gray-900" id="risk-flood-count">--</div>
                        </div>
                        <div class="text-center">
                            <div class="text-xs text-gray-500">Incendies</div>
                            <div class="font-semibold text-gray-900" id="risk-fire-count">--</div>
                        </div>
                        <div class="text-center">
                            <div class="text-xs text-gray-500">Cyclones</div>
                            <div class="font-semibold text-gray-900" id="risk-cyclone-count">--</div>
                        </div>
                    </div>
                </div>

                <!-- Activity Trend -->
                <div class="card-modern p-5 lg:col-span-2">
                    <div class="flex items-center justify-between mb-4">
                        <div>
                            <h3 class="font-semibold text-gray-900">Tendance des incidents</h3>
                            <p class="text-xs text-gray-500">7 derniers jours</p>
                        </div>
                        <div class="flex items-center gap-2">
                            <span class="flex items-center gap-1 text-xs text-gray-500">
                                <span class="w-2 h-2 rounded-full" style="background: #dc2626;"></span> Alertes
                            </span>
                            <span class="flex items-center gap-1 text-xs text-gray-500">
                                <span class="w-2 h-2 rounded-full" style="background: #059669;"></span> Résolus
                            </span>
                        </div>
                    </div>
                    <div style="height: 180px;">
                        <canvas id="trendChart"></canvas>
                    </div>
                </div>
            </div>
            
            <!-- Main Grid -->
            <div class="grid grid-cols-1 lg:grid-cols-4 gap-6 animate-fade-in-up delay-200">
                
                <!-- Map -->
                <div class="lg:col-span-3 card-modern overflow-hidden">
                    <div class="flex items-center justify-between p-5 border-b border-gray-100">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600">
                                <i class="bi bi-map-fill"></i>
                            </div>
                            <div>
                                <h3 class="font-semibold text-gray-900">Carte temps réel</h3>
                                <p class="text-xs text-gray-500">Surveillance active des zones à risque</p>
                            </div>
                        </div>
                        <div class="flex items-center gap-2 flex-wrap justify-end">
                            <div class="flex bg-gray-100 rounded-lg p-0.5">
                                <button onclick="filterLayers('all', event)" class="layer-filter-btn px-2.5 py-1.5 rounded-md text-xs font-semibold bg-white text-gray-900 shadow-sm transition-all">Tout</button>
                                <button onclick="filterLayers('risk', event)" class="layer-filter-btn px-2.5 py-1.5 rounded-md text-xs font-semibold text-gray-500 hover:text-gray-900 transition-all">Risques</button>
                                <button onclick="filterLayers('incident', event)" class="layer-filter-btn px-2.5 py-1.5 rounded-md text-xs font-semibold text-gray-500 hover:text-gray-900 transition-all">Incidents</button>
                                <button onclick="filterLayers('shelter', event)" class="layer-filter-btn px-2.5 py-1.5 rounded-md text-xs font-semibold text-gray-500 hover:text-gray-900 transition-all">Abris</button>
                            </div>
                            <a href="./map" 
                               class="flex items-center gap-2 px-3 py-2 bg-primary-500 text-white rounded-lg text-sm font-medium hover:bg-primary-600 transition-colors">
                                Agrandir
                            </a>
                        </div>
                    </div>
                    <div id="dashboard-map" class="h-[400px] bg-gray-100"></div>
                    
                    <!-- Map Legend and Info Panel -->
                    <div class="p-4 bg-gray-50 border-t border-gray-100">
                        <div class="flex flex-wrap gap-4 items-start justify-between">
                            <!-- Legend -->
                            <div class="flex-1 min-w-[180px]">
                                <h4 class="text-xs font-bold text-gray-500 uppercase mb-2">Légende & Statuts</h4>
                                <div class="space-y-1.5">
                                    <div class="flex items-center justify-between">
                                        <span class="flex items-center gap-2 text-xs text-gray-700">🔥 Risque d'incendie</span>
                                        <span class="text-xs font-semibold text-red-600">Urgence</span>
                                    </div>
                                    <div class="flex items-center justify-between">
                                        <span class="flex items-center gap-2 text-xs text-gray-700">💧 Zone inondable</span>
                                        <span class="text-xs font-semibold text-amber-500">Alerte</span>
                                    </div>
                                    <div class="flex items-center justify-between">
                                        <span class="flex items-center gap-2 text-xs text-gray-700">🌀 Cyclone tropical</span>
                                        <span class="text-xs font-semibold text-blue-500">Vigilance</span>
                                    </div>
                                    <div class="flex items-center justify-between">
                                        <span class="flex items-center gap-2 text-xs text-gray-700">🏠 Abri / Refuge</span>
                                        <span class="text-xs font-semibold text-green-600">Sécurisé</span>
                                    </div>
                                    <div class="flex items-center justify-between">
                                        <span class="flex items-center gap-2 text-xs text-gray-700">📍 Incident signalé</span>
                                        <span class="text-xs font-semibold text-orange-500">Actif</span>
                                    </div>
                                    <div class="flex items-center gap-2">
                                        <span class="w-3 h-3 rounded-full bg-blue-500 border-2 border-white shadow-sm"></span>
                                        <span class="text-xs text-gray-700">Votre position</span>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Live Statistics -->
                            <div class="flex-1 min-w-[180px]">
                                <h4 class="text-xs font-bold text-gray-500 uppercase mb-2">Statistiques en direct</h4>
                                <div class="grid grid-cols-2 gap-2">
                                    <div class="bg-white rounded-lg p-2 border border-gray-200">
                                        <div class="text-[10px] text-gray-500">Zones actives</div>
                                        <div class="text-lg font-bold text-red-600" id="active-zones-count">3</div>
                                    </div>
                                    <div class="bg-white rounded-lg p-2 border border-gray-200">
                                        <div class="text-[10px] text-gray-500">Alertes en cours</div>
                                        <div class="text-lg font-bold text-orange-600" id="active-alerts-count">4</div>
                                    </div>
                                    <div class="bg-white rounded-lg p-2 border border-gray-200">
                                        <div class="text-[10px] text-gray-500">Refuges ouverts</div>
                                        <div class="text-lg font-bold text-green-600" id="shelters-count">5</div>
                                    </div>
                                    <div class="bg-white rounded-lg p-2 border border-gray-200">
                                        <div class="text-[10px] text-gray-500">Population protégée</div>
                                        <div class="text-lg font-bold text-blue-600" id="protected-count">125K</div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Quick Actions -->
                            <div class="flex-1 min-w-[180px]">
                                <h4 class="text-xs font-bold text-gray-500 uppercase mb-2">Actions rapides</h4>
                                <div class="space-y-1.5">
                                    <button onclick="centerOnUser()" class="w-full text-left px-2 py-1.5 bg-white rounded-lg text-xs text-gray-700 hover:bg-gray-100 transition-colors border border-gray-200 flex items-center gap-2">
                                        <i class="bi bi-crosshair text-blue-500"></i>
                                        Centrer sur ma position
                                    </button>
                                    <button onclick="showAllAlerts()" class="w-full text-left px-2 py-1.5 bg-white rounded-lg text-xs text-gray-700 hover:bg-gray-100 transition-colors border border-gray-200 flex items-center gap-2">
                                        <i class="bi bi-bell text-red-500"></i>
                                        Voir toutes les alertes
                                    </button>
                                    <button onclick="showNearestShelter()" class="w-full text-left px-2 py-1.5 bg-white rounded-lg text-xs text-gray-700 hover:bg-gray-100 transition-colors border border-gray-200 flex items-center gap-2">
                                        <i class="bi bi-house-door text-green-500"></i>
                                        Refuge le plus proche
                                    </button>
                                    <button onclick="refreshMapData()" class="w-full text-left px-2 py-1.5 bg-white rounded-lg text-xs text-gray-700 hover:bg-gray-100 transition-colors border border-gray-200 flex items-center gap-2">
                                        <i class="bi bi-arrow-clockwise text-gray-500"></i>
                                        Actualiser les données
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Sidebar Cards -->
                <div class="flex flex-col gap-6">
                    
                    <!-- Recent Alerts -->
                    <div class="card-modern">
                        <div class="flex items-center justify-between p-5 border-b border-gray-100">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 rounded-xl bg-red-50 flex items-center justify-center text-red-600">
                                    <i class="bi bi-bell-fill"></i>
                                </div>
                                <h3 class="font-semibold text-gray-900">Alertes récentes</h3>
                            </div>
                            <a href="./alerts" class="text-sm text-primary-600 hover:text-primary-700 font-medium">Voir tout</a>
                        </div>
                        <div class="p-4">
                            <c:forEach items="${recentAlerts}" var="alert">
                                <div class="flex items-start gap-3 p-3 rounded-xl bg-gray-50 mb-2 border-l-4 
                                            ${alert.level == 'urgence' ? 'border-danger-600' : alert.level == 'alerte' ? 'border-warning-500' : 'border-blue-500'}">
                                    <div class="w-2 h-2 rounded-full mt-2 flex-shrink-0 
                                                ${alert.level == 'urgence' ? 'bg-danger-600' : alert.level == 'alerte' ? 'bg-warning-500' : 'bg-blue-500'}"></div>
                                    <div class="flex-1 min-w-0">
                                        <span class="inline-block px-2 py-0.5 rounded-md text-xs font-medium bg-white border border-gray-200 text-gray-600 mb-1">${alert.type}</span>
                                        <p class="text-sm font-medium text-gray-900 truncate">${alert.title}</p>
                                        <p class="text-xs text-gray-500">
                                            <i class="bi bi-clock mr-1"></i>
                                            <fmt:formatDate value="${alert.emittedAt}" pattern="HH:mm"/>
                                        </p>
                                    </div>
                                </div>
                            </c:forEach>
                            
                            <c:if test="${empty recentAlerts}">
                                <div class="text-center py-8">
                                    <div class="w-16 h-16 bg-green-50 rounded-full flex items-center justify-center mx-auto mb-3">
                                        <i class="bi bi-check-lg text-2xl text-green-600"></i>
                                    </div>
                                    <p class="text-gray-500">Aucune alerte active</p>
                                </div>
                            </c:if>
                        </div>
                    </div>
                    
                    <!-- System Status -->
                    <div class="card-modern p-5">
                        <div class="flex items-center gap-3 mb-4">
                            <div class="w-10 h-10 rounded-xl bg-green-50 flex items-center justify-center text-green-600">
                                <i class="bi bi-diagram-3-fill"></i>
                            </div>
                            <div>
                                <h3 class="font-semibold text-gray-900">État du système</h3>
                            </div>
                        </div>
                        <div class="space-y-3">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-2">
                                    <div class="status-pulse"></div>
                                    <span class="text-sm text-gray-700">API Gateway</span>
                                </div>
                                <span class="text-xs font-semibold text-green-600">Opérationnel</span>
                            </div>
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-2">
                                    <div class="status-pulse"></div>
                                    <span class="text-sm text-gray-700">IA Service</span>
                                </div>
                                <span class="text-xs font-semibold text-green-600">Opérationnel</span>
                            </div>
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-2">
                                    <div class="status-pulse"></div>
                                    <span class="text-sm text-gray-700">WebSocket</span>
                                </div>
                                <span class="text-xs font-semibold text-green-600">Connecté</span>
                            </div>
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-2">
                                    <span class="w-2 h-2 rounded-full bg-warning-500"></span>
                                    <span class="text-sm text-gray-700">Base de données</span>
                                </div>
                                <span class="text-xs font-semibold text-amber-600">25ms lat.</span>
                            </div>
                        </div>
                    </div>

                    <!-- Weather -->
                    <div class="card-modern p-5">
                        <div class="flex items-center justify-between mb-4">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600">
                                    <i class="bi bi-cloud-sun-fill"></i>
                                </div>
                                <h3 class="font-semibold text-gray-900">Météo</h3>
                            </div>
                            <span class="text-xs text-gray-400">
                                <i class="bi bi-geo-alt mr-1"></i><span id="weather-location">Antananarivo</span>
                            </span>
                        </div>
                        <div class="flex items-center gap-4 mb-4">
                            <span class="text-5xl" id="weather-icon-emoji">⏳</span>
                            <img id="weather-icon-img" src="" alt="Météo" class="w-16 h-16 hidden" />
                            <div>
                                <div class="text-4xl font-bold text-gray-900"><span id="weather-temp">--</span>°C</div>
                                <div class="text-sm text-gray-500" id="weather-desc" style="text-transform: capitalize;">Chargement...</div>
                            </div>
                        </div>
                        <div class="grid grid-cols-3 gap-2">
                            <div class="bg-gray-50 rounded-xl p-3 text-center">
                                <i class="bi bi-droplet text-blue-500 mb-1"></i>
                                <div class="text-xs text-gray-500">Humidité</div>
                                <div class="font-semibold text-gray-900"><span id="weather-humidity">--</span>%</div>
                            </div>
                            <div class="bg-gray-50 rounded-xl p-3 text-center">
                                <i class="bi bi-wind text-gray-400 mb-1"></i>
                                <div class="text-xs text-gray-500">Vent</div>
                                <div class="font-semibold text-gray-900"><span id="weather-wind">--</span> km/h</div>
                            </div>
                            <div class="bg-gray-50 rounded-xl p-3 text-center">
                                <i class="bi bi-cloud-rain text-blue-500 mb-1"></i>
                                <div class="text-xs text-gray-500">Pluie (1h)</div>
                                <div class="font-semibold text-gray-900"><span id="weather-rain">0</span>mm</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Activity & Incidents Row -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6 animate-fade-in-up delay-300">
                <!-- Recent Incidents -->
                <div class="card-modern">
                    <div class="flex items-center justify-between p-5 border-b border-gray-100">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl bg-amber-50 flex items-center justify-center text-amber-600">
                                <i class="bi bi-geo-alt-fill"></i>
                            </div>
                            <h3 class="font-semibold text-gray-900">Incidents récents</h3>
                        </div>
                        <a href="./incidents" class="text-sm text-primary-600 hover:text-primary-700 font-medium">Voir tout</a>
                    </div>
                    <div class="p-4">
                        <div id="recent-incidents-list">
                            <c:forEach items="${nearbyIncidents}" var="incident">
                                <div class="flex items-start gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors border border-transparent hover:border-gray-100 mb-2">
                                    <div class="w-9 h-9 rounded-lg bg-amber-50 flex items-center justify-center text-amber-600 flex-shrink-0">
                                        <i class="bi bi-pin-map-fill"></i>
                                    </div>
                                    <div class="flex-1 min-w-0">
                                        <div class="flex items-center gap-2">
                                            <p class="text-sm font-medium text-gray-900 truncate">${incident.title}</p>
                                            <span class="inline-block px-2 py-0.5 rounded-md text-xs font-medium 
                                                       ${incident.status == 'critique' ? 'bg-danger-50 text-danger-600' : incident.status == 'en_cours' ? 'bg-warning-50 text-warning-600' : 'bg-info-50 text-info-600'}">
                                                ${incident.status}
                                            </span>
                                        </div>
                                        <p class="text-xs text-gray-500 mt-0.5">
                                            <i class="bi bi-clock mr-1"></i>
                                            <fmt:formatDate value="${incident.reportedAt}" pattern="dd/MM HH:mm"/>
                                            <c:if test="${not empty incident.locationName}">
                                                <i class="bi bi-geo-alt mx-1"></i>${incident.locationName}
                                            </c:if>
                                        </p>
                                    </div>
                                </div>
                            </c:forEach>
                            <c:if test="${empty nearbyIncidents}">
                                <div class="text-center py-8" id="no-incidents-placeholder">
                                    <div class="w-16 h-16 bg-gray-50 rounded-full flex items-center justify-center mx-auto mb-3">
                                        <i class="bi bi-check-circle text-2xl text-gray-400"></i>
                                    </div>
                                    <p class="text-gray-500">Aucun incident récent</p>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- Activity Timeline -->
                <div class="card-modern">
                    <div class="flex items-center justify-between p-5 border-b border-gray-100">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center text-blue-600">
                                <i class="bi bi-activity"></i>
                            </div>
                            <h3 class="font-semibold text-gray-900">Activité récente</h3>
                        </div>
                        <span class="text-xs text-gray-400">En direct</span>
                    </div>
                    <div class="p-4" id="activity-timeline">
                        <c:forEach items="${recentActivities}" var="activity">
                            <div class="flex gap-3 pb-4 relative">
                                <div class="flex flex-col items-center">
                                    <div class="activity-dot
                                                ${activity.type == 'alerte' ? 'bg-danger-500' : activity.type == 'incident' ? 'bg-warning-500' : activity.type == 'refuge' ? 'bg-green-500' : 'bg-blue-500'}"></div>
                                    <div class="w-0.5 flex-1 bg-gray-200 mt-2"></div>
                                </div>
                                <div class="flex-1 pb-2">
                                    <p class="text-sm font-medium text-gray-900">${activity.title}</p>
                                    <p class="text-xs text-gray-500">${activity.description}</p>
                                    <p class="text-xs text-gray-400 mt-1">
                                        <i class="bi bi-clock mr-1"></i>
                                        <fmt:formatDate value="${activity.timestamp}" pattern="HH:mm - dd/MM"/>
                                    </p>
                                </div>
                            </div>
                        </c:forEach>
                        <c:if test="${empty recentActivities}">
                            <div class="text-center py-8">
                                <div class="w-16 h-16 bg-gray-50 rounded-full flex items-center justify-center mx-auto mb-3">
                                    <i class="bi bi-clock-history text-2xl text-gray-400"></i>
                                </div>
                                <p class="text-gray-500">Aucune activité récente</p>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    
    <script>
        // Toggle sidebar on mobile
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.getElementById('sidebarOverlay');
            sidebar.classList.toggle('open');
            overlay.classList.toggle('hidden');
        }
        
        // Update last refreshed time
        function updateLastUpdated() {
            const el = document.getElementById('last-updated');
            if (el) {
                const now = new Date();
                const time = now.getHours().toString().padStart(2, '0') + ':' + now.getMinutes().toString().padStart(2, '0');
                el.innerHTML = '<i class="bi bi-arrow-clockwise"></i> Mis à jour à ' + time;
            }
        }
        updateLastUpdated();

        // Initialize charts
        let riskChart, trendChart;

        function initCharts() {
            // Risk Distribution (Donut)
            const riskCtx = document.getElementById('riskChart').getContext('2d');
            riskChart = new Chart(riskCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Inondations', 'Incendies', 'Cyclones', 'Autres'],
                    datasets: [{
                        data: [42, 28, 18, 12],
                        backgroundColor: ['#3b82f6', '#ef4444', '#8b5cf6', '#f59e0b'],
                        borderWidth: 0,
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '70%',
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: function(ctx) {
                                    return ctx.label + ': ' + ctx.parsed + '%';
                                }
                            }
                        }
                    }
                }
            });

            // Activity Trend (Line)
            const trendCtx = document.getElementById('trendChart').getContext('2d');
            trendChart = new Chart(trendCtx, {
                type: 'line',
                data: {
                    labels: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
                    datasets: [{
                        label: 'Alertes',
                        data: [12, 19, 15, 22, 18, 14, 9],
                        borderColor: '#dc2626',
                        backgroundColor: 'rgba(220, 38, 38, 0.08)',
                        fill: true,
                        tension: 0.4,
                        pointRadius: 3,
                        pointBackgroundColor: '#dc2626',
                        borderWidth: 2,
                    }, {
                        label: 'Résolus',
                        data: [8, 14, 12, 18, 15, 11, 7],
                        borderColor: '#059669',
                        backgroundColor: 'rgba(5, 150, 105, 0.08)',
                        fill: true,
                        tension: 0.4,
                        pointRadius: 3,
                        pointBackgroundColor: '#059669',
                        borderWidth: 2,
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        x: {
                            grid: { display: false },
                            ticks: { font: { size: 11 }, color: '#94a3b8' }
                        },
                        y: {
                            grid: { color: '#f1f5f9' },
                            ticks: { font: { size: 11 }, color: '#94a3b8', maxTicksLimit: 5 },
                            beginAtZero: true
                        }
                    },
                    interaction: {
                        intersect: false,
                        mode: 'index'
                    }
                }
            });
        }
        
        // Initialize map
        const map = L.map('dashboard-map').setView([parseFloat('${userLat}') || -18.9078, parseFloat('${userLng}') || 47.5208], 10);
        
        const osmLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '© OpenStreetMap'
        }).addTo(map);

        const satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
            maxZoom: 19,
            attribution: '© Esri, Maxar, Earthstar Geographics'
        });

        L.control.layers({
            'Carte': osmLayer,
            'Satellite': satelliteLayer
        }, null, { position: 'topright', collapsed: true }).addTo(map);
        
        // Layer groups for filtering
        const riskLayer = L.layerGroup().addTo(map);
        const incidentLayer = L.layerGroup().addTo(map);
        const shelterLayer = L.layerGroup().addTo(map);

        // Scale control
        L.control.scale({ position: 'bottomright', metric: true, imperial: false }).addTo(map);

        // Custom marker icons by disaster type
        const createMarkerIcon = (emoji, color, pulse) => {
            return L.divIcon({
                className: 'custom-marker',
                html: '<div class="marker-pin" style="background: ' + color + '; animation: ' + (pulse ? 'pulse 2s infinite' : 'none') + '">' + emoji + '</div>',
                iconSize: [36, 36],
                iconAnchor: [18, 36],
                popupAnchor: [0, -36]
            });
        };

        const icons = {
            incendie: createMarkerIcon('🔥', '#ef4444', true),
            inondation: createMarkerIcon('💧', '#3b82f6', false),
            cyclone: createMarkerIcon('🌀', '#8b5cf6', false),
            seisme: createMarkerIcon('🏚️', '#f59e0b', false),
            tsunami: createMarkerIcon('🌊', '#2563eb', false),
            glissement_terrain: createMarkerIcon('⛰️', '#78350f', false),
            urgence: createMarkerIcon('🔴', '#ef4444', true),
            alerte: createMarkerIcon('🟠', '#f59e0b', false),
            vigilance: createMarkerIcon('🟡', '#eab308', false),
            shelter: createMarkerIcon('🏠', '#059669', false),
            incident: createMarkerIcon('📍', '#f97316', false),
            user: createMarkerIcon('👤', '#3b82f6', false)
        };

        // User position
        const userLat = parseFloat('${userLat}') || -18.9078;
        const userLng = parseFloat('${userLng}') || 47.5208;
        L.marker([userLat, userLng], { icon: icons.user, zIndexOffset: 1000 })
            .addTo(map)
            .bindPopup(`
                <div style="min-width: 200px;">
                    <h3 style="font-weight: bold; margin-bottom: 8px;">📍 Votre Position</h3>
                    <p style="margin: 4px 0;"><strong>Latitude:</strong> ${userLat.toFixed(6)}</p>
                    <p style="margin: 4px 0;"><strong>Longitude:</strong> ${userLng.toFixed(6)}</p>
                    <p style="margin: 4px 0; color: #059669;">✓ Position sécurisée</p>
                    <button onclick="window.location.href='./evacuation'" style="margin-top: 8px; padding: 6px 12px; background: #059669; color: white; border: none; border-radius: 4px; cursor: pointer; width: 100%;">
                        🚀 Planifier évacuation
                    </button>
                </div>
            `);

        // Fetch alerts (risks)
        const fetchAlerts = () => {
            riskLayer.clearLayers();
            fetch('/api/v1/alerts?active=true', {
                headers: { 'Authorization': 'Bearer ${sessionScope.token}' }
            })
            .then(res => res.json())
            .then(data => {
                const alertsList = data.alerts || [];
                let activeZones = 0;
                let floodCount = 0, fireCount = 0, cycloneCount = 0;

                alertsList.forEach(a => {
                    const lat = a.center_lat || -18.9078;
                    const lng = a.center_lng || 47.5208;
                    const level = a.level || 'vigilance';
                    const iconKey = icons[a.type] || icons[level] || icons.vigilance;

                    activeZones++;

                    if (a.type === 'inondation') floodCount++;
                    else if (a.type === 'incendie') fireCount++;
                    else if (a.type === 'cyclone') cycloneCount++;

                    L.marker([lat, lng], { icon: iconKey })
                        .bindPopup(`
                            <div style="min-width: 250px;">
                                <span style="display:inline-block;padding:2px 8px;font-size:10px;font-weight:bold;color:white;background:\${level === 'urgence' ? '#ef4444' : level === 'alerte' ? '#f59e0b' : '#eab308'};border-radius:4px;text-transform:uppercase;margin-bottom:6px;">\${level}</span>
                                <h3 style="font-weight:bold;margin-bottom:6px;font-size:14px;">\${a.title}</h3>
                                <p style="margin:4px 0;font-size:12px;color:#666;">\${a.type}</p>
                                <hr style="margin:8px 0;border:none;border-top:1px solid #eee;">
                                <p style="margin:4px 0;font-size:12px;">\${a.message ? a.message.substring(0,200) + '...' : ''}</p>
                                <div style="margin-top:8px;padding:8px;background:\${level === 'urgence' ? '#fef2f2' : level === 'alerte' ? '#fffbeb' : '#fefce8'};border-radius:6px;font-size:11px;">
                                    <strong>Score:</strong> \${a.danger_score || 'N/A'}/100 &nbsp;|&nbsp; <strong>Confiance:</strong> \${a.confidence_score || 'N/A'}%
                                </div>
                                <button onclick="window.location.href='./evacuation?alert=\${a.id}'" style="margin-top:8px;padding:6px 12px;background:\${level === 'urgence' ? '#ef4444' : '#f59e0b'};color:white;border:none;border-radius:6px;cursor:pointer;width:100%;font-weight:600;">
                                    🚨 Voir évacuation
                                </button>
                            </div>
                        `)
                        .addTo(riskLayer);

                    L.circle([lat, lng], {
                        color: level === 'urgence' ? '#ef4444' : level === 'alerte' ? '#f59e0b' : '#eab308',
                        fillColor: level === 'urgence' ? '#ef4444' : level === 'alerte' ? '#f59e0b' : '#eab308',
                        fillOpacity: 0.12,
                        radius: 5000
                    }).addTo(riskLayer);
                });

                document.getElementById('active-zones-count').textContent = activeZones;
                document.getElementById('active-alerts-count').textContent = alertsList.length;
                document.getElementById('risk-flood-count').textContent = floodCount;
                document.getElementById('risk-fire-count').textContent = fireCount;
                document.getElementById('risk-cyclone-count').textContent = cycloneCount;

                // Update donut chart
                if (riskChart) {
                    riskChart.data.datasets[0].data = [
                        floodCount || 42,
                        fireCount || 28,
                        cycloneCount || 18,
                        Math.max(0, alertsList.length - floodCount - fireCount - cycloneCount) || 12
                    ];
                    riskChart.update();
                }
            })
            .catch(err => console.log('Err fetching alerts:', err));
        };

        // Fetch shelters
        const fetchShelters = () => {
            shelterLayer.clearLayers();
            fetch('/api/v1/shelters', {
                headers: { 'Authorization': 'Bearer ${sessionScope.token}' }
            })
            .then(res => res.json())
            .then(data => {
                const shelters = data.shelters || [];
                shelters.forEach(s => {
                    const occupancyPct = s.capacity > 0 ? ((s.current_occupancy || 0) / s.capacity * 100) : 0;
                    L.marker([s.location_lat, s.location_lng], { icon: icons.shelter })
                        .bindPopup(`
                            <div style="min-width: 220px;">
                                <h3 style="font-weight:bold;margin-bottom:6px;">🏠 \${s.name}</h3>
                                <p style="margin:4px 0;font-size:12px;color:#666;">\${s.type || 'Refuge'}</p>
                                <hr style="margin:8px 0;border:none;border-top:1px solid #eee;">
                                <div style="font-size:12px;">
                                    <p style="margin:4px 0;"><strong>Capacité:</strong> \${s.current_occupancy || 0}/\${s.capacity}</p>
                                    <div style="width:100%;background:#e2e8f0;height:6px;border-radius:4px;overflow:hidden;margin:4px 0;">
                                        <div style="width:\${occupancyPct}%;background:\${occupancyPct > 80 ? '#ef4444' : occupancyPct > 50 ? '#f59e0b' : '#059669'};height:100%;"></div>
                                    </div>
                                    <p style="margin:4px 0;"><strong>Disponible:</strong> \${s.capacity - (s.current_occupancy || 0)} places</p>
                                    <p style="margin:4px 0;font-size:11px;color:#666;">
                                        \${s.has_medical_facilities ? '🏥 Médical ' : ''}\${s.has_food ? '🍲 Nourriture ' : ''}\${s.has_water ? '💧 Eau' : ''}
                                    </p>
                                </div>
                                \${s.phone ? '<p style="margin:4px 0;"><strong>📞</strong> ' + s.phone + '</p>' : ''}
                                <button onclick="window.location.href='./evacuation?shelter=\${s.id}'" style="margin-top:8px;padding:6px 12px;background:#059669;color:white;border:none;border-radius:6px;cursor:pointer;width:100%;font-weight:600;">
                                    🧭 Itinéraire vers ce refuge
                                </button>
                            </div>
                        `)
                        .addTo(shelterLayer);
                });
                document.getElementById('shelters-count').textContent = shelters.length;
            })
            .catch(err => console.log('Err fetching shelters:', err));
        };

        // Fetch incidents
        const fetchIncidents = () => {
            incidentLayer.clearLayers();
            fetch('/api/v1/incidents', {
                headers: { 'Authorization': 'Bearer ${sessionScope.token}' }
            })
            .then(res => res.json())
            .then(data => {
                const incidentsList = data.incidents || [];
                incidentsList.forEach(i => {
                    L.marker([i.location_lat, i.location_lng], { icon: icons.incident })
                        .bindPopup(`
                            <div style="min-width: 220px;">
                                <span style="display:inline-block;padding:2px 8px;font-size:10px;font-weight:bold;color:white;background:\${i.status === 'critique' ? '#ef4444' : i.status === 'en_cours' ? '#f59e0b' : '#3b82f6'};border-radius:4px;text-transform:uppercase;margin-bottom:6px;">\${i.status || 'signalé'}</span>
                                <h3 style="font-weight:bold;margin-bottom:6px;font-size:14px;">📍 \${i.title}</h3>
                                <p style="margin:4px 0;font-size:12px;color:#666;">\${i.description || ''}</p>
                                \${i.severity ? '<div style="margin-top:6px;font-size:11px;color:#666;"><strong>Sévérité:</strong> ' + i.severity + '/10</div>' : ''}
                            </div>
                        `)
                        .addTo(incidentLayer);
                });
            })
            .catch(err => console.log('Err fetching incidents:', err));
        };

        // Load all map data
        fetchAlerts();
        fetchShelters();
        fetchIncidents();

        // Auto-refresh every 30 seconds
        let refreshInterval = setInterval(() => {
            fetchAlerts();
            fetchShelters();
            fetchIncidents();
            updateLastUpdated();
        }, 30000);

        // Layer filter logic
        function filterLayers(type, event) {
            const buttons = document.querySelectorAll('.layer-filter-btn');
            buttons.forEach(btn => {
                btn.classList.remove('bg-white', 'text-gray-900', 'shadow-sm');
                btn.classList.add('text-gray-500');
            });
            if (event) {
                event.currentTarget.classList.add('bg-white', 'text-gray-900', 'shadow-sm');
                event.currentTarget.classList.remove('text-gray-500');
            }

            map.removeLayer(riskLayer);
            map.removeLayer(incidentLayer);
            map.removeLayer(shelterLayer);

            if (type === 'all' || type === 'risk') map.addLayer(riskLayer);
            if (type === 'all' || type === 'incident') map.addLayer(incidentLayer);
            if (type === 'all' || type === 'shelter') map.addLayer(shelterLayer);
        }

        // Quick action functions
        function centerOnUser() {
            map.setView([userLat, userLng], 14);
        }
        
        function showAllAlerts() {
            window.location.href = './alerts';
        }
        
        function showNearestShelter() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(pos => {
                    const { latitude, longitude } = pos.coords;
                    window.location.href = './evacuation?lat=' + latitude + '&lng=' + longitude;
                }, () => window.location.href = './evacuation');
            } else {
                window.location.href = './evacuation';
            }
        }
        
        function refreshMapData() {
            fetchAlerts();
            fetchShelters();
            fetchIncidents();
            updateLastUpdated();
        }

        // Pulse animation for urgent markers
        const style = document.createElement('style');
        style.textContent = `
            @keyframes pulse {
                0% { transform: scale(1); opacity: 1; }
                50% { transform: scale(1.15); opacity: 0.8; }
                100% { transform: scale(1); opacity: 1; }
            }
            .custom-marker { background: transparent; border: none; }
            .marker-pin {
                width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center;
                font-size: 18px; box-shadow: 0 4px 12px rgba(0,0,0,0.25); border: 2.5px solid white; transition: transform 0.2s;
                cursor: pointer;
            }
            .marker-pin:hover { transform: scale(1.15); }
        `;
        document.head.appendChild(style);
        
        // WebSocket for real-time updates
        const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const ws = new WebSocket(wsProtocol + '//' + window.location.host + '/ws');
        
        ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            if (data.type === 'alert' || data.type === 'incident' || data.type === 'shelter_update') {
                refreshMapData();
            }
        };

        // Aggregation Weather API Fetch via Gateway / AI Service with OpenWeatherMap fallback
        async function fetchWeather() {
            const lat = parseFloat('${userLat}') || -18.9078;
            const lng = parseFloat('${userLng}') || 47.5208;
            const fallbackCity = '${userLocation}' || 'Antananarivo';
            
            // 1. Try our aggregated gateway endpoint first
            const localUrl = "/api/ai/weather/current?lat=" + lat + "&lng=" + lng;
            
            try {
                const response = await fetch(localUrl);
                if (response.ok) {
                    const result = await response.json();
                    
                    let weatherData = result.data || result;
                    
                    if (weatherData && weatherData.main) {
                        updateWeatherUI({
                            temp: Math.round(weatherData.main.temp),
                            desc: weatherData.weather[0].description,
                            humidity: weatherData.main.humidity,
                            wind: Math.round(weatherData.wind.speed * 3.6),
                            location: weatherData.name || fallbackCity,
                            rain: (weatherData.rain && weatherData.rain['1h']) ? weatherData.rain['1h'] : '0',
                            iconCode: weatherData.weather[0].icon
                        });
                        return;
                    } 
                    else if (weatherData && weatherData.temperature !== undefined) {
                        updateWeatherUI({
                            temp: Math.round(weatherData.temperature),
                            desc: weatherData.weather_condition || 'Météo',
                            humidity: weatherData.humidity || '--',
                            wind: Math.round((weatherData.wind_speed || 0) * 3.6),
                            location: fallbackCity,
                            rain: weatherData.precipitation_24h !== undefined ? Math.round(weatherData.precipitation_24h / 24) : '0',
                            iconEmoji: getWeatherEmoji(weatherData.weather_code || 800)
                        });
                        return;
                    }
                }
            } catch (err) {
                console.warn("Local weather API unavailable or error:", err);
            }
            
            // 2. Direct browser fallback
            const apiKey = 'bd5e378503939ddaee76f12ad7a97608';
            const fallbackUrl = "https://api.openweathermap.org/data/2.5/weather?q=" + encodeURIComponent(fallbackCity) + "&units=metric&lang=fr&appid=" + apiKey;
            try {
                const response = await fetch(fallbackUrl);
                if (response.ok) {
                    const data = await response.json();
                    updateWeatherUI({
                        temp: Math.round(data.main.temp),
                        desc: data.weather[0].description,
                        humidity: data.main.humidity,
                        wind: Math.round(data.wind.speed * 3.6),
                        location: data.name,
                        rain: (data.rain && data.rain['1h']) ? data.rain['1h'] : '0',
                        iconCode: data.weather[0].icon
                    });
                } else {
                    showStaticFallback();
                }
            } catch (error) {
                console.error("Erreur lors de la récupération de la météo :", error);
                showStaticFallback();
            }
        }

        function updateWeatherUI(info) {
            document.getElementById('weather-temp').innerText = info.temp;
            
            const descEl = document.getElementById('weather-desc');
            if (descEl) descEl.innerText = info.desc;
            
            const humEl = document.getElementById('weather-humidity');
            if (humEl) humEl.innerText = info.humidity;
            
            const windEl = document.getElementById('weather-wind');
            if (windEl) windEl.innerText = info.wind;
            
            const locEl = document.getElementById('weather-location');
            if (locEl) locEl.innerText = info.location;
            
            const rainEl = document.getElementById('weather-rain');
            if (rainEl) rainEl.innerText = info.rain;
            
            const imgEl = document.getElementById('weather-icon-img');
            const emojiEl = document.getElementById('weather-icon-emoji');
            
            if (info.iconCode) {
                const iconUrl = 'https://openweathermap.org/img/wn/' + info.iconCode + '@2x.png';
                if (imgEl) {
                    imgEl.src = iconUrl;
                    imgEl.classList.remove('hidden');
                    imgEl.style.display = 'inline-block';
                }
                if (emojiEl) {
                    emojiEl.classList.add('hidden');
                    emojiEl.style.display = 'none';
                }
            } else if (info.iconEmoji) {
                if (imgEl) {
                    imgEl.classList.add('hidden');
                    imgEl.style.display = 'none';
                }
                if (emojiEl) {
                    emojiEl.innerText = info.iconEmoji;
                    emojiEl.classList.remove('hidden');
                    emojiEl.style.display = 'inline-block';
                }
            }
        }

        function showStaticFallback() {
            const descEl = document.getElementById('weather-desc');
            if (descEl) descEl.innerText = "Service indisponible";
            
            document.getElementById('weather-temp').innerText = "24";
            document.getElementById('weather-humidity').innerText = "65";
            document.getElementById('weather-wind').innerText = "12";
            document.getElementById('weather-rain').innerText = "0";
            
            const emojiEl = document.getElementById('weather-icon-emoji');
            if (emojiEl) {
                emojiEl.innerText = "⛅";
                emojiEl.classList.remove('hidden');
                emojiEl.style.display = 'inline-block';
            }
            const imgEl = document.getElementById('weather-icon-img');
            if (imgEl) {
                imgEl.classList.add('hidden');
                imgEl.style.display = 'none';
            }
        }

        function getWeatherEmoji(code) {
            if (code >= 200 && code < 300) return "⛈️";
            if (code >= 300 && code < 600) return "🌧️";
            if (code >= 600 && code < 700) return "❄️";
            if (code >= 700 && code < 800) return "🌫️";
            if (code === 800) return "☀️";
            return "☁️";
        }
        
        document.addEventListener('DOMContentLoaded', () => {
            fetchWeather();
            initCharts();
        });
    </script>
</body>
</html>