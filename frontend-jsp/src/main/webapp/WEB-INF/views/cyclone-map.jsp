<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carte des cyclones - MITANDRINA</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />

    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { sans: ['Inter', 'system-ui', 'sans-serif'] },
                    colors: {
                        primary: { 50: '#ecfdf5', 100: '#d1fae5', 200: '#a7f3d0', 300: '#6ee7b7', 400: '#34d399', 500: '#10b981', 600: '#059669', 700: '#047857', 800: '#065f46', 900: '#064e3b' },
                        danger: { 50: '#fef2f2', 500: '#ef4444', 600: '#dc2626', 700: '#b91c1c' },
                        warning: { 50: '#fffbeb', 500: '#f59e0b', 600: '#d97706' },
                        info: { 50: '#eff6ff', 500: '#3b82f6', 600: '#2563eb' }
                    }
                }
            }
        }
    </script>

    <style>
        body { font-family: 'Inter', sans-serif; background: #f8fafc; }
        .sidebar { width: 280px; background: #ffffff; border-right: 1px solid #e2e8f0; }
        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); position: fixed; z-index: 50; box-shadow: 4px 0 24px rgba(0,0,0,0.1); }
            .sidebar.open { transform: translateX(0); }
            .main-content { margin-left: 0 !important; }
        }
        .nav-item {
            display: flex; align-items: center; gap: 0.75rem; padding: 0.75rem 1rem; border-radius: 10px;
            color: #64748b; text-decoration: none; font-weight: 500; font-size: 0.9rem; transition: all 0.2s ease; margin-bottom: 0.25rem;
        }
        .nav-item:hover { background: #ecfdf5; color: #059669; }
        .nav-item.active { background: #ecfdf5; color: #059669; font-weight: 600; border-left: 3px solid #10b981; }
        .btn-icon {
            width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center;
            background: white; border: 1px solid #e2e8f0; color: #64748b; transition: all 0.2s ease;
        }
        .btn-icon:hover { background: #f8fafc; border-color: #cbd5e1; color: #1e293b; }

        .custom-marker { background: transparent; border: none; }
        .marker-pin {
            width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center;
            font-size: 18px; box-shadow: 0 4px 12px rgba(0,0,0,0.25); border: 2.5px solid white; transition: transform 0.2s;
        }
        .marker-pin:hover { transform: scale(1.15); }

        .stats-card {
            background: rgba(255, 255, 255, 0.95); border: 1px solid #e2e8f0; border-radius: 16px;
            backdrop-filter: blur(12px); padding: 1.25rem; box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        .animate-fade-in-up { animation: fadeInUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; opacity: 0; }

        .leaflet-container { background: #f8fafc !important; }
        .leaflet-popup-content-wrapper {
            background: rgba(255, 255, 255, 0.98) !important; backdrop-filter: blur(12px);
            border: 1px solid #e2e8f0 !important; border-radius: 12px !important; color: #1e293b !important;
        }
        .leaflet-popup-tip { background: rgba(255, 255, 255, 0.98) !important; border: 1px solid #e2e8f0 !important; }
        .leaflet-control-zoom a { background: #ffffff !important; color: #475569 !important; border-color: #e2e8f0 !important; }
        .leaflet-control-zoom a:hover { background: #f8fafc !important; }
    </style>
    <link rel="stylesheet" href="/assets/css/custom.css?v=13a3d199">
</head>
<body class="min-h-screen flex overflow-hidden">

    <!-- Sidebar -->
    <aside class="sidebar fixed top-0 left-0 bottom-0 z-50 transition-transform" id="sidebar">
        <div class="flex flex-col h-full">
            <div class="p-6 border-b border-gray-100">
                <a href="./" class="flex items-center gap-2 text-xl font-bold text-gray-900">
                    <i class="bi bi-tornado text-primary-600"></i>
                    <span>MITANDRINA</span>
                </a>
            </div>

            <nav class="flex-1 overflow-y-auto py-4 px-3">
                <div class="px-3 mb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">Principal</div>

                <a href="dashboard" class="nav-item">
                    <i class="bi bi-grid-1x2-fill text-lg"></i>
                    <span>Tableau de bord</span>
                </a>

                <a href="map" class="nav-item">
                    <i class="bi bi-map-fill text-lg"></i>
                    <span>Carte des risques</span>
                </a>

                <a href="cyclone-map" class="nav-item active">
                    <i class="bi bi-tornado text-lg"></i>
                    <span>Carte des cyclones</span>
                </a>

                <a href="alerts" class="nav-item">
                    <i class="bi bi-bell-fill text-lg"></i>
                    <span>Alertes</span>
                </a>

                <a href="incidents" class="nav-item">
                    <i class="bi bi-geo-alt-fill text-lg"></i>
                    <span>Incidents</span>
                </a>

                <a href="evacuation" class="nav-item">
                    <i class="bi bi-car-front-fill text-lg"></i>
                    <span>Évacuation</span>
                </a>

                <c:if test="${sessionScope.user.role == 'administrateur'}">
                    <div class="px-3 mt-6 mb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">Administration</div>
                    <a href="admin/users" class="nav-item"><i class="bi bi-people-fill text-lg"></i><span>Utilisateurs</span></a>
                    <a href="admin/teams" class="nav-item"><i class="bi bi-building-fill text-lg"></i><span>Équipes</span></a>
                    <a href="admin/simulations" class="nav-item"><i class="bi bi-magic text-lg"></i><span>Simulations</span></a>
                </c:if>
            </nav>

            <div class="p-4 border-t border-gray-100">
                <div class="flex items-center gap-3 mb-3 p-3 bg-gray-50 rounded-xl">
                    <div class="w-10 h-10 rounded-full bg-primary-600 flex items-center justify-center font-semibold text-white text-sm">
                        ${sessionScope.user.firstName.charAt(0)}${sessionScope.user.lastName.charAt(0)}
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-sm font-semibold text-gray-900 truncate">${sessionScope.user.firstName} ${sessionScope.user.lastName}</p>
                        <p class="text-xs text-gray-500 capitalize">${sessionScope.user.role}</p>
                    </div>
                </div>
                <a href="auth/logout" class="flex items-center justify-center gap-2 w-full py-2.5 rounded-xl border border-gray-200 text-gray-600 font-medium hover:bg-primary-50 hover:text-primary-700 transition-all text-sm">
                    <i class="bi bi-box-arrow-right"></i>Déconnexion
                </a>
            </div>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="main-content flex-1 ml-[280px] flex flex-col h-screen">
        <!-- Top Bar -->
        <header class="bg-white border-b border-gray-100 h-16 flex items-center justify-between px-6 z-10 flex-shrink-0">
            <div class="flex items-center gap-4">
                <button class="md:hidden btn-icon" onclick="toggleSidebar()">
                    <i class="bi bi-list text-xl"></i>
                </button>
                <div>
                    <h1 class="text-xl font-bold text-gray-900 flex items-center gap-2">
                        <i class="bi bi-tornado text-primary-500"></i>
                        Carte des cyclones
                    </h1>
                    <p class="text-xs text-gray-500">Suivi en temps réel des systèmes cycloniques</p>
                </div>
            </div>

            <div class="flex items-center gap-3">
                <div class="flex bg-gray-100 rounded-xl p-1">
                    <button onclick="filterLayers('all', event)" class="layer-filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold bg-primary-600 text-white shadow-sm transition-all">Tout</button>
                    <button onclick="filterLayers('cyclone', event)" class="layer-filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold text-gray-500 hover:text-gray-900 transition-all">Cyclones</button>
                    <button onclick="filterLayers('incident', event)" class="layer-filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold text-gray-500 hover:text-gray-900 transition-all">Incidents</button>
                    <button onclick="filterLayers('shelter', event)" class="layer-filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold text-gray-500 hover:text-gray-900 transition-all">Abris</button>
                </div>
            </div>
        </header>

        <!-- Map Container -->
        <div class="flex-1 relative">
            <div id="cyclone-map" class="w-full h-full"></div>

            <!-- Stats Overlay -->
            <div class="absolute top-4 left-4 z-[1000] flex flex-col gap-2 animate-fade-in-up" style="animation-delay: 0.2s">
                <div class="stats-card flex items-center gap-3 px-4 py-3 border-l-4 border-l-primary-500">
                    <i class="bi bi-tornado text-2xl text-primary-500"></i>
                    <div>
                        <div class="text-xs text-gray-500">Cyclones actifs</div>
                        <div class="text-lg font-bold text-gray-900" id="cycloneCount">0</div>
                    </div>
                </div>
                <div class="stats-card flex items-center gap-3 px-4 py-3 border-l-4 border-l-amber-500">
                    <i class="bi bi-exclamation-triangle text-2xl text-amber-500"></i>
                    <div>
                        <div class="text-xs text-gray-500">Incidents</div>
                        <div class="text-lg font-bold text-gray-900" id="incidentCount">0</div>
                    </div>
                </div>
                <div class="stats-card flex items-center gap-3 px-4 py-3 border-l-4 border-l-emerald-500">
                    <i class="bi bi-house-heart text-2xl text-emerald-500"></i>
                    <div>
                        <div class="text-xs text-gray-500">Abris disponibles</div>
                        <div class="text-lg font-bold text-gray-900" id="shelterCount">0</div>
                    </div>
                </div>
            </div>

            <!-- Legend Panel -->
            <div class="absolute bottom-6 left-6 z-[1000] stats-card max-w-xs w-72 hidden md:block animate-fade-in-up" style="animation-delay: 0.4s">
                <div class="flex items-center justify-between mb-3">
                    <h4 class="font-bold text-gray-900 text-sm flex items-center gap-2">
                        <span class="w-2 h-2 bg-primary-500 rounded-full animate-pulse"></span>
                        Légende cyclonique
                    </h4>
                    <button onclick="toggleSimulation()" class="text-xs px-2.5 py-1 rounded-lg bg-purple-50 text-purple-700 font-medium hover:bg-purple-100 transition-colors flex items-center gap-1" id="sim-toggle-btn">
                        <i class="bi bi-magic"></i> Simulation
                    </button>
                </div>
                <div class="space-y-2 text-xs text-gray-600">
                    <div class="flex items-center justify-between">
                        <span class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-red-500 inline-block"></span> Alerte cyclone (Urgence)</span>
                        <span class="font-semibold text-red-600">Critique</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-blue-500 inline-block"></span> Alerte cyclone (Vigilance)</span>
                        <span class="font-semibold text-blue-600">Surveillance</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="flex items-center gap-2"><span class="w-3 h-3 rounded-full bg-amber-500 inline-block"></span> Alerte cyclone (Alerte)</span>
                        <span class="font-semibold text-amber-600">Modéré</span>
                    </div>
                    <div class="flex items-center justify-between pt-2 border-t border-gray-100">
                        <span class="flex items-center gap-2">🌀 Centre du cyclone</span>
                        <span class="font-semibold text-primary-600">Œil</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="flex items-center gap-2">📍 Incident signalé</span>
                        <span class="font-semibold text-amber-600">Actif</span>
                    </div>
                    <div class="flex items-center justify-between">
                        <span class="flex items-center gap-2">🏠 Abri / Refuge</span>
                        <span class="font-semibold text-emerald-600">Sécurisé</span>
                    </div>
                </div>
                <!-- Simulation Panel -->
                <div id="sim-panel" class="hidden border-t border-gray-100 pt-3 mt-2">
                    <div class="flex items-center justify-between mb-2">
                        <span class="text-xs font-semibold text-gray-700">Scénarios simulés</span>
                        <span class="text-[10px] text-purple-600 font-medium" id="sim-status">Actif</span>
                    </div>
                    <div class="space-y-1.5">
                        <button onclick="loadScenario('cyclone')" class="w-full text-left px-2 py-1.5 bg-purple-50 rounded-lg text-xs text-purple-700 font-medium hover:bg-purple-100 transition-colors flex items-center gap-2">
                            <i class="bi bi-tornado"></i> Cyclone tropical
                        </button>
                        <button onclick="loadScenario('tout')" class="w-full text-left px-2 py-1.5 bg-gray-50 rounded-lg text-xs text-gray-700 font-medium hover:bg-gray-100 transition-colors flex items-center gap-2">
                            <i class="bi bi-globe"></i> Tous les risques
                        </button>
                        <button onclick="clearSimulation()" class="w-full text-left px-2 py-1.5 rounded-lg text-xs text-gray-500 font-medium hover:bg-gray-100 transition-colors flex items-center gap-2">
                            <i class="bi bi-x-circle"></i> Effacer simulation
                        </button>
                    </div>
                </div>
            </div>

            <!-- AI Advisor Panel (toggle button) -->
            <div class="absolute top-4 right-4 z-[1000] animate-fade-in-up" style="animation-delay: 0.3s">
                <button onclick="toggleAIPanel()" class="btn-icon relative" title="Conseiller IA">
                    <i class="bi bi-robot text-xl" style="color: #10b981;"></i>
                    <span class="absolute -top-1 -right-1 w-3 h-3 bg-primary-500 rounded-full animate-pulse" id="aiDot"></span>
                </button>
                <button onclick="toggleSimPanel()" class="btn-icon relative" title="Simulation cyclonique">
                    <i class="bi bi-play-circle text-xl" style="color: #7c3aed;"></i>
                </button>
                <button onclick="refreshAIAnalysis()" class="btn-icon relative mt-1" title="Rafraîchir analyse IA">
                    <i class="bi bi-arrow-clockwise text-xl" style="color: #7c3aed;"></i>
                </button>
            </div>

            <!-- AI Advisor Panel -->
            <div id="aiPanel" class="absolute top-20 max-sm:top-40 right-2 sm:right-4 z-[1000] stats-card w-80 max-sm:w-[calc(100vw-2rem)] max-h-[70vh] overflow-y-auto hidden shadow-xl" style="opacity: 0; transition: opacity 0.4s ease;">
                <div class="flex items-center justify-between mb-3">
                    <h4 class="font-bold text-gray-900 text-sm flex items-center gap-2">
                        <i class="bi bi-robot text-primary-500"></i>
                        <span id="aiPanelTitle">Conseiller IA</span>
                        <span id="aiSourceBadge" class="text-[10px] bg-primary-100 text-primary-700 px-1.5 py-0.5 rounded-full font-medium">Local</span>
                        <span id="aiSimBadge" class="text-[10px] bg-purple-100 text-purple-700 px-1.5 py-0.5 rounded-full font-medium hidden">Simulation</span>
                        <span id="aiRefreshIndicator" class="text-[10px] text-gray-400 px-1.5 py-0.5 rounded-full font-medium" style="display:none">30s⏱</span>
                    </h4>
                    <div class="flex items-center gap-1">
                        <button onclick="refreshAIAnalysis()" class="text-gray-400 hover:text-primary-600 transition p-1" title="Rafraîchir">
                            <i class="bi bi-arrow-clockwise text-sm"></i>
                        </button>
                        <button onclick="toggleAIPanel()" class="text-gray-400 hover:text-gray-600 transition p-1">
                            <i class="bi bi-x text-sm"></i>
                        </button>
                    </div>
                </div>

                <div id="aiLoading" class="text-center py-6">
                    <div class="animate-spin w-8 h-8 border-2 border-primary-500 border-t-transparent rounded-full mx-auto mb-2"></div>
                    <p class="text-xs text-gray-400">Analyse en cours...</p>
                </div>

                <div id="aiContent" class="hidden">
                    <!-- Risk Global Badge -->
                    <div id="aiRiskBadge" class="flex items-center gap-2 mb-3 px-3 py-2 rounded-xl text-white text-xs font-bold hidden">
                    </div>

                    <!-- Resume -->
                    <div id="aiResume" class="text-xs text-gray-600 mb-3 leading-relaxed"></div>

                    <!-- Cyclones Analysis -->
                    <div id="aiCyclonesSection" class="mb-3 hidden">
                        <h5 class="text-xs font-bold text-gray-800 mb-2 flex items-center gap-1">
                            <i class="bi bi-tornado"></i> Analyse par cyclone
                        </h5>
                        <div id="aiCyclonesList" class="space-y-2"></div>
                    </div>

                    <!-- Recommendations -->
                    <div id="aiRecommandationsSection" class="mb-3 hidden">
                        <h5 class="text-xs font-bold text-gray-800 mb-2 flex items-center gap-1">
                            <i class="bi bi-lightbulb text-amber-500"></i> Recommandations
                        </h5>
                        <ul id="aiRecommandationsList" class="space-y-1"></ul>
                    </div>

                    <!-- Generated Alerts -->
                    <div id="aiAlertsSection" class="mb-3 hidden">
                        <h5 class="text-xs font-bold text-gray-800 mb-2 flex items-center gap-1">
                            <i class="bi bi-bell text-red-500"></i> Alertes générées
                        </h5>
                        <div id="aiAlertsList" class="space-y-2"></div>
                    </div>

                    <!-- Evacuation Advice -->
                    <div id="aiEvacuationSection" class="mb-3 hidden">
                        <h5 class="text-xs font-bold text-gray-800 mb-2 flex items-center gap-1">
                            <i class="bi bi-car-front text-blue-500"></i> Évacuation
                        </h5>
                        <p id="aiEvacuationText" class="text-xs text-gray-600 bg-blue-50 rounded-lg p-2"></p>
                    </div>

                    <!-- Timestamp -->
                    <div id="aiTimestamp" class="text-[10px] text-gray-400 mt-2 text-right"></div>
                </div>

                <div id="aiError" class="hidden text-center py-4">
                    <i class="bi bi-exclamation-triangle text-2xl text-amber-500"></i>
                    <p class="text-xs text-gray-500 mt-1">Analyse temporairement indisponible</p>
                    <button onclick="refreshAIAnalysis()" class="mt-2 px-3 py-1 bg-primary-600 text-white text-xs font-semibold rounded-lg hover:bg-primary-700 transition">
                        Réessayer
                    </button>
                </div>
            </div>

            <!-- Trajectory Simulation Panel -->
            <div id="simPanel" class="absolute top-44 max-sm:top-72 right-2 sm:right-4 z-[1000] stats-card w-80 max-sm:w-[calc(100vw-2rem)] max-h-[60vh] overflow-y-auto hidden shadow-xl" style="opacity: 0; transition: opacity 0.4s ease;">
                <div class="flex items-center justify-between mb-3">
                    <h4 class="font-bold text-gray-900 text-sm flex items-center gap-2">
                        <i class="bi bi-play-circle text-purple-600"></i>
                        Simulation trajectoire
                    </h4>
                    <button onclick="toggleSimPanel()" class="text-gray-400 hover:text-gray-600 transition p-1">
                        <i class="bi bi-x text-sm"></i>
                    </button>
                </div>

                <div id="simLoading" class="text-center py-4">
                    <div class="animate-spin w-6 h-6 border-2 border-purple-500 border-t-transparent rounded-full mx-auto mb-2"></div>
                    <p class="text-xs text-gray-400">Chargement des simulations...</p>
                </div>

                <div id="simContent" class="hidden">
                    <select id="simSelect" onchange="onSimSelect(this.value)" class="form-select w-full text-xs bg-gray-50 border-gray-200 rounded-xl mb-3 py-1.5">
                        <option value="">Selectionner une simulation</option>
                    </select>

                    <div id="simTrackInfo" class="hidden">
                        <div class="flex items-center justify-center gap-3 mb-3">
                            <button onclick="togglePlayback()" id="simPlayBtn" class="px-4 py-2 bg-purple-600 text-white font-bold rounded-xl text-xs hover:bg-purple-700 transition flex items-center gap-1">
                                <i class="bi bi-play-fill"></i> Lire
                            </button>
                            <div class="flex gap-1">
                                <button onclick="setSpeed(1)" id="spd1" class="px-2 py-1 text-xs font-bold rounded-lg bg-purple-600 text-white">1x</button>
                                <button onclick="setSpeed(2)" id="spd2" class="px-2 py-1 text-xs font-bold rounded-lg bg-gray-200 text-gray-600">2x</button>
                                <button onclick="setSpeed(4)" id="spd4" class="px-2 py-1 text-xs font-bold rounded-lg bg-gray-200 text-gray-600">4x</button>
                            </div>
                        </div>

                        <input type="range" id="simSlider" min="0" max="100" value="0" oninput="onSimSlider(this.value)" class="w-full mb-2 accent-purple-600">
                        <div class="flex justify-between text-[10px] text-gray-400 mb-2">
                            <span id="simTimeLabel">Debut</span>
                            <span id="simTimeEnd">Fin</span>
                        </div>

                        <div class="grid grid-cols-2 gap-1.5 text-[11px] bg-purple-50 rounded-xl p-2.5">
                            <div><span class="text-gray-500">Position:</span> <span class="font-semibold text-gray-800" id="simPos">--</span></div>
                            <div><span class="text-gray-500">Vent:</span> <span class="font-semibold text-purple-700" id="simWind">-- km/h</span></div>
                            <div><span class="text-gray-500">Pression:</span> <span class="font-semibold text-gray-800" id="simPressure">-- hPa</span></div>
                            <div><span class="text-gray-500">Phase:</span> <span class="font-semibold text-gray-800" id="simStage">--</span></div>
                        </div>
                        <!-- F5: Population counter -->
                        <div class="text-center text-xs font-bold text-red-600 mt-2 bg-red-50 rounded-lg py-1" id="simPopulation">Population touchée: 0</div>
                        <!-- F6: Post-simulation summary -->
                        <div id="simSummary" class="hidden mt-2 text-xs space-y-1 bg-gray-50 rounded-lg p-2 border border-gray-200">
                            <div class="font-bold text-gray-800 mb-1 border-b pb-1">Bilan post-simulation</div>
                            <div class="flex justify-between"><span class="text-gray-500">Superficie impactée:</span> <span class="font-semibold text-red-600" id="sumArea">0 km²</span></div>
                            <div class="flex justify-between"><span class="text-gray-500">Population touchée:</span> <span class="font-semibold text-red-600" id="sumPopulation">0</span></div>
                            <div class="flex justify-between"><span class="text-gray-500">Abris sollicités:</span> <span class="font-semibold text-amber-600" id="sumShelters">0</span></div>
                            <div class="flex justify-between"><span class="text-gray-500">Vent max:</span> <span class="font-semibold text-purple-700" id="sumWind">-- km/h</span></div>
                            <div class="flex justify-between"><span class="text-gray-500">Distance parcourue:</span> <span class="font-semibold text-gray-800" id="sumDistance">0 km</span></div>
                        </div>
                    </div>
                </div>

                <div id="simEmpty" class="hidden text-center py-4">
                    <p class="text-xs text-gray-500">Aucune simulation cyclonique disponible</p>
                </div>
            </div>

            <!-- Red Alert Banner -->
            <div id="criticalAlertBanner" class="fixed top-0 left-0 right-0 z-[9999] hidden" style="display:none">
                <div class="bg-red-600 text-white px-4 py-3 shadow-2xl" style="animation: alertFlash 0.8s ease-in-out infinite alternate;">
                    <div class="flex items-center justify-between max-w-7xl mx-auto">
                        <div class="flex items-center gap-3">
                            <i class="bi bi-exclamation-triangle-fill text-3xl animate-pulse"></i>
                            <div>
                                <div class="font-bold text-lg" id="criticalAlertTitle">🚨 ALERTE ROUGE</div>
                                <div class="text-sm text-red-100" id="criticalAlertMessage"></div>
                            </div>
                        </div>
                        <button onclick="dismissCriticalAlert()" class="text-white/80 hover:text-white text-3xl ml-4 leading-none">&times;</button>
                    </div>
                </div>
            </div>

            <style>
                @keyframes alertFlash {
                    0% { background-color: #dc2626; box-shadow: 0 0 30px rgba(220,38,38,0.5); }
                    100% { background-color: #b91c1c; box-shadow: 0 0 60px rgba(220,38,38,0.9); }
                }
                @keyframes alertSlideDown {
                    from { transform: translateY(-100%); opacity: 0; }
                    to { transform: translateY(0); opacity: 1; }
                }
                #criticalAlertBanner:not(.hidden) > div {
                    animation: alertFlash 0.8s ease-in-out infinite alternate, alertSlideDown 0.3s ease-out;
                }
            </style>

            <!-- Wind Speed Indicator -->
            <div class="absolute bottom-6 right-6 z-[1000] stats-card max-w-xs w-64 animate-fade-in-up" style="animation-delay: 0.6s">
                <h4 class="font-bold text-gray-900 text-sm mb-2">Vitesse du vent</h4>
                <div class="flex items-center gap-3">
                    <div class="flex-1 bg-gray-200 rounded-full h-2.5 overflow-hidden">
                        <div class="bg-gradient-to-r from-primary-500 via-amber-500 to-red-500 h-full rounded-full transition-all duration-1000" id="windBar" style="width: 0%"></div>
                    </div>
                    <span class="text-sm font-bold text-gray-900" id="windSpeed">-- km/h</span>
                </div>
                <p class="text-xs text-gray-400 mt-1">Vent maximal estimé</p>
            </div>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('open');
        }

        const userLat = numCoord(parseFloat('${userLat}'), -18.9078);
        const userLng = numCoord(parseFloat('${userLng}'), 47.5208);

        const map = L.map('cyclone-map', {
            center: [userLat, userLng],
            zoom: 6,
            zoomControl: false,
            attributionControl: false
        });

        L.control.zoom({ position: 'topright' }).addTo(map);

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

        const cycloneLayer = L.layerGroup().addTo(map);
        const incidentLayer = L.layerGroup().addTo(map);
        const shelterLayer = L.layerGroup().addTo(map);

        const createMarkerIcon = (emoji, color, size) => {
            return L.divIcon({
                className: 'custom-marker',
                html: '<div class="marker-pin" style="background: ' + color + ';width:' + size + 'px;height:' + size + 'px;font-size:' + (size-2) + 'px">' + emoji + '</div>',
                iconSize: [size, size],
                iconAnchor: [size/2, size],
                popupAnchor: [0, -size]
            });
        };

        const icons = {
            cyclone_urgence: createMarkerIcon('🌀', 'linear-gradient(135deg, #059669, #dc2626)', 42),
            cyclone_vigilance: createMarkerIcon('🌀', 'linear-gradient(135deg, #059669, #3b82f6)', 38),
            cyclone_alerte: createMarkerIcon('🌀', 'linear-gradient(135deg, #059669, #f59e0b)', 38),
            cyclone_info: createMarkerIcon('🌀', '#10b981', 34),
            shelter: createMarkerIcon('🏠', '#059669', 34),
            incident: createMarkerIcon('📍', '#f97316', 34),
            user: createMarkerIcon('👤', '#6366f1', 34)
        };

        L.marker([userLat, userLng], { icon: icons.user }).addTo(map)
            .bindPopup('<div class="p-1"><strong>Votre position</strong></div>');

        function getCycloneIcon(level) {
            switch(level) {
                case 'urgence': return icons.cyclone_urgence;
                case 'alerte': return icons.cyclone_alerte;
                case 'vigilance': return icons.cyclone_vigilance;
                default: return icons.cyclone_info;
            }
        }

        function makeCycloneClickable(marker, data) {
            marker.on('click', function() {
                var pos = marker.getLatLng();
                showZoneAdvice(data, pos.lat, pos.lng);
            });
        }

        function getLevelColor(level) {
            switch(level) {
                case 'urgence': return '#dc2626';
                case 'alerte': return '#f59e0b';
                case 'vigilance': return '#3b82f6';
                default: return '#6b7280';
            }
        }

        function getLevelLabel(level) {
            switch(level) {
                case 'urgence': return 'CRITIQUE';
                case 'alerte': return 'ALERTE';
                case 'vigilance': return 'VIGILANCE';
                default: return 'INFO';
            }
        }

        const cycloneAlertsData = ${cycloneAlertsJson};
        const cycloneIncidentsData = ${cycloneIncidentsJson};
        const sheltersData = ${sheltersJson};

        const alertsList = cycloneAlertsData.alerts || [];
        const incidentsList = cycloneIncidentsData.incidents || [];
        const sheltersList = sheltersData.shelters || [];

        function numCoord(v, d) { var n = Number(v); return isFinite(n) ? n : d; }

        function safeCoord(a, latKey, lngKey, dlat, dlng) {
            return [numCoord(a[latKey], dlat), numCoord(a[lngKey], dlng)];
        }

        // ============================================
        // Simulation Data - fetched from real simulations API
        // ============================================
        let REAL_SIMULATION_DATA = null;

        async function fetchRealSimulations() {
            if (REAL_SIMULATION_DATA) return REAL_SIMULATION_DATA;
            try {
                var controller = new AbortController();
                var timeout = setTimeout(function() { controller.abort(); }, 8000);
                var resp = await fetch(window.location.pathname + '?action=simulations', { signal: controller.signal });
                clearTimeout(timeout);
                if (!resp.ok) throw new Error('Erreur reseau');
                var data = await resp.json();
                var zones = [], shelters = [], incidents = [];

                (data.simulations || []).forEach(function(sim) {
                    if (sim.status !== 'completed') return;
                    var track = sim.results ? sim.results.track : null;
                    if (!track || track.length === 0) return;

                    var maxWind = sim.results.max_wind_kmh || 0;
                    var type = sim.scenario_type || 'cyclone';
                    var level = maxWind >= 120 ? 'urgence' : maxWind >= 80 ? 'alerte' : 'vigilance';

                    zones.push({
                        id: 'sim-' + sim.id,
                        type: type,
                        level: level,
                        lat: track[0].lat,
                        lng: track[0].lng,
                        name: sim.name,
                        desc: track.length + ' points de trajectoire - Vents max ' + maxWind + ' km/h - Population ' + (sim.results.affected_population || '?'),
                        danger_score: Math.min(100, Math.round(maxWind / 2.5)),
                        confidence: 85,
                        radius: (sim.radius_km || 50) * 1000
                    });

                    (sim.results.safe_refuges_identified || []).forEach(function(name, i) {
                        var idx = Math.min(i * Math.max(1, Math.floor(track.length / 5)), track.length - 1);
                        var pt = track[idx];
                        var clamped = clampToLand(pt.lat + (Math.random() - 0.5) * 0.08, pt.lng + (Math.random() - 0.5) * 0.08);
                        shelters.push({
                            id: 'sim-shelter-' + sim.id + '-' + i,
                            name: name,
                            lat: clamped.lat,
                            lng: clamped.lng,
                            capacity: 500,
                            occupied: Math.round(50 + Math.random() * 250),
                            type: 'Simulation IA',
                            medical: true,
                            food: true,
                            water: true
                        });
                    });

                    var severePoints = track.filter(function(p) { return p.wind >= (maxWind * 0.7); }).slice(0, 3);
                    severePoints.forEach(function(p, i) {
                        incidents.push({
                            id: 'sim-incident-' + sim.id + '-' + i,
                            title: 'Tempête ' + (sim.name || '').split(' ').slice(0, 2).join(' '),
                            status: 'critique',
                            lat: p.lat,
                            lng: p.lng,
                            description: 'Vents ' + p.wind + ' km/h - Phase ' + (p.stage || 'N/A'),
                            severity: Math.min(10, Math.round(p.wind / 25))
                        });
                    });
                });

                REAL_SIMULATION_DATA = { zones: zones, shelters: shelters, incidents: incidents };
                return REAL_SIMULATION_DATA;
            } catch(e) {
                console.warn('API simulations non disponible, utilisation données par défaut');
                return null;
            }
        }

        fetchRealSimulations();

        // ============================================
        // Render real cyclone/incident/shelter data on map
        // ============================================
        function renderRealMapData() {
            cycloneLayer.clearLayers();
            incidentLayer.clearLayers();
            shelterLayer.clearLayers();

            var cycCount = 0, incCount = 0, shlCount = 0;

            alertsList.forEach(function(a) {
                var lat = a.center_lat || a.lat;
                var lng = a.center_lng || a.lng;
                if (!lat || !lng) return;
                var level = a.level || 'vigilance';
                var marker = L.marker([lat, lng], { icon: getCycloneIcon(level) })
                    .bindPopup(
                        '<div class="p-3 min-w-[220px]">' +
                            '<span class="px-2 py-0.5 text-[10px] font-bold text-white rounded" style="background:' + getLevelColor(level) + '">' + getLevelLabel(level) + '</span>' +
                            '<h6 class="font-bold text-gray-900 text-sm mt-2 mb-1">' + (a.title || 'Système cyclonique') + '</h6>' +
                            '<p class="text-xs text-gray-500 mb-2">' + (a.message || '') + '</p>' +
                            (a.level === 'urgence' || a.level === 'alerte'
                                ? "<button onclick='showZoneAdvice(" + JSON.stringify({ title: a.title, level: level, wind_speed: (a.features_input || {}).wind_speed, pressure: (a.features_input || {}).pressure }) + ", " + lat + ", " + lng + ")' class='w-full px-3 py-1.5 bg-purple-600 text-white font-semibold text-xs rounded-lg hover:bg-purple-700 transition-colors'>💡 Conseil IA OpenRouter</button>"
                                : '') +
                        '</div>'
                    );
                makeCycloneClickable(marker, { title: a.title, level: level, wind_speed: (a.features_input || {}).wind_speed, danger_score: 50, pressure: (a.features_input || {}).pressure });
                cycloneLayer.addLayer(marker);

                var radius = level === 'urgence' ? 20000 : level === 'alerte' ? 12000 : 5000;
                cycloneLayer.addLayer(L.circle([lat, lng], {
                    color: getLevelColor(level), fillColor: getLevelColor(level), fillOpacity: 0.1, weight: 2, radius: radius
                }));
                cycCount++;
            });

            incidentsList.forEach(function(i) {
                var lat = i.location_lat || i.lat;
                var lng = i.location_lng || i.lng;
                if (!lat || !lng) return;
                incidentLayer.addLayer(L.marker([lat, lng], { icon: icons.incident })
                    .bindPopup(
                        '<div class="p-2">' +
                            '<span class="px-2 py-0.5 text-[9px] font-bold text-white bg-amber-500 rounded uppercase">' + (i.status || 'signalé') + '</span>' +
                            '<h6 class="font-bold text-gray-900 mt-1 mb-1 text-sm">' + (i.title || 'Incident') + '</h6>' +
                            '<p class="text-xs text-gray-500">' + (i.description || '') + '</p>' +
                        '</div>'
                    ));
                incCount++;
            });

            sheltersList.forEach(function(s) {
                var lat = s.location_lat || s.lat;
                var lng = s.location_lng || s.lng;
                if (!lat || !lng) return;
                var occPct = s.capacity > 0 ? ((s.current_occupancy || s.occupied || 0) / s.capacity * 100) : 0;
                shelterLayer.addLayer(L.marker([lat, lng], { icon: icons.shelter })
                    .bindPopup(
                        '<div class="p-2">' +
                            '<h6 class="font-bold text-gray-900 text-sm mb-1">🏠 ' + (s.name || 'Abri') + '</h6>' +
                            '<p class="text-xs text-gray-500 mb-1">Capacité : ' + (s.current_occupancy || s.occupied || 0) + '/' + s.capacity + '</p>' +
                            '<div class="w-full bg-gray-200 h-1.5 rounded-full overflow-hidden mb-2"><div class="bg-emerald-500 h-full" style="width:' + occPct + '%"></div></div>' +
                            '<a href="evacuation?shelter=' + s.id + '" class="inline-block px-3 py-1.5 bg-emerald-600 text-white font-semibold text-xs rounded-lg no-underline hover:bg-emerald-700 transition-colors">Itinéraire</a>' +
                        '</div>'
                    ));
                shelterLayer.addLayer(L.circle([lat, lng], {
                    color: '#059669', fillColor: '#059669', fillOpacity: 0.08, weight: 1.5, radius: 2500
                }));
                shlCount++;
            });

            document.getElementById('cycloneCount').textContent = cycCount;
            document.getElementById('incidentCount').textContent = incCount;
            document.getElementById('shelterCount').textContent = shlCount;

            var allZones = alertsList.map(function(a) {
                var w = (a.features_input || {}).wind_speed || (a.level === 'urgence' ? 80 : a.level === 'alerte' ? 50 : 30);
                return { danger_score: w };
            });
            updateWindDisplay(allZones);
        }

        // Render real data immediately
        renderRealMapData();

        // ============================================
        // Helper: clamps ocean coordinates to nearest known land city
        // ============================================
        var LAND_CITIES = [
            { name: 'Antananarivo', lat: -18.8792, lng: 47.5079 },
            { name: 'Toamasina', lat: -18.1492, lng: 49.4000 },
            { name: 'Mahajanga', lat: -15.7150, lng: 46.3200 },
            { name: 'Fianarantsoa', lat: -21.4527, lng: 47.0875 },
            { name: 'Antsiranana', lat: -12.2800, lng: 49.2900 },
            { name: 'Toliara', lat: -23.3500, lng: 43.6800 },
            { name: 'Antsirabe', lat: -19.8667, lng: 47.0333 },
            { name: 'Morondava', lat: -20.2833, lng: 44.2833 },
        ];

        function clampToLand(lat, lng) {
            var best = LAND_CITIES[0], bestDist = Infinity;
            LAND_CITIES.forEach(function(c) {
                var d = distanceKm(lat, lng, c.lat, c.lng);
                if (d < bestDist) { bestDist = d; best = c; }
            });
            if (bestDist > 80) {
                return { lat: best.lat + (Math.random() - 0.5) * 0.04, lng: best.lng + (Math.random() - 0.5) * 0.04 };
            }
            return { lat: lat, lng: lng };
        }

        // ============================================
        // Fallback simulation data (quand API indisponible)
        // ============================================
        const SIMULATION_ZONES = [
            { id: 1, type: 'cyclone', level: 'urgence', lat: -18.1, lng: 49.5, name: 'Cyclone Gezani - Toamasina', desc: 'Cyclone tropical intense - Vents 185 km/h - Landfall imminent', danger_score: 95, confidence: 92, radius: 80000 },
        ];

        const SIMULATION_SHELTERS = [
            { id: 1, name: 'Centre d\'urgence Analakely', lat: -18.91, lng: 47.525, capacity: 500, occupied: 120, type: 'Refuge municipal', medical: true, food: true, water: true },
            { id: 2, name: 'Refuge Toamasina', lat: -18.15, lng: 49.4, capacity: 300, occupied: 45, type: 'Refuge régional', medical: true, food: true, water: false },
            { id: 3, name: 'Stade de Fianarantsoa', lat: -21.4527, lng: 47.0875, capacity: 800, occupied: 150, type: 'Refuge public', medical: true, food: false, water: true },
        ];

        const SIMULATION_INCIDENTS = [
            { id: 1, title: 'Route inondée - Toamasina', status: 'critique', lat: -18.15, lng: 49.4, description: 'RN2 coupée par les eaux près de Toamasina', severity: 7 },
            { id: 2, title: 'Glissement de terrain', status: 'critique', lat: -19.35, lng: 48.2, description: 'Route nationale obstruée', severity: 6 },
        ];

        let simulationMode = false;
        let simulationDataCache = null;

        document.getElementById('cycloneCount').textContent = '0';
        document.getElementById('incidentCount').textContent = '0';
        document.getElementById('shelterCount').textContent = '0';

        // ============================================
        // Trajectoire réelle du Cyclone Gezani (source: Gezani.odt)
        // ============================================
        var GEZANI_TRACK = [
            {lat:-14.5, lng:61.0, wind:0, pressure:1008, stage:'Perturbation tropicale', datetime:'2026-02-03 00:00'},
            {lat:-16.2, lng:59.5, wind:55, pressure:1002, stage:'Dépression tropicale', datetime:'2026-02-06 00:00'},
            {lat:-16.8, lng:58.8, wind:45, pressure:1005, stage:'Perturbation tropicale', datetime:'2026-02-06 12:00'},
            {lat:-17.2, lng:57.5, wind:50, pressure:1004, stage:'Perturbation tropicale', datetime:'2026-02-07 12:00'},
            {lat:-17.5, lng:56.0, wind:65, pressure:998, stage:'Tempête tropicale modérée', datetime:'2026-02-08 00:00'},
            {lat:-17.8, lng:54.0, wind:100, pressure:985, stage:'Forte tempête tropicale', datetime:'2026-02-09 00:00'},
            {lat:-17.9, lng:53.0, wind:110, pressure:980, stage:'Forte tempête tropicale', datetime:'2026-02-09 12:00'},
            {lat:-18.0, lng:51.1, wind:155, pressure:968, stage:'Cyclone tropical', datetime:'2026-02-10 00:00'},
            {lat:-18.1, lng:49.5, wind:185, pressure:950, stage:'Cyclone tropical intense', datetime:'2026-02-10 12:00'},
            {lat:-18.2, lng:49.4, wind:185, pressure:945, stage:'Cyclone tropical intense', datetime:'2026-02-10 16:30'},
            {lat:-18.5, lng:48.0, wind:130, pressure:965, stage:'Cyclone tropical', datetime:'2026-02-11 00:00'},
            {lat:-19.0, lng:44.5, wind:55, pressure:990, stage:'Dépression tropicale', datetime:'2026-02-11 13:00'},
            {lat:-18.8, lng:43.0, wind:80, pressure:985, stage:'Tempête tropicale modérée', datetime:'2026-02-12 00:00'},
            {lat:-19.5, lng:40.0, wind:120, pressure:970, stage:'Cyclone tropical', datetime:'2026-02-13 12:00'},
            {lat:-20.0, lng:37.5, wind:185, pressure:948, stage:'Cyclone tropical intense', datetime:'2026-02-14 00:00'},
            {lat:-21.0, lng:36.5, wind:150, pressure:960, stage:'Cyclone tropical', datetime:'2026-02-14 12:00'},
            {lat:-22.0, lng:36.0, wind:110, pressure:972, stage:'Forte tempête tropicale', datetime:'2026-02-15 00:00'},
            {lat:-24.0, lng:35.6, wind:120, pressure:968, stage:'Cyclone tropical', datetime:'2026-02-16 00:00'},
            {lat:-26.1, lng:37.4, wind:105, pressure:975, stage:'Forte tempête tropicale', datetime:'2026-02-17 00:00'},
            {lat:-26.5, lng:40.0, wind:120, pressure:968, stage:'Cyclone tropical', datetime:'2026-02-17 19:00'},
            {lat:-27.5, lng:41.0, wind:100, pressure:978, stage:'Forte tempête tropicale', datetime:'2026-02-18 00:00'},
            {lat:-30.0, lng:43.0, wind:95, pressure:982, stage:'Forte tempête tropicale', datetime:'2026-02-19 00:00'},
            {lat:-35.0, lng:48.0, wind:65, pressure:992, stage:'Dépression post-tropicale', datetime:'2026-02-20 12:00'},
        ];

        function generateSyntheticTrack(zones, type) {
            if (type === 'cyclone' || type === 'tout') {
                return GEZANI_TRACK.slice();
            }
            var filtered = type === 'tout' ? zones : zones.filter(function(z) { return z.type === type; });
            if (filtered.length === 0) return [];
            var zone = filtered[0];
            var track = [];
            var startLat = zone.lat;
            var startLng = zone.lng;
            var steps = 12;
            var windMax = zone.danger_score * 1.5 || 80;
            for (var i = 0; i < steps; i++) {
                var progress = i / (steps - 1);
                var lat = startLat + (Math.random() - 0.5) * progress * 2;
                var lng = startLng + (Math.random() - 0.5) * progress * 2 + progress * 0.5;
                track.push({
                    lat: parseFloat(lat.toFixed(4)),
                    lng: parseFloat(lng.toFixed(4)),
                    wind: Math.round(windMax * (1 - progress * 0.3)),
                    pressure: Math.round(1005 - progress * 40),
                    stage: i < 3 ? 'Formation' : i < 6 ? 'Intensification' : i < 9 ? 'Maturité' : 'Dissipation',
                    datetime: 'J+' + i,
                });
            }
            return track;
        }

        // ============================================
        // Simulation Toggle Functions
        // ============================================
        function toggleSimulation() {
            simulationMode = !simulationMode;
            const panel = document.getElementById('simPanel');
            const btn = document.getElementById('sim-toggle-btn');
            if (simulationMode) {
                if (panel) { panel.classList.remove('hidden'); }
                if (btn) {
                    btn.innerHTML = '<i class="bi bi-stop-fill"></i> Masquer';
                    btn.classList.remove('bg-purple-50', 'text-purple-700');
                    btn.classList.add('bg-purple-600', 'text-white');
                }
                loadScenario('cyclone');
            } else {
                if (panel) { panel.classList.add('hidden'); }
                if (btn) {
                    btn.innerHTML = '<i class="bi bi-magic"></i> Simulation';
                    btn.classList.remove('bg-purple-600', 'text-white');
                    btn.classList.add('bg-purple-50', 'text-purple-700');
                }
                clearSimulation();
                reloadRealData();
            }
        }

        function loadScenario(type) {
            try {
                document.getElementById('sim-status').textContent = 'Chargement...';
                clearSimTrack();
                cycloneLayer.clearLayers();
                incidentLayer.clearLayers();
                shelterLayer.clearLayers();

                let sourceZones = SIMULATION_ZONES;
                let sourceShelters = SIMULATION_SHELTERS;
                let sourceIncidents = SIMULATION_INCIDENTS;
                if (REAL_SIMULATION_DATA && REAL_SIMULATION_DATA.zones.length > 0) {
                    sourceZones = REAL_SIMULATION_DATA.zones;
                    sourceShelters = REAL_SIMULATION_DATA.shelters;
                    sourceIncidents = REAL_SIMULATION_DATA.incidents;
                }
                const zones = type === 'tout' ? sourceZones : sourceZones.filter(z => z.type === type);
                const shelters = sourceShelters;
                const incidents = sourceIncidents;

                simulationDataCache = {
                    cyclones: zones.map(function(z) {
                        return {
                            lat: z.lat, lng: z.lng,
                            title: z.name || 'Zone simulée',
                            level: z.level || 'vigilance',
                            wind_speed: (z.danger_score || 50) * 1.5,
                            pressure: 990 - (z.danger_score || 50) * 0.5
                        };
                    }),
                    incidents: incidents.map(function(i) {
                        return {
                            lat: i.lat, lng: i.lng,
                            title: i.title || 'Incident simulé',
                            status: i.status || 'critique',
                            description: i.description || ''
                        };
                    }),
                    shelters: shelters.map(function(s) {
                        return {
                            lat: s.lat, lng: s.lng,
                            name: s.name || 'Abri simulé',
                            capacity: s.capacity || 500
                        };
                    })
                };

                shelters.forEach(s => {
                    const occPct = s.capacity > 0 ? (s.occupied / s.capacity * 100) : 0;
                    shelterLayer.addLayer(L.marker([s.lat, s.lng], { icon: icons.shelter })
                        .bindPopup(
                            '<div class="p-2">' +
                                '<h6 class="font-bold text-gray-900 text-sm mb-1">🏠 ' + s.name + '</h6>' +
                                '<p class="text-xs text-gray-500 mb-1">Capacité : ' + s.occupied + '/' + s.capacity + '</p>' +
                                '<div class="w-full bg-gray-200 h-1.5 rounded-full overflow-hidden mb-2"><div class="bg-emerald-500 h-full" style="width:' + occPct + '%"></div></div>' +
                                '<a href="evacuation?shelter=' + s.id + '" class="inline-block px-3 py-1.5 bg-emerald-600 text-white font-semibold text-xs rounded-lg no-underline hover:bg-emerald-700 transition-colors">Itinéraire</a>' +
                            '</div>'
                        ));
                    shelterLayer.addLayer(L.circle([s.lat, s.lng], {
                        color: '#059669',
                        fillColor: '#059669',
                        fillOpacity: 0.08,
                        weight: 1.5,
                        radius: 2500
                    }));
                });

                incidents.forEach(i => {
                    incidentLayer.addLayer(L.marker([i.lat, i.lng], { icon: icons.incident })
                        .bindPopup(
                            '<div class="p-2">' +
                                '<span class="px-2 py-0.5 text-[9px] font-bold text-white bg-amber-500 rounded uppercase">' + i.status + '</span>' +
                                '<h6 class="font-bold text-gray-900 mt-1 mb-1 text-sm">' + i.title + '</h6>' +
                                '<p class="text-xs text-gray-500">' + i.description + '</p>' +
                            '</div>'
                        ));
                });

                document.getElementById('cycloneCount').textContent = zones.length;
                document.getElementById('incidentCount').textContent = incidents.length;
                document.getElementById('shelterCount').textContent = shelters.length;
                document.getElementById('sim-status').textContent = 'Actif - ' + zones.length + ' zones';
                updateWindDisplay(zones);

                var srcZones = REAL_SIMULATION_DATA && REAL_SIMULATION_DATA.zones.length > 0 ? REAL_SIMULATION_DATA.zones : SIMULATION_ZONES;
                if (srcZones.length > 0) {
                    var track = generateSyntheticTrack(srcZones, type);
                    if (track.length > 0) {
                        loadTrack(track);
                        var sp = document.getElementById('simPanel');
                        sp.classList.remove('hidden');
                        sp.style.opacity = '1';
                        document.getElementById('simLoading').classList.add('hidden');
                        document.getElementById('simContent').classList.remove('hidden');
                        document.getElementById('simEmpty').classList.add('hidden');
                        var sel = document.getElementById('simSelect');
                        if (sel.options.length <= 1) {
                            var opt = document.createElement('option');
                            opt.value = 'gezani';
                            opt.textContent = 'Cyclone Gezani (185 km/h)';
                            opt._track = track;
                            sel.appendChild(opt);
                            sel.value = 'gezani';
                        }
                    }
                }

                var simCur = getSimCurrentData();
                aiAnalysisData = { data: analyzeLocally(simCur || simulationDataCache) };
                renderAIAnalysis();
                fetchOpenRouterAnalysis();
            } catch (e) {
                console.error('Erreur loadScenario:', e);
            } finally {
                var st = document.getElementById('sim-status');
                if (st && st.textContent === 'Chargement...') st.textContent = 'Erreur';
                var sl = document.getElementById('simLoading');
                if (sl) sl.classList.add('hidden');
            }
        }

        function clearSimulation() {
            clearSimTrack();
            var sp = document.getElementById('simPanel');
            sp.style.opacity = '0';
            sp.classList.add('hidden');
            cycloneLayer.clearLayers();
            incidentLayer.clearLayers();
            shelterLayer.clearLayers();
            document.getElementById('sim-status').textContent = 'Désactivé';
            document.getElementById('cycloneCount').textContent = '0';
            document.getElementById('incidentCount').textContent = '0';
            document.getElementById('shelterCount').textContent = '0';
            document.getElementById('windSpeed').textContent = '-- km/h';
            document.getElementById('windBar').style.width = '0%';

            // Reset simSelect to default option
            var sel = document.getElementById('simSelect');
            sel.innerHTML = '<option value="">Sélectionner une simulation</option>';

            // Reset panel visibility states
            document.getElementById('simLoading').classList.add('hidden');
            document.getElementById('simContent').classList.add('hidden');
            document.getElementById('simEmpty').classList.add('hidden');

            // Clear simulation data cache and re-run AI analysis with real data
            simulationDataCache = null;
            aiAnalysisData = { data: analyzeLocally() };
            renderAIAnalysis();
            fetchOpenRouterAnalysis();
        }

        function reloadRealData() {
            renderRealMapData();
        }

        function updateWindDisplay(zones) {
            let maxWind = 0;
            zones.forEach(z => { const w = z.danger_score * 1.5 || 0; maxWind = Math.max(maxWind, w); });
            if (maxWind > 0) {
                document.getElementById('windSpeed').textContent = Math.round(maxWind) + ' km/h';
                document.getElementById('windBar').style.width = Math.min(100, (maxWind / 120) * 100) + '%';
            }
        }

        // ====== AI ADVISOR PANEL - Analyse 100% locale (instantanée, sans appel API) ======

        function analyzeLocally(customData) {
            const month = new Date().getMonth() + 1;
            const isCycloneSeason = month >= 1 && month <= 3;
            const now = new Date().toLocaleString('fr-FR', { timeZone: 'UTC' });

            const cyclones = customData ? customData.cyclones : alertsList;
            const incidents = customData ? customData.incidents : incidentsList;
            const shelters = customData ? customData.shelters : sheltersList;

            if (!cyclones || cyclones.length === 0) {
                return {
                    resume: 'Rien à signaler. Aucun système cyclonique actif détecté à Madagascar.',
                    risque_global: 'faible',
                    analyse_cyclones: [],
                    recommandations_public: [
                        'Aucune action immédiate nécessaire',
                        'Restez informé des prévisions météo',
                        'Profitez-en pour vérifier votre kit d\'urgence',
                        'Consultez régulièrement les alertes officielles'
                    ],
                    recommandations_autorites: ['Maintenez la veille', 'Vérifiez les stocks d\'urgence'],
                    alertes_generees: [],
                    abris_recommandes: (shelters || []).slice(0, 3).map(function(s) {
                        return { nom: s.name || 'Abri', raison: 'Abri disponible à proximité' };
                    }),
                    conseils_evacuation: 'Aucune évacuation nécessaire pour le moment. Restez vigilant.',
                    timestamp_analyse: now,
                    source: 'analyse_locale'
                };
            }

            const windValues = cyclones.map(function(a) {
                return a.wind_speed || (a.level === 'urgence' ? 80 : a.level === 'alerte' ? 50 : 30);
            });
            const pressureValues = cyclones.map(function(a) {
                return a.pressure || (a.level === 'urgence' ? 950 : a.level === 'alerte' ? 980 : 1010);
            });
            const maxWind = windValues.length > 0 ? Math.max.apply(null, windValues) : 0;
            const minPressure = pressureValues.length > 0 ? Math.min.apply(null, pressureValues) : 1020;
            const nHigh = cyclones.filter(function(a) { return a.level === 'alerte' || a.level === 'urgence'; }).length;

            let score = 0;
            if (maxWind >= 100) score += 40; else if (maxWind >= 60) score += 30; else if (maxWind >= 30) score += 15;
            if (minPressure < 980) score += 20; else if (minPressure < 1000) score += 10;
            score += nHigh * 10;
            if (isCycloneSeason) score += 10;
            score += Math.min((incidents || []).length * 5, 15);

            let risk, recs, evac, alerts;
            if (score >= 70) {
                risk = 'critique';
                recs = ['Évacuez immédiatement si vous êtes en zone côtière ou inondable', 'Mettez-vous à l\'abri dans un bâtiment solide', 'Suivez ABSOLUMENT les instructions des autorités', 'N\'empruntez pas les routes inondées'];
                evac = 'ÉVACUATION OBLIGATOIRE dans les zones côtières et à risque. Rendez-vous immédiatement à l\'abri le plus proche.';
                alerts = [{ titre: 'ALERTE ROUGE - Cyclone majeur', message: 'Vents de ' + maxWind.toFixed(0) + ' km/h attendus. Évacuation obligatoire.', niveau: 'urgence', zone_concernee: 'Zones côtières et à risque' }];
            } else if (score >= 45) {
                risk = 'élevé';
                recs = ['Préparez-vous à évacuer si l\'ordre est donné', 'Sécurisez votre maison (volets, objets extérieurs)', 'Faites des réserves d\'eau et de nourriture pour 72h', 'Restez informé en continu'];
                evac = 'Préparez votre évacuation. Faites le plein, préparez vos documents et un sac d\'urgence.';
                alerts = [{ titre: 'Alerte orange - Cyclone puissant', message: 'Vents de ' + maxWind.toFixed(0) + ' km/h. Préparez-vous à évacuer.', niveau: 'alerte', zone_concernee: 'Zones menacées' }];
            } else if (score >= 25) {
                risk = 'modéré';
                recs = ['Restez informé de l\'évolution de la situation', 'Vérifiez votre kit d\'urgence', 'Repérez l\'abri le plus proche', 'Évitez les déplacements non essentiels'];
                evac = 'Surveillez la situation. Identifiez votre abri le plus proche et préparez un sac d\'urgence.';
                alerts = [{ titre: 'Vigilance cyclonique', message: 'Vents de ' + maxWind.toFixed(0) + ' km/h. Restez informé.', niveau: 'vigilance', zone_concernee: 'À déterminer' }];
            } else {
                risk = 'faible';
                recs = ['Aucune action immédiate nécessaire', 'Restez informé des prévisions météo', 'Profitez-en pour vérifier votre kit d\'urgence'];
                evac = 'Aucune évacuation nécessaire pour le moment. Restez vigilant.';
                alerts = [];
            }

            const cycAnalysis = cyclones.map(function(a) {
                const w = a.wind_speed || (a.level === 'urgence' ? 80 : a.level === 'alerte' ? 50 : 30);
                const lvl = a.level || 'vigilance';
                const cr = w >= 100 || lvl === 'urgence' ? 'critique' : w >= 60 || lvl === 'alerte' ? 'élevé' : w >= 30 ? 'modéré' : 'faible';
                const dir = a.direction || (a.lng > 48 ? 'Se déplace vers l\'Ouest' : a.lng > 44 ? 'Trajectoire côtière Est' : 'Trajectoire intérieure');
                const menace = a.zones_menacees || (a.lng > 48 ? ['Côte Est', 'Toamasina', 'Régions côtières'] : a.lng > 44 ? ['Régions intérieures', 'Antananarivo'] : ['Zones Ouest', 'Toliara']);
                return {
                    nom: a.title || 'Système cyclonique',
                    risque: cr,
                    vitesse_vent_estimee_kmh: Math.round(w),
                    direction: dir,
                    zones_menacees: menace,
                    recommandation: recs[0] || 'Restez vigilant'
                };
            });

            return {
                resume: 'Situation cyclonique ' + risk + ' à Madagascar. ' + cyclones.length + ' système(s) actif(s), vent max ' + maxWind.toFixed(0) + ' km/h.' + (isCycloneSeason ? ' Saison cyclonique active.' : ''),
                risque_global: risk,
                analyse_cyclones: cycAnalysis,
                recommandations_public: recs,
                recommandations_autorites: [
                    score >= 45 ? 'Activez les cellules de crise communales' : 'Maintenez la veille',
                    score >= 25 ? 'Préparez l\'ouverture des abris' : 'Vérifiez les stocks d\'urgence'
                ],
                alertes_generees: alerts,
                abris_recommandes: (shelters || []).slice(0, 3).map(function(s) {
                    return { nom: s.name || 'Abri', raison: 'Abri disponible à proximité' };
                }),
                conseils_evacuation: evac,
                timestamp_analyse: now,
                source: 'analyse_locale'
            };
        }

        var aiAnalysisData = { data: {} };
        try {
            aiAnalysisData = { data: analyzeLocally() };
        } catch (e) {
            console.warn('analyzeLocally error, using fallback:', e);
            aiAnalysisData = { data: { resume: 'Analyse locale non disponible', risque_global: 'modere', recommandations_public: ['Consultez les autorites locales'], conseils_evacuation: 'Restez vigilant' } };
        }
        window._aiDataLoaded = true;

        setTimeout(function() {
            var aiLoad = document.getElementById('aiLoading');
            if (aiLoad && !aiLoad.classList.contains('hidden')) {
                aiLoad.classList.add('hidden');
                document.getElementById('aiContent').classList.remove('hidden');
                document.getElementById('aiError').classList.remove('hidden');
            }
            var simLoad = document.getElementById('simLoading');
            if (simLoad && !simLoad.classList.contains('hidden')) {
                simLoad.classList.add('hidden');
                if (document.getElementById('simSelect').options.length <= 1) {
                    var opt = document.createElement('option');
                    opt.value = 'gezani';
                    opt.textContent = 'Cyclone Gezani (185 km/h)';
                    opt._track = GEZANI_TRACK;
                    document.getElementById('simSelect').appendChild(opt);
                    document.getElementById('simContent').classList.remove('hidden');
                    document.getElementById('simEmpty').classList.add('hidden');
                }
            }
        }, 20000);

        // ========== BUILD CYCLONE PAYLOAD (reused) ==========
        function buildCyclonePayload() {
            var simCurrent = getSimCurrentData();
            if (simCurrent) {
                return {
                    cyclones: simCurrent.cyclones,
                    incidents: simCurrent.incidents,
                    shelters: simCurrent.shelters,
                    user_lat: userLat,
                    user_lng: userLng
                };
            }
            if (simulationMode && simulationDataCache) {
                return {
                    cyclones: (simulationDataCache.cyclones || []).map(function(a) {
                        return {
                            lat: a.lat || -18.9078,
                            lng: a.lng || 47.5208,
                            title: a.title || 'Zone simulée',
                            level: a.level || 'vigilance',
                            wind_speed: a.wind_speed || 50,
                            pressure: a.pressure || 990
                        };
                    }),
                    incidents: (simulationDataCache.incidents || []).map(function(i) {
                        return {
                            lat: i.lat || -18.9078,
                            lng: i.lng || 47.5208,
                            title: i.title || 'Incident simulé',
                            status: i.status || 'signalé'
                        };
                    }),
                    shelters: (simulationDataCache.shelters || []).map(function(s) {
                        return {
                            lat: s.lat || -18.9078,
                            lng: s.lng || 47.5208,
                            name: s.name || 'Abri simulé',
                            capacity: s.capacity || 0
                        };
                    }),
                    user_lat: userLat,
                    user_lng: userLng
                };
            }
            return {
                cyclones: alertsList.map(function(a) { return {
                    lat: a.center_lat || a.lat || -18.9078,
                    lng: a.center_lng || a.lng || 47.5208,
                    title: a.title || 'Système cyclonique',
                    level: a.level || 'vigilance',
                    wind_speed: (a.features_input || {}).wind_speed || (a.level === 'urgence' ? 80 : a.level === 'alerte' ? 50 : 30),
                    pressure: (a.features_input || {}).pressure || (a.level === 'urgence' ? 950 : a.level === 'alerte' ? 980 : 1005)
                }; }),
                incidents: incidentsList.map(function(i) { return {
                    lat: i.location_lat || i.lat || -18.9078,
                    lng: i.location_lng || i.lng || 47.5208,
                    title: i.title || 'Incident',
                    status: i.status || 'signalé'
                }; }),
                shelters: sheltersList.map(function(s) { return {
                    lat: s.location_lat || s.lat || -18.9078,
                    lng: s.location_lng || s.lng || 47.5208,
                    name: s.name || 'Abri',
                    capacity: s.capacity || 0
                }; }),
                user_lat: userLat,
                user_lng: userLng
            };
        }

        // ========== FETCH OPENROUTER ANALYSIS (via backend-ai) ==========
        async function fetchOpenRouterAnalysis() {
            try {
                document.getElementById('aiSourceBadge').textContent = '⏳ OpenRouter...';
                document.getElementById('aiSourceBadge').className = 'text-[10px] bg-purple-100 text-purple-700 px-1.5 py-0.5 rounded-full font-medium animate-pulse';
            } catch (_) {}

            const payload = buildCyclonePayload();

            const controller = new AbortController();
            const timeout = setTimeout(() => controller.abort(), 15000);

            try {
                const response = await fetch(window.location.pathname + '?action=openrouter', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload),
                    signal: controller.signal
                });
                if (!response.ok) return;
                const result = await response.json();
                if (result && result.success && result.data) {
                    aiAnalysisData = { data: result.data };
                    renderAIAnalysis();
                    return;
                }
            } catch (e) {
                console.warn('Analyse OpenRouter non disponible:', e);
            } finally {
                clearTimeout(timeout);
                try {
                    var src = (aiAnalysisData.data || {}).source || 'Local';
                    var badgeLabel = {'openrouter+ml': 'OpenRouter+ML', 'openrouter': 'OpenRouter', 'ml_local': 'ML Local', 'gemini': 'Gemini'};
                    var badgeClass = {'openrouter+ml': 'bg-purple-100 text-purple-700', 'openrouter': 'bg-purple-100 text-purple-700', 'ml_local': 'bg-blue-100 text-blue-700', 'gemini': 'bg-amber-100 text-amber-700'};
                    document.getElementById('aiSourceBadge').textContent = badgeLabel[src] || src.charAt(0).toUpperCase() + src.slice(1);
                    document.getElementById('aiSourceBadge').className = 'text-[10px] ' + (badgeClass[src] || 'bg-primary-100 text-primary-700') + ' px-1.5 py-0.5 rounded-full font-medium';
                    document.getElementById('aiDot').classList.add('hidden');
                } catch (_) {}
            }
        }

        // ========== FETCH GEMINI ANALYSIS ==========
        async function fetchGeminiAnalysis() {
            var geminiOk = false;
            try {
                document.getElementById('aiSourceBadge').textContent = '⏳ Gemini...';
                document.getElementById('aiSourceBadge').className = 'text-[10px] bg-amber-100 text-amber-700 px-1.5 py-0.5 rounded-full font-medium animate-pulse';
            } catch (_) {}

            const payload = buildCyclonePayload();

            const controller = new AbortController();
            const timeout = setTimeout(() => controller.abort(), 10000);

            try {
                const response = await fetch(window.location.pathname, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload),
                    signal: controller.signal
                });
                if (!response.ok) return;
                const result = await response.json();
                if (result && result.success && result.data) {
                    aiAnalysisData = { data: result.data };
                    renderAIAnalysis();
                    geminiOk = true;
                    return;
                }
            } catch (e) {
                console.warn('Analyse Gemini non disponible:', e);
            } finally {
                clearTimeout(timeout);
                if (!geminiOk) {
                    try {
                        document.getElementById('aiSourceBadge').textContent = 'Local';
                        document.getElementById('aiSourceBadge').className = 'text-[10px] bg-primary-100 text-primary-700 px-1.5 py-0.5 rounded-full font-medium';
                        document.getElementById('aiDot').classList.add('hidden');
                    } catch (_) {}
                }
            }
        }

        // ========== AUTO-REFRESH AI ANALYSIS ==========
        var aiAutoRefreshTimer = null;

        function startAIAutoRefresh() {
            stopAIAutoRefresh();
            var ri = document.getElementById('aiRefreshIndicator');
            if (ri) { ri.style.display = 'inline'; }
            var countdown = 30;
            aiAutoRefreshTimer = setInterval(function() {
                countdown--;
                if (ri) { ri.textContent = countdown + 's⏱'; }
                if (countdown <= 0) {
                    var panel = document.getElementById('aiPanel');
                    if (!panel.classList.contains('hidden') && !simulationMode) {
                        fetchOpenRouterAnalysis();
                    }
                    countdown = 30;
                }
            }, 1000);
        }

        function stopAIAutoRefresh() {
            if (aiAutoRefreshTimer) {
                clearInterval(aiAutoRefreshTimer);
                aiAutoRefreshTimer = null;
            }
            var ri = document.getElementById('aiRefreshIndicator');
            if (ri) { ri.style.display = 'none'; }
        }

        // ========== ZONE-SPECIFIC ADVICE - LOCAL HEURISTIC FALLBACK ==========
        function analyzeZoneLocally(cycloneData, lat, lng, nearbyShelters) {
            var w = cycloneData.wind_speed || cycloneData.danger_score || 50;
            var lvl = cycloneData.level || 'vigilance';
            var shelterName = nearbyShelters && nearbyShelters.length > 0
                ? nearbyShelters[0].name : 'Abri le plus proche';

            if (w >= 120 || lvl === 'urgence') {
                return {
                    conseil_zone: 'DANGER IMMÉDIAT. Évacuez vers l\'abri le plus proche sans attendre.',
                    abri_conseille: shelterName,
                    action_immediate: 'Évacuez immédiatement vers l\'intérieur des terres ou l\'abri désigné.',
                    duree_alerte: 'Impact imminent (moins d\'1 heure)'
                };
            } else if (w >= 80 || lvl === 'alerte') {
                return {
                    conseil_zone: 'Situation dangereuse. Préparez-vous à évacuer rapidement.',
                    abri_conseille: shelterName,
                    action_immediate: 'Sécurisez votre maison et faites vos bagages d\'urgence.',
                    duree_alerte: 'Arrivée estimée dans 2 à 4 heures'
                };
            } else if (w >= 50 || lvl === 'vigilance') {
                return {
                    conseil_zone: 'Surveillez la situation. Restez informé via les canaux officiels.',
                    abri_conseille: shelterName,
                    action_immediate: 'Préparez un kit d\'urgence par précaution.',
                    duree_alerte: 'Non déterminée avec précision'
                };
            } else {
                return {
                    conseil_zone: 'Aucune menace immédiate pour cette zone.',
                    abri_conseille: shelterName,
                    action_immediate: 'Restez vigilant et suivez les informations officielles.',
                    duree_alerte: 'Aucune alerte en cours'
                };
            }
        }

        // ========== ZONE-SPECIFIC ADVICE ON CYCLONE CLICK ==========
        function showZoneAdvice(cycloneData, lat, lng) {
            var nearbyShelters = (simulationMode && simulationDataCache && simulationDataCache.shelters
                ? simulationDataCache.shelters
                : sheltersList.concat(SIMULATION_SHELTERS)
            ).filter(function(s) {
                var slat = s.location_lat || s.lat;
                var slng = s.location_lng || s.lng;
                return slat && slng && distanceKm(lat, lng, slat, slng) < 50;
            }).slice(0, 3);

            var advicePopup = L.popup({ className: 'zone-advice-popup', maxWidth: 350 })
                .setLatLng([lat, lng])
                .setContent(
                    '<div class="p-2" style="min-width:250px">' +
                        '<div class="flex items-center gap-2 mb-2">' +
                            '<span class="px-2 py-0.5 text-[10px] font-bold text-white rounded bg-purple-600">CONSEIL IA</span>' +
                            '<span class="text-[10px] text-gray-400" id="zoneAdviceSource">OpenRouter</span>' +
                        '</div>' +
                        '<div id="zoneAdviceContent" class="text-xs text-gray-600">' +
                            '<div class="animate-spin w-5 h-5 border-2 border-purple-500 border-t-transparent rounded-full mx-auto mb-2"></div>' +
                            '<p class="text-center text-gray-400">Analyse de la zone...</p>' +
                        '</div>' +
                    '</div>'
                ).openOn(map);

            fetch(window.location.pathname + '?action=zone-advice', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    cyclone: {
                        lat: lat,
                        lng: lng,
                        title: cycloneData.title || 'Système cyclonique',
                        level: cycloneData.level || 'vigilance',
                        wind_speed: cycloneData.wind_speed || cycloneData.danger_score || 50,
                        pressure: cycloneData.pressure || 990
                    },
                    user_lat: lat,
                    user_lng: lng,
                    nearby_shelters: nearbyShelters.map(function(s) {
                        return {
                            lat: s.location_lat || s.lat,
                            lng: s.location_lng || s.lng,
                            name: s.name || 'Abri',
                            capacity: s.capacity || 0
                        };
                    })
                })
            })
            .then(function(r) { return r.json(); })
            .then(function(result) {
                if (result && result.success && result.data) {
                    var d = result.data;
                    document.getElementById('zoneAdviceContent').innerHTML =
                        '<div class="space-y-2">' +
                            '<div class="bg-purple-50 rounded-lg p-2"><span class="font-semibold text-purple-700">💡 ' + (d.conseil_zone || 'Soyez vigilant') + '</span></div>' +
                            (d.action_immediate ? '<div class="bg-amber-50 rounded-lg p-2"><span class="font-semibold text-amber-700">⚡ Action: ' + d.action_immediate + '</span></div>' : '') +
                            (d.abri_conseille ? '<div class="bg-emerald-50 rounded-lg p-2"><span class="font-semibold text-emerald-700">🏠 Abri: ' + d.abri_conseille + '</span></div>' : '') +
                            (d.duree_alerte ? '<div class="bg-blue-50 rounded-lg p-2"><span class="font-semibold text-blue-700">🕐 ' + d.duree_alerte + '</span></div>' : '') +
                        '</div>';
                } else {
                    // Fallback local si API indisponible
                    var localAdvice = analyzeZoneLocally(cycloneData, lat, lng, nearbyShelters);
                    document.getElementById('zoneAdviceSource').textContent = 'Local';
                    document.getElementById('zoneAdviceContent').innerHTML =
                        '<div class="space-y-2">' +
                            '<div class="bg-purple-50 rounded-lg p-2"><span class="font-semibold text-purple-700">💡 ' + localAdvice.conseil_zone + '</span></div>' +
                            '<div class="bg-amber-50 rounded-lg p-2"><span class="font-semibold text-amber-700">⚡ Action: ' + localAdvice.action_immediate + '</span></div>' +
                            '<div class="bg-emerald-50 rounded-lg p-2"><span class="font-semibold text-emerald-700">🏠 Abri: ' + localAdvice.abri_conseille + '</span></div>' +
                            '<div class="bg-blue-50 rounded-lg p-2"><span class="font-semibold text-blue-700">🕐 ' + localAdvice.duree_alerte + '</span></div>' +
                        '</div>';
                }
            })
            .catch(function() {
                // Fallback local en cas d'erreur réseau
                var localAdvice = analyzeZoneLocally(cycloneData, lat, lng, nearbyShelters);
                document.getElementById('zoneAdviceSource').textContent = 'Local';
                document.getElementById('zoneAdviceContent').innerHTML =
                    '<div class="space-y-2">' +
                        '<div class="bg-purple-50 rounded-lg p-2"><span class="font-semibold text-purple-700">💡 ' + localAdvice.conseil_zone + '</span></div>' +
                        '<div class="bg-amber-50 rounded-lg p-2"><span class="font-semibold text-amber-700">⚡ Action: ' + localAdvice.action_immediate + '</span></div>' +
                        '<div class="bg-emerald-50 rounded-lg p-2"><span class="font-semibold text-emerald-700">🏠 Abri: ' + localAdvice.abri_conseille + '</span></div>' +
                        '<div class="bg-blue-50 rounded-lg p-2"><span class="font-semibold text-blue-700">🕐 ' + localAdvice.duree_alerte + '</span></div>' +
                    '</div>';
            });
        }

        // ========== LAUNCH AI ANALYSES ==========
        // 1. Local analysis (instantané)
        // 2. OpenRouter+ML analysis immédiate (primaire)
        // 3. Auto-refresh toutes les 30s
        fetchOpenRouterAnalysis();
        startAIAutoRefresh();

        function toggleAIPanel() {
            var ap = document.getElementById('aiPanel');
            ap.classList.toggle('hidden');
            ap.style.opacity = ap.classList.contains('hidden') ? '0' : '1';
            if (!ap.classList.contains('hidden')) {
                renderAIAnalysis();
            }
        }

        function renderAIAnalysis() {
            try {
                const data = aiAnalysisData && aiAnalysisData.data ? aiAnalysisData.data : aiAnalysisData;
                document.getElementById('aiLoading').classList.add('hidden');
                document.getElementById('aiContent').classList.remove('hidden');

                // Show simulation badge if in simulation mode
                var simBadge = document.getElementById('aiSimBadge');
                if (simBadge) {
                    if (simulationMode && simulationDataCache) {
                        simBadge.classList.remove('hidden');
                    } else {
                        simBadge.classList.add('hidden');
                    }
                }

                const riskBadge = document.getElementById('aiRiskBadge');
                const risk = data.risque_global || 'modéré';
                const riskColors = { faible: 'bg-emerald-500', modéré: 'bg-amber-500', eleve: 'bg-orange-600', critique: 'bg-red-600' };
                const riskIcons = { faible: 'bi-check-circle', modéré: 'bi-exclamation-triangle', eleve: 'bi-exclamation-triangle-fill', critique: 'bi-x-circle-fill' };
                riskBadge.className = 'flex items-center gap-2 mb-3 px-3 py-2 rounded-xl text-white text-xs font-bold ' + (riskColors[risk] || 'bg-amber-500');
                riskBadge.innerHTML = '<i class="' + (riskIcons[risk] || 'bi-exclamation-triangle') + '"></i> Risque global: ' + risk.toUpperCase();
                riskBadge.classList.remove('hidden');

                document.getElementById('aiResume').textContent = data.resume || '';

                const cycSection = document.getElementById('aiCyclonesSection');
                const cycList = document.getElementById('aiCyclonesList');
                if (data.analyse_cyclones && data.analyse_cyclones.length > 0) {
                    cycList.innerHTML = data.analyse_cyclones.map(c => {
                        const rc = c.risque || 'modéré';
                        const cm = { faible: 'bg-emerald-100 text-emerald-700', modéré: 'bg-amber-100 text-amber-700', eleve: 'bg-orange-100 text-orange-700', critique: 'bg-red-100 text-red-700' };
                        return '<div class="bg-gray-50 rounded-lg p-2 text-xs">' +
                            '<div class="flex items-center justify-between mb-1"><span class="font-semibold text-gray-800">' + (c.nom || 'Cyclone') + '</span><span class="px-1.5 py-0.5 rounded ' + (cm[rc] || 'bg-gray-100 text-gray-600') + ' font-bold text-[10px]">' + rc.toUpperCase() + '</span></div>' +
                            (c.vitesse_vent_estimee_kmh ? '<div class="text-gray-500">💨 ' + c.vitesse_vent_estimee_kmh + ' km/h</div>' : '') +
                            (c.direction ? '<div class="text-gray-500">➡️ ' + c.direction + '</div>' : '') +
                            (c.zones_menacees && c.zones_menacees.length ? '<div class="text-gray-500 mt-1">📍 ' + c.zones_menacees.join(', ') + '</div>' : '') +
                            (c.recommandation ? '<div class="mt-1 text-primary-600 font-medium">💡 ' + c.recommandation + '</div>' : '') +
                        '</div>';
                    }).join('');
                    cycSection.classList.remove('hidden');
                } else cycSection.classList.add('hidden');

                const recSection = document.getElementById('aiRecommandationsSection');
                const recList = document.getElementById('aiRecommandationsList');
                const recs = data.recommandations_public || [];
                if (recs.length > 0) {
                    recList.innerHTML = recs.map(r => '<li class="flex items-start gap-2 text-xs text-gray-600"><i class="bi bi-check-circle text-primary-500 mt-0.5"></i>' + r + '</li>').join('');
                    recSection.classList.remove('hidden');
                } else recSection.classList.add('hidden');

                const alertSection = document.getElementById('aiAlertsSection');
                const alertList = document.getElementById('aiAlertsList');
                const alertsData = data.alertes_generees || [];
                if (alertsData.length > 0) {
                    const lc = { info: 'bg-blue-500', vigilance: 'bg-amber-500', alerte: 'bg-orange-500', urgence: 'bg-red-600' };
                    alertList.innerHTML = alertsData.map(a => '<div class="border-l-4 ' + (lc[a.niveau] || 'bg-gray-400') + ' bg-gray-50 rounded-r-lg p-2 text-xs"><div class="font-semibold text-gray-800">' + (a.titre || '') + '</div><div class="text-gray-500">' + (a.message || '') + '</div>' + (a.zone_concernee ? '<div class="text-gray-400 mt-1">📍 ' + a.zone_concernee + '</div>' : '') + '</div>').join('');
                    alertSection.classList.remove('hidden');
                } else alertSection.classList.add('hidden');

                const evacSection = document.getElementById('aiEvacuationSection');
                const evacText = document.getElementById('aiEvacuationText');
                if (data.conseils_evacuation) {
                    evacText.textContent = data.conseils_evacuation;
                    evacSection.classList.remove('hidden');
                } else evacSection.classList.add('hidden');

                document.getElementById('aiTimestamp').textContent = '🕐 ' + (data.timestamp_analyse || '');
                checkCriticalAlert(data);
            } catch (e) {
                console.error('renderAIAnalysis error:', e);
                document.getElementById('aiLoading').classList.add('hidden');
                document.getElementById('aiError').classList.remove('hidden');
            }
        }

        // ========== RED ALERT SOUND & BANNER ==========
        function playAlertSound() {
            try {
                var ctx = new (window.AudioContext || window.webkitAudioContext)();
                var osc = ctx.createOscillator();
                var gain = ctx.createGain();
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.type = 'sawtooth';
                gain.gain.setValueAtTime(0.25, ctx.currentTime);
                var baseFreq = 440;
                for (var i = 0; i < 8; i++) {
                    var t = ctx.currentTime + i * 0.4;
                    osc.frequency.setValueAtTime(baseFreq, t);
                    osc.frequency.exponentialRampToValueAtTime(baseFreq * 2, t + 0.2);
                    osc.frequency.exponentialRampToValueAtTime(baseFreq, t + 0.4);
                }
                osc.start(ctx.currentTime);
                osc.stop(ctx.currentTime + 3.2);
                osc.onended = function() { try { ctx.close(); } catch(e) {} };
            } catch(e) { console.warn('Alert sound not available:', e); }
        }

        function checkCriticalAlert(data) {
            try {
                var risk = (data.risque_global || '').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
                var hasUrgence = (data.alertes_generees || []).some(function(a) {
                    return (a.niveau || '').toLowerCase() === 'urgence';
                });
                var shouldAlert = risk === 'critique' || hasUrgence;
                var banner = document.getElementById('criticalAlertBanner');
                if (!banner) return;
                if (shouldAlert) {
                    var msg = data.resume || 'Alerte cyclonique critique detectee';
                    document.getElementById('criticalAlertMessage').textContent = msg;
                    banner.style.display = 'block';
                    banner.classList.remove('hidden');
                    playAlertSound();
                    if (window._alertTimeout) clearTimeout(window._alertTimeout);
                    window._alertTimeout = setTimeout(dismissCriticalAlert, 12000);
                }
            } catch(e) { console.warn('checkCriticalAlert error:', e); }
        }

        function dismissCriticalAlert() {
            var banner = document.getElementById('criticalAlertBanner');
            if (banner) { banner.style.display = 'none'; banner.classList.add('hidden'); }
            if (window._alertTimeout) { clearTimeout(window._alertTimeout); window._alertTimeout = null; }
        }

        function getSimCurrentData() {
            if (!simTrack.length || simIndex < 0 || simIndex >= simTrack.length) return null;
            var p = simTrack[simIndex];
            var prev = simIndex > 0 ? simTrack[simIndex - 1] : null;
            var dir = 'Stationnaire';
            if (prev) {
                var dLat = p.lat - prev.lat;
                var dLng = p.lng - prev.lng;
                if (Math.abs(dLat) < 0.01 && Math.abs(dLng) < 0.01) {
                    dir = 'Stationnaire';
                } else if (Math.abs(dLat) < Math.abs(dLng)) {
                    dir = dLng > 0 ? 'Se déplace vers l\'Est' : 'Se déplace vers l\'Ouest';
                } else if (Math.abs(dLng) < Math.abs(dLat)) {
                    dir = dLat > 0 ? 'Se déplace vers le Sud' : 'Se déplace vers le Nord';
                } else {
                    dir = dLng > 0 ? 'Se déplace vers le Sud-Est' : 'Se déplace vers le Sud-Ouest';
                }
            }
            var menace = [];
            if (p.lng > 48) menace = ['Côte Est', 'Toamasina', 'Régions côtières'];
            else if (p.lng > 44) menace = ['Régions intérieures', 'Antananarivo'];
            else menace = ['Zones Ouest', 'Toliara'];
            return {
                cyclones: [{
                    lat: p.lat, lng: p.lng,
                    title: p.stage || 'Cyclone simulé',
                    level: (p.wind || 0) >= 154 ? 'urgence' : (p.wind || 0) >= 63 ? 'alerte' : 'vigilance',
                    wind_speed: p.wind || 0,
                    pressure: p.pressure || 990,
                    direction: dir,
                    zones_menacees: menace
                }],
                incidents: simulationDataCache ? simulationDataCache.incidents : [],
                shelters: simulationDataCache ? simulationDataCache.shelters : []
            };
        }

        function refreshAIAnalysis() {
            var simCurrent = getSimCurrentData();
            if (simCurrent) {
                aiAnalysisData = { data: analyzeLocally(simCurrent) };
            } else if (simulationMode && simulationDataCache) {
                aiAnalysisData = { data: analyzeLocally(simulationDataCache) };
            } else {
                aiAnalysisData = { data: analyzeLocally() };
            }
            renderAIAnalysis();
            fetchOpenRouterAnalysis();
            fetchGeminiAnalysis();
        }

        // Auto-show AI panel immediately
        setTimeout(function() {
            try {
                var ap = document.getElementById('aiPanel');
                if (ap) {
                    ap.classList.remove('hidden');
                    ap.style.opacity = '1';
                }
                renderAIAnalysis();
            } catch(e) {
                console.error('Auto-show AI panel error:', e);
            }
        }, 300);

        function filterLayers(type, event) {
            const buttons = document.querySelectorAll('.layer-filter-btn');
            buttons.forEach(btn => {
                btn.classList.remove('bg-primary-600', 'text-white', 'shadow-sm');
                btn.classList.add('text-gray-500');
            });

            if (event) {
                event.target.classList.add('bg-primary-600', 'text-white', 'shadow-sm');
                event.target.classList.remove('text-gray-500');
            }

            map.removeLayer(cycloneLayer);
            map.removeLayer(incidentLayer);
            map.removeLayer(shelterLayer);

            if (type === 'all') {
                map.addLayer(cycloneLayer);
                map.addLayer(incidentLayer);
                map.addLayer(shelterLayer);
            } else if (type === 'cyclone') {
                map.addLayer(cycloneLayer);
            } else if (type === 'incident') {
                map.addLayer(incidentLayer);
            } else if (type === 'shelter') {
                map.addLayer(shelterLayer);
            }
        }

        // ====== TRAJECTORY SIMULATION PLAYBACK ======

        var simTrack = [];
        var simIndex = 0;
        var simPlaying = false;
        var simPlaybackSpeed = 1;
        var simTimer = null;
        var simMarker = null;
        var simPolyline = null;
        var simLayer = null; try { simLayer = L.layerGroup().addTo(map); } catch(e) { console.warn('simLayer init:', e); }
        var simDamageCircle = null;
        var heatmapGrid = {};
        var heatmapLayer = null; try { heatmapLayer = L.layerGroup().addTo(map); } catch(e) { console.warn('heatmapLayer init:', e); }
        var evacLines = [];
        var totalAffectedPopulation = 0;
        var totalImpactedArea = 0;
        var simSheltersUsed = [];
        var frameCounter = 0;
        var affectedCityIds = [];
        var newlyAffected = [];

        function toggleSimPanel() {
            var p = document.getElementById('simPanel');
            p.classList.toggle('hidden');
            p.style.opacity = p.classList.contains('hidden') ? '0' : '1';
            if (!p.classList.contains('hidden') && document.getElementById('simSelect').options.length <= 1) {
                loadSimulations();
            }
        }

        async function loadSimulations() {
            try {
                document.getElementById('simLoading').classList.remove('hidden');
                document.getElementById('simContent').classList.add('hidden');
                document.getElementById('simEmpty').classList.add('hidden');
            } catch(_) {}

            var sel = document.getElementById('simSelect');
            if (sel) sel.innerHTML = '<option value="">Sélectionner une simulation</option>';

            var trackToLoad = null;
            try {
                var controller = new AbortController();
                var timeout = setTimeout(function() { controller.abort(); }, 8000);
                var resp = await fetch(window.location.pathname + '?action=simulations', { signal: controller.signal });
                clearTimeout(timeout);
                if (!resp.ok) throw new Error('Erreur réseau');
                var data = await resp.json();
                var sims = (data.simulations || []).filter(function(s) {
                    return s.status === 'completed' && s.results && s.results.track;
                });
                if (sims.length > 0) {
                    sims.forEach(function(s) {
                        var opt = document.createElement('option');
                        opt.value = s.id;
                        opt.textContent = s.name + ' (' + (s.results.max_wind_kmh || '?') + ' km/h)';
                        opt._data = s;
                        if (sel) sel.appendChild(opt);
                    });
                    trackToLoad = sims[0].results.track;
                } else {
                    throw new Error('Aucune simulation');
                }
            } catch (e) {
                console.warn('API simulations indisponible, utilisation Gezani par défaut:', e);
                trackToLoad = GEZANI_TRACK;
            }
            // Always add Gezani option
            if (sel) {
                var opt = document.createElement('option');
                opt.value = 'gezani';
                opt.textContent = 'Cyclone Gezani (185 km/h)';
                opt._track = trackToLoad || GEZANI_TRACK;
                sel.appendChild(opt);
                sel.value = 'gezani';
            }
            if (trackToLoad) {
                try {
                    document.getElementById('simContent').classList.remove('hidden');
                    document.getElementById('simEmpty').classList.add('hidden');
                } catch(_) {}
                loadTrack(trackToLoad);
            } else {
                try {
                    document.getElementById('simEmpty').classList.remove('hidden');
                } catch(_) {}
            }
            try {
                document.getElementById('simLoading').classList.add('hidden');
            } catch(_) {}
        }

        function onSimSelect(id) {
            if (!id) { clearSimTrack(); return; }
            var sel = document.getElementById('simSelect');
            var data = null, track = null;
            for (var i = 0; i < sel.options.length; i++) {
                if (sel.options[i].value === id) {
                    data = sel.options[i]._data;
                    track = sel.options[i]._track;
                    break;
                }
            }
            if (track) { loadTrack(track); return; }
            if (!data || !data.results || !data.results.track) return;
            loadTrack(data.results.track);
        }

        function createSimPopupContent(p) {
            var level = (p.wind||0) >= 154 ? 'urgence' : (p.wind||0) >= 63 ? 'alerte' : 'vigilance';
            var levelColor = getLevelColor(level);
            var label = getLevelLabel(level);
            var lat = p.lat, lng = p.lng;
            return '<div class="p-3 min-w-[220px]">' +
                '<span class="px-2 py-0.5 text-[10px] font-bold text-white rounded" style="background:' + levelColor + '">SIMULATION ' + label + '</span>' +
                '<h6 class="font-bold text-gray-900 text-sm mt-2 mb-1">' + (p.stage || 'Cyclone simulé') + '</h6>' +
                '<p class="text-xs text-gray-500 mb-2">Vent: ' + (p.wind||0) + ' km/h | Pression: ' + (p.pressure||0) + ' hPa</p>' +
                '<div class="grid grid-cols-2 gap-2 text-xs mb-2">' +
                    '<div class="bg-gray-100 rounded-lg p-2 text-center"><div class="text-' + (level === 'urgence' ? 'red' : level === 'alerte' ? 'amber' : 'blue') + '-600 font-bold text-sm">' + (p.wind||0) + '</div><div class="text-gray-500">Vent (km/h)</div></div>' +
                    '<div class="bg-gray-100 rounded-lg p-2 text-center"><div class="text-primary-600 font-bold text-sm">' + (p.pressure||0) + '</div><div class="text-gray-500">Pression</div></div>' +
                '</div>' +
                (p.datetime ? '<p class="text-[10px] text-gray-400 mb-2">' + p.datetime + '</p>' : '') +
                "<button onclick='showZoneAdvice(" + JSON.stringify({ title: p.stage || 'Cyclone simulé', level: level, wind_speed: p.wind, pressure: p.pressure }) + ", " + lat + ", " + lng + ")' class='w-full px-3 py-1.5 bg-purple-600 text-white font-semibold text-xs rounded-lg hover:bg-purple-700 transition-colors'>💡 Conseil IA OpenRouter</button>" +
                '<a href="evacuation?lat=' + lat + '&lng=' + lng + '" class="mt-1 inline-block w-full text-center px-3 py-1.5 bg-primary-600 text-white font-semibold text-xs rounded-lg no-underline hover:bg-primary-700 transition-colors">Voir évacuation</a>' +
            '</div>';
        }

        function loadTrack(track) {
            try {
                simPlaying = false;
                if (simTimer) { clearInterval(simTimer); simTimer = null; }
                if (simMarker) { map.removeLayer(simMarker); simMarker = null; }
                if (simPolyline) { map.removeLayer(simPolyline); simPolyline = null; }
                if (simDamageCircle) { map.removeLayer(simDamageCircle); simDamageCircle = null; }
                if (evacLines) { evacLines.forEach(function(l) { try { map.removeLayer(l); } catch(e) {} }); }
                evacLines = [];
                simTrack = [];
                simIndex = 0;

                simTrack = track;
                if (simTrack.length === 0) return;

                var slider = document.getElementById('simSlider');
                if (slider) {
                    slider.max = simTrack.length - 1;
                    slider.value = 0;
                }

                var timeEnd = document.getElementById('simTimeEnd');
                if (timeEnd) timeEnd.textContent = simTrack[simTrack.length - 1].datetime || 'Fin';
                var trackInfo = document.getElementById('simTrackInfo');
                if (trackInfo) {
                    trackInfo.classList.remove('hidden');
                    trackInfo.style.display = 'block';
                }

                var pts = simTrack.map(function(p) { return [p.lat, p.lng]; });
                simPolyline = L.polyline(pts, { color: '#7c3aed', weight: 2.5, opacity: 0.7, dashArray: '6, 4' }).addTo(map);

                var last = simTrack[0];
                simMarker = L.marker([last.lat, last.lng], {
                    icon: createMarkerIcon('🌀', 'linear-gradient(135deg, #7c3aed, #ec4899)', 44)
                }).addTo(map);
                simMarker.bindPopup(createSimPopupContent(last));
                simMarker.on('click', function() {
                    var p = simTrack[simIndex];
                    showZoneAdvice({ title: p.stage || 'Cyclone simulé', level: (p.wind||0) >= 154 ? 'urgence' : (p.wind||0) >= 63 ? 'alerte' : 'vigilance', wind_speed: p.wind, pressure: p.pressure }, p.lat, p.lng);
                });

                var initWind = last.wind || 0;
                var initRadius = getDamageRadius(initWind);
                var initColor = initWind >= 209 ? '#dc2626' : initWind >= 154 ? '#f97316' : initWind >= 119 ? '#f59e0b' : '#3b82f6';
                simDamageCircle = L.circle([last.lat, last.lng], {
                    color: initColor,
                    fillColor: initColor,
                    fillOpacity: 0.15,
                    weight: 3,
                    radius: initRadius
                }).addTo(map);

                try { map.fitBounds(pts, { padding: [50, 50], maxZoom: 7 }); } catch(e) {}
                try { map.invalidateSize(); } catch(e) {}
                updateSimFrame(0);
            } catch (e) {
                console.error('Erreur loadTrack:', e);
            }
        }

        function clearSimTrack() {
            simPlaying = false;
            if (simTimer) { clearInterval(simTimer); simTimer = null; }
            simTrack = [];
            simIndex = 0;
            try { if (simMarker) { map.removeLayer(simMarker); } } catch(e) {}
            try { if (simPolyline) { map.removeLayer(simPolyline); } } catch(e) {}
            try { if (simDamageCircle) { map.removeLayer(simDamageCircle); } } catch(e) {}
            if (evacLines) { evacLines.forEach(function(l) { try { map.removeLayer(l); } catch(e) {} }); }
            evacLines = [];
            if (heatmapLayer) { try { heatmapLayer.clearLayers(); } catch(e) {} }
            simMarker = null;
            simPolyline = null;
            simDamageCircle = null;
            heatmapGrid = {};
            totalAffectedPopulation = 0;
            totalImpactedArea = 0;
            simSheltersUsed = [];
            frameCounter = 0;
            affectedCityIds = [];
            var el;
            el = document.getElementById('simTrackInfo'); if (el) { el.classList.add('hidden'); el.style.display = 'none'; }
            el = document.getElementById('simPlayBtn'); if (el) el.innerHTML = '<i class="bi bi-play-fill"></i> Lire';
            el = document.getElementById('simPopulation'); if (el) el.textContent = 'Population touchée: 0';
            el = document.getElementById('simSummary'); if (el) el.classList.add('hidden');
        }

        function updateSimFrame(idx) {
            if (!simTrack.length || idx < 0 || idx >= simTrack.length) return;
            simIndex = idx;
            var p = simTrack[idx];

            document.getElementById('simSlider').value = idx;
            document.getElementById('simTimeLabel').textContent = p.datetime || '';
            document.getElementById('simPos').textContent = p.lat + 'S, ' + p.lng + 'E';
            document.getElementById('simWind').textContent = (p.wind || 0) + ' km/h';
            document.getElementById('simPressure').textContent = (p.pressure || 0) + ' hPa';
            document.getElementById('simStage').textContent = p.stage || '--';

            if (simMarker) {
                simMarker.setLatLng([p.lat, p.lng]);
                simMarker.setPopupContent(createSimPopupContent(p));
            }
            if (simPolyline) {
                var pts = simTrack.slice(0, idx + 1).map(function(pt) { return [pt.lat, pt.lng]; });
                simPolyline.setLatLngs(pts);
            }
            var windPct = Math.min(100, ((p.wind || 0) / 220) * 100);
            var wColor = windPct > 70 ? '#dc2626' : windPct > 40 ? '#f59e0b' : '#10b981';
            document.getElementById('simWind').className = 'font-semibold ' + (windPct > 70 ? 'text-red-600' : windPct > 40 ? 'text-amber-600' : 'text-emerald-600');

            // Cercle de dégâts mobile : basé sur l'échelle de Saffir-Simpson réelle
            var wind = p.wind || 0;
            var dmgRadius = getDamageRadius(wind);
            var dmgColor = wind >= 209 ? '#dc2626' : wind >= 154 ? '#f97316' : wind >= 119 ? '#f59e0b' : wind >= 63 ? '#3b82f6' : '#6b7280';
            if (simDamageCircle) {
                simDamageCircle.setLatLng([p.lat, p.lng]);
                simDamageCircle.setRadius(dmgRadius);
                simDamageCircle.setStyle({ color: dmgColor, fillColor: dmgColor, fillOpacity: dmgRadius > 0 ? 0.15 : 0 });
            }

            // F2: Update heatmap grid
            var gridLat = Math.round(p.lat * 4) / 4;
            var gridLng = Math.round(p.lng * 4) / 4;
            var key = gridLat + ',' + gridLng;
            heatmapGrid[key] = (heatmapGrid[key] || 0) + 1;

            // F4: Evacuation line from damage center to nearest shelter
            var nearestS = findNearestShelter(p.lat, p.lng);
            if (nearestS) {
                var slat = nearestS.location_lat || nearestS.lat;
                var slng = nearestS.location_lng || nearestS.lng;
                if (slat && slng) {
                    var evacLine = L.polyline([[p.lat, p.lng], [slat, slng]], {
                        color: '#f59e0b',
                        weight: 2,
                        opacity: 0.5,
                        dashArray: '8, 6'
                    }).addTo(map);
                    evacLines.push(evacLine);
                    if (simSheltersUsed.indexOf(nearestS.id) === -1) {
                        simSheltersUsed.push(nearestS.id);
                    }
                }
            }

            // F5: Population touchée basée sur les villes réelles dans le rayon
            var radiusKm = dmgRadius / 1000;
            var popResult = getAffectedPopulation(p.lat, p.lng, radiusKm);
            popResult.cities.forEach(function(cityName) {
                if (affectedCityIds.indexOf(cityName) === -1) {
                    affectedCityIds.push(cityName);
                    newlyAffected.push(cityName);
                }
            });
            totalAffectedPopulation = 0;
            affectedCityIds.forEach(function(cid) {
                POPULATION_CENTERS.forEach(function(c) {
                    if (c.name === cid) totalAffectedPopulation += c.pop;
                });
            });
            var areaKm2 = Math.PI * dmgRadius * dmgRadius / 1000000;
            totalImpactedArea += areaKm2;
            var citiesNow = popResult.cities.length > 0 ? popResult.cities.join(', ') : 'aucune';
            document.getElementById('simPopulation').textContent = 'Touchés: ' + totalAffectedPopulation.toLocaleString() + ' hab. | Villes: ' + citiesNow;

            // Zone advice when cyclone passes near populated cities
            if (popResult.cities.length > 0 && Math.random() < 0.3) {
                var nearestCity = popResult.cities[0];
                var adviceMsg = '🌀 Cyclone impacte ' + nearestCity + ' (vents ' + (p.wind || 0) + ' km/h). Consultez le panneau IA pour les recommandations.';
                var c = POPULATION_CENTERS.filter(function(x) { return x.name === nearestCity; })[0];
                if (c) {
                    L.popup()
                        .setLatLng([c.lat, c.lng])
                        .setContent('<div class="p-2 text-xs bg-purple-50 rounded"><span class="font-semibold text-purple-700">⚡ ' + adviceMsg + '</span></div>')
                        .openOn(map);
                    setTimeout(function() { map.closePopup(); }, 4000);
                }
            }
        }

        // ============================================
        // Population data réelle (villes sur la trajectoire de Gezani)
        // ============================================
        var POPULATION_CENTERS = [
            // Madagascar - côte Est (zone d'approche et landfall)
            { name: 'Sambava', lat: -14.2667, lng: 50.1667, pop: 84000 },
            { name: 'Antalaha', lat: -14.9000, lng: 50.2833, pop: 67000 },
            { name: 'Maroantsetra', lat: -15.4333, lng: 49.7333, pop: 42000 },
            { name: 'Fenoarivo Atsinanana', lat: -17.3833, lng: 49.4000, pop: 47000 },
            { name: 'Toamasina', lat: -18.1492, lng: 49.4000, pop: 325857 },
            { name: 'Vatomandry', lat: -19.3333, lng: 48.9833, pop: 35000 },
            // Madagascar - Intérieur (traversée)
            { name: 'Ambatondrazaka', lat: -17.8333, lng: 48.4167, pop: 65000 },
            { name: 'Moramanga', lat: -18.9333, lng: 48.2000, pop: 55000 },
            { name: 'Antananarivo', lat: -18.8792, lng: 47.5079, pop: 1391433 },
            { name: 'Antsirabe', lat: -19.8667, lng: 47.0333, pop: 265018 },
            { name: 'Fianarantsoa', lat: -21.4527, lng: 47.0875, pop: 191776 },
            // Madagascar - côte Ouest (sortie)
            { name: 'Maintirano', lat: -18.0500, lng: 44.0333, pop: 40000 },
            { name: 'Mahajanga', lat: -15.7150, lng: 46.3200, pop: 246022 },
            { name: 'Morondava', lat: -20.2833, lng: 44.2833, pop: 107000 },
            { name: 'Belo sur Tsiribihina', lat: -19.7000, lng: 44.5333, pop: 28000 },
            // Madagascar - Sud-Ouest (second passage)
            { name: 'Toliara', lat: -23.3500, lng: 43.6800, pop: 179147 },
            { name: 'Morombe', lat: -21.7500, lng: 43.3667, pop: 38000 },
            { name: 'Taolanaro', lat: -25.0325, lng: 46.9833, pop: 45000 },
            // Mozambique (traversée canal)
            { name: 'Inhambane', lat: -23.8764, lng: 35.3833, pop: 82000 },
            { name: 'Maxixe', lat: -23.8667, lng: 35.3500, pop: 120000 },
            { name: 'Vilanculos', lat: -22.0000, lng: 35.3167, pop: 56000 },
            { name: 'Beira', lat: -19.8333, lng: 34.8500, pop: 533825 },
            // Autres grandes villes
            { name: 'Antsiranana', lat: -12.2800, lng: 49.2900, pop: 129320 },
            { name: 'Nosy Be', lat: -13.3150, lng: 48.2825, pop: 73000 },
        ];

        function getDamageRadius(wind) {
            if (wind >= 209) return Math.round(wind * 1200);
            if (wind >= 154) return Math.round(wind * 1000);
            if (wind >= 119) return Math.round(wind * 800);
            if (wind >= 89) return Math.round(wind * 500);
            if (wind >= 63) return Math.round(wind * 300);
            if (wind >= 30) return 50000;
            return 30000;
        }

        function getAffectedPopulation(lat, lng, radiusKm) {
            var total = 0, cities = [];
            POPULATION_CENTERS.forEach(function(c) {
                var d = distanceKm(lat, lng, c.lat, c.lng);
                if (d <= radiusKm) {
                    total += c.pop;
                    cities.push(c.name);
                }
            });
            return { total: total, cities: cities };
        }

        // Haversine distance in km
        function distanceKm(lat1, lng1, lat2, lng2) {
            var R = 6371;
            var dLat = (lat2 - lat1) * Math.PI / 180;
            var dLng = (lng2 - lng1) * Math.PI / 180;
            var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                    Math.sin(dLng/2) * Math.sin(dLng/2);
            return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        }

        // F4: Find nearest shelter for evacuation line
        function findNearestShelter(lat, lng) {
            var candidates = [];
            if (simulationMode && simulationDataCache && simulationDataCache.shelters && simulationDataCache.shelters.length > 0) {
                candidates = simulationDataCache.shelters;
            } else if (REAL_SIMULATION_DATA && REAL_SIMULATION_DATA.shelters.length > 0) {
                candidates = REAL_SIMULATION_DATA.shelters;
            } else {
                candidates = sheltersList.length > 0 ? sheltersList : SIMULATION_SHELTERS;
            }
            var best = null, bestDist = Infinity;
            candidates.forEach(function(s) {
                var slat = s.location_lat || s.lat;
                var slng = s.location_lng || s.lng;
                if (!slat || !slng) return;
                var d = distanceKm(lat, lng, slat, slng);
                if (d < bestDist) { bestDist = d; best = s; }
            });
            return best;
        }

        // F6: Show post-simulation summary
        function showSimulationSummary() {
            var totalDist = 0;
            for (var i = 1; i < simTrack.length; i++) {
                totalDist += distanceKm(simTrack[i-1].lat, simTrack[i-1].lng, simTrack[i].lat, simTrack[i].lng);
            }
            var maxW = 0;
            simTrack.forEach(function(p) { if ((p.wind || 0) > maxW) maxW = p.wind; });
            document.getElementById('sumArea').textContent = Math.round(totalImpactedArea) + ' km²';
            document.getElementById('sumPopulation').textContent = totalAffectedPopulation.toLocaleString();
            document.getElementById('sumShelters').textContent = simSheltersUsed.length;
            document.getElementById('sumWind').textContent = Math.round(maxW) + ' km/h';
            document.getElementById('sumDistance').textContent = Math.round(totalDist) + ' km';
            document.getElementById('simSummary').classList.remove('hidden');
            document.getElementById('simSummary').setAttribute('data-cities', affectedCityIds.join(', '));
            var citiesHtml = '';
            if (affectedCityIds.length > 0) {
                citiesHtml = '<div class="text-xs text-gray-600 mt-1 border-t pt-1">🏙️ ' + affectedCityIds.slice(0, 8).join(', ') + (affectedCityIds.length > 8 ? '...' : '') + '</div>';
                document.getElementById('simSummary').insertAdjacentHTML('beforeend', citiesHtml);
            }
            renderHeatmap();
        }

        // F2: Render heatmap grid from collected data
        function renderHeatmap() {
            if (!heatmapLayer) return;
            heatmapLayer.clearLayers();
            var maxFreq = 0;
            for (var k in heatmapGrid) { if (heatmapGrid[k] > maxFreq) maxFreq = heatmapGrid[k]; }
            if (maxFreq === 0) return;
            for (var key in heatmapGrid) {
                var parts = key.split(',');
                var lat = parseFloat(parts[0]);
                var lng = parseFloat(parts[1]);
                var freq = heatmapGrid[key];
                var intensity = freq / maxFreq;
                var r, g, b;
                if (intensity < 0.3) { r = 255; g = Math.round(255 - intensity * 500); b = 100; }
                else if (intensity < 0.6) { r = 255; g = Math.round(200 - intensity * 300); b = 50; }
                else { r = 255; g = Math.round(150 - intensity * 150); b = 50; }
                var color = 'rgb(' + r + ',' + Math.max(0,g) + ',' + Math.max(0,b) + ')';
                L.circle([lat + 0.125, lng + 0.125], {
                    color: color,
                    fillColor: color,
                    fillOpacity: 0.2 + intensity * 0.3,
                    weight: 1,
                    radius: 14000
                }).addTo(heatmapLayer);
            }
        }

        function onSimSlider(val) {
            if (simPlaying) { simPlaying = false; clearInterval(simTimer); simTimer = null; }
            document.getElementById('simPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Lire';
            updateSimFrame(parseInt(val));
            refreshAIAnalysis();
        }

        function togglePlayback() {
            if (simTrack.length === 0) return;
            if (simPlaying) {
                simPlaying = false;
                if (simTimer) { clearInterval(simTimer); simTimer = null; }
                document.getElementById('simPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Lire';
                return;
            }
            if (simIndex >= simTrack.length - 1) simIndex = 0;
            simPlaying = true;
            document.getElementById('simPlayBtn').innerHTML = '<i class="bi bi-pause-fill"></i> Pause';
            var simFrameCount = 0;
            simTimer = setInterval(function() {
                if (simIndex >= simTrack.length - 1) {
                    simPlaying = false;
                    clearInterval(simTimer);
                    simTimer = null;
                    document.getElementById('simPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Rejouer';
                    showSimulationSummary();
                    return;
                }
                simIndex++;
                updateSimFrame(simIndex);
                simFrameCount++;
                if (simFrameCount % 3 === 0) refreshAIAnalysis();
            }, 400 / simPlaybackSpeed);
        }

        function setSpeed(s) {
            simPlaybackSpeed = s;
            document.getElementById('spd1').className = 'px-2 py-1 text-xs font-bold rounded-lg ' + (s === 1 ? 'bg-purple-600 text-white' : 'bg-gray-200 text-gray-600');
            document.getElementById('spd2').className = 'px-2 py-1 text-xs font-bold rounded-lg ' + (s === 2 ? 'bg-purple-600 text-white' : 'bg-gray-200 text-gray-600');
            document.getElementById('spd4').className = 'px-2 py-1 text-xs font-bold rounded-lg ' + (s === 4 ? 'bg-purple-600 text-white' : 'bg-gray-200 text-gray-600');
            if (simPlaying) {
                clearInterval(simTimer);
                var simFrameCount = 0;
                simTimer = setInterval(function() {
                    if (simIndex >= simTrack.length - 1) {
                        simPlaying = false;
                        clearInterval(simTimer);
                        simTimer = null;
                        document.getElementById('simPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Rejouer';
                        showSimulationSummary();
                        return;
                    }
                    simIndex++;
                    updateSimFrame(simIndex);
                    simFrameCount++;
                    if (simFrameCount % 3 === 0) refreshAIAnalysis();
                }, 400 / s);
            }
        }
    </script>
</body>
</html>
