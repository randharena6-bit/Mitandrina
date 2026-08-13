<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Planificateur d'Évacuation - MITANDRINA</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Leaflet Maps -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: { sans: ['Inter', 'system-ui', 'sans-serif'] },
                    colors: {
                        primary: { 50: '#ecfdf5', 100: '#d1fae5', 500: '#10b981', 600: '#059669', 700: '#047857' },
                        danger: { 50: '#fef2f2', 100: '#fee2e2', 500: '#ef4444', 600: '#dc2626', 700: '#b91c1c' },
                        warning: { 50: '#fffbeb', 100: '#fef3c7', 500: '#f59e0b', 600: '#d97706' },
                        info: { 50: '#eff6ff', 100: '#dbeafe', 500: '#3b82f6', 600: '#2563eb' }
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
        .nav-item.active { background: #ecfdf5; color: #059669; font-weight: 600; }
        .card-modern {
            background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .card-modern:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.08); }
        .animate-fade-in-up { animation: fadeInUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; opacity: 0; }
        .delay-100 { animation-delay: 100ms; }
        .delay-200 { animation-delay: 200ms; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        .btn-icon {
            width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center;
            background: white; border: 1px solid #e2e8f0; color: #64748b; transition: all 0.2s ease;
        }
        .btn-icon:hover { background: #f8fafc; border-color: #cbd5e1; color: #1e293b; }
        
        /* Map Styles */
        .custom-marker { background: transparent; border: none; }
        .marker-pin {
            width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center;
            font-size: 18px; box-shadow: 0 4px 12px rgba(0,0,0,0.25); border: 2.5px solid white;
        }
        .shelter-card {
            cursor: pointer; transition: all 0.2s ease; border: 2px solid transparent;
        }
        .shelter-card:hover { border-color: #059669; background: #f0fdf4; }
        .shelter-card.selected { border-color: #059669; background: #ecfdf5; }
        .capacity-bar { height: 6px; border-radius: 3px; background: #e2e8f0; overflow: hidden; }
        .capacity-bar-fill { height: 100%; border-radius: 3px; transition: width 0.5s ease; }
        .step-card {
            border-left: 3px solid #059669; padding-left: 12px; margin-bottom: 8px;
            animation: slideIn 0.3s ease;
        }
        @keyframes slideIn { from { opacity: 0; transform: translateX(-10px); } to { opacity: 1; transform: translateX(0); } }
        .weather-widget {
            background: linear-gradient(135deg, #1e3a5f, #2d5a87);
            color: white; border-radius: 14px; padding: 14px;
        }
        .tip-card {
            background: #fffbeb; border: 1px solid #fde68a; border-radius: 12px; padding: 12px;
        }
        .search-shelter-input {
            width: 100%; padding: 8px 12px; border: 1px solid #e2e8f0; border-radius: 8px;
            font-size: 12px; outline: none; transition: border 0.2s;
        }
        .search-shelter-input:focus { border-color: #059669; box-shadow: 0 0 0 3px rgba(5,150,105,0.1); }
    </style>
    <link rel="stylesheet" href="/assets/css/custom.css?v=2b712ebf">
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
                
                <a href="dashboard" class="nav-item">
                    <i class="bi bi-grid-1x2-fill text-lg"></i>
                    <span>Tableau de bord</span>
                </a>
                
                <a href="map" class="nav-item">
                    <i class="bi bi-map-fill text-lg"></i>
                    <span>Carte des risques</span>
                </a>
                
                <a href="cyclone-map" class="nav-item">
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
                
                <a href="evacuation" class="nav-item active">
                    <i class="bi bi-car-front-fill text-lg"></i>
                    <span>Évacuation</span>
                </a>
                
                <c:if test="${sessionScope.user.role == 'administrateur'}">
                    <div class="px-3 mt-6 mb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">Administration</div>
                    
                    <a href="admin/users" class="nav-item">
                        <i class="bi bi-people-fill text-lg"></i>
                        <span>Utilisateurs</span>
                    </a>
                    
                    <a href="admin/teams" class="nav-item">
                        <i class="bi bi-building-fill text-lg"></i>
                        <span>Équipes</span>
                    </a>
                    
                    <a href="admin/simulations" class="nav-item">
                        <i class="bi bi-magic text-lg"></i>
                        <span>Simulations</span>
                    </a>
                </c:if>
            </nav>
            
            <div class="p-4 border-t border-gray-100">
                <div class="flex items-center gap-3 mb-3 p-3 bg-gray-50 rounded-xl">
                    <div class="w-10 h-10 rounded-full bg-emerald-600 flex items-center justify-center font-semibold text-white text-sm">
                        ${not empty sessionScope.user.firstName ? sessionScope.user.firstName.charAt(0) : '?'}${not empty sessionScope.user.lastName ? sessionScope.user.lastName.charAt(0) : '?'}
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-sm font-semibold text-gray-900 truncate">${not empty sessionScope.user.firstName ? sessionScope.user.firstName : ''} ${not empty sessionScope.user.lastName ? sessionScope.user.lastName : 'Utilisateur'}</p>
                        <p class="text-xs text-gray-500 capitalize">${sessionScope.user.role}</p>
                    </div>
                </div>
                <a href="auth/logout" class="flex items-center justify-center gap-2 w-full py-2.5 rounded-xl border border-gray-200 text-gray-600 font-medium hover:bg-primary-50 hover:text-primary-700 transition-all text-sm">
                    <i class="bi bi-box-arrow-right"></i>
                    Déconnexion
                </a>
            </div>
        </div>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content flex-1 ml-[280px] flex flex-col md:flex-row h-screen">
        <!-- Control Panel -->
        <div class="w-full md:w-96 bg-white/90 backdrop-blur-xl border-r border-gray-200 p-6 flex flex-col justify-between overflow-y-auto flex-shrink-0 z-10 animate-fade-in-up">
            <div class="space-y-6">
                <div>
                    <h1 class="text-xl font-bold text-gray-900">Évacuation IA A*</h1>
                    <p class="text-xs text-gray-500">Générez un chemin de survie contournant les dangers</p>
                </div>
                
                <div class="space-y-4">
                    <!-- Origin -->
                    <div>
                        <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Point de départ (Votre position)</label>
                        <div class="relative">
                            <span class="absolute inset-y-0 left-0 pl-3 flex items-center text-gray-400">
                                📍
                            </span>
                            <input type="text" id="origin-label" value="Votre position (chargement...)" disabled 
                                   class="form-control pl-8 bg-gray-50 border-gray-200 rounded-xl text-xs font-medium">
                        </div>
                    </div>
                    
                    <!-- Destination Shelter -->
                    <div>
                        <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Refuge de destination</label>
                        <input type="text" id="shelter-search" class="search-shelter-input mb-2" placeholder="Rechercher un refuge..." oninput="filterShelters(this.value)">
                        <div id="shelter-list" class="space-y-1.5 max-h-48 overflow-y-auto rounded-xl bg-gray-50 p-1.5 border border-gray-100">
                            <div class="text-xs text-gray-400 text-center py-4">Chargement des refuges...</div>
                        </div>
                        <select id="destination-shelter" class="form-select bg-gray-50 border-gray-200 rounded-xl text-xs font-medium hidden">
                            <option value="">-- Choisir le refuge cible --</option>
                        </select>
                    </div>

                    <!-- Transit mode -->
                    <div>
                        <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Mode de Transport</label>
                        <select id="routing-mode" class="form-select bg-gray-50 border-gray-200 rounded-xl text-xs font-medium">
                            <option value="car">🚗 Voiture / Véhicule d'urgence</option>
                            <option value="walk">🚶 À pied / Évacuation pédestre</option>
                            <option value="bike">🚲 Vélo / Deux roues</option>
                        </select>
                    </div>
                </div>

                <button onclick="calculateAStarRoute(event)" 
                        class="w-full py-3 bg-primary-600 hover:bg-primary-700 text-white font-bold rounded-xl shadow-lg shadow-primary-600/25 transition-all text-xs flex items-center justify-center gap-2">
                    <i class="bi bi-lightning-charge-fill"></i>
                    Calculer l'itinéraire optimal
                </button>

                <!-- Simulation Toggle -->
                <div class="border-t border-gray-100 pt-4 mt-4">
                    <div class="flex items-center justify-between mb-2">
                        <span class="text-xs font-bold text-gray-600 flex items-center gap-1.5">
                            <i class="bi bi-magic text-purple-600"></i> Simulation catastrophes
                        </span>
                        <button onclick="toggleSimulation()" id="sim-toggle-btn-evac" class="text-xs px-2.5 py-1 rounded-lg bg-purple-50 text-purple-700 font-medium hover:bg-purple-100 transition-colors flex items-center gap-1">
                            <i class="bi bi-play-fill"></i> Activer
                        </button>
                    </div>
                    <div id="sim-panel-evac" class="hidden space-y-1.5 mt-2">
                        <p class="text-[10px] text-gray-500">Affiche des scénarios de catastrophe simulés sur la carte pour tester les itinéraires d'évacuation.</p>
                        <div class="flex gap-1.5 flex-wrap">
                            <button onclick="loadScenarioEvac('inondation')" class="px-2 py-1 bg-blue-50 text-blue-700 text-[10px] font-medium rounded-lg hover:bg-blue-100 transition-colors">💧 Inondation</button>
                            <button onclick="loadScenarioEvac('incendie')" class="px-2 py-1 bg-red-50 text-red-700 text-[10px] font-medium rounded-lg hover:bg-red-100 transition-colors">🔥 Incendie</button>
                            <button onclick="loadScenarioEvac('cyclone')" class="px-2 py-1 bg-purple-50 text-purple-700 text-[10px] font-medium rounded-lg hover:bg-purple-100 transition-colors">🌀 Cyclone</button>
                            <button onclick="loadScenarioEvac('tout')" class="px-2 py-1 bg-gray-50 text-gray-700 text-[10px] font-medium rounded-lg hover:bg-gray-100 transition-colors">🌍 Tous</button>
                        </div>
                        <button onclick="clearSimulationEvac()" class="text-[10px] text-gray-400 hover:text-gray-600 transition-colors">Effacer simulation</button>

                        <!-- === Trajectory Simulation Panel === -->
                        <div class="border-t border-gray-100 pt-3 mt-3">
                            <div class="flex items-center justify-between mb-2">
                                <span class="text-xs font-bold text-gray-600 flex items-center gap-1.5">
                                    <i class="bi bi-play-circle text-purple-600"></i> Trajectoire cyclonique
                                </span>
                            </div>
                            <div id="simTrajLoading" class="text-center py-2 hidden">
                                <div class="animate-spin w-4 h-4 border-2 border-purple-500 border-t-transparent rounded-full mx-auto mb-1"></div>
                                <p class="text-[10px] text-gray-400">Chargement...</p>
                            </div>
                            <div id="simTrajContent" class="hidden">
                                <select id="simTrajSelect" onchange="onEvacSimSelect(this.value)" class="form-select w-full text-[10px] bg-gray-50 border-gray-200 rounded-lg mb-2 py-1">
                                    <option value="">Sélectionner un cyclone</option>
                                </select>
                                <div id="simTrajTrackInfo" class="hidden">
                                    <div class="flex items-center justify-center gap-2 mb-2">
                                        <button onclick="toggleEvacPlayback()" id="simTrajPlayBtn" class="px-3 py-1.5 bg-purple-600 text-white font-bold rounded-lg text-[10px] hover:bg-purple-700 transition flex items-center gap-1">
                                            <i class="bi bi-play-fill"></i> Lire
                                        </button>
                                        <div class="flex gap-0.5">
                                            <button onclick="setEvacSpeed(1)" id="evacSpd1" class="px-1.5 py-1 text-[9px] font-bold rounded-md bg-purple-600 text-white">1x</button>
                                            <button onclick="setEvacSpeed(2)" id="evacSpd2" class="px-1.5 py-1 text-[9px] font-bold rounded-md bg-gray-200 text-gray-600">2x</button>
                                            <button onclick="setEvacSpeed(4)" id="evacSpd4" class="px-1.5 py-1 text-[9px] font-bold rounded-md bg-gray-200 text-gray-600">4x</button>
                                        </div>
                                    </div>
                                    <input type="range" id="simTrajSlider" min="0" max="100" value="0" oninput="onEvacSimSlider(this.value)" class="w-full mb-1.5 accent-purple-600" style="height:4px">
                                    <div class="flex justify-between text-[9px] text-gray-400 mb-1.5">
                                        <span id="simTrajTimeLabel">Début</span>
                                        <span id="simTrajTimeEnd">Fin</span>
                                    </div>
                                    <div class="grid grid-cols-2 gap-1 text-[10px] bg-purple-50 rounded-lg p-2">
                                        <div><span class="text-gray-500">Vent:</span> <span class="font-semibold text-purple-700" id="simTrajWind">-- km/h</span></div>
                                        <div><span class="text-gray-500">Pression:</span> <span class="font-semibold text-gray-800" id="simTrajPressure">-- hPa</span></div>
                                        <div><span class="text-gray-500">Phase:</span> <span class="font-semibold text-gray-800" id="simTrajStage">--</span></div>
                                        <div><span class="text-gray-500">Position:</span> <span class="font-semibold text-gray-800" id="simTrajPos">--</span></div>
                                    </div>
                                    <div class="text-center text-[10px] font-bold text-red-600 mt-1.5 bg-red-50 rounded-md py-1" id="simTrajPopulation">Population touchée: 0</div>
                                </div>
                            </div>
                            <div id="simTrajEmpty" class="hidden text-center py-2">
                                <p class="text-[10px] text-gray-500">Aucune simulation cyclonique disponible</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
                    <!-- Weather Widget -->
                <div id="weather-widget" class="weather-widget hidden mt-4">
                    <div class="flex items-center justify-between mb-2">
                        <span class="text-xs font-bold opacity-90">🌤 Météo actuelle</span>
                        <span id="weather-location" class="text-[10px] opacity-75">Antananarivo</span>
                    </div>
                    <div class="flex items-center gap-3">
                        <span id="weather-icon" class="text-2xl">☀️</span>
                        <div>
                            <span id="weather-temp" class="text-xl font-bold">--°C</span>
                            <span id="weather-desc" class="text-[11px] opacity-80 block">--</span>
                        </div>
                        <div class="ml-auto text-right text-[10px] opacity-75">
                            <div>💧 <span id="weather-humidity">--%</span></div>
                            <div>💨 <span id="weather-wind">-- km/h</span></div>
                        </div>
                    </div>
                </div>

        <!-- Dynamic Routing Metrics -->
            <div id="routing-metrics" class="mt-6 bg-gray-50 border border-gray-100 rounded-2xl p-4 space-y-3 hidden">
                <h4 class="font-bold text-gray-900 text-xs flex items-center gap-1.5">
                    <i class="bi bi-activity text-green-500"></i>
                    Statistiques de survie du trajet
                </h4>
                <div class="grid grid-cols-2 gap-2 text-center">
                    <div class="bg-white border border-gray-100 rounded-xl p-3">
                        <p class="text-[10px] text-gray-500 font-bold uppercase">Distance</p>
                        <p id="metric-distance" class="text-base font-bold text-gray-900">-- km</p>
                    </div>
                    <div class="bg-white border border-gray-100 rounded-xl p-3">
                        <p class="text-[10px] text-gray-500 font-bold uppercase">Temps estimé</p>
                        <p id="metric-time" class="text-base font-bold text-gray-900">-- min</p>
                    </div>
                </div>
                <div class="bg-white border border-gray-100 rounded-xl p-3 flex items-center justify-between">
                    <span class="text-[10px] text-gray-500 font-bold uppercase">Indice de Risque du trajet :</span>
                    <span id="metric-danger" class="px-2 py-0.5 rounded text-[10px] font-bold text-white bg-green-500">Sûr</span>
                </div>
            </div>

            <!-- Danger Warning & Safe Alternatives -->
            <div id="danger-warning" class="mt-4 bg-red-50 border border-red-200 rounded-2xl p-4 hidden">
                <div class="flex items-start gap-2">
                    <i class="bi bi-exclamation-triangle-fill text-red-500 mt-0.5"></i>
                    <div>
                        <p class="text-xs font-bold text-red-700">Refuge en zone de danger</p>
                        <p id="danger-detail" class="text-[11px] text-red-600 mt-0.5"></p>
                    </div>
                </div>
            </div>

            <div id="safe-alternatives" class="mt-3 space-y-2 hidden">
                <p class="text-[11px] font-bold text-gray-600 flex items-center gap-1">
                    <i class="bi bi-shield-check text-green-600"></i>
                    Refuges alternatifs sûrs à proximité :
                </p>
                <div id="alternatives-list" class="space-y-1.5 max-h-40 overflow-y-auto"></div>
            </div>

            <!-- Route Steps -->
            <div id="route-steps" class="mt-4 hidden">
                <div class="flex items-center gap-1.5 mb-2">
                    <i class="bi bi-signpost-2 text-green-600 text-sm"></i>
                    <span class="text-[11px] font-bold text-gray-600">Instructions du trajet</span>
                </div>
                <div id="steps-list" class="space-y-1"></div>
            </div>

            <!-- Survival Tips -->
            <div id="survival-tips" class="mt-3 hidden">
                <div class="flex items-center gap-1.5 mb-2">
                    <i class="bi bi-lightbulb text-amber-500 text-sm"></i>
                    <span class="text-[11px] font-bold text-gray-600">Conseils de survie pour ce trajet</span>
                </div>
                <div id="tips-content" class="tip-card text-xs text-amber-800 space-y-1"></div>
            </div>
        </div>
        
        <!-- Live Routing Map -->
        <div class="flex-1 relative">
            <div id="evac-map" class="w-full h-full"></div>
            
            <button class="absolute top-4 left-4 z-[1000] md:hidden btn-icon" onclick="toggleSidebar()">
                <i class="bi bi-list text-xl"></i>
            </button>
        </div>
    </main>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('open');
        }

        // ============================================
        // Simulation Data - fetched from real simulations API
        // ============================================
        let REAL_SIMULATION_DATA = null;

        async function fetchRealSimulations() {
            if (REAL_SIMULATION_DATA) return REAL_SIMULATION_DATA;
            try {
                const res = await fetch('/api/v1/admin/simulations', {
                    headers: { 'Authorization': 'Bearer ' + ('<%= session.getAttribute("token") %>') }
                });
                const data = await res.json();
                const zones = [], shelters = [], incidents = [];

                (data.simulations || []).forEach(function(sim) {
                    if (sim.status !== 'completed') return;
                    const track = sim.results ? sim.results.track : null;
                    if (!track || track.length === 0) return;

                    const maxWind = sim.results.max_wind_kmh || 0;
                    const type = sim.scenario_type || 'cyclone';
                    const level = maxWind >= 120 ? 'urgence' : maxWind >= 80 ? 'alerte' : 'vigilance';

                    zones.push({
                        id: 'sim-' + sim.id,
                        type: type,
                        level: level,
                        lat: track[0].lat,
                        lng: track[0].lng,
                        name: sim.name,
                        desc: (track.length + ' points de trajectoire - Vents max ' + maxWind + ' km/h - Pression min ' + (sim.results.min_pressure_hpa || 'N/A') + ' hPa'),
                        danger_score: Math.min(100, Math.round(maxWind / 2.5)),
                        confidence: 85,
                        radius: (sim.radius_km || 50) * 1000
                    });

                    (sim.results.safe_refuges_identified || []).forEach(function(name, i) {
                        const idx = Math.min(i * Math.max(1, Math.floor(track.length / 5)), track.length - 1);
                        const pt = track[idx];
                        shelters.push({
                            id: 'sim-shelter-' + sim.id + '-' + i,
                            name: name,
                            lat: pt.lat + (Math.random() - 0.5) * 0.08,
                            lng: pt.lng + (Math.random() - 0.5) * 0.08,
                            capacity: 500,
                            occupied: Math.round(50 + Math.random() * 250),
                            type: 'Simulation IA',
                            medical: true,
                            food: true,
                            water: true
                        });
                    });

                    const severePoints = track.filter(function(p) { return p.wind >= (maxWind * 0.7); }).slice(0, 3);
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

        // Fetch simulations on page load
        fetchRealSimulations();

        // ============================================
        // Fallback simulation data (quand API indisponible)
        // ============================================
        const SIMULATION_ZONES = [
            { id: 1, type: 'cyclone', level: 'urgence', lat: -18.1, lng: 49.5, name: 'Cyclone Gezani - Toamasina', desc: 'Cyclone tropical intense - Vents 185 km/h', danger_score: 95, confidence: 92, radius: 80000 },
            { id: 2, type: 'inondation', level: 'alerte', lat: -18.9078, lng: 47.5208, name: 'Inondation - Antananarivo', desc: "Niveau d'eau élevé - Précautions recommandées", danger_score: 65, confidence: 78, radius: 5000 },
            { id: 3, type: 'incendie', level: 'urgence', lat: -18.1442, lng: 49.3956, name: 'Incendie - Toamasina', desc: 'Feu de forêt détecté - Évacuation en cours', danger_score: 80, confidence: 88, radius: 3000 },
        ];

        const SIMULATION_ACTIVE_ZONES_ICONS = {
            incendie: { emoji: '🔥', color: '#ef4444' },
            inondation: { emoji: '💧', color: '#3b82f6' },
            cyclone: { emoji: '🌀', color: '#8b5cf6' },
            tsunami: { emoji: '🌊', color: '#2563eb' },
            glissement_terrain: { emoji: '⛰️', color: '#78350f' },
        };

        const createZoneIcon = (emoji, color) => {
            return L.divIcon({
                className: 'custom-marker',
                html: '<div class="marker-pin" style="background: ' + color + '">' + emoji + '</div>',
                iconSize: [36, 36],
                iconAnchor: [18, 36],
                popupAnchor: [0, -36]
            });
        };

        let simulationModeEvac = false;
        let simZoneMarkers = [];
        let simCircles = [];

        function loadScenarioEvac(type) {
            clearSimulationEvac();
            let zones = type === 'tout' ? SIMULATION_ZONES : SIMULATION_ZONES.filter(z => z.type === type);
            if (REAL_SIMULATION_DATA && REAL_SIMULATION_DATA.zones.length > 0) {
                const allZones = REAL_SIMULATION_DATA.zones;
                zones = type === 'tout' ? allZones : allZones.filter(z => z.type === type);
            }
            zones.forEach(z => {
                const iconInfo = SIMULATION_ACTIVE_ZONES_ICONS[z.type] || { emoji: '📍', color: '#f97316' };
                const zoneIcon = createZoneIcon(iconInfo.emoji, iconInfo.color);
                const levelColor = z.level === 'urgence' ? '#ef4444' : z.level === 'alerte' ? '#f59e0b' : '#3b82f6';
                const marker = L.marker([z.lat, z.lng], { icon: zoneIcon })
                    .addTo(map)
                    .bindPopup(
                        '<div style="min-width:200px;">' +
                            '<span style="display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;color:white;background:' + levelColor + ';border-radius:4px;text-transform:uppercase;margin-bottom:6px;">SIMULATION ' + z.level.toUpperCase() + '</span>' +
                            '<h6 style="font-weight:700;font-size:13px;margin-bottom:4px;">' + z.name + '</h6>' +
                            '<p style="font-size:11px;color:#64748b;margin-bottom:8px;">' + z.desc + '</p>' +
                            '<div style="font-size:11px;color:#64748b;">Danger: <strong>' + z.danger_score + '/100</strong> | Confiance: <strong>' + z.confidence + '%</strong></div>' +
                        '</div>'
                    );
                simZoneMarkers.push(marker);

                if (z.type !== 'cyclone') {
                    const circle = L.circle([z.lat, z.lng], {
                        color: levelColor,
                        fillColor: levelColor,
                        fillOpacity: 0.12,
                        radius: z.radius
                    }).addTo(map);
                    simCircles.push(circle);
                }
            });

            if (zones.length > 0) {
                const bounds = zones.map(z => [z.lat, z.lng]);
                map.fitBounds(bounds, { padding: [50, 50], maxZoom: 8 });
            }
        }

        function clearSimulationEvac() {
            simZoneMarkers.forEach(m => map.removeLayer(m));
            simCircles.forEach(c => map.removeLayer(c));
            simZoneMarkers = [];
            simCircles = [];
        }

        // ====== TRAJECTORY SIMULATION PLAYBACK (Evacuation) ======
        var evacSimTrack = [];
        var evacSimIndex = 0;
        var evacSimPlaying = false;
        var evacSimSpeed = 1;
        var evacSimTimer = null;
        var evacSimMarker = null;
        var evacSimPolyline = null;
        var evacSimDamageCircle = null;
        var evacSimLayer = null;
        var evacLastDamagePos = null;
        var evacHeatmapGrid = {};
        var evacHeatmapLayer = null;
        var evacLines = [];
        var evacTotalPop = 0;
        var evacTotalArea = 0;
        var evacSheltersUsed = [];
        var evacFrameCount = 0;

        function haversineKm(lat1, lng1, lat2, lng2) {
            var R = 6371;
            var dLat = (lat2 - lat1) * Math.PI / 180;
            var dLng = (lng2 - lng1) * Math.PI / 180;
            var a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * Math.sin(dLng/2) * Math.sin(dLng/2);
            return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        }

        var EVAC_CITIES = [
            { name: 'Antananarivo', lat: -18.8792, lng: 47.5079 },
            { name: 'Toamasina',     lat: -18.1492, lng: 49.4000 },
            { name: 'Mahajanga',     lat: -15.7150, lng: 46.3200 },
            { name: 'Fianarantsoa',  lat: -21.4527, lng: 47.0875 },
            { name: 'Antsiranana',   lat: -12.2800, lng: 49.2900 },
            { name: 'Toliara',       lat: -23.3500, lng: 43.6800 },
            { name: 'Antsirabe',     lat: -19.8667, lng: 47.0333 },
            { name: 'Morondava',     lat: -20.2833, lng: 44.2833 },
        ];

        function evacGetDensity(lat, lng) {
            var minDist = Infinity;
            EVAC_CITIES.forEach(function(c) {
                var d = haversineKm(lat, lng, c.lat, c.lng);
                if (d < minDist) minDist = d;
            });
            if (minDist < 20) return 2500;
            if (minDist < 50) return 500;
            if (minDist < 100) return 100;
            return 35;
        }

        function evacDistanceKm(lat1, lng1, lat2, lng2) {
            return haversineKm(lat1, lng1, lat2, lng2);
        }

        function evacFindNearestShelter(lat, lng) {
            var candidates = allShelters.length > 0 ? allShelters : [];
            var best = null, bestDist = Infinity;
            candidates.forEach(function(s) {
                var slat = s.location_lat || s.lat;
                var slng = s.location_lng || s.lng;
                if (!slat || !slng) return;
                var d = evacDistanceKm(lat, lng, slat, slng);
                if (d < bestDist) { bestDist = d; best = s; }
            });
            return best;
        }

        async function loadEvacSimulations() {
            document.getElementById('simTrajLoading').classList.remove('hidden');
            document.getElementById('simTrajContent').classList.add('hidden');
            document.getElementById('simTrajEmpty').classList.add('hidden');

            var sel = document.getElementById('simTrajSelect');
            sel.innerHTML = '<option value="">Sélectionner un cyclone</option>';

            try {
                var resp = await fetch('/api/v1/admin/simulations', {
                    headers: { 'Authorization': 'Bearer ' + ('<%= session.getAttribute("token") %>') }
                });
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
                        sel.appendChild(opt);
                    });
                    document.getElementById('simTrajContent').classList.remove('hidden');
                } else {
                    document.getElementById('simTrajEmpty').classList.remove('hidden');
                }
            } catch (e) {
                console.warn('Impossible de charger les simulations:', e);
                document.getElementById('simTrajEmpty').classList.remove('hidden');
            } finally {
                document.getElementById('simTrajLoading').classList.add('hidden');
            }
        }

        function onEvacSimSelect(id) {
            if (!id) { clearEvacSimTrack(); return; }
            var sel = document.getElementById('simTrajSelect');
            var data = null;
            for (var i = 0; i < sel.options.length; i++) {
                if (sel.options[i].value === id) { data = sel.options[i]._data; break; }
            }
            if (!data || !data.results || !data.results.track) return;
            loadEvacTrack(data.results.track);
        }

        function loadEvacTrack(track) {
            clearEvacSimTrack();
            evacSimTrack = track;
            if (evacSimTrack.length === 0) return;

            var slider = document.getElementById('simTrajSlider');
            slider.max = evacSimTrack.length - 1;
            slider.value = 0;

            document.getElementById('simTrajTimeEnd').textContent = evacSimTrack[evacSimTrack.length - 1].datetime || 'Fin';
            document.getElementById('simTrajTrackInfo').classList.remove('hidden');

            var pts = evacSimTrack.map(function(p) { return [p.lat, p.lng]; });
            evacSimPolyline = L.polyline(pts, { color: '#7c3aed', weight: 2.5, opacity: 0.7, dashArray: '6, 4' }).addTo(evacSimLayer);

            var last = evacSimTrack[0];
            evacSimMarker = L.marker([last.lat, last.lng], {
                icon: createMarkerIcon('🌀', '#7c3aed')
            }).addTo(evacSimLayer).bindPopup('<div class="p-1 text-xs"><strong>Simulation</strong></div>');

            map.setView([last.lat, last.lng], 6);
            updateEvacSimFrame(0);
        }

        function clearEvacSimTrack() {
            evacSimPlaying = false;
            if (evacSimTimer) { clearInterval(evacSimTimer); evacSimTimer = null; }
            evacSimTrack = [];
            evacSimIndex = 0;
            evacSimLayer.clearLayers();
            evacHeatmapLayer.clearLayers();
            evacSimMarker = null;
            evacSimPolyline = null;
            evacSimDamageCircle = null;
            evacLastDamagePos = null;
            evacHeatmapGrid = {};
            evacLines = [];
            evacTotalPop = 0;
            evacTotalArea = 0;
            evacSheltersUsed = [];
            evacFrameCount = 0;
            document.getElementById('simTrajTrackInfo').classList.add('hidden');
            document.getElementById('simTrajPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Lire';
            document.getElementById('simTrajPopulation').textContent = 'Population touchée: 0';
        }

        function updateEvacSimFrame(idx) {
            if (!evacSimTrack.length || idx < 0 || idx >= evacSimTrack.length) return;
            evacSimIndex = idx;
            var p = evacSimTrack[idx];

            document.getElementById('simTrajSlider').value = idx;
            document.getElementById('simTrajTimeLabel').textContent = p.datetime || (idx + '/' + evacSimTrack.length);
            document.getElementById('simTrajPos').textContent = p.lat.toFixed(2) + 'S, ' + p.lng.toFixed(2) + 'E';
            document.getElementById('simTrajWind').textContent = (p.wind || 0) + ' km/h';
            document.getElementById('simTrajPressure').textContent = (p.pressure || 0) + ' hPa';
            document.getElementById('simTrajStage').textContent = p.stage || '--';

            if (evacSimMarker) {
                evacSimMarker.setLatLng([p.lat, p.lng]);
            }
            if (evacSimPolyline) {
                var pts = evacSimTrack.slice(0, idx + 1).map(function(pt) { return [pt.lat, pt.lng]; });
                evacSimPolyline.setLatLngs(pts);
            }

            // Cercle d'impact mobile : taille basée sur l'échelle de Saffir-Simpson
            var wind = p.wind || 0;
            var dmgRadius = wind >= 63 ? Math.round(wind * 1000) : 0;
            var dmgColor = wind >= 209 ? '#dc2626' : wind >= 154 ? '#f97316' : wind >= 119 ? '#f59e0b' : wind >= 63 ? '#3b82f6' : '#6b7280';
            if (!evacSimDamageCircle && dmgRadius > 0) {
                evacSimDamageCircle = L.circle([p.lat, p.lng], {
                    color: dmgColor, fillColor: dmgColor,
                    fillOpacity: 0.15, weight: 3,
                    radius: dmgRadius
                }).addTo(evacSimLayer);
            }
            if (evacSimDamageCircle) {
                evacSimDamageCircle.setLatLng([p.lat, p.lng]);
                evacSimDamageCircle.setRadius(dmgRadius);
                evacSimDamageCircle.setStyle({
                    color: dmgColor, fillColor: dmgColor,
                    fillOpacity: dmgRadius > 0 ? 0.15 : 0
                });
            }

            if (!evacLastDamagePos || evacDistanceKm(evacLastDamagePos.lat, evacLastDamagePos.lng, p.lat, p.lng) > 0.3) {
                evacLastDamagePos = { lat: p.lat, lng: p.lng };

                var gridLat = Math.round(p.lat * 4) / 4;
                var gridLng = Math.round(p.lng * 4) / 4;
                var key = gridLat + ',' + gridLng;
                evacHeatmapGrid[key] = (evacHeatmapGrid[key] || 0) + 1;

                var nearestS = evacFindNearestShelter(p.lat, p.lng);
                if (nearestS) {
                    var slat = nearestS.location_lat || nearestS.lat;
                    var slng = nearestS.location_lng || nearestS.lng;
                    if (slat && slng) {
                        var evacLine = L.polyline([[p.lat, p.lng], [slat, slng]], {
                            color: '#f59e0b', weight: 2, opacity: 0.5, dashArray: '8, 6'
                        }).addTo(evacSimLayer);
                        evacLines.push(evacLine);
                        if (evacSheltersUsed.indexOf(nearestS.id) === -1) evacSheltersUsed.push(nearestS.id);
                    }
                }

                var areaKm2 = Math.PI * dmgRadius * dmgRadius / 1000000;
                evacTotalArea += areaKm2;
                var density = evacGetDensity(p.lat, p.lng);
                var newPop = Math.round(areaKm2 * density);
                evacTotalPop += newPop;
                document.getElementById('simTrajPopulation').textContent = 'Population touchée: ' + evacTotalPop.toLocaleString();
                evacFrameCount++;
            }
        }

        function onEvacSimSlider(val) {
            if (evacSimPlaying) { evacSimPlaying = false; clearInterval(evacSimTimer); evacSimTimer = null; }
            document.getElementById('simTrajPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Lire';
            updateEvacSimFrame(parseInt(val));
        }

        function toggleEvacPlayback() {
            if (evacSimTrack.length === 0) return;
            if (evacSimPlaying) {
                evacSimPlaying = false;
                if (evacSimTimer) { clearInterval(evacSimTimer); evacSimTimer = null; }
                document.getElementById('simTrajPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Lire';
                return;
            }
            if (evacSimIndex >= evacSimTrack.length - 1) evacSimIndex = 0;
            evacSimPlaying = true;
            document.getElementById('simTrajPlayBtn').innerHTML = '<i class="bi bi-pause-fill"></i> Pause';
            evacSimTimer = setInterval(function() {
                if (evacSimIndex >= evacSimTrack.length - 1) {
                    evacSimPlaying = false;
                    clearInterval(evacSimTimer);
                    evacSimTimer = null;
                    document.getElementById('simTrajPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Rejouer';
                    return;
                }
                evacSimIndex++;
                updateEvacSimFrame(evacSimIndex);
            }, 400 / evacSimSpeed);
        }

        function setEvacSpeed(s) {
            evacSimSpeed = s;
            ['evacSpd1','evacSpd2','evacSpd4'].forEach(function(id, i) {
                var el = document.getElementById(id);
                var speed = [1,2,4][i];
                el.className = 'px-1.5 py-1 text-[9px] font-bold rounded-md ' + (s === speed ? 'bg-purple-600 text-white' : 'bg-gray-200 text-gray-600');
            });
            if (evacSimPlaying) {
                clearInterval(evacSimTimer);
                evacSimTimer = setInterval(function() {
                    if (evacSimIndex >= evacSimTrack.length - 1) {
                        evacSimPlaying = false;
                        clearInterval(evacSimTimer);
                        evacSimTimer = null;
                        document.getElementById('simTrajPlayBtn').innerHTML = '<i class="bi bi-play-fill"></i> Rejouer';
                        return;
                    }
                    evacSimIndex++;
                    updateEvacSimFrame(evacSimIndex);
                }, 400 / s);
            }
        }

        // Override toggleSimulation to also load trajectory simulations
        toggleSimulation = function() {
            simulationModeEvac = !simulationModeEvac;
            var panel = document.getElementById('sim-panel-evac');
            var btn = document.getElementById('sim-toggle-btn-evac');
            if (simulationModeEvac) {
                panel.classList.remove('hidden');
                btn.innerHTML = '<i class="bi bi-stop-fill"></i> Désactiver';
                btn.classList.remove('bg-purple-50', 'text-purple-700');
                btn.classList.add('bg-purple-600', 'text-white');
                loadScenarioEvac('tout');
                loadEvacSimulations();
            } else {
                panel.classList.add('hidden');
                btn.innerHTML = '<i class="bi bi-play-fill"></i> Activer';
                btn.classList.remove('bg-purple-600', 'text-white');
                btn.classList.add('bg-purple-50', 'text-purple-700');
                clearSimulationEvac();
                clearEvacSimTrack();
            }
        };

        const token = "${sessionScope.token}";

        // Initialize Map with default center (will update on geolocation)
        const map = L.map('evac-map', {
            center: [-18.9078, 47.5208],
            zoom: 12,
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

        evacSimLayer = L.layerGroup().addTo(map);
        evacHeatmapLayer = L.layerGroup().addTo(map);

        // Marker builders
        const createMarkerIcon = (emoji, color) => {
            return L.divIcon({
                className: 'custom-marker',
                html: '<div class="marker-pin" style="background: ' + color + '">' + emoji + '</div>',
                iconSize: [36, 36],
                iconAnchor: [18, 36],
                popupAnchor: [0, -36]
            });
        };

        const icons = {
            user: createMarkerIcon('👤', '#3b82f6'),
            shelter: createMarkerIcon('🏠', '#059669'),
            activeZone: createMarkerIcon('🔥', '#ef4444')
        };

        // Current User Position marker (will be moved on geolocation)
        let userLat = -18.9078;
        let userLng = 47.5208;
        let userMarker = L.marker([userLat, userLng], { icon: icons.user }).addTo(map).bindPopup('<strong>Votre position de départ</strong>');

        // Get actual browser position
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(pos) {
                userLat = pos.coords.latitude;
                userLng = pos.coords.longitude;
                map.setView([userLat, userLng], 14);
                userMarker.setLatLng([userLat, userLng]);
                document.getElementById('origin-label').value = 'Votre position (' + userLat.toFixed(4) + ', ' + userLng.toFixed(4) + ')';
                sortSheltersByDistance();
                loadWeather();
            }, function() {
                loadWeather();
            });
        } else {
            loadWeather();
        }

        // Dynamic polyline for drawing A* route
        let activeRoutePolyline = null;
        let shelterMarkers = {};

        // Fetch shelters to populate card selector and map
        let allShelters = [];
        fetch('/api/v1/shelters', {
            headers: { 'Authorization': 'Bearer ' + token }
        })
        .then(res => res.json())
        .then(data => {
            allShelters = data.shelters || data;
            const select = document.getElementById('destination-shelter');
            const listContainer = document.getElementById('shelter-list');
            
            // Ajouter distance depuis l'utilisateur et trier
            allShelters.forEach(function(sh) {
                const slat = sh.lat || sh.location_lat;
                const slng = sh.lng || sh.location_lng;
                sh.distance_km = haversineKm(userLat, userLng, slat, slng);
            });
            allShelters.sort(function(a, b) { return a.distance_km - b.distance_km; });
            
            renderShelterCards(allShelters);
            
            allShelters.forEach(s => {
                const shelterLat = s.lat || s.location_lat;
                const shelterLng = s.lng || s.location_lng;
                // Add to hidden dropdown for compatibility
                const opt = document.createElement('option');
                opt.value = s.id;
                opt.dataset.lat = shelterLat;
                opt.dataset.lng = shelterLng;
                opt.textContent = s.name;
                select.appendChild(opt);

                // Add to map markers
                const occ = s.current_occupancy || 0;
                const cap = s.capacity || 100;
                const pct = Math.round((occ / cap) * 100);
                const barColor = pct > 80 ? '#ef4444' : pct > 50 ? '#f59e0b' : '#059669';
                const m = L.marker([shelterLat, shelterLng], { icon: icons.shelter })
                    .addTo(map)
                    .bindPopup(
                        '<div style="min-width:200px;">' +
                            '<h6 style="font-weight:700;font-size:13px;margin-bottom:4px;">🏠 ' + s.name + '</h6>' +
                            '<p style="font-size:11px;color:#64748b;margin-bottom:6px;">' + (s.type || 'Refuge') + '</p>' +
                            '<div style="font-size:11px;margin-bottom:4px;">Capacité: <strong>' + occ + '/' + cap + '</strong></div>' +
                            '<div style="width:100%;height:6px;background:#e2e8f0;border-radius:3px;overflow:hidden;">' +
                                '<div style="width:' + pct + '%;height:100%;background:' + barColor + ';border-radius:3px;"></div>' +
                            '</div>' +
                            '<div style="display:flex;gap:4px;margin-top:6px;flex-wrap:wrap;">' +
                                (s.has_medical_facilities ? '<span style="padding:1px 6px;background:#ecfdf5;color:#059669;border-radius:4px;font-size:10px;">🏥 Médical</span>' : '') +
                                (s.has_food ? '<span style="padding:1px 6px;background:#fffbeb;color:#d97706;border-radius:4px;font-size:10px;">🍲 Nourriture</span>' : '') +
                                (s.has_water ? '<span style="padding:1px 6px;background:#eff6ff;color:#2563eb;border-radius:4px;font-size:10px;">💧 Eau</span>' : '') +
                            '</div>' +
                            '<button onclick="selectShelter(\'' + s.id + '\')" style="margin-top:8px;padding:6px 12px;background:#059669;color:white;border-radius:8px;font-size:11px;font-weight:600;border:none;cursor:pointer;width:100%;">🚀 Choisir ce refuge</button>' +
                        '</div>'
                    );
                shelterMarkers[s.id] = m;
            });

            // Focus map on pre-selected shelter if present
            const targetShelterId = "${targetShelterId}";
            if (targetShelterId && shelterMarkers[targetShelterId]) {
                selectShelter(targetShelterId);
                const m = shelterMarkers[targetShelterId];
                map.setView(m.getLatLng(), 14);
                m.openPopup();
            }

        })
        .catch(err => console.log('Err fetching shelters:', err));

        function sortSheltersByDistance() {
            if (allShelters.length === 0) return;
            allShelters.forEach(function(sh) {
                var slat = sh.lat || sh.location_lat;
                var slng = sh.lng || sh.location_lng;
                sh.distance_km = haversineKm(userLat, userLng, slat, slng);
            });
            allShelters.sort(function(a, b) { return a.distance_km - b.distance_km; });
            renderShelterCards(allShelters);
        }

        function renderShelterCards(shelters) {
            const container = document.getElementById('shelter-list');
            container.innerHTML = '';
            if (shelters.length === 0) {
                container.innerHTML = '<div class="text-xs text-gray-400 text-center py-4">Aucun refuge trouvé</div>';
                return;
            }
            shelters.forEach(s => {
                const occ = s.current_occupancy || 0;
                const cap = s.capacity || 100;
                const pct = Math.round((occ / cap) * 100);
                const barColor = pct > 80 ? '#ef4444' : pct > 50 ? '#f59e0b' : '#059669';
                const card = document.createElement('div');
                card.className = 'shelter-card rounded-xl p-2.5 bg-white border border-gray-100';
                card.id = 'shelter-card-' + s.id;
                card.innerHTML =
                    '<div class="flex items-center gap-2" onclick="selectShelter(\'' + s.id + '\')">' +
                        '<div class="w-8 h-8 rounded-lg bg-green-50 flex items-center justify-center flex-shrink-0">🏠</div>' +
                        '<div class="flex-1 min-w-0">' +
                            '<div class="text-[12px] font-bold text-gray-800 truncate">' + s.name + '</div>' +
                            '<div class="text-[10px] text-gray-500">' + (s.type || 'Refuge') + ' · ' + (s.distance_km ? (Math.round(s.distance_km * 10) / 10) + ' km' : '') + '</div>' +
                        '</div>' +
                        '<div class="text-right flex-shrink-0">' +
                            '<div class="text-[10px] font-bold ' + (pct > 80 ? 'text-red-500' : pct > 50 ? 'text-amber-500' : 'text-green-500') + '">' + occ + '/' + cap + '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="capacity-bar mt-1.5">' +
                        '<div class="capacity-bar-fill" style="width:' + pct + '%;background:' + barColor + ';"></div>' +
                    '</div>' +
                    '<div class="flex gap-1.5 mt-1">' +
                        (s.has_medical_facilities ? '<span class="text-[9px] text-green-600">🏥</span>' : '') +
                        (s.has_food ? '<span class="text-[9px] text-amber-600">🍲</span>' : '') +
                        (s.has_water ? '<span class="text-[9px] text-blue-600">💧</span>' : '') +
                    '</div>';
                container.appendChild(card);
            });
        }

        function filterShelters(query) {
            const filtered = allShelters.filter(s => {
                const name = (s.name || '').toLowerCase();
                const type = (s.type || '').toLowerCase();
                const q = query.toLowerCase();
                return name.includes(q) || type.includes(q);
            });
            renderShelterCards(filtered);
        }

        function selectShelter(shelterId) {
            const select = document.getElementById('destination-shelter');
            const s = allShelters.find(sh => String(sh.id) === String(shelterId));
            if (!s) return;
            select.value = String(shelterId);

            // Update card highlights
            document.querySelectorAll('.shelter-card').forEach(c => c.classList.remove('selected', 'ring-2', 'ring-green-500'));
            const card = document.getElementById('shelter-card-' + shelterId);
            if (card) card.classList.add('selected', 'ring-2', 'ring-green-500');

            // Scroll to card
            if (card) card.scrollIntoView({ behavior: 'smooth', block: 'nearest' });

            // Zoom map to shelter
            const shelterLat = s.lat || s.location_lat;
            const shelterLng = s.lng || s.location_lng;
            if (shelterLat && shelterLng) {
                map.setView([shelterLat, shelterLng], 14, { animate: true });
            }

            // Update search placeholder
            document.getElementById('shelter-search').value = s.name;
            
            // Clear previous route
            document.getElementById('routing-metrics').classList.add('hidden');
            document.getElementById('route-steps').classList.add('hidden');
            document.getElementById('survival-tips').classList.add('hidden');
        }

        // Load weather data from Open-Meteo (free, no API key required)
        function loadWeather() {
            const widget = document.getElementById('weather-widget');
            const url = 'https://api.open-meteo.com/v1/forecast?latitude=' + userLat + '&longitude=' + userLng +
                '&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m' +
                '&timezone=auto';
            fetch(url)
            .then(res => res.json())
            .then(data => {
                const w = data.current;
                if (w) {
                    widget.classList.remove('hidden');
                    document.getElementById('weather-temp').textContent = w.temperature_2m + '°C';
                    document.getElementById('weather-desc').textContent = getWeatherDescription(w.weather_code);
                    document.getElementById('weather-humidity').textContent = w.relative_humidity_2m + '%';
                    document.getElementById('weather-wind').textContent = w.wind_speed_10m + ' km/h';
                    document.getElementById('weather-icon').textContent = getWeatherEmoji(getWeatherDescription(w.weather_code));
                }
            })
            .catch(() => {});
        }

        function getWeatherDescription(code) {
            if (code === 0) return 'Ciel dégagé';
            if (code <= 3) return 'Partiellement nuageux';
            if (code <= 48) return 'Brouillard';
            if (code <= 57) return 'Bruine';
            if (code <= 67) return 'Pluie';
            if (code <= 77) return 'Neige';
            if (code <= 82) return 'Averses';
            if (code === 85 || code === 86) return 'Averses de neige';
            if (code <= 99) return 'Orage';
            return '--';
        }

        function getWeatherEmoji(desc) {
            const d = desc.toLowerCase();
            if (d.includes('pluie') || d.includes('rain')) return '🌧';
            if (d.includes('nuage') || d.includes('cloud')) return '☁️';
            if (d.includes('soleil') || d.includes('clear')) return '☀️';
            if (d.includes('orage') || d.includes('thunder')) return '⛈';
            if (d.includes('brouillard') || d.includes('fog') || d.includes('mist')) return '🌫';
            if (d.includes('neige') || d.includes('snow')) return '❄️';
            if (d.includes('vent') || d.includes('wind')) return '💨';
            return '🌤';
        }

        // Fetch and display active disaster danger zones with auto-refresh
        let activeDangerCircles = [];

        function loadActiveDangers() {
            // Clear previous
            activeDangerCircles.forEach(c => map.removeLayer(c));
            activeDangerCircles = [];

            fetch('/api/v1/alerts?active=true', {
                headers: { 'Authorization': 'Bearer ' + token }
            })
            .then(res => res.json())
            .then(data => {
                const alertsList = data.alerts || [];
                alertsList.forEach(a => {
                    const lat = a.center_lat || a.lat || -18.9078;
                    const lng = a.center_lng || a.lng || 47.5208;
                    const levelColor = a.level === 'urgence' ? '#ef4444' : a.level === 'alerte' ? '#f59e0b' : '#3b82f6';
                    
                    const marker = L.marker([lat, lng], {
                        icon: L.divIcon({
                            className: 'custom-marker',
                            html: '<div class="marker-pin" style="background:' + levelColor + '">⚠️</div>',
                            iconSize: [36, 36], iconAnchor: [18, 36]
                        })
                    }).addTo(map)
                      .bindPopup('<strong>' + (a.title || 'Danger actif') + '</strong><br>' + (a.message || a.description || ''));
                    activeDangerCircles.push(marker);

                    const circle = L.circle([lat, lng], {
                        color: levelColor,
                        fillColor: levelColor,
                        fillOpacity: 0.12,
                        radius: 4000
                    }).addTo(map);
                    activeDangerCircles.push(circle);
                });
            })
            .catch(() => {});
        }

        // Fetch and display real incidents on the evacuation map
        let activeIncidentMarkers = [];
        let allIncidents = [];

        loadActiveDangers();
        loadIncidents();
        // Auto-refresh danger zones and incidents every 60 seconds
        setInterval(loadActiveDangers, 60000);
        setInterval(loadIncidents, 60000);

        function loadIncidents() {
            activeIncidentMarkers.forEach(m => map.removeLayer(m));
            activeIncidentMarkers = [];

            fetch('/api/v1/incidents?limit=100', {
                headers: { 'Authorization': 'Bearer ' + token }
            })
            .then(res => res.json())
            .then(data => {
                allIncidents = data.incidents || [];
                allIncidents.forEach(inc => {
                    if (inc.status === 'resolu') return;
                    const lat = parseFloat(inc.location_lat);
                    const lng = parseFloat(inc.location_lng);
                    if (!lat || !lng) return;

                    const typeIcons = {
                        incendie: { emoji: '🔥', color: '#ef4444' },
                        inondation: { emoji: '💧', color: '#3b82f6' },
                        cyclone: { emoji: '🌀', color: '#8b5cf6' },
                        seisme: { emoji: '🏚️', color: '#78350f' },
                        glissement_terrain: { emoji: '⛰️', color: '#92400e' },
                    };
                    const iconInfo = typeIcons[inc.type] || { emoji: '📍', color: '#f97316' };

                    const statusLabels = {
                        signale: 'Signalé',
                        verifie: 'Vérifié',
                        en_cours: 'En cours',
                        resolu: 'Résolu'
                    };
                    const statusColors = {
                        signale: '#ef4444',
                        verifie: '#f59e0b',
                        en_cours: '#3b82f6',
                        resolu: '#10b981'
                    };
                    const statusColor = statusColors[inc.status] || '#6b7280';

                    const marker = L.marker([lat, lng], {
                        icon: L.divIcon({
                            className: 'custom-marker',
                            html: '<div class="marker-pin" style="background:' + iconInfo.color + '">' + iconInfo.emoji + '</div>',
                            iconSize: [36, 36],
                            iconAnchor: [18, 36],
                            popupAnchor: [0, -36]
                        })
                    }).addTo(map)
                      .bindPopup(
                          '<div style="min-width:220px;">' +
                              '<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px;">' +
                                  '<span style="display:inline-block;padding:2px 8px;font-size:10px;font-weight:700;color:white;background:' + statusColor + ';border-radius:4px;text-transform:uppercase;">' + (statusLabels[inc.status] || inc.status) + '</span>' +
                                  '<span style="font-size:11px;color:#64748b;font-weight:600;">' + (inc.type || '').replace(/_/g, ' ') + '</span>' +
                              '</div>' +
                              '<h6 style="font-weight:700;font-size:13px;margin-bottom:4px;">' + (inc.title || 'Incident') + '</h6>' +
                              '<p style="font-size:11px;color:#64748b;margin-bottom:6px;">' + (inc.description || '') + '</p>' +
                              '<div style="font-size:10px;color:#64748b;">📍 ' + lat.toFixed(4) + ', ' + lng.toFixed(4) + '</div>' +
                              (inc.reporter_email ? '<div style="font-size:10px;color:#64748b;margin-top:2px;">👤 ' + inc.reporter_email + '</div>' : '') +
                              (inc.assigned_team ? '<div style="font-size:10px;color:#64748b;margin-top:2px;">🚑 Équipe: ' + inc.assigned_team + '</div>' : '') +
                              '<div style="margin-top:8px;">' +
                                  '<a href="evacuation?incident=' + inc.id + '" style="display:inline-block;padding:5px 12px;background:#059669;color:white;border-radius:8px;font-size:11px;font-weight:600;text-decoration:none;">🚀 Itinéraire d\'évacuation</a>' +
                              '</div>' +
                          '</div>'
                      );
                    activeIncidentMarkers.push(marker);
                });
            })
            .catch(() => {});
        }

        function rerouteToShelter(shelterId, lat, lng, name) {
            const select = document.getElementById('destination-shelter');
            for (let i = 0; i < select.options.length; i++) {
                if (select.options[i].value === shelterId) {
                    select.value = shelterId;
                    break;
                }
            }
            document.getElementById('safe-alternatives').classList.add('hidden');
            document.getElementById('danger-warning').classList.add('hidden');
            calculateAStarRoute();
        }

        function renderAlternatives(alternatives) {
            const container = document.getElementById('alternatives-list');
            container.innerHTML = '';
            alternatives.forEach(s => {
                const badge = document.createElement('div');
                badge.className = 'flex items-center justify-between bg-white border border-green-200 rounded-xl p-2.5 cursor-pointer hover:bg-green-50 transition-all';
                badge.innerHTML =
                    '<div class="flex-1 min-w-0">' +
                        '<p class="text-[11px] font-bold text-gray-800 truncate">' + s.name + '</p>' +
                        '<p class="text-[10px] text-gray-500">' + s.distance_km + ' km \u00B7 ' + s.type + (s.has_medical ? ' \u00B7 \uD83C\uDFE5 M\u00E9dical' : '') + '</p>' +
                    '</div>' +
                    '<button onclick="rerouteToShelter(\'' + s.id + '\', ' + s.lat + ', ' + s.lng + ', \'' + s.name.replace(/'/g, "\\'") + '\')"' +
                            ' class="ml-2 px-3 py-1.5 bg-green-500 hover:bg-green-600 text-white text-[10px] font-bold rounded-lg transition-colors whitespace-nowrap">' +
                        'Choisir' +
                    '</button>';
                container.appendChild(badge);
            });
        }

        function generateRouteSteps(latlngs, mode) {
            const stepsContainer = document.getElementById('steps-list');
            stepsContainer.innerHTML = '';
            
            if (!latlngs || latlngs.length < 2) {
                stepsContainer.innerHTML = '<div class="text-[10px] text-gray-400">Pas assez de points pour générer des instructions.</div>';
                return;
            }

            const totalDistance = latlngs.length;
            const stepInterval = Math.max(1, Math.floor(totalDistance / 5));
            const modeEmoji = mode === 'car' ? '🚗' : mode === 'walk' ? '🚶' : '🚲';
            const modeLabel = mode === 'car' ? 'Voiture' : mode === 'walk' ? 'À pied' : 'Vélo';
            
            let steps = [
                { icon: '📍', text: 'Départ de votre position (' + userLat.toFixed(4) + ', ' + userLng.toFixed(4) + ')' }
            ];

            for (let i = stepInterval; i < totalDistance - 1; i += stepInterval) {
                const pt = latlngs[i];
                const bearing = i + stepInterval < totalDistance
                    ? getBearing(latlngs[i], latlngs[Math.min(i + stepInterval, totalDistance - 1)])
                    : 0;
                const dir = bearingToDir(bearing);
                steps.push({
                    icon: modeEmoji,
                    text: 'Continuer vers le ' + dir + ' (' + pt[0].toFixed(4) + ', ' + pt[1].toFixed(4) + ')'
                });
            }

            steps.push({ icon: '🏠', text: 'Arrivée au refuge sélectionné' });

            steps.forEach((step, i) => {
                const el = document.createElement('div');
                el.className = 'step-card';
                el.style.animationDelay = (i * 50) + 'ms';
                el.innerHTML =
                    '<div class="flex items-center gap-2">' +
                        '<span class="text-sm">' + step.icon + '</span>' +
                        '<span class="text-[11px] text-gray-700">' + step.text + '</span>' +
                    '</div>';
                stepsContainer.appendChild(el);
            });
        }

        function getBearing(p1, p2) {
            const dLon = (p2[1] - p1[1]) * Math.PI / 180;
            const lat1 = p1[0] * Math.PI / 180;
            const lat2 = p2[0] * Math.PI / 180;
            const y = Math.sin(dLon) * Math.cos(lat2);
            const x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);
            return (Math.atan2(y, x) * 180 / Math.PI + 360) % 360;
        }

        function bearingToDir(deg) {
            const dirs = ['Nord', 'Nord-Est', 'Est', 'Sud-Est', 'Sud', 'Sud-Ouest', 'Ouest', 'Nord-Ouest'];
            return dirs[Math.round(deg / 45) % 8];
        }

        function generateSurvivalTips(distanceKm, timeMin, dangerScore, mode) {
            const container = document.getElementById('tips-content');
            container.innerHTML = '';
            const tips = [];

            if (distanceKm > 5 && mode === 'walk') {
                tips.push('🚶<strong> Marche longue :</strong> Prévoyez de l\'eau (1L par heure de marche) et des chaussures adaptées.');
            }
            if (mode === 'car') {
                tips.push('🚗<strong> En voiture :</strong> Vérifiez le niveau de carburant. Gardez les fenêtres fermées dans les zones de danger.');
            }
            if (mode === 'bike') {
                tips.push('🚲<strong> À vélo :</strong> Portez un casque. Évitez les routes inondées ou endommagées.');
            }
            if (dangerScore > 30) {
                tips.push('⚠️<strong> Zone à risque :</strong> Restez informé via la radio ou votre téléphone. Suivez les consignes des autorités.');
            }
            if (timeMin > 30) {
                tips.push('🎒<strong> Trajet long :</strong> Emportez un kit d\'urgence (lampe, batterie portable, eau, nourriture non périssable).');
            }
            tips.push('📱<strong> Communication :</strong> Informez vos proches de votre itinéraire et de votre destination.');
            tips.push('🆘<strong> En cas d\'urgence :</strong> Contactez les secours au 117 (Madagascar). Donnez votre position GPS.');

            tips.forEach(tip => {
                const el = document.createElement('div');
                el.innerHTML = tip;
                container.appendChild(el);
            });
        }

        // A* evacuation path calculation triggering
        function calculateAStarRoute(event) {
            event = event || window.event;
            const select = document.getElementById('destination-shelter');
            const selectedOpt = select.options[select.selectedIndex];
            
            if (!select.value) {
                alert('Veuillez choisir un refuge de destination.');
                return;
            }

            const destLat = parseFloat(selectedOpt.dataset.lat);
            const destLng = parseFloat(selectedOpt.dataset.lng);
            const mode = document.getElementById('routing-mode').value;

            // Collecter les zones de danger actives (simulations, alertes, incidents)
            var activeDangerZones = [];
            SIMULATION_ZONES.forEach(function(z) {
                activeDangerZones.push({
                    id: String(z.id),
                    center_lat: z.lat,
                    center_lng: z.lng,
                    radius: z.radius,
                    danger_level: z.danger_score || 50,
                    type: z.type,
                    name: z.name,
                    level: z.level
                });
            });
            if (REAL_SIMULATION_DATA && REAL_SIMULATION_DATA.zones) {
                REAL_SIMULATION_DATA.zones.forEach(function(z) {
                    activeDangerZones.push({
                        id: String(z.id),
                        center_lat: z.lat,
                        center_lng: z.lng,
                        radius: z.radius,
                        danger_level: z.danger_score || 50,
                        type: z.type,
                        name: z.name,
                        level: z.level
                    });
                });
            }
            // Ajouter les incidents non résolus comme zones de danger
            if (typeof activeIncidentMarkers !== 'undefined') {
                allIncidents.forEach(function(inc) {
                    if (inc.status === 'resolu') return;
                    var radiusMap = { incendie: 2000, inondation: 3000, cyclone: 5000, seisme: 2000, glissement_terrain: 1500 };
                    activeDangerZones.push({
                        id: 'incident-' + inc.id,
                        center_lat: parseFloat(inc.location_lat),
                        center_lng: parseFloat(inc.location_lng),
                        radius: radiusMap[inc.type] || 2000,
                        danger_level: inc.status === 'en_cours' ? 80 : inc.status === 'verifie' ? 60 : 40,
                        type: inc.type,
                        name: inc.title || 'Incident ' + inc.type,
                        level: inc.status === 'en_cours' ? 'urgence' : inc.status === 'verifie' ? 'alerte' : 'vigilance'
                    });
                });
            }

            const payload = {
                origin_lat: userLat,
                origin_lng: userLng,
                destination_lat: destLat,
                destination_lng: destLng,
                max_distance_km: 30.0,
                mode: mode,
                avoid_zones: [],
                shelter_id: select.value,
                inline_zones: activeDangerZones
            };

            // Show loading state on button
            const calcBtn = event && event.target ? event.target : document.querySelector('button[onclick*="calculateAStarRoute"]');
            const origText = calcBtn ? calcBtn.innerHTML : '';
            if (calcBtn) calcBtn.innerHTML = '<i class="bi bi-arrow-repeat animate-spin"></i> Calcul...';

            fetch('/api/v1/ai/routing/evacuation', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer ' + token
                },
                body: JSON.stringify(payload)
            })
            .then(res => res.json())
            .then(data => {
                if (calcBtn) calcBtn.innerHTML = origText;

                if (data.error || data.detail) {
                    alert('Erreur calcul itinéraire: ' + (data.error || data.detail));
                    return;
                }

                if (data.path && data.path.coordinates) {
                    const latlngs = data.path.coordinates.map(coords => [coords[1], coords[0]]);
                    
                    if (activeRoutePolyline) {
                        map.removeLayer(activeRoutePolyline);
                    }
                    if (window._animLine) {
                        map.removeLayer(window._animLine);
                    }

                    const isInDanger = data.shelter_in_danger;
                    const dangerScore = data.danger_score || 0.0;
                    const routeColor = isInDanger ? '#dc2626' : dangerScore > 30 ? '#f97316' : dangerScore > 5 ? '#f59e0b' : '#059669';
                    
                    activeRoutePolyline = L.polyline(latlngs, {
                        color: routeColor,
                        weight: 6,
                        opacity: 0.85,
                        dashArray: mode === 'walk' ? '5, 10' : null
                    }).addTo(map);

                    // Add animated dashed overlay for visual effect
                    window._animLine = L.polyline(latlngs, {
                        color: '#fff',
                        weight: 2,
                        opacity: 0.3,
                        dashArray: '2, 12'
                    }).addTo(map);

                    map.fitBounds(activeRoutePolyline.getBounds(), { padding: [50, 50] });

                    // Metrics
                    const distKm = data.distance_km || 0;
                    const timeMin = Math.ceil(data.estimated_time_minutes || 0);
                    
                    document.getElementById('metric-distance').textContent = distKm.toFixed(2) + ' km';
                    document.getElementById('metric-time').textContent = timeMin + ' min';
                    
                    const dangerLabel = document.getElementById('metric-danger');
                    if (isInDanger) {
                        dangerLabel.textContent = 'CRITIQUE - Refuge en zone dangereuse';
                        dangerLabel.className = 'px-2 py-0.5 rounded text-[10px] font-bold text-white bg-red-600 animate-pulse';
                    } else {
                        dangerLabel.textContent = dangerScore > 30 ? 'Critique' : dangerScore > 5 ? 'Modéré' : 'Sécurisé';
                        dangerLabel.className = 'px-2 py-0.5 rounded text-[10px] font-bold text-white ' + 
                            (dangerScore > 30 ? 'bg-red-500' : dangerScore > 5 ? 'bg-amber-500' : 'bg-green-500');
                    }

                    document.getElementById('routing-metrics').classList.remove('hidden');

                    // Danger warning
                    if (isInDanger && typeof isInDanger === 'object') {
                        document.getElementById('danger-detail').textContent =
                            "Le refuge sélectionné est à " + (isInDanger.distance_km || '?') + " km d'une zone " + (isInDanger.type || 'de danger') + " (" + (isInDanger.title || '') + "). Il est dangereux de s'y réfugier.";
                        document.getElementById('danger-warning').classList.remove('hidden');
                    } else {
                        document.getElementById('danger-warning').classList.add('hidden');
                    }

                    // Alternatives
                    const alternatives = data.safe_alternatives;
                    if (alternatives && alternatives.length > 0) {
                        renderAlternatives(alternatives);
                        document.getElementById('safe-alternatives').classList.remove('hidden');
                    } else {
                        document.getElementById('safe-alternatives').classList.add('hidden');
                    }

                    // Route steps with staggered animation
                    document.getElementById('route-steps').classList.remove('hidden');
                    generateRouteSteps(latlngs, mode);

                    // Survival tips
                    document.getElementById('survival-tips').classList.remove('hidden');
                    generateSurvivalTips(distKm, timeMin, dangerScore, mode);
                }
            })
            .catch(err => {
                console.log('Err calculating route:', err);
                if (calcBtn) calcBtn.innerHTML = origText;
                alert("Erreur de communication avec le service IA d'itinéraire.");
            });
        }
    </script>
</body>
</html>
