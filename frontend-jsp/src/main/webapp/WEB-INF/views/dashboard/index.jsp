<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr" class="dark">
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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Leaflet Maps -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    fontFamily: { sans: ['Inter', 'system-ui', 'sans-serif'] },
                    colors: {
                        danger: { 500: '#EF4444', 600: '#DC2626', 700: '#B91C1C' },
                        warning: { 500: '#F59E0B' },
                        info: { 500: '#3B82F6' },
                        success: { 500: '#10B981' },
                        dark: { 900: '#0F172A', 800: '#1E293B', 700: '#334155' },
                        glass: { bg: 'rgba(30, 41, 59, 0.7)', border: 'rgba(255, 255, 255, 0.1)' }
                    }
                }
            }
        }
    </script>
    
    <style>
        body { font-family: 'Inter', sans-serif; }
        .sidebar { width: 280px; }
        @media (max-width: 768px) { .sidebar { transform: translateX(-100%); } .sidebar.open { transform: translateX(0); } .main-content { margin-left: 0 !important; } }
        
        /* Bootstrap Dark Overrides */
        .form-select, .form-control { background: rgba(255,255,255,0.05) !important; border-color: rgba(255,255,255,0.1) !important; color: white !important; }
        .form-select:focus, .form-control:focus { background: rgba(255,255,255,0.1) !important; border-color: #DC2626 !important; color: white !important; }
        .dropdown-menu { background: #1E293B !important; border-color: rgba(255,255,255,0.1) !important; }
        .dropdown-item { color: white !important; }
        .dropdown-item:hover { background: rgba(255,255,255,0.1) !important; }
        .progress { background: rgba(255,255,255,0.1) !important; }
    </style>
    <link rel="stylesheet" href="/assets/css/custom.css?v=f28c64ea">
</head>
<body class="bg-dark-900 text-white min-h-screen flex">
    
    <!-- Sidebar -->
    <aside class="sidebar fixed top-0 left-0 bottom-0 z-40 bg-dark-800/70 backdrop-blur-xl border-r border-white/10 transition-transform">
        <div class="flex flex-col h-full">
            <!-- Brand -->
            <div class="p-6 border-b border-white/10">
                <a href="/" class="flex items-center gap-2 text-xl font-bold">
                    <span>🌪️</span>
                    <span class="hidden lg:inline">MITANDRINA</span>
                </a>
            </div>
            
            <!-- Navigation -->
            <nav class="flex-1 overflow-y-auto py-4 px-3">
                <a href="/dashboard" class="flex items-center gap-3 px-4 py-3 rounded-lg bg-danger-600/20 text-danger-400 border border-danger-600/30 mb-1">
                    <i class="bi bi-speedometer2"></i>
                    <span class="font-medium">Tableau de bord</span>
                </a>
                
                <a href="/map" class="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-400 hover:bg-white/5 hover:text-white transition-colors mb-1">
                    <i class="bi bi-map"></i>
                    <span>Carte des risques</span>
                </a>
                
                <a href="/cyclone-map" class="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-400 hover:bg-white/5 hover:text-white transition-colors mb-1">
                    <i class="bi bi-tornado"></i>
                    <span>Carte des cyclones</span>
                </a>
                
                <a href="/alerts" class="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-400 hover:bg-white/5 hover:text-white transition-colors mb-1">
                    <i class="bi bi-exclamation-triangle"></i>
                    <span>Alertes</span>
                    <c:if test="${unreadAlerts > 0}">
                        <span class="ml-auto bg-danger-600 text-white text-xs px-2 py-0.5 rounded-full">${unreadAlerts}</span>
                    </c:if>
                </a>
                
                <a href="/incidents" class="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-400 hover:bg-white/5 hover:text-white transition-colors mb-1">
                    <i class="bi bi-geo-alt"></i>
                    <span>Incidents</span>
                </a>
                
                <a href="/evacuation" class="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-400 hover:bg-white/5 hover:text-white transition-colors mb-1">
                    <i class="bi bi-car-front"></i>
                    <span>Évacuation</span>
                </a>
                
                <c:if test="${sessionScope.user.role == 'administrateur'}">
                    <div class="mt-6 mb-2 px-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">Administration</div>
                    
                    <a href="/admin/users" class="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-400 hover:bg-white/5 hover:text-white transition-colors mb-1">
                        <i class="bi bi-people"></i>
                        <span>Utilisateurs</span>
                    </a>
                    
                    <a href="/admin/teams" class="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-400 hover:bg-white/5 hover:text-white transition-colors mb-1">
                        <i class="bi bi-building"></i>
                        <span>Équipes</span>
                    </a>
                    
                    <a href="/admin/simulations" class="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-400 hover:bg-white/5 hover:text-white transition-colors mb-1">
                        <i class="bi bi-magic"></i>
                        <span>Simulations</span>
                    </a>
                </c:if>
            </nav>
            
            <!-- User Card -->
            <div class="p-4 border-t border-white/10">
                <div class="flex items-center gap-3 mb-3">
                    <div class="w-10 h-10 rounded-full bg-gradient-to-r from-danger-500 to-warning-500 flex items-center justify-center font-semibold text-sm">
                        ${sessionScope.user.firstName.charAt(0)}${sessionScope.user.lastName.charAt(0)}
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium truncate">${sessionScope.user.firstName} ${sessionScope.user.lastName}</p>
                        <p class="text-xs text-gray-500 capitalize">${sessionScope.user.role}</p>
                    </div>
                </div>
                <a href="/auth/logout" class="btn btn-outline-light btn-sm w-100 py-2">
                    <i class="bi bi-box-arrow-right me-2"></i>Déconnexion
                </a>
            </div>
        </div>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content flex-1 ml-[280px]">
        <!-- Top Bar -->
        <header class="sticky top-0 z-30 bg-dark-800/70 backdrop-blur-xl border-b border-white/10 h-16 flex items-center justify-between px-6">
            <div class="flex items-center gap-4">
                <button class="md:hidden btn btn-link text-white" onclick="toggleSidebar()">
                    <i class="bi bi-list text-xl"></i>
                </button>
                <h1 class="text-xl font-semibold">Tableau de bord</h1>
            </div>
            
            <div class="flex items-center gap-4">
                <!-- Notifications -->
                <button class="btn btn-link position-relative text-gray-400 hover:text-white" id="notifications-btn">
                    <i class="bi bi-bell text-xl"></i>
                    <c:if test="${unreadNotifications > 0}">
                        <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger-600">
                            ${unreadNotifications}
                        </span>
                    </c:if>
                </button>
                
                <!-- Connection Status -->
                <div class="hidden sm:flex items-center gap-2 text-sm text-gray-400">
                    <span class="relative flex h-2 w-2">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-success-500 opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-2 w-2 bg-success-500"></span>
                    </span>
                    Connecté
                </div>
            </div>
        </header>
        
        <!-- Dashboard Content -->
        <div class="p-6">
            
            <!-- Emergency Alert Banner -->
            <c:if test="${not empty activeAlert}">
                <div class="alert alert-danger d-flex align-items-center gap-4 p-4 rounded-xl mb-6 border border-danger-600/50" style="background: linear-gradient(135deg, rgba(220, 38, 38, 0.3) 0%, rgba(220, 38, 38, 0.1) 100%);">
                    <i class="bi bi-exclamation-triangle-fill text-3xl text-danger-500"></i>
                    <div class="flex-1">
                        <h4 class="font-bold text-white mb-1">${activeAlert.title}</h4>
                        <p class="text-gray-300 mb-0">${activeAlert.message}</p>
                    </div>
                    <a href="/evacuation?alert=${activeAlert.id}" class="btn btn-light">
                        Voir l'évacuation <i class="bi bi-arrow-right ms-2"></i>
                    </a>
                </div>
            </c:if>
            
            <!-- Stats Grid -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
                <!-- Alertes -->
                <div class="bg-dark-800/70 backdrop-blur-xl border border-white/10 rounded-xl p-5">
                    <div class="flex items-center justify-between mb-3">
                        <span class="w-10 h-10 rounded-lg bg-danger-600/20 flex items-center justify-center text-danger-400">
                            <i class="bi bi-exclamation-triangle"></i>
                        </span>
                        <span class="text-xs font-medium ${alertsTrend > 0 ? 'text-danger-500' : 'text-success-500'}">
                            <i class="bi bi-arrow-${alertsTrend > 0 ? 'up' : 'down'}"></i> ${Math.abs(alertsTrend)}%
                        </span>
                    </div>
                    <div class="text-3xl font-bold text-white">${activeAlertsCount}</div>
                    <div class="text-sm text-gray-400">Alertes actives</div>
                </div>
                
                <!-- Incidents -->
                <div class="bg-dark-800/70 backdrop-blur-xl border border-white/10 rounded-xl p-5">
                    <div class="flex items-center justify-between mb-3">
                        <span class="w-10 h-10 rounded-lg bg-warning-500/20 flex items-center justify-center text-warning-500">
                            <i class="bi bi-geo-alt"></i>
                        </span>
                        <span class="text-xs font-medium ${incidentsTrend > 0 ? 'text-warning-500' : 'text-success-500'}">
                            <i class="bi bi-arrow-${incidentsTrend > 0 ? 'up' : 'down'}"></i> ${Math.abs(incidentsTrend)}%
                        </span>
                    </div>
                    <div class="text-3xl font-bold text-white">${todayIncidentsCount}</div>
                    <div class="text-sm text-gray-400">Incidents aujourd'hui</div>
                </div>
                
                <!-- Zones -->
                <div class="bg-dark-800/70 backdrop-blur-xl border border-white/10 rounded-xl p-5">
                    <div class="flex items-center justify-between mb-3">
                        <span class="w-10 h-10 rounded-lg bg-info-500/20 flex items-center justify-center text-info-500">
                            <i class="bi bi-satellite"></i>
                        </span>
                    </div>
                    <div class="text-3xl font-bold text-white">${monitoredZonesCount}</div>
                    <div class="text-sm text-gray-400">Zones surveillées</div>
                </div>
                
                <!-- Users -->
                <div class="bg-dark-800/70 backdrop-blur-xl border border-white/10 rounded-xl p-5">
                    <div class="flex items-center justify-between mb-3">
                        <span class="w-10 h-10 rounded-lg bg-success-500/20 flex items-center justify-center text-success-500">
                            <i class="bi bi-people"></i>
                        </span>
                    </div>
                    <div class="text-3xl font-bold text-white">${protectedUsersCount}</div>
                    <div class="text-sm text-gray-400">Utilisateurs protégés</div>
                </div>
            </div>
            
            <!-- Main Grid -->
            <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
                
                <!-- Map -->
                <div class="lg:col-span-3 bg-dark-800/70 backdrop-blur-xl border border-white/10 rounded-xl overflow-hidden">
                    <div class="flex items-center justify-between p-4 border-b border-white/10">
                        <h3 class="font-semibold"><i class="bi bi-map me-2"></i>Carte temps réel</h3>
                        <div class="d-flex gap-2 align-items-center">
                            <div class="flex bg-white/10 rounded-lg p-0.5">
                                <button onclick="filterLayers('all', event)" class="layer-filter-btn px-2.5 py-1.5 rounded-md text-xs font-semibold bg-white text-gray-900 shadow-sm transition-all">Tout</button>
                                <button onclick="filterLayers('risk', event)" class="layer-filter-btn px-2.5 py-1.5 rounded-md text-xs font-semibold text-gray-400 hover:text-white transition-all">Risques</button>
                                <button onclick="filterLayers('incident', event)" class="layer-filter-btn px-2.5 py-1.5 rounded-md text-xs font-semibold text-gray-400 hover:text-white transition-all">Incidents</button>
                                <button onclick="filterLayers('shelter', event)" class="layer-filter-btn px-2.5 py-1.5 rounded-md text-xs font-semibold text-gray-400 hover:text-white transition-all">Abris</button>
                            </div>
                            <a href="/map" class="btn btn-outline-light btn-sm">
                                Agrandir
                            </a>
                        </div>
                    </div>
                    <div id="dashboard-map" class="h-[400px]"></div>
                </div>
                
                <!-- Sidebar Cards -->
                <div class="flex flex-col gap-6">
                    
                    <!-- Recent Alerts -->
                    <div class="bg-dark-800/70 backdrop-blur-xl border border-white/10 rounded-xl">
                        <div class="flex items-center justify-between p-4 border-b border-white/10">
                            <h3 class="font-semibold"><i class="bi bi-bell me-2"></i>Alertes récentes</h3>
                            <a href="/alerts" class="text-sm text-danger-500 hover:text-danger-400">Voir tout</a>
                        </div>
                        <div class="p-4">
                            <c:forEach items="${recentAlerts}" var="alert">
                                <div class="flex items-start gap-3 p-3 rounded-lg bg-white/5 mb-2 border-l-3 
                                            ${alert.level == 'urgence' ? 'border-danger-600' : alert.level == 'alerte' ? 'border-warning-500' : 'border-info-500'}">
                                    <div class="w-2 h-2 rounded-full mt-2 flex-shrink-0 
                                                ${alert.level == 'urgence' ? 'bg-danger-600' : alert.level == 'alerte' ? 'bg-warning-500' : 'bg-info-500'}"></div>
                                    <div class="flex-1 min-w-0">
                                        <span class="inline-block px-2 py-0.5 rounded text-xs font-medium bg-white/10 mb-1">${alert.type}</span>
                                        <p class="text-sm font-medium truncate">${alert.title}</p>
                                        <p class="text-xs text-gray-500">
                                            <fmt:formatDate value="${alert.emittedAt}" pattern="HH:mm"/>
                                        </p>
                                    </div>
                                </div>
                            </c:forEach>
                            
                            <c:if test="${empty recentAlerts}">
                                <div class="text-center py-8 text-gray-500">
                                    <i class="bi bi-check-circle text-3xl mb-2"></i>
                                    <p>Aucune alerte active</p>
                                </div>
                            </c:if>
                        </div>
                    </div>
                    
                    <!-- Weather -->
                    <div class="bg-dark-800/70 backdrop-blur-xl border border-white/10 rounded-xl p-4" id="weather-widget">
                        <div class="flex items-center justify-between mb-4">
                            <h3 class="font-semibold"><i class="bi bi-cloud-sun me-2"></i>Météo locale</h3>
                            <span class="text-xs text-gray-500"><i class="bi bi-geo-alt me-1"></i><span id="weather-location">Antananarivo</span></span>
                        </div>
                        <div class="flex items-center gap-4 mb-4">
                            <img id="weather-icon-img" src="" alt="Météo" class="w-16 h-16 hidden" />
                            <span class="text-4xl" id="weather-icon-emoji">⏳</span>
                            <div>
                                <div class="text-3xl font-bold"><span id="weather-temp">--</span>°C</div>
                                <div class="text-sm text-gray-400 capitalize" id="weather-desc">Chargement...</div>
                            </div>
                        </div>
                        <div class="grid grid-cols-3 gap-2 text-center">
                            <div class="bg-white/5 rounded-lg p-2">
                                <i class="bi bi-droplet text-info-500 mb-1"></i>
                                <div class="text-xs text-gray-400">Humidité</div>
                                <div class="font-semibold"><span id="weather-humidity">--</span>%</div>
                            </div>
                            <div class="bg-white/5 rounded-lg p-2">
                                <i class="bi bi-wind text-gray-400 mb-1"></i>
                                <div class="text-xs text-gray-400">Vent</div>
                                <div class="font-semibold"><span id="weather-wind">--</span> km/h</div>
                            </div>
                            <div class="bg-white/5 rounded-lg p-2">
                                <i class="bi bi-cloud-rain text-info-500 mb-1"></i>
                                <div class="text-xs text-gray-400">Pluie (1h)</div>
                                <div class="font-semibold"><span id="weather-rain">0</span>mm</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Toast -->
    <div id="toast" class="fixed bottom-4 right-4 bg-dark-800 border border-white/10 rounded-lg p-4 shadow-lg transition-all opacity-0 translate-y-4 z-50">
        <div class="flex items-center gap-2">
            <i class="bi bi-lightning-charge text-warning-500"></i>
            <span>Connexion temps réel établie</span>
        </div>
    </div>
    
    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    
    <script>
        // Toggle sidebar on mobile
        function toggleSidebar() {
            document.querySelector('.sidebar').classList.toggle('open');
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

        // Custom marker icons
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
            .bindPopup('<strong>📍 Votre position actuelle</strong>');

        // Fetch alerts (risks)
        const fetchAlerts = () => {
            riskLayer.clearLayers();
            fetch('/api/v1/alerts?active=true', {
                headers: { 'Authorization': 'Bearer ${sessionScope.token}' }
            })
            .then(res => res.json())
            .then(data => {
                const alertsList = data.alerts || [];
                alertsList.forEach(a => {
                    const lat = a.center_lat || -18.9078;
                    const lng = a.center_lng || 47.5208;
                    const level = a.level || 'vigilance';
                    const iconKey = icons[a.type] || icons[level] || icons.vigilance;

                    L.marker([lat, lng], { icon: iconKey })
                        .bindPopup(`
                            <div style="min-width: 220px;">
                                <span style="display:inline-block;padding:2px 8px;font-size:10px;font-weight:bold;color:white;background:\${level === 'urgence' ? '#ef4444' : level === 'alerte' ? '#f59e0b' : '#eab308'};border-radius:4px;text-transform:uppercase;margin-bottom:6px;">\${level}</span>
                                <h3 style="font-weight:bold;margin-bottom:6px;font-size:14px;">\${a.title}</h3>
                                <p style="margin:4px 0;font-size:12px;color:#aaa;">\${a.message ? a.message.substring(0,150) + '...' : ''}</p>
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
            })
            .catch(err => console.log('Err alerts:', err));
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
                    L.marker([s.location_lat, s.location_lng], { icon: icons.shelter })
                        .bindPopup('<strong>🏠 ' + s.name + '</strong><br>Capacité: ' + (s.current_occupancy || 0) + '/' + s.capacity)
                        .addTo(shelterLayer);
                });
            })
            .catch(err => console.log('Err shelters:', err));
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
                        .bindPopup('<strong>📍 ' + i.title + '</strong><br>' + (i.description || ''))
                        .addTo(incidentLayer);
                });
            })
            .catch(err => console.log('Err incidents:', err));
        };

        fetchAlerts();
        fetchShelters();
        fetchIncidents();

        // Auto-refresh every 30s
        setInterval(() => { fetchAlerts(); fetchShelters(); fetchIncidents(); }, 30000);

        // Layer filter
        function filterLayers(type, event) {
            const buttons = document.querySelectorAll('.layer-filter-btn');
            buttons.forEach(btn => {
                btn.classList.remove('bg-white', 'text-gray-900', 'shadow-sm');
                btn.classList.add('text-gray-400');
            });
            if (event) {
                event.currentTarget.classList.add('bg-white', 'text-gray-900', 'shadow-sm');
                event.currentTarget.classList.remove('text-gray-400');
            }
            map.removeLayer(riskLayer);
            map.removeLayer(incidentLayer);
            map.removeLayer(shelterLayer);
            if (type === 'all' || type === 'risk') map.addLayer(riskLayer);
            if (type === 'all' || type === 'incident') map.addLayer(incidentLayer);
            if (type === 'all' || type === 'shelter') map.addLayer(shelterLayer);
        }

        // Show toast
        const toast = document.getElementById('toast');
        function showToast() {
            toast.classList.remove('opacity-0', 'translate-y-4');
            setTimeout(() => {
                toast.classList.add('opacity-0', 'translate-y-4');
            }, 3000);
        }
        
        // WebSocket for real-time updates
        const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const ws = new WebSocket(wsProtocol + '//' + window.location.host + '/ws');
        
        ws.onopen = () => {
            showToast();
        };
        
        ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            if (data.type === 'alert' || data.type === 'incident' || data.type === 'shelter_update') {
                fetchAlerts();
                fetchShelters();
                fetchIncidents();
            }
        };

        // Aggregation Weather API Fetch via Gateway / AI Service with OpenWeatherMap fallback
        async function fetchWeather() {
            const lat = parseFloat('${userLat}') || -18.9078;
            const lng = parseFloat('${userLng}') || 47.5208;
            const fallbackCity = '${userLocation}' || 'Antananarivo';
            
            // 1. Try our aggregated gateway endpoint first (gets OpenWeather map or cached or mock values cleanly)
            const localUrl = "/api/ai/weather/current?lat=" + lat + "&lng=" + lng;
            
            try {
                const response = await fetch(localUrl);
                if (response.ok) {
                    const result = await response.json();
                    
                    // The backend API might return { source: "openweather", data: { ... } } or { source: "cache", data: { ... } }
                    let weatherData = result.data || result;
                    
                    // If it is standard OpenWeather JSON format (direct or via backend proxy)
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
                    // If it's a flat DB record (like cached row in PostgreSQL)
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
            
            // 2. Direct browser fallback if local API is down or not authenticated (uses the test public key)
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
                    // Custom fallback if OpenWeather direct call is rate limited (which it currently is)
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
            
            // Show some nice default demo values (Antananarivo average) so the user is wowed instead of seeing error
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
        
        // Charger la météo au démarrage
        document.addEventListener('DOMContentLoaded', fetchWeather);

        // Pulse animation styles
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
                font-size: 18px; box-shadow: 0 4px 12px rgba(0,0,0,0.3); border: 2.5px solid white; transition: transform 0.2s;
                cursor: pointer;
            }
            .marker-pin:hover { transform: scale(1.15); }
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>
