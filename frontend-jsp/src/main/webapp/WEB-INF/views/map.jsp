<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carte des risques - MITANDRINA</title>
    
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
                        primary: { 50: '#ecfdf5', 100: '#d1fae5', 500: '#10b981', 600: '#059669', 700: '#047857' },
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
            .sidebar { transform: translateX(-100%); position: fixed; z-index: 50; }
            .sidebar.open { transform: translateX(0); }
            .main-content { margin-left: 0 !important; }
        }
        .nav-item {
            display: flex; align-items: center; gap: 0.75rem; padding: 0.75rem 1rem; border-radius: 10px;
            color: #64748b; text-decoration: none; font-weight: 500; font-size: 0.9rem; transition: all 0.2s ease; margin-bottom: 0.25rem;
        }
        .nav-item:hover { background: #ecfdf5; color: #059669; }
        .nav-item.active { background: #ecfdf5; color: #059669; font-weight: 600; }
        .btn-icon {
            width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center;
            background: white; border: 1px solid #e2e8f0; color: #64748b; transition: all 0.2s ease;
        }
        .btn-icon:hover { background: #f8fafc; border-color: #cbd5e1; color: #1e293b; }
        .custom-marker { background: transparent; border: none; }
        .marker-pin {
            width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center;
            font-size: 18px; box-shadow: 0 4px 12px rgba(0,0,0,0.25); border: 2.5px solid white; transition: transform 0.2s; cursor: pointer;
        }
        .marker-pin:hover { transform: scale(1.15); }
        @keyframes pulse { 0% { transform: scale(1); opacity: 1; } 50% { transform: scale(1.15); opacity: 0.8; } 100% { transform: scale(1); opacity: 1; } }
        .animate-fade-in-up { animation: fadeInUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; opacity: 0; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        
        .stat-card {
            background: white; border: 1px solid #e2e8f0; border-radius: 12px; padding: 12px 16px;
            transition: all 0.2s ease;
        }
        .stat-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.06); }
        
        .map-popup-card {
            font-family: 'Inter', sans-serif;
            min-width: 240px;
        }
        .map-popup-card h6 { font-weight: 700; font-size: 14px; margin-bottom: 4px; }
        .map-popup-card p { font-size: 12px; color: #64748b; margin-bottom: 4px; }
        
        .leaflet-popup-content-wrapper {
            border-radius: 12px !important;
            box-shadow: 0 8px 24px rgba(0,0,0,0.12) !important;
        }
        .leaflet-popup-content { margin: 12px 16px !important; }
        
        /* Chatbot */
        .chatbot-btn {
            position: fixed; bottom: 24px; right: 24px; z-index: 9999;
            width: 56px; height: 56px; border-radius: 50%;
            background: linear-gradient(135deg, #059669, #047857);
            border: none; color: white; font-size: 24px; cursor: pointer;
            box-shadow: 0 4px 20px rgba(5, 150, 105, 0.4);
            transition: all 0.3s ease; display: flex; align-items: center; justify-content: center;
        }
        .chatbot-btn:hover { transform: scale(1.1); box-shadow: 0 6px 28px rgba(5, 150, 105, 0.5); }
        .chatbot-btn.active { background: #dc2626; box-shadow: 0 4px 20px rgba(220, 38, 38, 0.4); }
        
        .chatbot-panel {
            position: fixed; bottom: 92px; right: 24px; z-index: 9998;
            width: 380px; max-width: calc(100vw - 48px);
            height: 520px; max-height: calc(100vh - 140px);
            background: white; border-radius: 16px; box-shadow: 0 12px 48px rgba(0,0,0,0.18);
            display: none; flex-direction: column; overflow: hidden;
            animation: chatSlideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .chatbot-panel.open { display: flex; }
        @keyframes chatSlideUp { from { opacity: 0; transform: translateY(16px) scale(0.96); } to { opacity: 1; transform: translateY(0) scale(1); } }
        
        .chatbot-header {
            background: linear-gradient(135deg, #059669, #047857);
            padding: 16px 20px; color: white; display: flex; align-items: center; gap: 12px;
        }
        .chatbot-header h3 { font-size: 15px; font-weight: 700; margin: 0; }
        .chatbot-header p { font-size: 11px; opacity: 0.85; margin: 0; }
        
        .chatbot-messages {
            flex: 1; overflow-y: auto; padding: 16px;
            background: #f8fafc; display: flex; flex-direction: column; gap: 12px;
        }
        .chatbot-messages::-webkit-scrollbar { width: 4px; }
        .chatbot-messages::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 2px; }
        
        .chat-msg {
            max-width: 85%; padding: 10px 14px; border-radius: 12px;
            font-size: 13px; line-height: 1.5; word-wrap: break-word;
            animation: msgIn 0.25s ease;
        }
        @keyframes msgIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
        .chat-msg.bot {
            align-self: flex-start; background: white; border: 1px solid #e2e8f0;
            color: #1e293b; border-bottom-left-radius: 4px;
        }
        .chat-msg.user {
            align-self: flex-end; background: #059669; color: white;
            border-bottom-right-radius: 4px;
        }
        .chat-msg.error { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
        
        .chatbot-input {
            display: flex; gap: 8px; padding: 12px 16px;
            border-top: 1px solid #e2e8f0; background: white;
        }
        .chatbot-input input {
            flex: 1; padding: 10px 14px; border: 1px solid #e2e8f0; border-radius: 10px;
            font-size: 13px; outline: none; transition: border 0.2s;
        }
        .chatbot-input input:focus { border-color: #059669; box-shadow: 0 0 0 3px rgba(5,150,105,0.1); }
        .chatbot-input button {
            padding: 10px 18px; background: #059669; color: white; border: none;
            border-radius: 10px; font-size: 13px; font-weight: 600; cursor: pointer;
            transition: background 0.2s; white-space: nowrap;
        }
        .chatbot-input button:hover { background: #047857; }
        .chatbot-input button:disabled { opacity: 0.5; cursor: not-allowed; }
        
        .chatbot-suggestions {
            display: flex; gap: 6px; padding: 8px 16px; flex-wrap: wrap;
            border-top: 1px solid #e2e8f0; background: #f8fafc;
        }
        .chatbot-suggestions button {
            padding: 5px 10px; background: white; border: 1px solid #e2e8f0; border-radius: 16px;
            font-size: 11px; color: #475569; cursor: pointer; transition: all 0.2s;
            white-space: nowrap;
        }
        .chatbot-suggestions button:hover { background: #ecfdf5; border-color: #059669; color: #059669; }
    </style>
    <script src="https://cdn.socket.io/4.7.4/socket.io.min.js"></script>
    <link rel="stylesheet" href="/assets/css/custom.css?v=13a3d199">
</head>
<body class="min-h-screen flex overflow-hidden">
    
    <!-- Sidebar -->
    <aside class="sidebar fixed top-0 left-0 bottom-0 z-50 transition-transform" id="sidebar">
        <div class="flex flex-col h-full">
            <div class="p-6 border-b border-gray-100">
                <a href="./" class="flex items-center gap-2 text-xl font-bold text-gray-900">
                    <i class="bi bi-shield-shaded text-danger-600"></i>
                    <span>MITANDRINA</span>
                </a>
            </div>
            <nav class="flex-1 overflow-y-auto py-4 px-3">
                <div class="px-3 mb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">Principal</div>
                <a href="dashboard" class="nav-item"><i class="bi bi-grid-1x2-fill text-lg"></i><span>Tableau de bord</span></a>
                <a href="map" class="nav-item active"><i class="bi bi-map-fill text-lg"></i><span>Carte des risques</span></a>
                <a href="cyclone-map" class="nav-item"><i class="bi bi-tornado text-lg"></i><span>Carte des cyclones</span></a>
                <a href="alerts" class="nav-item"><i class="bi bi-bell-fill text-lg"></i><span>Alertes</span></a>
                <a href="incidents" class="nav-item"><i class="bi bi-geo-alt-fill text-lg"></i><span>Incidents</span></a>
                <a href="evacuation" class="nav-item"><i class="bi bi-car-front-fill text-lg"></i><span>Évacuation</span></a>
                <c:if test="${sessionScope.user.role == 'administrateur'}">
                    <div class="px-3 mt-6 mb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">Administration</div>
                    <a href="admin/users" class="nav-item"><i class="bi bi-people-fill text-lg"></i><span>Utilisateurs</span></a>
                    <a href="admin/teams" class="nav-item"><i class="bi bi-building-fill text-lg"></i><span>Équipes</span></a>
                    <a href="admin/simulations" class="nav-item"><i class="bi bi-magic text-lg"></i><span>Simulations</span></a>
                </c:if>
            </nav>
            <div class="p-4 border-t border-gray-100">
                <div class="flex items-center gap-3 mb-3 p-3 bg-gray-50 rounded-xl">
                    <div class="w-10 h-10 rounded-full bg-emerald-600 flex items-center justify-center font-semibold text-white text-sm">
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
                <button class="md:hidden btn-icon" onclick="toggleSidebar()"><i class="bi bi-list text-xl"></i></button>
                <div>
                    <h1 class="text-xl font-bold text-gray-900">Carte temps réel</h1>
                    <p class="text-xs text-gray-500">Visualisez les menaces et refuges géolocalisés</p>
                </div>
            </div>
            <div class="flex items-center gap-3">
                <div class="flex items-center gap-1.5 text-xs text-gray-400" id="last-updated">
                    <i class="bi bi-arrow-clockwise"></i><span>Mise à jour...</span>
                </div>
                <div class="flex bg-gray-100 rounded-xl p-1">
                    <button onclick="filterLayers('all', event)" class="layer-filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold bg-white text-gray-900 shadow-sm transition-all">Tout</button>
                    <button onclick="filterLayers('risk', event)" class="layer-filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold text-gray-500 hover:text-gray-900 transition-all">Risques</button>
                    <button onclick="filterLayers('incident', event)" class="layer-filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold text-gray-500 hover:text-gray-900 transition-all">Incidents</button>
                    <button onclick="filterLayers('shelter', event)" class="layer-filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold text-gray-500 hover:text-gray-900 transition-all">Abris</button>
                </div>
                <button onclick="refreshMapData()" class="btn-icon" title="Actualiser">
                    <i class="bi bi-arrow-clockwise"></i>
                </button>
            </div>
        </header>
        
        <!-- Stats Bar -->
        <div class="bg-white border-b border-gray-100 px-6 py-3 flex-shrink-0" id="stats-bar">
            <div class="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-6 gap-3">
                <div class="stat-card flex items-center gap-3">
                    <div class="w-9 h-9 rounded-lg bg-red-50 flex items-center justify-center text-red-600 flex-shrink-0"><i class="bi bi-exclamation-triangle-fill"></i></div>
                    <div><div class="text-lg font-bold text-gray-900" id="stat-risks">0</div><div class="text-[10px] text-gray-500">Risques actifs</div></div>
                </div>
                <div class="stat-card flex items-center gap-3">
                    <div class="w-9 h-9 rounded-lg bg-amber-50 flex items-center justify-center text-amber-600 flex-shrink-0"><i class="bi bi-geo-alt-fill"></i></div>
                    <div><div class="text-lg font-bold text-gray-900" id="stat-incidents">0</div><div class="text-[10px] text-gray-500">Incidents</div></div>
                </div>
                <div class="stat-card flex items-center gap-3">
                    <div class="w-9 h-9 rounded-lg bg-green-50 flex items-center justify-center text-green-600 flex-shrink-0"><i class="bi bi-house-heart-fill"></i></div>
                    <div><div class="text-lg font-bold text-gray-900" id="stat-shelters">0</div><div class="text-[10px] text-gray-500">Refuges ouverts</div></div>
                </div>
                <div class="stat-card flex items-center gap-3">
                    <div class="w-9 h-9 rounded-lg bg-blue-50 flex items-center justify-center text-blue-600 flex-shrink-0"><i class="bi bi-people-fill"></i></div>
                    <div><div class="text-lg font-bold text-gray-900" id="stat-protected">0</div><div class="text-[10px] text-gray-500">Population protégée</div></div>
                </div>
                <div class="stat-card flex items-center gap-3">
                    <div class="w-9 h-9 rounded-lg bg-purple-50 flex items-center justify-center text-purple-600 flex-shrink-0"><i class="bi bi-tornado"></i></div>
                    <div><div class="text-lg font-bold text-gray-900" id="stat-cyclones">0</div><div class="text-[10px] text-gray-500">Cyclones actifs</div></div>
                </div>
                <div class="stat-card flex items-center gap-3">
                    <div class="w-9 h-9 rounded-lg bg-teal-50 flex items-center justify-center text-teal-600 flex-shrink-0"><i class="bi bi-fire"></i></div>
                    <div><div class="text-lg font-bold text-gray-900" id="stat-fires">0</div><div class="text-[10px] text-gray-500">Incendies actifs</div></div>
                </div>
            </div>
        </div>
        
        <!-- Map Container -->
        <div class="flex-1 relative">
            <div id="realtime-map" class="w-full h-full"></div>
            
            <!-- Legend Panel -->
            <div class="absolute bottom-6 left-6 z-[1000] bg-white/90 backdrop-blur-md border border-gray-200 rounded-2xl p-4 shadow-xl max-w-xs w-72 hidden md:block animate-fade-in-up">
                <div class="flex items-center justify-between mb-3">
                    <h4 class="font-bold text-gray-900 text-sm flex items-center gap-2">
                        <span class="w-2.5 h-2.5 bg-green-500 rounded-full animate-pulse"></span>Légende
                    </h4>
                    <button onclick="toggleSimulation()" class="text-xs px-2.5 py-1 rounded-lg bg-purple-50 text-purple-700 font-medium hover:bg-purple-100 transition-colors flex items-center gap-1" id="sim-toggle-btn">
                        <i class="bi bi-magic"></i> Simulation
                    </button>
                </div>
                <div class="space-y-1.5 text-xs text-gray-600 mb-3" id="legend-items">
                    <div class="flex items-center justify-between py-1 px-2 rounded-lg hover:bg-gray-50">
                        <span class="flex items-center gap-2">🔥 Incendie</span>
                        <span class="font-semibold text-red-600 text-[10px]">Critique</span>
                    </div>
                    <div class="flex items-center justify-between py-1 px-2 rounded-lg hover:bg-gray-50">
                        <span class="flex items-center gap-2">💧 Inondation</span>
                        <span class="font-semibold text-amber-500 text-[10px]">Alerte</span>
                    </div>
                    <div class="flex items-center justify-between py-1 px-2 rounded-lg hover:bg-gray-50">
                        <span class="flex items-center gap-2">🌀 Cyclone</span>
                        <span class="font-semibold text-purple-500 text-[10px]">Vigilance</span>
                    </div>
                    <div class="flex items-center justify-between py-1 px-2 rounded-lg hover:bg-gray-50">
                        <span class="flex items-center gap-2">🌊 Tsunami</span>
                        <span class="font-semibold text-blue-600 text-[10px]">Vigilance</span>
                    </div>
                    <div class="flex items-center justify-between py-1 px-2 rounded-lg hover:bg-gray-50">
                        <span class="flex items-center gap-2">🏠 Refuge</span>
                        <span class="font-semibold text-green-600 text-[10px]">Sécurisé</span>
                    </div>
                    <div class="flex items-center justify-between py-1 px-2 rounded-lg hover:bg-gray-50">
                        <span class="flex items-center gap-2">📍 Incident</span>
                        <span class="font-semibold text-orange-500 text-[10px]">Signalé</span>
                    </div>
                    <div class="flex items-center gap-2 py-1 px-2 rounded-lg hover:bg-gray-50">
                        <span class="w-3 h-3 rounded-full bg-blue-500 border-2 border-white shadow-sm"></span>
                        <span class="text-gray-700">Votre position</span>
                    </div>
                </div>
                <div id="sim-panel" class="hidden border-t border-gray-100 pt-3 mt-1">
                    <div class="flex items-center justify-between mb-2">
                        <span class="text-xs font-semibold text-gray-700">Scénarios simulés</span>
                        <span class="text-[10px] text-purple-600 font-medium" id="sim-status">Actif</span>
                    </div>
                    <div class="space-y-1.5">
                        <button onclick="loadScenario('inondation')" class="w-full text-left px-2 py-1.5 bg-blue-50 rounded-lg text-xs text-blue-700 font-medium hover:bg-blue-100 transition-colors flex items-center gap-2">
                            <i class="bi bi-droplet"></i> Crue généralisée
                        </button>
                        <button onclick="loadScenario('incendie')" class="w-full text-left px-2 py-1.5 bg-red-50 rounded-lg text-xs text-red-700 font-medium hover:bg-red-100 transition-colors flex items-center gap-2">
                            <i class="bi bi-fire"></i> Feux de forêt
                        </button>
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

                    <!-- Trajectory Simulation Playback -->
                    <div id="sim-playback" class="hidden border-t border-gray-100 pt-3 mt-2">
                        <div class="flex items-center justify-between mb-2">
                            <span class="text-xs font-semibold text-gray-700">Trajectoire simulée</span>
                            <span class="text-[10px] text-purple-600 font-medium" id="sim-track-status">Prêt</span>
                        </div>
                        <div class="flex items-center justify-center gap-2 mb-2">
                            <button onclick="togglePlayback()" id="simPlayBtn" class="px-3 py-1.5 bg-purple-600 text-white font-bold rounded-lg text-xs hover:bg-purple-700 transition flex items-center gap-1 flex-1">
                                <i class="bi bi-play-fill"></i> Lire
                            </button>
                            <div class="flex gap-1">
                                <button onclick="setSimSpeed(1)" id="simSpd1" class="px-2 py-1 text-xs font-bold rounded-lg bg-purple-600 text-white">1x</button>
                                <button onclick="setSimSpeed(2)" id="simSpd2" class="px-2 py-1 text-xs font-bold rounded-lg bg-gray-200 text-gray-600">2x</button>
                                <button onclick="setSimSpeed(4)" id="simSpd4" class="px-2 py-1 text-xs font-bold rounded-lg bg-gray-200 text-gray-600">4x</button>
                            </div>
                        </div>
                        <input type="range" id="simSlider" min="0" max="100" value="0" oninput="onSimSlider(this.value)" class="w-full mb-1 accent-purple-600" style="height:4px">
                        <div class="flex justify-between text-[10px] text-gray-400 mb-2">
                            <span id="simTimeLabel">Début</span>
                            <span id="simTimeEnd">Fin</span>
                        </div>
                        <div class="grid grid-cols-2 gap-1 text-[10px] bg-purple-50 rounded-lg p-2">
                            <div><span class="text-gray-500">Position:</span> <span class="font-semibold text-gray-800" id="simPos">--</span></div>
                            <div><span class="text-gray-500">Vent:</span> <span class="font-semibold text-purple-700" id="simWind">-- km/h</span></div>
                            <div><span class="text-gray-500">Pression:</span> <span class="font-semibold text-gray-800" id="simPressure">-- hPa</span></div>
                            <div><span class="text-gray-500">Phase:</span> <span class="font-semibold text-gray-800" id="simStage">--</span></div>
                        </div>
                        <div class="text-center text-xs font-bold text-red-600 mt-1 bg-red-50 rounded-lg py-1" id="simPopulation">Population touchée: 0</div>
                        <div id="simSummary" class="hidden mt-1 text-xs space-y-0.5 bg-gray-50 rounded-lg p-2 border border-gray-200">
                            <div class="font-bold text-gray-800 mb-0.5 border-b pb-0.5 text-[10px]">Bilan post-simulation</div>
                            <div class="flex justify-between"><span class="text-gray-500">Superficie impactée:</span> <span class="font-semibold text-red-600" id="sumArea">0 km²</span></div>
                            <div class="flex justify-between"><span class="text-gray-500">Population touchée:</span> <span class="font-semibold text-red-600" id="sumPopulation">0</span></div>
                            <div class="flex justify-between"><span class="text-gray-500">Vent max:</span> <span class="font-semibold text-purple-700" id="sumWind">-- km/h</span></div>
                            <div class="flex justify-between"><span class="text-gray-500">Distance parcourue:</span> <span class="font-semibold text-gray-800" id="sumDistance">0 km</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Chatbot Button -->
        <button class="chatbot-btn" id="chatbot-btn" onclick="toggleChat()">
            <i class="bi bi-robot"></i>
        </button>
        
        <!-- Chatbot Panel -->
        <div class="chatbot-panel" id="chatbot-panel">
            <div class="chatbot-header">
                <i class="bi bi-robot" style="font-size: 22px;"></i>
                <div>
                    <h3>Conseiller Catastrophes</h3>
                    <p>Posez vos questions sur les risques et la survie</p>
                </div>
                <button onclick="toggleChat()" style="margin-left:auto;background:none;border:none;color:white;font-size:20px;cursor:pointer;">
                    <i class="bi bi-x-lg"></i>
                </button>
            </div>
            <div class="chatbot-messages" id="chatbot-messages">
                <div class="chat-msg bot">
                    <strong>👋 Bienvenue sur Mitandrina !</strong><br><br>
                    Je suis votre conseiller spécialisé en catastrophes naturelles à Madagascar.<br><br>
                    Vous pouvez me poser des questions sur :<br>
                    • 🌪️ Cyclones et tempêtes<br>
                    • 💧 Inondations et crues<br>
                    • 🔥 Incendies et feux de forêt<br>
                    • 🌊 Tsunamis et glissements de terrain<br>
                    • 🎒 Kits d'urgence et évacuation<br>
                    • 🏥 Premiers secours et survie<br><br>
                    <em>Comment puis-je vous aider ?</em>
                </div>
            </div>
            <div class="chatbot-suggestions" id="chatbot-suggestions">
                <button onclick="sendSuggestion('Que faire en cas de cyclone ?')">🌀 Cyclone</button>
                <button onclick="sendSuggestion('Comment préparer un kit d\'urgence ?')">🎒 Kit urgence</button>
                <button onclick="sendSuggestion('Conseils pour inondation')">💧 Inondation</button>
                <button onclick="sendSuggestion('Itinéraire d\'évacuation')">🚶 Évacuation</button>
                <button onclick="sendSuggestion('Analyser la simulation en cours')">📊 Simulation</button>
                <button onclick="sendSuggestion('Premiers secours')">🏥 Secours</button>
            </div>
            <div class="chatbot-input">
                <input type="text" id="chatbot-input" placeholder="Posez votre question..." onkeydown="if(event.key==='Enter') sendChatMessage()">
                <button id="chatbot-send-btn" onclick="sendChatMessage()"><i class="bi bi-send-fill"></i> Envoyer</button>
            </div>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        // ============================================
        // Real Simulation Data (fetched from API)
        // ============================================
        let REAL_SIMULATION_DATA = null;

        async function fetchRealSimulations() {
            if (REAL_SIMULATION_DATA) return REAL_SIMULATION_DATA;
            try {
                var resp = await fetch('/api/v1/admin/simulations', {
                    headers: { 'Authorization': 'Bearer ' + ('${sessionScope.token}') }
                });
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
        // Helper: clamps ocean coordinates to nearest known land
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
            { id: 2, type: 'inondation', level: 'alerte', lat: -18.9078, lng: 47.5208, name: 'Inondation - Antananarivo', desc: 'Niveau d\'eau élevé - Précautions recommandées', danger_score: 65, confidence: 78, radius: 5000 },
            { id: 3, type: 'incendie', level: 'urgence', lat: -18.1442, lng: 49.3956, name: 'Incendie - Toamasina', desc: 'Feu de forêt détecté - Évacuation en cours', danger_score: 80, confidence: 88, radius: 3000 },
            { id: 5, type: 'inondation', level: 'alerte', lat: -18.1492, lng: 49.4, name: 'Inondation côtière - Toamasina', desc: 'Forte houle et inondation côtière', danger_score: 55, confidence: 72, radius: 4000 },
        ];

        const SIMULATION_SHELTERS = [
            { id: 1, name: 'Centre d\'urgence Analakely', lat: -18.91, lng: 47.525, capacity: 500, occupied: 120, type: 'Refuge municipal', medical: true, food: true, water: true },
            { id: 2, name: 'Refuge Toamasina', lat: -18.15, lng: 49.4, capacity: 300, occupied: 45, type: 'Refuge régional', medical: true, food: true, water: false },
            { id: 3, name: 'École Mahajanga', lat: -15.72, lng: 46.32, capacity: 200, occupied: 80, type: 'Refuge scolaire', medical: false, food: true, water: true },
            { id: 4, name: 'Stade de Fianarantsoa', lat: -21.4527, lng: 47.0875, capacity: 800, occupied: 150, type: 'Refuge public', medical: true, food: false, water: true },
            { id: 5, name: 'Centre polyvalent Antsiranana', lat: -12.28, lng: 49.29, capacity: 350, occupied: 60, type: 'Refuge régional', medical: true, food: true, water: true },
        ];

        const SIMULATION_INCIDENTS = [
            { id: 1, title: 'Feu de forêt actif', status: 'critique', lat: -18.1442, lng: 49.3956, description: 'Incendie non maîtrisé - propagation rapide', severity: 8 },
            { id: 2, title: 'Route inondée', status: 'en_cours', lat: -18.88, lng: 47.5, description: 'RN1 coupée par les eaux', severity: 5 },
            { id: 3, title: 'Glissement de terrain', status: 'critique', lat: -19.35, lng: 48.2, description: 'Route nationale obstruée - équipes dépêchées', severity: 7 },
        ];

        // ============================================
        // Map Initialization
        // ============================================
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('open');
        }

        const map = L.map('realtime-map', {
            center: [parseFloat('${userLat}') || -18.9078, parseFloat('${userLng}') || 47.5208],
            zoom: 7,
            zoomControl: false
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

        // Layer groups
        const riskLayer = L.layerGroup().addTo(map);
        const incidentLayer = L.layerGroup().addTo(map);
        const shelterLayer = L.layerGroup().addTo(map);
        const bufferLayer = L.layerGroup().addTo(map);
        let simulationMode = false;

        // Custom marker pins
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
            cyclone: createMarkerIcon('🌀', '#8b5cf6', true),
            seisme: createMarkerIcon('🏚️', '#f59e0b', false),
            tsunami: createMarkerIcon('🌊', '#2563eb', true),
            glissement_terrain: createMarkerIcon('⛰️', '#78350f', false),
            shelter: createMarkerIcon('🏠', '#059669', false),
            incident: createMarkerIcon('📍', '#f97316', false),
            user: createMarkerIcon('👤', '#3b82f6', false),
        };



        // User position
        const userLat = parseFloat('${userLat}') || -18.9078;
        const userLng = parseFloat('${userLng}') || 47.5208;
        L.marker([userLat, userLng], { icon: icons.user, zIndexOffset: 1000 })
            .addTo(map)
            .bindPopup('<div class="map-popup-card"><h6>📍 Votre position</h6><p>Latitude: ' + userLat.toFixed(4) + '<br>Longitude: ' + userLng.toFixed(4) + '</p><a href="./evacuation" style="display:inline-block;margin-top:6px;padding:4px 12px;background:#059669;color:white;border-radius:6px;font-size:12px;font-weight:600;text-decoration:none;">🚀 Planifier évacuation</a></div>');

        // ============================================
        // Simulation Functions
        // ============================================
        function toggleSimulation() {
            simulationMode = !simulationMode;
            const panel = document.getElementById('sim-panel');
            const btn = document.getElementById('sim-toggle-btn');
            if (simulationMode) {
                panel.classList.remove('hidden');
                btn.innerHTML = '<i class="bi bi-stop-fill"></i> Masquer';
                btn.classList.remove('bg-purple-50', 'text-purple-700');
                btn.classList.add('bg-purple-600', 'text-white');
                loadScenario('tout');
            } else {
                panel.classList.add('hidden');
                btn.innerHTML = '<i class="bi bi-magic"></i> Simulation';
                btn.classList.remove('bg-purple-600', 'text-white');
                btn.classList.add('bg-purple-50', 'text-purple-700');
                clearSimulation();
                updateLastUpdated();
            }
        }

        function loadScenario(type) {
            document.getElementById('sim-status').textContent = 'Chargement...';
            clearSimTrack();
            clearAllLayers();

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

            renderSimulationData(zones, shelters, incidents, type);
            document.getElementById('sim-status').textContent = 'Actif - ' + zones.length + ' zones';
            updateStats(zones.length, incidents.length, shelters.length, zones, shelters);

            var srcZones = REAL_SIMULATION_DATA && REAL_SIMULATION_DATA.zones.length > 0 ? REAL_SIMULATION_DATA.zones : SIMULATION_ZONES;
            if (srcZones.length > 0) {
                var track = generateSyntheticTrack(srcZones, type);
                if (track.length > 0) {
                    loadSimulationTrack(track);
                }
            }
        }

        function clearSimulation() {
            clearSimTrack();
            clearAllLayers();
            document.getElementById('sim-status').textContent = 'Désactivé';
            resetStats();
        }

        function clearAllLayers() {
            riskLayer.clearLayers();
            incidentLayer.clearLayers();
            shelterLayer.clearLayers();
            bufferLayer.clearLayers();
        }

        function renderSimulationData(zones, shelters, incidents, type) {
            var trackedTypes = ['cyclone'];
            if (type === 'cyclone' || type === 'tout') {
                var hasTrack = (REAL_SIMULATION_DATA && REAL_SIMULATION_DATA.zones.length > 0) || SIMULATION_ZONES.length > 0;
                if (!hasTrack) trackedTypes = [];
            } else {
                trackedTypes = [];
            }

            // Render zones
            zones.forEach(z => {
                // Skip cyclones markers when trajectory playback handles them
                if (trackedTypes.includes(z.type)) return;

                const marker = L.marker([z.lat, z.lng], { icon: icons[z.type] || icons.incendie })
                    .bindPopup(buildRiskPopup(z));
                riskLayer.addLayer(marker);

                if (z.type !== 'cyclone') {
                    const circle = L.circle([z.lat, z.lng], {
                        color: z.level === 'urgence' ? '#ef4444' : z.level === 'alerte' ? '#f59e0b' : '#3b82f6',
                        fillColor: z.level === 'urgence' ? '#ef4444' : z.level === 'alerte' ? '#f59e0b' : '#3b82f6',
                        fillOpacity: 0.12,
                        radius: z.radius
                    });
                    riskLayer.addLayer(circle);

                    // Inner damage circle — skipped for tracked types (trajectory playback handles them)
                    if (!trackedTypes.includes(z.type)) {
                        var estWind = (z.danger_score || 50) * 1.5;
                        var dmgRadius = Math.max(2000, (estWind / 120) * 10000);
                        var dmgCircle = L.circle([z.lat, z.lng], {
                            color: '#dc2626',
                            fillColor: '#dc2626',
                            fillOpacity: 0.2,
                            weight: 2.5,
                            radius: dmgRadius
                        });
                        riskLayer.addLayer(dmgCircle);
                    }
                }
            });

            // Render shelters
            shelters.forEach(s => {
                const occupancyPct = s.capacity > 0 ? (s.occupied / s.capacity * 100) : 0;
                const marker = L.marker([s.lat, s.lng], { icon: icons.shelter })
                    .bindPopup(buildShelterPopup(s, occupancyPct));
                shelterLayer.addLayer(marker);
                bufferLayer.addLayer(L.circle([s.lat, s.lng], {
                    color: '#059669',
                    fillColor: '#059669',
                    fillOpacity: 0.08,
                    weight: 1.5,
                    radius: 2500
                }));
            });

            // Render incidents
            incidents.forEach(i => {
                const marker = L.marker([i.lat, i.lng], { icon: icons.incident })
                    .bindPopup(buildIncidentPopup(i));
                incidentLayer.addLayer(marker);
            });

            // Focus map on data
            if (zones.length > 0) {
                const bounds = zones.map(z => [z.lat, z.lng]);
                if (bounds.length > 0) map.fitBounds(bounds, { padding: [50, 50], maxZoom: 8 });
            }
        }

        function buildRiskPopup(zone) {
            const levelColor = zone.level === 'urgence' ? '#ef4444' : zone.level === 'alerte' ? '#f59e0b' : '#3b82f6';
            const levelLabel = zone.level.toUpperCase();
            return '<div class="map-popup-card" style="min-width:260px;">' +
                '<span style="display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;color:white;background:' + levelColor + ';border-radius:4px;text-transform:uppercase;margin-bottom:6px;">' + levelLabel + '</span>' +
                '<h6>' + zone.name + '</h6>' +
                '<p style="margin:6px 0;font-size:12px;color:#475569;">' + zone.desc + '</p>' +
                '<div style="margin-top:8px;padding:8px;background:#f8fafc;border-radius:8px;font-size:11px;">' +
                    '<div style="display:flex;justify-content:space-between;margin-bottom:4px;"><span style="color:#64748b;">Danger score</span><strong style="color:' + levelColor + ';">' + zone.danger_score + '/100</strong></div>' +
                    '<div style="display:flex;justify-content:space-between;margin-bottom:4px;"><span style="color:#64748b;">Confiance IA</span><strong style="color:#059669;">' + zone.confidence + '%</strong></div>' +
                    '<div style="display:flex;justify-content:space-between;"><span style="color:#64748b;">Rayon</span><strong>' + (zone.radius / 1000) + ' km</strong></div>' +
                '</div>' +
                '<a href="./evacuation?lat=' + zone.lat + '&lng=' + zone.lng + '" style="display:block;margin-top:8px;padding:6px 12px;background:' + levelColor + ';color:white;border-radius:8px;font-size:12px;font-weight:600;text-decoration:none;text-align:center;">🚨 Voir itinéraire d\'évacuation</a>' +
                '</div>';
        }

        function buildShelterPopup(s, occupancyPct) {
            const barColor = occupancyPct > 80 ? '#ef4444' : occupancyPct > 50 ? '#f59e0b' : '#059669';
            return '<div class="map-popup-card" style="min-width:240px;">' +
                '<h6>🏠 ' + s.name + '</h6>' +
                '<p style="font-size:11px;color:#64748b;margin-bottom:8px;">' + (s.type || 'Refuge') + '</p>' +
                '<div style="font-size:12px;">' +
                    '<div style="display:flex;justify-content:space-between;margin-bottom:2px;"><span style="color:#64748b;">Capacité</span><strong>' + s.occupied + '/' + s.capacity + '</strong></div>' +
                    '<div style="width:100%;background:#e2e8f0;height:6px;border-radius:3px;overflow:hidden;margin:6px 0;">' +
                        '<div style="width:' + occupancyPct + '%;background:' + barColor + ';height:100%;border-radius:3px;"></div>' +
                    '</div>' +
                    '<div style="display:flex;justify-content:space-between;margin-bottom:2px;"><span style="color:#64748b;">Places disponibles</span><strong style="color:' + barColor + ';">' + (s.capacity - s.occupied) + '</strong></div>' +
                    '<div style="margin-top:6px;display:flex;gap:4px;flex-wrap:wrap;">' +
                        (s.medical ? '<span style="padding:1px 6px;background:#ecfdf5;color:#059669;border-radius:4px;font-size:10px;">🏥 Médical</span>' : '') +
                        (s.food ? '<span style="padding:1px 6px;background:#fffbeb;color:#d97706;border-radius:4px;font-size:10px;">🍲 Nourriture</span>' : '') +
                        (s.water ? '<span style="padding:1px 6px;background:#eff6ff;color:#2563eb;border-radius:4px;font-size:10px;">💧 Eau</span>' : '') +
                    '</div>' +
                    (s.phone ? '<p style="margin-top:6px;font-size:11px;color:#64748b;"><strong>📞</strong> ' + s.phone + '</p>' : '') +
                '</div>' +
                '<a href="./evacuation?shelter=' + s.id + '" style="display:block;margin-top:8px;padding:6px 12px;background:#059669;color:white;border-radius:8px;font-size:12px;font-weight:600;text-decoration:none;text-align:center;">🧭 Itinéraire vers ce refuge</a>' +
                '</div>';
        }

        function buildIncidentPopup(incident) {
            const statusColor = incident.status === 'critique' ? '#ef4444' : incident.status === 'en_cours' ? '#f59e0b' : '#3b82f6';
            return '<div class="map-popup-card" style="min-width:240px;">' +
                '<span style="display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;color:white;background:' + statusColor + ';border-radius:4px;text-transform:uppercase;margin-bottom:6px;">' + incident.status + '</span>' +
                '<h6>📍 ' + incident.title + '</h6>' +
                '<p style="font-size:12px;color:#475569;margin:6px 0;">' + incident.description + '</p>' +
                '<div style="margin-top:4px;font-size:11px;color:#64748b;"><strong>Sévérité:</strong> ' + incident.severity + '/10</div>' +
                '</div>';
        }

        // ============================================
        // Trajectory Simulation Playback (Lire/Pause/Vitesse)
        // ============================================
        var simTrack = [];
        var simIndex = 0;
        var simPlaying = false;
        var simPlaybackSpeed = 1;
        var simTimer = null;
        var simMarker = null;
        var simPolyline = null;
        var simLayer = L.layerGroup().addTo(map);
        var simDamageCircle = null;
        var simTotalPopulation = 0;
        var simTotalArea = 0;
        var simFrameCounter = 0;
        var simAffectedCityIds = [];

        function createSimPopupContent(p) {
            var level = (p.wind||0) >= 154 ? 'urgence' : (p.wind||0) >= 63 ? 'alerte' : 'vigilance';
            var levelColor = level === 'urgence' ? '#ef4444' : level === 'alerte' ? '#f59e0b' : '#3b82f6';
            var label = level.toUpperCase();
            var lat = p.lat, lng = p.lng;
            return '<div class="p-3 min-w-[220px]" style="font-family:Inter,sans-serif">' +
                '<span style="display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;color:white;background:' + levelColor + ';border-radius:4px;text-transform:uppercase;margin-bottom:6px;">SIMULATION ' + label + '</span>' +
                '<h6 style="font-weight:700;font-size:14px;margin:0 0 4px 0;">' + (p.stage || 'Cyclone simulé') + '</h6>' +
                '<p style="font-size:12px;color:#64748b;margin:0 0 8px 0;">Vent: ' + (p.wind||0) + ' km/h | Pression: ' + (p.pressure||0) + ' hPa</p>' +
                '<div style="display:grid;grid-template-columns:1fr 1fr;gap:6px;font-size:12px;margin-bottom:8px;">' +
                    '<div style="background:#f8fafc;border-radius:8px;padding:6px;text-align:center;"><div style="font-weight:700;font-size:16px;color:' + levelColor + '">' + (p.wind||0) + '</div><div style="color:#64748b;font-size:10px;">Vent (km/h)</div></div>' +
                    '<div style="background:#f8fafc;border-radius:8px;padding:6px;text-align:center;"><div style="font-weight:700;font-size:16px;color:#059669;">' + (p.pressure||0) + '</div><div style="color:#64748b;font-size:10px;">Pression</div></div>' +
                '</div>' +
                (p.datetime ? '<p style="font-size:10px;color:#94a3b8;margin:0 0 8px 0;">' + p.datetime + '</p>' : '') +
                '<button onclick="var p=window._simCurrentPos||{};document.getElementById(\'chatbot-input\').value=\'Analyse la position actuelle du cyclone (Lat: \'+p.lat+\', Lng: \'+p.lng+\', Vent: \'+p.wind+\' km/h)\';sendChatMessage();" style="width:100%;padding:6px 12px;background:#7c3aed;color:white;border:none;border-radius:8px;font-size:12px;font-weight:600;cursor:pointer;">🤖 Analyser avec IA</button>' +
            '</div>';
        }

        function loadSimulationTrack(track) {
            clearSimTrack();
            simTrack = track;
            if (simTrack.length === 0) return;

            var slider = document.getElementById('simSlider');
            slider.max = simTrack.length - 1;
            slider.value = 0;

            document.getElementById('simTimeEnd').textContent = simTrack[simTrack.length - 1].datetime || 'Fin';
            document.getElementById('sim-playback').classList.remove('hidden');
            document.getElementById('sim-track-status').textContent = simTrack.length + ' points';

            var pts = simTrack.map(function(p) { return [p.lat, p.lng]; });
            simPolyline = L.polyline(pts, { color: '#7c3aed', weight: 2.5, opacity: 0.7, dashArray: '6, 4' }).addTo(simLayer);

            var last = simTrack[0];
            simMarker = L.marker([last.lat, last.lng], {
                icon: createMarkerIcon('🌀', 'linear-gradient(135deg, #7c3aed, #ec4899)', 44)
            }).addTo(simLayer);
            simMarker.bindPopup(createSimPopupContent(last));
            simMarker.on('click', function() {
                var p = simTrack[simIndex];
                if (window._simCurrentPos) {
                    window._simCurrentPos = {
                        lat: p.lat, lng: p.lng,
                        wind: p.wind || 0, pressure: p.pressure || 0,
                        stage: p.stage || '', datetime: p.datetime || '',
                        index: simIndex, total: simTrack.length,
                        population: simTotalPopulation, area: simTotalArea
                    };
                }
                var msg = 'Analyse la position actuelle du cyclone (Lat: ' + p.lat.toFixed(2) + ', Lng: ' + p.lng.toFixed(2) + ', Vent: ' + (p.wind||0) + ' km/h)';
                document.getElementById('chatbot-input').value = msg;
                sendChatMessage();
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
            }).addTo(simLayer);

            updateSimFrame(0);

            // Send initial position to chatbot
            sendSimPositionToChat(simTrack[0]);
        }

        function clearSimTrack() {
            simPlaying = false;
            if (simTimer) { clearInterval(simTimer); simTimer = null; }
            simTrack = [];
            simIndex = 0;
            simLayer.clearLayers();
            simMarker = null;
            simPolyline = null;
            simDamageCircle = null;
            simTotalPopulation = 0;
            simTotalArea = 0;
            simFrameCounter = 0;
            simAffectedCityIds = [];
            document.getElementById('sim-playback').classList.add('hidden');
            document.getElementById('simPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Lire';
            document.getElementById('simPopulation').textContent = 'Population touchée: 0';
            document.getElementById('simSummary').classList.add('hidden');
            document.getElementById('sim-track-status').textContent = 'Prêt';
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

            // METTRE À JOUR LE CHATBOT À CHAQUE FRAME (temps réel)
            sendSimPositionToChat(p);

            // Cercle de dégâts mobile : basé sur l'échelle de Saffir-Simpson réelle
            var wind = p.wind || 0;
            var dmgRadius = getDamageRadius(wind);
            var dmgColor = wind >= 209 ? '#dc2626' : wind >= 154 ? '#f97316' : wind >= 119 ? '#f59e0b' : wind >= 63 ? '#3b82f6' : '#6b7280';
            if (simDamageCircle) {
                simDamageCircle.setLatLng([p.lat, p.lng]);
                simDamageCircle.setRadius(dmgRadius);
                simDamageCircle.setStyle({ color: dmgColor, fillColor: dmgColor, fillOpacity: dmgRadius > 0 ? 0.15 : 0 });
            }

            // Population touchée basée sur les villes réelles dans le rayon
            var radiusKm = dmgRadius / 1000;
            var popResult = getAffectedPopulation(p.lat, p.lng, radiusKm);
            popResult.cities.forEach(function(cityName) {
                if (simAffectedCityIds.indexOf(cityName) === -1) {
                    simAffectedCityIds.push(cityName);
                }
            });
            simTotalPopulation = 0;
            simAffectedCityIds.forEach(function(cid) {
                POPULATION_CENTERS.forEach(function(c) {
                    if (c.name === cid) simTotalPopulation += c.pop;
                });
            });
            simTotalArea += Math.PI * dmgRadius * dmgRadius / 1000000;
            var citiesNow = popResult.cities.length > 0 ? popResult.cities.join(', ') : 'aucune';
            document.getElementById('simPopulation').textContent = 'Touchés: ' + simTotalPopulation.toLocaleString() + ' hab. | Villes: ' + citiesNow;
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
            simTimer = setInterval(function() {
                if (simIndex >= simTrack.length - 1) {
                    simPlaying = false;
                    clearInterval(simTimer);
                    simTimer = null;
                    document.getElementById('simPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Rejouer';
                    showSimSummary();
                    return;
                }
                simIndex++;
                updateSimFrame(simIndex);
            }, 400 / simPlaybackSpeed);
        }

        function setSimSpeed(s) {
            simPlaybackSpeed = s;
            document.getElementById('simSpd1').className = 'px-2 py-1 text-xs font-bold rounded-lg ' + (s === 1 ? 'bg-purple-600 text-white' : 'bg-gray-200 text-gray-600');
            document.getElementById('simSpd2').className = 'px-2 py-1 text-xs font-bold rounded-lg ' + (s === 2 ? 'bg-purple-600 text-white' : 'bg-gray-200 text-gray-600');
            document.getElementById('simSpd4').className = 'px-2 py-1 text-xs font-bold rounded-lg ' + (s === 4 ? 'bg-purple-600 text-white' : 'bg-gray-200 text-gray-600');
            if (simPlaying) {
                clearInterval(simTimer);
                simTimer = setInterval(function() {
                    if (simIndex >= simTrack.length - 1) {
                        simPlaying = false;
                        clearInterval(simTimer);
                        simTimer = null;
                        document.getElementById('simPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Rejouer';
                        showSimSummary();
                        return;
                    }
                    simIndex++;
                    updateSimFrame(simIndex);
                }, 400 / s);
            }
        }

        function onSimSlider(val) {
            if (simPlaying) { simPlaying = false; clearInterval(simTimer); simTimer = null; }
            document.getElementById('simPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Lire';
            updateSimFrame(parseInt(val));
        }

        function showSimSummary() {
            var totalDist = 0;
            for (var i = 1; i < simTrack.length; i++) {
                totalDist += distanceKm(simTrack[i-1].lat, simTrack[i-1].lng, simTrack[i].lat, simTrack[i].lng);
            }
            var maxW = 0;
            simTrack.forEach(function(p) { if ((p.wind || 0) > maxW) maxW = p.wind; });
            document.getElementById('sumArea').textContent = Math.round(simTotalArea) + ' km²';
            document.getElementById('sumPopulation').textContent = simTotalPopulation.toLocaleString();
            document.getElementById('sumWind').textContent = Math.round(maxW) + ' km/h';
            document.getElementById('sumDistance').textContent = Math.round(totalDist) + ' km';
            document.getElementById('simSummary').classList.remove('hidden');
            if (simAffectedCityIds.length > 0) {
                document.getElementById('simSummary').insertAdjacentHTML('beforeend',
                    '<div class="text-xs text-gray-600 mt-1 border-t pt-1">🏙️ ' + simAffectedCityIds.slice(0, 8).join(', ') + (simAffectedCityIds.length > 8 ? '...' : '') + '</div>');
            }
        }

        // ============================================
        // Population data réelle (villes sur la trajectoire de Gezani)
        // ============================================
        var POPULATION_CENTERS = [
            { name: 'Sambava', lat: -14.2667, lng: 50.1667, pop: 84000 },
            { name: 'Antalaha', lat: -14.9000, lng: 50.2833, pop: 67000 },
            { name: 'Maroantsetra', lat: -15.4333, lng: 49.7333, pop: 42000 },
            { name: 'Fenoarivo Atsinanana', lat: -17.3833, lng: 49.4000, pop: 47000 },
            { name: 'Toamasina', lat: -18.1492, lng: 49.4000, pop: 325857 },
            { name: 'Vatomandry', lat: -19.3333, lng: 48.9833, pop: 35000 },
            { name: 'Ambatondrazaka', lat: -17.8333, lng: 48.4167, pop: 65000 },
            { name: 'Moramanga', lat: -18.9333, lng: 48.2000, pop: 55000 },
            { name: 'Antananarivo', lat: -18.8792, lng: 47.5079, pop: 1391433 },
            { name: 'Antsirabe', lat: -19.8667, lng: 47.0333, pop: 265018 },
            { name: 'Fianarantsoa', lat: -21.4527, lng: 47.0875, pop: 191776 },
            { name: 'Maintirano', lat: -18.0500, lng: 44.0333, pop: 40000 },
            { name: 'Mahajanga', lat: -15.7150, lng: 46.3200, pop: 246022 },
            { name: 'Morondava', lat: -20.2833, lng: 44.2833, pop: 107000 },
            { name: 'Belo sur Tsiribihina', lat: -19.7000, lng: 44.5333, pop: 28000 },
            { name: 'Toliara', lat: -23.3500, lng: 43.6800, pop: 179147 },
            { name: 'Morombe', lat: -21.7500, lng: 43.3667, pop: 38000 },
            { name: 'Taolanaro', lat: -25.0325, lng: 46.9833, pop: 45000 },
            { name: 'Inhambane', lat: -23.8764, lng: 35.3833, pop: 82000 },
            { name: 'Maxixe', lat: -23.8667, lng: 35.3500, pop: 120000 },
            { name: 'Vilanculos', lat: -22.0000, lng: 35.3167, pop: 56000 },
            { name: 'Beira', lat: -19.8333, lng: 34.8500, pop: 533825 },
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

        function distanceKm(lat1, lng1, lat2, lng2) {
            var R = 6371;
            var dLat = (lat2 - lat1) * Math.PI / 180;
            var dLng = (lng2 - lng1) * Math.PI / 180;
            var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                    Math.sin(dLng/2) * Math.sin(dLng/2);
            return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        }

        // Send current simulation position to chatbot for analysis
        var lastChatPosSent = '';

        function sendSimPositionToChat(point) {
            var posKey = point.lat.toFixed(2) + ',' + point.lng.toFixed(2);
            if (posKey === lastChatPosSent) return;
            lastChatPosSent = posKey;

            // Update chatbot context with current simulation position
            var radiusKm = getDamageRadius(point.wind || 0) / 1000;
            var popResult = getAffectedPopulation(point.lat, point.lng, radiusKm);
            window._simCurrentPos = {
                lat: point.lat,
                lng: point.lng,
                wind: point.wind || 0,
                pressure: point.pressure || 0,
                stage: point.stage || '',
                datetime: point.datetime || '',
                index: simIndex,
                total: simTrack.length,
                population: simTotalPopulation,
                area: simTotalArea,
                affectedCities: popResult.cities
            };
        }

        // Trajectoire réelle du Cyclone Gezani (source: Gezani.odt)
        var GEZANI_TRACK = [
            {lat:-14.5, lng:61.0, wind:0, pressure:1008, stage:'Perturbation tropicale', datetime:'2026-02-03 00:00', note:'Formation au nord-est de Saint-Brandon'},
            {lat:-16.2, lng:59.5, wind:55, pressure:1002, stage:'Dépression tropicale', datetime:'2026-02-06 00:00', note:'~700km NE de Saint-Brandon'},
            {lat:-16.8, lng:58.8, wind:45, pressure:1005, stage:'Perturbation tropicale', datetime:'2026-02-06 12:00', note:'Traverse archipel Saint-Brandon'},
            {lat:-17.2, lng:57.5, wind:50, pressure:1004, stage:'Perturbation tropicale', datetime:'2026-02-07 12:00', note:'~200km au nord de île Maurice'},
            {lat:-17.5, lng:56.0, wind:65, pressure:998, stage:'Tempête tropicale modérée', datetime:'2026-02-08 00:00', note:'Nommé Gezani – col barométrique'},
            {lat:-17.8, lng:54.0, wind:100, pressure:985, stage:'Forte tempête tropicale', datetime:'2026-02-09 00:00', note:'350km au nord de La Réunion'},
            {lat:-17.9, lng:53.0, wind:110, pressure:980, stage:'Forte tempête tropicale', datetime:'2026-02-09 12:00', note:'Intensification rapide'},
            {lat:-18.0, lng:51.1, wind:155, pressure:968, stage:'Cyclone tropical', datetime:'2026-02-10 00:00', note:'Équiv. catégorie 2 – 545km NW La Réunion'},
            {lat:-18.1, lng:49.5, wind:185, pressure:950, stage:'Cyclone tropical intense', datetime:'2026-02-10 12:00', note:'75km à l\'est de Toamasina'},
            {lat:-18.2, lng:49.4, wind:185, pressure:945, stage:'Cyclone tropical intense', datetime:'2026-02-10 16:30', note:'LANDFALL Toamasina – pic intensité'},
            {lat:-18.5, lng:48.0, wind:130, pressure:965, stage:'Cyclone tropical', datetime:'2026-02-11 00:00', note:'Traverse Madagascar – affaiblit'},
            {lat:-19.0, lng:44.5, wind:55, pressure:990, stage:'Dépression tropicale', datetime:'2026-02-11 13:00', note:'Sortie ~80km sud Maintirano'},
            {lat:-18.8, lng:43.0, wind:80, pressure:985, stage:'Tempête tropicale modérée', datetime:'2026-02-12 00:00', note:'Réintensification canal Mozambique'},
            {lat:-19.5, lng:40.0, wind:120, pressure:970, stage:'Cyclone tropical', datetime:'2026-02-13 12:00', note:'Milieu du canal Mozambique'},
            {lat:-20.0, lng:37.5, wind:185, pressure:948, stage:'Cyclone tropical intense', datetime:'2026-02-14 00:00', note:'50km de la côte d\'Inhambane'},
            {lat:-21.0, lng:36.5, wind:150, pressure:960, stage:'Cyclone tropical', datetime:'2026-02-14 12:00', note:'Frôle province d\'Inhambane'},
            {lat:-22.0, lng:36.0, wind:110, pressure:972, stage:'Forte tempête tropicale', datetime:'2026-02-15 00:00', note:'Boucle vers le sud'},
            {lat:-24.0, lng:35.6, wind:120, pressure:968, stage:'Cyclone tropical', datetime:'2026-02-16 00:00', note:'Boucle vers est/nord-est'},
            {lat:-26.1, lng:37.4, wind:105, pressure:975, stage:'Forte tempête tropicale', datetime:'2026-02-17 00:00', note:'<150km SW Madagascar'},
            {lat:-26.5, lng:40.0, wind:120, pressure:968, stage:'Cyclone tropical', datetime:'2026-02-17 19:00', note:'~45km côte SW Madagascar'},
            {lat:-27.5, lng:41.0, wind:100, pressure:978, stage:'Forte tempête tropicale', datetime:'2026-02-18 00:00', note:'Trajectoire sud-sud-est'},
            {lat:-30.0, lng:43.0, wind:95, pressure:982, stage:'Forte tempête tropicale', datetime:'2026-02-19 00:00', note:'S\'éloigne vers le sud'},
            {lat:-35.0, lng:48.0, wind:65, pressure:992, stage:'Dépression post-tropicale', datetime:'2026-02-20 12:00', note:'Eaux froides >1200km au sud'},
        ];

        function generateSyntheticTrack(zones, type) {
            // Use real Gezani track for cyclone scenario
            if (type === 'cyclone' || type === 'tout') {
                return GEZANI_TRACK.slice();
            }

            var filtered = type === 'tout' ? zones : zones.filter(function(z) { return z.type === type; });
            if (filtered.length === 0) return [];

            // Generate a trajectory from the first zone
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
                    note: 'Point de trajectoire ' + (i + 1)
                });
            }
            return track;
        }

        // ============================================
        // Real Data Fetching (from API)
        // ============================================
        function updateLastUpdated() {
            const el = document.getElementById('last-updated');
            if (el) {
                const now = new Date();
                el.innerHTML = '<i class="bi bi-arrow-clockwise"></i> ' + now.getHours().toString().padStart(2, '0') + ':' + now.getMinutes().toString().padStart(2, '0');
            }
        }

        function updateStats(zonesCount, incidentsCount, sheltersCount, zones, shelters) {
            document.getElementById('stat-risks').textContent = zonesCount;
            document.getElementById('stat-incidents').textContent = incidentsCount;
            document.getElementById('stat-shelters').textContent = sheltersCount;
            var totalProtected = 0;
            if (shelters && shelters.length > 0) {
                totalProtected = shelters.reduce(function(sum, s) { return sum + (s.capacity - s.occupied); }, 0);
            }
            document.getElementById('stat-protected').textContent = totalProtected > 0 ? (totalProtected > 1000 ? Math.round(totalProtected / 1000) + 'K' : totalProtected) : '0';
            const cyclones = zones ? zones.filter(z => z.type === 'cyclone').length : 0;
            const fires = zones ? zones.filter(z => z.type === 'incendie').length : 0;
            document.getElementById('stat-cyclones').textContent = cyclones;
            document.getElementById('stat-fires').textContent = fires;
        }

        function resetStats() {
            document.getElementById('stat-risks').textContent = '0';
            document.getElementById('stat-incidents').textContent = '0';
            document.getElementById('stat-shelters').textContent = '0';
            document.getElementById('stat-protected').textContent = '0';
            document.getElementById('stat-cyclones').textContent = '0';
            document.getElementById('stat-fires').textContent = '0';
        }

        const API_TOKEN = '${sessionScope.token}';
        const API_HEADERS = { 'Authorization': 'Bearer ' + API_TOKEN, 'Content-Type': 'application/json' };

        // Icônes type → emoji
        const TYPE_EMOJI = {
            inondation: '💧', incendie: '🔥', cyclone: '🌀',
            seisme: '🏚️', tsunami: '🌊', glissement_terrain: '⛰️'
        };

        async function loadRealData() {
            clearAllLayers();
            resetStats();

            let apiIncidents = [];
            let apiShelters  = [];

            try {
                const [incRes, shelRes] = await Promise.all([
                    fetch('/api/v1/incidents?limit=200', { headers: API_HEADERS }),
                    fetch('/api/v1/shelters?limit=200',  { headers: API_HEADERS })
                ]);

                if (incRes.ok) {
                    const incData = await incRes.json();
                    apiIncidents = (incData.incidents || []).filter(i =>
                        i.location_lat != null && i.location_lng != null
                    );
                }
                if (shelRes.ok) {
                    const shelData = await shelRes.json();
                    apiShelters = (shelData.shelters || []).filter(s =>
                        s.location_lat != null && s.location_lng != null
                    );
                }
            } catch (e) {
                console.warn('Erreur chargement API, fallback données statiques:', e);
            }

            // --- Render incidents réels ---
            if (apiIncidents.length > 0) {
                apiIncidents.forEach(inc => {
                    const lat = parseFloat(inc.location_lat);
                    const lng = parseFloat(inc.location_lng);
                    if (isNaN(lat) || isNaN(lng)) return;

                    const statusColor = inc.status === 'en_cours' ? '#ef4444'
                        : inc.status === 'verifie' ? '#f59e0b' : '#3b82f6';
                    const emoji = TYPE_EMOJI[inc.type] || '📍';

                    const icon = L.divIcon({
                        className: 'custom-marker',
                        html: '<div class="marker-pin" style="background:' + statusColor + '">' + emoji + '</div>',
                        iconSize: [36, 36], iconAnchor: [18, 36], popupAnchor: [0, -36]
                    });

                    const popup = '<div class="map-popup-card" style="min-width:240px;">' +
                        '<span style="display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;color:white;background:' + statusColor + ';border-radius:4px;text-transform:uppercase;margin-bottom:6px;">' + (inc.status || 'signalé') + '</span>' +
                        '<h6>📍 ' + escapeHtml(inc.title || 'Incident') + '</h6>' +
                        '<p style="font-size:12px;color:#475569;margin:6px 0;">' + escapeHtml(inc.description || '') + '</p>' +
                        '<p style="font-size:11px;color:#94a3b8;">Type: ' + escapeHtml(inc.type || '') + ' | Signalé le: ' + new Date(inc.reported_at || '').toLocaleString('fr-FR') + '</p>' +
                        '</div>';

                    L.marker([lat, lng], { icon: icon })
                        .bindPopup(popup)
                        .addTo(incidentLayer);
                });
            } else {
                // Fallback données statiques
                SIMULATION_INCIDENTS.forEach(i => {
                    L.marker([i.lat, i.lng], { icon: icons.incident })
                        .bindPopup(buildIncidentPopup(i))
                        .addTo(incidentLayer);
                });
            }

            // --- Render refuges réels ---
            if (apiShelters.length > 0) {
                apiShelters.forEach(s => {
                    const lat = parseFloat(s.location_lat);
                    const lng = parseFloat(s.location_lng);
                    if (isNaN(lat) || isNaN(lng)) return;

                    const occupancyPct = s.capacity > 0 ? (s.current_occupancy / s.capacity * 100) : 0;
                    const shelObj = {
                        id: s.id, name: s.name, lat, lng,
                        capacity: s.capacity, occupied: s.current_occupancy,
                        type: s.type, medical: s.has_medical_facilities,
                        food: s.has_food, water: s.has_water, phone: s.phone
                    };
                    L.marker([lat, lng], { icon: icons.shelter })
                        .bindPopup(buildShelterPopup(shelObj, occupancyPct))
                        .addTo(shelterLayer);

                    bufferLayer.addLayer(L.circle([lat, lng], {
                        color: '#059669', fillColor: '#059669',
                        fillOpacity: 0.08, weight: 1.5, radius: 2500
                    }));
                });
            } else {
                SIMULATION_SHELTERS.forEach(s => {
                    const pct = s.capacity > 0 ? (s.occupied / s.capacity * 100) : 0;
                    L.marker([s.lat, s.lng], { icon: icons.shelter })
                        .bindPopup(buildShelterPopup(s, pct))
                        .addTo(shelterLayer);
                    bufferLayer.addLayer(L.circle([s.lat, s.lng], {
                        color: '#059669', fillColor: '#059669',
                        fillOpacity: 0.08, weight: 1.5, radius: 2500
                    }));
                });
            }

            // --- Render zones de risque statiques (toujours affichées) ---
            SIMULATION_ZONES.forEach(z => {
                L.marker([z.lat, z.lng], { icon: icons[z.type] || icons.incendie })
                    .bindPopup(buildRiskPopup(z))
                    .addTo(riskLayer);
                L.circle([z.lat, z.lng], {
                    color: z.level === 'urgence' ? '#ef4444' : z.level === 'alerte' ? '#f59e0b' : '#3b82f6',
                    fillColor: z.level === 'urgence' ? '#ef4444' : z.level === 'alerte' ? '#f59e0b' : '#3b82f6',
                    fillOpacity: 0.10, radius: z.radius
                }).addTo(riskLayer);
            });

            updateStats(
                SIMULATION_ZONES.length,
                apiIncidents.length || SIMULATION_INCIDENTS.length,
                apiShelters.length  || SIMULATION_SHELTERS.length,
                SIMULATION_ZONES,
                apiShelters.length > 0 ? apiShelters.map(s => ({ capacity: s.capacity, occupied: s.current_occupancy })) : SIMULATION_SHELTERS
            );
            updateLastUpdated();
        }

        // ============================================
        // Temps réel : ajout d'un incident sur la carte via WebSocket
        // ============================================
        (function initMapWebSocket() {
            if (typeof io === 'undefined' || !API_TOKEN) return;
            const mapSocket = io('http://localhost:3001', { auth: { token: API_TOKEN } });
            mapSocket.on('incident:new', function(inc) {
                const lat = parseFloat(inc.location_lat);
                const lng = parseFloat(inc.location_lng);
                if (isNaN(lat) || isNaN(lng)) return;

                const emoji = TYPE_EMOJI[inc.type] || '📍';
                const icon = L.divIcon({
                    className: 'custom-marker',
                    html: '<div class="marker-pin" style="background:#ef4444;animation:pulse 2s infinite">' + emoji + '</div>',
                    iconSize: [36, 36], iconAnchor: [18, 36], popupAnchor: [0, -36]
                });
                const popup = '<div class="map-popup-card" style="min-width:240px;">' +
                    '<span style="display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;color:white;background:#ef4444;border-radius:4px;margin-bottom:6px;">NOUVEAU</span>' +
                    '<h6>📍 ' + escapeHtml(inc.title || 'Incident') + '</h6>' +
                    '<p style="font-size:12px;color:#475569;margin:6px 0;">' + escapeHtml(inc.description || '') + '</p>' +
                    '<p style="font-size:11px;color:#94a3b8;">' + new Date().toLocaleString('fr-FR') + '</p>' +
                    '</div>';

                L.marker([lat, lng], { icon })
                    .bindPopup(popup)
                    .addTo(incidentLayer)
                    .openPopup();

                map.flyTo([lat, lng], 13, { animate: true, duration: 1.2 });
            });
        })();

        // ============================================
        // Filter Controls
        // ============================================
        function filterLayers(type, event) {
            const buttons = document.querySelectorAll('.layer-filter-btn');
            buttons.forEach(btn => btn.classList.remove('bg-white', 'text-gray-900', 'shadow-sm'));
            buttons.forEach(btn => btn.classList.add('text-gray-500'));
            if (event) {
                event.currentTarget.classList.add('bg-white', 'text-gray-900', 'shadow-sm');
                event.currentTarget.classList.remove('text-gray-500');
            }

            map.removeLayer(riskLayer);
            map.removeLayer(incidentLayer);
            map.removeLayer(shelterLayer);
            map.removeLayer(bufferLayer);

            if (type === 'all' || type === 'risk') map.addLayer(riskLayer);
            if (type === 'all' || type === 'incident') map.addLayer(incidentLayer);
            if (type === 'all' || type === 'shelter') { map.addLayer(shelterLayer); map.addLayer(bufferLayer); }
        }

        function refreshMapData() {
            if (simulationMode) {
                loadScenario('tout');
            } else {
                loadRealData();
            }
        }

        // Auto-refresh timestamp every 30 seconds
        setInterval(() => {
            if (!simulationMode) {
                updateLastUpdated();
            }
        }, 30000);

        // ============================================
        // Chatbot
        // ============================================
        function toggleChat() {
            const panel = document.getElementById('chatbot-panel');
            const btn = document.getElementById('chatbot-btn');
            panel.classList.toggle('open');
            btn.classList.toggle('active');
            if (panel.classList.contains('open')) {
                btn.innerHTML = '<i class="bi bi-x-lg"></i>';
                document.getElementById('chatbot-input').focus();
            } else {
                btn.innerHTML = '<i class="bi bi-robot"></i>';
            }
        }

        function sendSuggestion(text) {
            document.getElementById('chatbot-input').value = text;
            sendChatMessage();
        }

        async function sendChatMessage() {
            const input = document.getElementById('chatbot-input');
            const message = input.value.trim();
            if (!message) return;

            const messagesDiv = document.getElementById('chatbot-messages');
            const sendBtn = document.getElementById('chatbot-send-btn');

            // Add user message
            messagesDiv.innerHTML += '<div class="chat-msg user">' + escapeHtml(message) + '</div>';
            input.value = '';
            sendBtn.disabled = true;
            messagesDiv.scrollTop = messagesDiv.scrollHeight;

            // Check if simulation is active and has data
            var hasContext = false;
            var contextData = { simulationMode: simulationMode };
            
            // Add real-time trajectory position if available
            if (simulationMode && window._simCurrentPos) {
                contextData.currentPosition = window._simCurrentPos;
                contextData.simulationTrack = {
                    current: window._simCurrentPos,
                    totalPoints: simTrack.length,
                    progress: ((simIndex + 1) / simTrack.length * 100).toFixed(0) + '%'
                };
                hasContext = true;
            }

            if (simulationMode && REAL_SIMULATION_DATA) {
                var srcZones = REAL_SIMULATION_DATA.zones || [];
                var srcShelters = REAL_SIMULATION_DATA.shelters || [];
                var srcIncidents = REAL_SIMULATION_DATA.incidents || [];
                if (srcZones.length > 0) {
                    contextData.zones = srcZones;
                    contextData.shelters = srcShelters;
                    contextData.incidents = srcIncidents;
                    hasContext = true;
                }
            }

            if (!hasContext) {
                // No simulation data → show "Rien à signaler" directly
                messagesDiv.innerHTML += '<div class="chat-msg bot"><strong>🔍 Analyse de la carte</strong><br><br>' +
                    'Rien à signaler. Aucun cyclone ou catastrophe n\'est actuellement actif sur la carte.<br><br>' +
                    '<em>Activez le mode <strong>Simulation</strong> (bouton violet dans le panneau de gauche) pour analyser les scénarios de cyclones et obtenir des prévisions détaillées.</em></div>';
                sendBtn.disabled = false;
                messagesDiv.scrollTop = messagesDiv.scrollHeight;
                input.focus();
                return;
            }

            // Build position info if simulation is active
            var positionInfo = '';
            if (simulationMode && window._simCurrentPos) {
                var p = window._simCurrentPos;
                var progress = p.total > 0 ? ((p.index + 1) / p.total * 100).toFixed(0) : '0';
                positionInfo =
                    '<div style="background:#f3e8ff;border:1px solid #d8b4fe;border-radius:10px;padding:10px;margin-bottom:10px;font-size:12px;">' +
                    '<strong style="color:#7c3aed;">🌀 Simulation en cours — Données temps réel</strong><br>' +
                    '📌 <strong>Position:</strong> ' + p.lat + 'S, ' + p.lng + 'E &nbsp;|&nbsp; ' +
                    '📈 <strong>Avancement:</strong> ' + progress + '% (' + (p.index + 1) + '/' + p.total + ')' +
                    (p.stage ? '<br>📊 <strong>Phase:</strong> ' + p.stage : '') +
                    (p.wind ? '<br>💨 <strong>Vent:</strong> ' + p.wind + ' km/h' : '') +
                    (p.pressure ? '<br>🌡️ <strong>Pression:</strong> ' + p.pressure + ' hPa' : '') +
                    (p.population ? '<br>👥 <strong>Population touchée cumulée:</strong> ' + p.population.toLocaleString() : '') +
                    (p.datetime ? '<br>🕐 <strong>Date:</strong> ' + p.datetime : '') +
                    '</div>';
            }

            // Add loading indicator
            const loadingId = 'loading-' + Date.now();
            messagesDiv.innerHTML += '<div class="chat-msg bot" id="' + loadingId + '"><em>Réflexion en cours...</em></div>';
            messagesDiv.scrollTop = messagesDiv.scrollHeight;

            try {
                const res = await fetch('/chatbot', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message: message, context: contextData })
                });
                const data = await res.json();

                // Remove loading indicator
                const loadingEl = document.getElementById(loadingId);
                if (loadingEl) loadingEl.remove();

                if (data.reply) {
                    messagesDiv.innerHTML += '<div class="chat-msg bot">' + positionInfo + formatReply(data.reply) + '</div>';
                } else {
                    messagesDiv.innerHTML += '<div class="chat-msg error">' + positionInfo + 'Désolé, je n\'ai pas compris. Veuillez réessayer.</div>';
                }
            } catch (err) {
                const loadingEl = document.getElementById(loadingId);
                if (loadingEl) loadingEl.remove();
                messagesDiv.innerHTML += '<div class="chat-msg error">' + positionInfo + 'Erreur de connexion. Veuillez réessayer.</div>';
            }

            sendBtn.disabled = false;
            messagesDiv.scrollTop = messagesDiv.scrollHeight;
            input.focus();
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        function formatReply(text) {
            if (!text) return '';
            // Convert markdown-style bold to HTML
            text = text.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
            text = text.replace(/\*(.+?)\*/g, '<em>$1</em>');
            // Convert newlines to <br>
            text = text.replace(/\n/g, '<br>');
            // Convert bullet lists
            text = text.replace(/^• /gm, '&bull; ');
            text = text.replace(/^- /gm, '&bull; ');
            return text;
        }

        // ============================================
        // Initialize - load default data
        // ============================================
        loadRealData();
    </script>
</body>
</html>