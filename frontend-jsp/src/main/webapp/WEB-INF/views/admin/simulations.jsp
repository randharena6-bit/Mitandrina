<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simulations IA "What-If" - MITANDRINA</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
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
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .card-modern:hover { box-shadow: 0 8px 24px rgba(0,0,0,0.08); transform: translateY(-2px); }
        .animate-fade-in-up { animation: fadeInUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; opacity: 0; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        .btn-icon {
            width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center;
            background: white; border: 1px solid #e2e8f0; color: #64748b; transition: all 0.2s ease;
        }
        .btn-icon:hover { background: #f8fafc; border-color: #cbd5e1; color: #1e293b; }
    </style>
    <link rel="stylesheet" href="/assets/css/custom.css?v=56f1e2d0">
</head>
<body class="min-h-screen flex">
    
    <!-- Sidebar -->
    <aside class="sidebar fixed top-0 left-0 bottom-0 z-50 transition-transform" id="sidebar">
        <div class="flex flex-col h-full">
            <div class="p-6 border-b border-gray-100">
                <a href="../" class="flex items-center gap-2 text-xl font-bold text-gray-900">
                    <i class="bi bi-shield-shaded text-danger-600"></i>
                    <span>MITANDRINA</span>
                </a>
            </div>
            
            <nav class="flex-1 overflow-y-auto py-4 px-3">
                <div class="px-3 mb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">Principal</div>
                
                <a href="../dashboard" class="nav-item">
                    <i class="bi bi-grid-1x2-fill text-lg"></i>
                    <span>Tableau de bord</span>
                </a>
                
                <a href="../map" class="nav-item">
                    <i class="bi bi-map-fill text-lg"></i>
                    <span>Carte des risques</span>
                </a>
                
                <a href="../cyclone-map" class="nav-item">
                    <i class="bi bi-tornado text-lg"></i>
                    <span>Carte des cyclones</span>
                </a>
                
                <a href="../alerts" class="nav-item">
                    <i class="bi bi-bell-fill text-lg"></i>
                    <span>Alertes</span>
                </a>
                
                <a href="../incidents" class="nav-item">
                    <i class="bi bi-geo-alt-fill text-lg"></i>
                    <span>Incidents</span>
                </a>
                
                <a href="../evacuation" class="nav-item">
                    <i class="bi bi-car-front-fill text-lg"></i>
                    <span>Évacuation</span>
                </a>
                
                <c:if test="${sessionScope.user.role == 'administrateur'}">
                    <div class="px-3 mt-6 mb-2 text-xs font-semibold text-gray-400 uppercase tracking-wider">Administration</div>
                    
                    <a href="users" class="nav-item">
                        <i class="bi bi-people-fill text-lg"></i>
                        <span>Utilisateurs</span>
                    </a>
                    
                    <a href="teams" class="nav-item">
                        <i class="bi bi-building-fill text-lg"></i>
                        <span>Équipes</span>
                    </a>
                    
                    <a href="simulations" class="nav-item active">
                        <i class="bi bi-magic text-lg"></i>
                        <span>Simulations</span>
                    </a>
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
                <a href="../auth/logout" class="flex items-center justify-center gap-2 w-full py-2.5 rounded-xl border border-gray-200 text-gray-600 font-medium hover:bg-primary-50 hover:text-primary-700 transition-all text-sm">
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
                    <h1 class="text-xl font-bold text-gray-900">Simulations IA "What-If"</h1>
                    <p class="text-xs text-gray-500">Anticipez l'impact des catastrophes naturelles sur le réseau routier</p>
                </div>
            </div>
            
            <button data-bs-toggle="modal" data-bs-target="#runSimulationModal" 
                    class="flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-xl font-semibold shadow-lg shadow-purple-600/20 hover:scale-[1.02] hover:shadow-purple-600/30 transition-all text-sm">
                <i class="bi bi-magic text-lg"></i>
                Lancer un scénario
            </button>
        </header>
        
        <!-- Simulations History -->
        <div class="p-6">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 animate-fade-in-up">
                <c:forEach items="${simulationsList}" var="sim">
                    <div class="card-modern overflow-hidden p-5 flex flex-col justify-between">
                        <div>
                            <div class="flex items-center justify-between mb-3">
                                <span class="px-2.5 py-1 text-xs font-bold rounded-lg uppercase
                                             ${sim.status == 'completed' ? 'bg-green-50 text-green-600 border border-green-100' : 'bg-purple-50 text-purple-600 border border-purple-100 animate-pulse'}">
                                    ${sim.status}
                                </span>
                                <span class="text-xs text-gray-400 font-bold uppercase">${sim.scenario_type}</span>
                            </div>

                            <h3 class="font-bold text-gray-900 text-base mb-1.5">${sim.name}</h3>
                            <p class="text-xs text-gray-500 mb-4">
                                <i class="bi bi-person-fill mr-1"></i>Démarreur : ${sim.creator_email}
                            </p>

                            <!-- Parameters Summary -->
                            <div class="grid grid-cols-3 gap-2 text-center text-xs text-gray-600 mb-4">
                                <div class="bg-gray-50 p-2.5 rounded-xl">
                                    <p class="font-bold text-gray-400 text-[10px] uppercase">Intensité</p>
                                    <p class="font-semibold text-gray-900">${sim.intensity_level}/10</p>
                                </div>
                                <div class="bg-gray-50 p-2.5 rounded-xl">
                                    <p class="font-bold text-gray-400 text-[10px] uppercase">Rayon</p>
                                    <p class="font-semibold text-gray-900">${sim.radius_km} km</p>
                                </div>
                                <div class="bg-gray-50 p-2.5 rounded-xl">
                                    <p class="font-bold text-gray-400 text-[10px] uppercase">GPS Centre</p>
                                    <p class="font-semibold text-gray-900 truncate">${sim.center_lat}, ${sim.center_lng}</p>
                                </div>
                            </div>

                            <!-- Simulation results if completed -->
                            <c:if test="${sim.status == 'completed'}">
                                <div class="border-t border-dashed border-gray-200 pt-4 space-y-2">
                                    <h4 class="text-xs font-bold text-gray-900 flex items-center gap-1">
                                        <i class="bi bi-graph-up text-purple-600"></i>
                                        Rapport d'Impact Prédictif IA :
                                    </h4>
                                    
                                     <c:choose>
                                         <c:when test="${sim.results.track != null and sim.results.track.size() > 0}">
                                             <div class="bg-gradient-to-br from-purple-50 to-indigo-50 border border-purple-100 p-4 rounded-2xl space-y-3 text-xs text-purple-950">
                                                 <div class="flex items-center justify-between border-b border-purple-100 pb-2">
                                                     <span class="font-bold text-xs text-purple-900">${sim.name}</span>
                                                     <span class="px-2 py-0.5 bg-purple-200 text-purple-800 rounded font-bold text-[9px] uppercase">${sim.results.total_days != null ? sim.results.total_days : sim.results.track.size()} jours</span>
                                                 </div>
                                                 
                                                 <div class="grid grid-cols-2 gap-2 text-center text-[10px] font-semibold text-purple-900">
                                                     <div class="bg-white/60 p-2 rounded-xl border border-purple-100/50">
                                                         <p class="text-[9px] text-purple-500 uppercase font-bold">Vents Absolus</p>
                                                         <p class="text-xs text-gray-950 font-bold">${sim.results.max_wind_kmh} km/h</p>
                                                         <p class="text-[8px] text-purple-400 font-medium">Rafales ${sim.results.max_gusts_kmh} km/h</p>
                                                     </div>
                                                     <div class="bg-white/60 p-2 rounded-xl border border-purple-100/50">
                                                         <p class="text-[9px] text-purple-500 uppercase font-bold">Pression Min</p>
                                                         <p class="text-xs text-gray-950 font-bold">${sim.results.min_pressure_hpa} hPa</p>
                                                         <p class="text-[8px] text-purple-400 font-medium">Catégorie 3 (CTI)</p>
                                                     </div>
                                                 </div>
                                                 
                                                 <div class="space-y-1.5 pt-1 text-[11px]">
                                                     <div class="flex items-center justify-between">
                                                         <span>Population affectée cumulée :</span>
<span class="font-bold text-gray-950"><fmt:formatNumber value="${sim.results.affected_population}" /> pers.</span>
                                                     </div>
                                                     <div class="flex items-center justify-between">
                                                         <span>Itinéraires A* simulés :</span>
                                                         <span class="font-bold text-gray-950">${sim.evacuation_routes_generated} routes</span>
                                                     </div>
                                                 </div>

                                                  <!-- Carte Trajectoire Toggle -->
                                                  <div class="flex gap-2 pt-2">
                                                      <button class="flex-1 text-center py-2 bg-purple-600 text-white font-bold rounded-xl shadow hover:bg-purple-700 transition-colors text-[10px] uppercase tracking-wider"
                                                              onclick="toggleMap('${sim.id}')">
                                                          <i class="bi bi-map"></i> Afficher la Carte (${sim.results.track.size()} étapes)
                                                      </button>
                                                      <button class="flex-1 text-center py-2 bg-indigo-100 text-indigo-700 font-bold rounded-xl hover:bg-indigo-200 transition-colors text-[10px] uppercase tracking-wider"
                                                              onclick="toggleTimeline('${sim.id}')">
                                                          <i class="bi bi-list-ul"></i> Chronologie
                                                      </button>
                                                  </div>
                                              </div>
                                              
                                              <!-- Hidden Map Container -->
                                              <div id="map-${sim.id}" class="hidden mt-3 rounded-2xl overflow-hidden border border-purple-100" style="height:320px;"></div>
                                              
                                              <!-- Hidden Trajectory Timeline Details -->
                                              <div id="timeline-${sim.id}" class="hidden mt-3 bg-gray-50 border border-gray-100 rounded-2xl p-3 max-h-60 overflow-y-auto space-y-3">
                                                  <h5 class="text-xs font-bold text-gray-900 border-b border-gray-200 pb-2 flex items-center gap-1">
                                                      <i class="bi bi-compass"></i>
                                                      Trajectoire :
                                                  </h5>
                                                  <div class="relative border-l-2 border-purple-200 ml-2 pl-3 space-y-3 text-[11px]">
                                                      <c:forEach items="${sim.results.track}" var="point">
                                                          <div class="relative">
                                                              <div class="absolute -left-[18px] top-1 w-2 h-2 rounded-full bg-purple-600 border border-white"></div>
                                                              <p class="font-bold text-gray-800">${point.datetime}</p>
                                                              <p class="font-semibold text-purple-700 text-[10px]">${point.stage} (${point.lat} S, ${point.lng} E)</p>
                                                              <p class="text-[10px] text-gray-500 font-medium">${point.note}</p>
                                                              <c:if test="${point.wind > 0}">
                                                                  <p class="text-[10px] font-bold text-purple-950">💨 Vents: ${point.wind} km/h (Pression: ${point.pressure} hPa)</p>
                                                              </c:if>
                                                          </div>
                                                      </c:forEach>
                                                  </div>
                                              </div>
                                         </c:when>
                                         <c:otherwise>
                                             <div class="bg-purple-50/50 p-3 rounded-xl space-y-2 text-xs text-purple-950">
                                                 <div class="flex items-center justify-between">
                                                     <span>Population affectée estimée :</span>
<span class="font-bold text-gray-950"><fmt:formatNumber value="${sim.results.affected_population}" /> pers.</span>
                                                </div>
                                                <div class="flex items-center justify-between">
                                                    <span>Temps d'évacuation estimé :</span>
                                                    <span class="font-bold text-gray-950">${sim.estimated_evacuation_time_minutes} min</span>
                                                 </div>
                                                 <div class="flex items-center justify-between">
                                                     <span>Itinéraires A* sûrs calculés :</span>
                                                     <span class="font-bold text-gray-950">${sim.evacuation_routes_generated} routes</span>
                                                 </div>
                                             </div>
                                         </c:otherwise>
                                     </c:choose>
                                </div>
                            </c:if>
                            
                            <c:if test="${sim.status == 'running'}">
                                <div class="border-t border-dashed border-gray-200 pt-4 text-center py-6 text-purple-600 text-xs font-semibold flex items-center justify-center gap-2">
                                    <div class="spinner-border spinner-border-sm" role="status"></div>
                                    Calcul de la simulation d'impact en cours par l'IA...
                                </div>
                            </c:if>
                        </div>
                        
                        <div class="mt-4 pt-3 border-t border-gray-100 flex items-center justify-between text-[11px] text-gray-400">
                            <span>Lancement : ${sim.created_at}</span>
                            <c:if test="${sim.status == 'completed'}">
                                <span class="text-green-600 font-bold"><i class="bi bi-clock-history mr-1"></i>Terminé en ${sim.execution_time_seconds}s</span>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
                
                <c:if test="${empty simulationsList}">
                    <div class="col-span-2 text-center py-20 text-gray-500 bg-white border border-gray-200 rounded-2xl">
                        <i class="bi bi-magic text-5xl text-gray-300 block mb-3 animate-pulse"></i>
                        Aucune simulation "What-If" enregistrée pour le moment
                    </div>
                </c:if>
            </div>
        </div>
    </main>

    <!-- Modal for Triggering AI Simulation Scenario -->
    <div class="modal fade" id="runSimulationModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 rounded-2xl shadow-2xl">
                <form action="simulations/create" method="POST">
                    <div class="modal-header border-b border-gray-100 p-4">
                        <h5 class="modal-title font-bold text-gray-900 flex items-center gap-2">
                            <i class="bi bi-magic text-purple-600"></i>
                            Lancer une Simulation Prédictive
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4 space-y-4">
                        <!-- Nom -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Nom du Scénario</label>
                            <input type="text" name="name" placeholder="Ex: Simulation Cyclone Catégorie 4 côte Est" 
                                   class="form-control bg-gray-50 border-gray-200 rounded-xl" required minlength="5">
                        </div>
                        
                        <!-- Scenario Type -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Type de Scénario de crise</label>
                            <select name="scenarioType" class="form-select bg-gray-50 border-gray-200 rounded-xl" required>
                                <option value="cyclone">🌀 Cyclone Tropical Majeur</option>
                                <option value="inondation">💧 Inondation par crues et ruptures</option>
                                <option value="incendie">🔥 Propagation rapide de feu de brousse</option>
                                <option value="seisme">🏚️ Tremblement de terre d'intensité élevée</option>
                            </select>
                        </div>

                        <!-- Intensity level scale -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Niveau de Gravité / Intensité (1 à 10)</label>
                            <div class="flex items-center gap-3">
                                <input type="range" name="intensity" min="1" max="10" value="5" class="form-range flex-1" id="intensityRange" oninput="updateIntensityVal(this.value)">
                                <span class="px-3 py-1 bg-purple-100 text-purple-700 font-bold rounded-lg text-xs" id="intensityVal">5/10</span>
                            </div>
                        </div>

                        <!-- GPS location coordinates -->
                        <div class="grid grid-cols-3 gap-2">
                            <div>
                                <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Latitude</label>
                                <input type="number" step="any" name="lat" value="-18.9078" 
                                       class="form-control bg-gray-50 border-gray-200 rounded-xl text-xs" required>
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Longitude</label>
                                <input type="number" step="any" name="lng" value="47.5208" 
                                       class="form-control bg-gray-50 border-gray-200 rounded-xl text-xs" required>
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Rayon (km)</label>
                                <input type="number" step="any" name="radius" value="8.0" min="0.5" max="100" 
                                       class="form-control bg-gray-50 border-gray-200 rounded-xl text-xs" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-t border-gray-100 p-4">
                        <button type="button" class="px-4 py-2 border border-gray-200 rounded-xl font-semibold text-gray-600 hover:bg-gray-50" data-bs-dismiss="modal">Annuler</button>
                        <button type="submit" 
                                class="px-5 py-2 bg-gradient-to-r from-purple-600 to-indigo-600 text-white rounded-xl font-bold shadow-lg shadow-purple-600/20 transition-all">
                            Démarrer la Simulation
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Leaflet JS -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    
    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Track data for all simulations
        var trackData = {};
        <c:forEach items="${simulationsList}" var="sim">
          <c:if test="${sim.results.track != null and sim.results.track.size() > 0}">
            trackData['${sim.id}'] = [
              <c:forEach items="${sim.results.track}" var="point" varStatus="status">
                {lat: ${point.lat}, lng: ${point.lng}, wind: ${point.wind != null ? point.wind : 0}, pressure: ${point.pressure != null ? point.pressure : 0}, stage: '${point.stage}', datetime: '${point.datetime}'}<c:if test="${!status.last}">,</c:if>
              </c:forEach>
            ];
          </c:if>
        </c:forEach>

        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('open');
        }
        function updateIntensityVal(val) {
            document.getElementById('intensityVal').textContent = val + '/10';
        }
        function toggleTimeline(simId) {
            var el = document.getElementById('timeline-' + simId);
            if (el) el.classList.toggle('hidden');
        }
        function toggleMap(simId) {
            var el = document.getElementById('map-' + simId);
            if (!el) return;
            el.classList.toggle('hidden');
            if (el.classList.contains('hidden')) return;

            var points = trackData[simId];
            if (!points || points.length === 0) return;

            if (!el._leaflet_map) {
                setTimeout(function() {
                    var map = L.map(el).setView([points[0].lat, points[0].lng], 6);

                    var osmLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                        maxZoom: 19,
                        attribution: '\u00a9 OpenStreetMap'
                    }).addTo(map);

                    var satelliteLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
                        maxZoom: 19,
                        attribution: '\u00a9 Esri, Maxar, Earthstar Geographics'
                    });

                    L.control.layers({
                        'Carte': osmLayer,
                        'Satellite': satelliteLayer
                    }, null, { position: 'topright', collapsed: true }).addTo(map);

                    var latlngs = points.map(function(p) { return [p.lat, p.lng]; });

                    L.polyline(latlngs, {color: '#7c3aed', weight: 3, opacity: 0.7}).addTo(map);

                    points.forEach(function(p) {
                        var color = '#22c55e';
                        if (p.wind >= 120) color = '#ef4444';
                        else if (p.wind >= 80) color = '#f97316';
                        else if (p.wind >= 55) color = '#eab308';

                        L.circleMarker([p.lat, p.lng], {
                            radius: 5,
                            fillColor: color,
                            color: '#fff',
                            weight: 1.5,
                            fillOpacity: 0.8
                        }).bindPopup(
                            '<b>' + p.datetime + '</b><br/>' +
                            p.stage + '<br/>' +
                            '\ud83d\udca8 ' + p.wind + ' km/h<br/>' +
                            '\ud83d\udcca ' + p.pressure + ' hPa'
                        ).addTo(map);
                    });

                    var bounds = L.latLngBounds(latlngs);
                    map.fitBounds(bounds.pad(0.15));

                    el._leaflet_map = map;
                    setTimeout(function() { map.invalidateSize(); }, 300);
                }, 150);
            } else {
                setTimeout(function() { el._leaflet_map.invalidateSize(); }, 300);
            }
        }
        // Auto-init maps for visible containers (when toggled after initial hidden state)
        document.addEventListener('DOMContentLoaded', function() {
            // nothing auto-init - maps are lazily initialized on toggle
        });
    </script>
</body>
</html>
