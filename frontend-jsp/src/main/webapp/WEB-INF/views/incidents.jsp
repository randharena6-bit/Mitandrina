<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Signalements d'Incidents - MITANDRINA</title>
    
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
    <link rel="stylesheet" href="/assets/css/custom.css?v=5d6825f1">
</head>
<body class="min-h-screen flex">
    
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
                
                <a href="incidents" class="nav-item active">
                    <i class="bi bi-geo-alt-fill text-lg"></i>
                    <span>Incidents</span>
                </a>
                
                <a href="evacuation" class="nav-item">
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
                        ${sessionScope.user.firstName.charAt(0)}${sessionScope.user.lastName.charAt(0)}
                    </div>
                    <div class="flex-1 min-w-0">
                        <p class="text-sm font-semibold text-gray-900 truncate">${sessionScope.user.firstName} ${sessionScope.user.lastName}</p>
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
    <main class="main-content flex-1 ml-[280px]">
        <!-- Alarme Banner -->
        <div id="alarm-banner" class="hidden fixed top-0 left-0 right-0 z-[9999] bg-red-600 text-white text-center py-3 flex items-center justify-center gap-4 shadow-2xl animate-pulse" style="margin-left:280px;">
            <span class="text-lg font-bold flex items-center gap-2">
                <i class="bi bi-exclamation-triangle-fill text-2xl animate-bounce"></i>
                INCIDENT NON RÉSOLU - ALARME ACTIVE
            </span>
            <button onclick="desactiverAlarme()" class="px-5 py-1.5 bg-white text-red-700 font-bold rounded-lg hover:bg-red-50 transition-all text-sm flex items-center gap-1.5 shadow-lg">
                <i class="bi bi-volume-mute-fill"></i> Désactiver l'alarme
            </button>
        </div>
        
        <!-- Top Bar -->
        <header class="sticky top-0 z-30 bg-white/80 backdrop-blur-md border-b border-gray-100 h-16 flex items-center justify-between px-6">
            <div class="flex items-center gap-4">
                <button class="md:hidden btn-icon" onclick="toggleSidebar()">
                    <i class="bi bi-list text-xl"></i>
                </button>
                <div>
                    <h1 class="text-xl font-bold text-gray-900">Incidents Signalés</h1>
                    <p class="text-xs text-gray-500">Gérez, vérifiez et déployez les secours en temps réel</p>
                </div>
            </div>
            
            <button onclick="reactiverAlarme()" id="btn-reactiv-alarme" title="Réactiver l'alarme" 
                    class="hidden items-center gap-2 px-4 py-2 bg-red-50 text-red-700 rounded-xl font-semibold hover:bg-red-100 transition-all text-sm mr-2">
                <i class="bi bi-volume-up-fill text-lg animate-pulse"></i>
                Réactiver alarme
            </button>
            <button data-bs-toggle="modal" data-bs-target="#reportIncidentModal" 
                    class="flex items-center gap-2 px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-xl font-semibold shadow-lg shadow-primary-600/20 hover:scale-[1.02] hover:shadow-primary-600/30 transition-all text-sm">
                <i class="bi bi-megaphone-fill text-lg"></i>
                Signaler un incident
            </button>
        </header>
        
        <!-- Error Banner -->
        <c:if test="${not empty error}">
            <div class="mx-6 mt-4 p-4 bg-red-50 border border-red-200 rounded-xl flex items-center gap-3 animate-fade-in-up">
                <i class="bi bi-exclamation-circle-fill text-red-500 text-lg"></i>
                <span class="text-sm text-red-700 flex-1">${error}</span>
                <button onclick="this.parentElement.remove()" class="text-red-400 hover:text-red-600">
                    <i class="bi bi-x-lg"></i>
                </button>
            </div>
        </c:if>
        
        <!-- Incidents List -->
        <div class="p-6">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 animate-fade-in-up">
                <c:forEach items="${incidentsList}" var="incident">
                    <div class="card-modern overflow-hidden flex flex-col justify-between" data-incident-status="${incident.status}">
                        <div>
                            <!-- Header Status -->
                            <div class="p-4 border-b border-gray-100 flex items-center justify-between">
                                <span class="px-2.5 py-1 text-xs font-bold rounded-lg uppercase
                                             ${incident.status == 'signale' ? 'bg-red-50 text-red-600' : incident.status == 'verifie' ? 'bg-amber-50 text-amber-600' : incident.status == 'en_cours' ? 'bg-blue-50 text-blue-600' : 'bg-green-50 text-green-600'}">
                                    ${incident.status}
                                </span>
                                <span class="text-xs text-gray-400 font-semibold uppercase flex items-center gap-1">
                                    <i class="bi bi-tag-fill text-xs"></i>
                                    ${incident.type}
                                </span>
                            </div>
                            
                            <!-- Body Content -->
                            <div class="p-5 space-y-3">
                                <h4 class="font-bold text-gray-900 text-base">${incident.title}</h4>
                                <p class="text-xs text-gray-500 line-clamp-3 leading-relaxed">${incident.description}</p>
                                
                                <div class="bg-gray-50 p-3 rounded-xl space-y-1.5 text-xs text-gray-600">
                                    <div class="flex items-center justify-between">
                                        <span>📍 Localisation :</span>
                                        <span class="font-semibold text-gray-900 truncate max-w-[150px]">${incident.location_lat}, ${incident.location_lng}</span>
                                    </div>
                                    <div class="flex items-center justify-between">
                                        <span>👤 Signalé par :</span>
                                        <span class="font-semibold text-gray-900 truncate max-w-[150px]">${incident.reporter_email}</span>
                                    </div>
                                    <div class="flex items-center justify-between">
                                        <span>📅 Équipe assignée :</span>
                                        <span class="font-semibold text-gray-900 truncate max-w-[150px]">
                                            ${incident.assigned_team != null ? incident.assigned_team : 'Aucune'}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Footer Action dispatch -->
                        <div class="p-4 bg-gray-50 border-t border-gray-100 flex items-center justify-end gap-2 flex-shrink-0">
                            <c:if test="${sessionScope.user.role == 'administrateur' || sessionScope.user.role == 'secouriste'}">
                                <c:if test="${incident.status == 'signale'}">
                                    <button onclick="updateIncidentStatus('${incident.id}', 'verifie')" 
                                            class="px-3 py-1.5 text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200 rounded-lg hover:bg-amber-100 transition-colors">
                                        Vérifier
                                    </button>
                                </c:if>
                                
                                <c:if test="${incident.status != 'resolu'}">
                                    <button onclick="openAssignTeamModal('${incident.id}')" 
                                            class="px-3 py-1.5 text-xs font-semibold bg-blue-50 text-blue-700 border border-blue-200 rounded-lg hover:bg-blue-100 transition-colors">
                                        Déployer secours
                                    </button>
                                    <button onclick="updateIncidentStatus('${incident.id}', 'resolu')" 
                                            class="px-3 py-1.5 text-xs font-semibold bg-green-50 text-green-700 border border-green-200 rounded-lg hover:bg-green-100 transition-colors">
                                        Clôturer
                                    </button>
                                </c:if>
                            </c:if>
                            
                            <a href="evacuation?incident=${incident.id}" 
                               class="px-3 py-1.5 text-xs font-semibold bg-gray-100 text-gray-600 rounded-lg no-underline hover:bg-gray-200 transition-colors">
                                Itinéraire
                            </a>
                        </div>
                    </div>
                </c:forEach>
                
                <c:if test="${empty incidentsList}">
                    <div class="col-span-3 text-center py-20 text-gray-500 bg-white border border-gray-200 rounded-2xl">
                        <i class="bi bi-geo-alt text-5xl text-gray-300 block mb-3 animate-bounce"></i>
                        Aucun incident actif signalé dans les environs
                    </div>
                </c:if>
            </div>
        </div>
    </main>

    <!-- Modal for Reporting Incident -->
    <div class="modal fade" id="reportIncidentModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 rounded-2xl shadow-2xl">
                <form action="incidents" method="POST">
                    <div class="modal-header border-b border-gray-100 p-4">
                        <h5 class="modal-title font-bold text-gray-900 flex items-center gap-2">
                            <i class="bi bi-megaphone-fill text-primary-500"></i>
                            Signaler un Sinistre
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4 space-y-4">
                        <!-- Type -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Nature de l'incident</label>
                            <select name="type" class="form-select bg-gray-50 border-gray-200 rounded-xl" required>
                                <option value="incendie">🔥 Feu de forêt / Incendie</option>
                                <option value="inondation">💧 Inondation / Montée d'eau</option>
                                <option value="cyclone">🌀 Dégâts cycloniques / Forts vents</option>
                                <option value="seisme">🏚️ Éboulement / Séisme</option>
                                <option value="glissement_terrain">⛰️ Glissement de terrain</option>
                            </select>
                        </div>
                        
                        <!-- Titre -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Titre descriptif</label>
                            <input type="text" name="title" placeholder="Ex: Débordement canal Analakely" 
                                   class="form-control bg-gray-50 border-gray-200 rounded-xl" required minlength="5">
                        </div>

                        <!-- Description -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Description et détails du danger</label>
                            <textarea name="description" rows="3" placeholder="Ex: L'eau monte rapidement et commence à bloquer l'avenue principale." 
                                      class="form-control bg-gray-50 border-gray-200 rounded-xl" required minlength="10"></textarea>
                        </div>

                        <!-- GPS Location -->
                        <div class="grid grid-cols-2 gap-3">
                            <div>
                                <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Latitude</label>
                                <input type="number" step="any" name="lat" id="gps-lat" 
                                       class="form-control bg-gray-50 border-gray-200 rounded-xl" required>
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Longitude</label>
                                <input type="number" step="any" name="lng" id="gps-lng" 
                                       class="form-control bg-gray-50 border-gray-200 rounded-xl" required>
                            </div>
                        </div>
                        <button type="button" onclick="getCurrentLocation()" 
                                class="w-full py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold text-xs rounded-xl flex items-center justify-center gap-1 transition-all">
                            <i class="bi bi-geo-fill"></i>
                            Récupérer mes coordonnées GPS actuelles
                        </button>
                    </div>
                    <div class="modal-footer border-t border-gray-100 p-4">
                        <button type="button" class="px-4 py-2 border border-gray-200 rounded-xl font-semibold text-gray-600 hover:bg-gray-50 transition-colors" data-bs-dismiss="modal">Annuler</button>
                        <button type="submit" 
                                class="px-5 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-xl font-bold shadow-lg shadow-primary-600/20 transition-all">
                            Envoyer le Signalement
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal for Assigning Rescue Team -->
    <div class="modal fade" id="assignTeamModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-sm">
            <div class="modal-content border-0 rounded-2xl shadow-2xl">
                <form action="incidents" method="POST">
                    <input type="hidden" name="action" value="assignTeam">
                    <input type="hidden" name="incidentId" id="assignIncidentId">
                    
                    <div class="modal-header border-b border-gray-100 p-4">
                        <h5 class="modal-title font-bold text-gray-900 flex items-center gap-2">
                            <i class="bi bi-building-fill text-blue-600"></i>
                            Déployer Secours
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4 space-y-4">
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Choisir l'Équipe de Secours</label>
                            <select name="teamId" class="form-select bg-gray-50 border-gray-200 rounded-xl" required>
                                <option value="">-- Sélectionner l'équipe --</option>
                                <c:forEach items="${rescueTeams}" var="team">
                                    <option value="${team.id}">${team.name} (${team.type} - size: ${team.team_size})</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-t border-gray-100 p-4">
                        <button type="button" class="px-4 py-2 border border-gray-200 rounded-xl font-semibold text-gray-600 hover:bg-gray-50" data-bs-dismiss="modal">Annuler</button>
                        <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 transition-colors shadow-lg shadow-blue-600/20">Déployer</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('open');
        }

        function getCurrentLocation() {
            if ("geolocation" in navigator) {
                navigator.geolocation.getCurrentPosition(position => {
                    document.getElementById('gps-lat').value = position.coords.latitude;
                    document.getElementById('gps-lng').value = position.coords.longitude;
                }, err => {
                    alert("Impossible d'obtenir la localisation : " + err.message);
                });
            } else {
                alert("La géolocalisation n'est pas supportée par votre navigateur.");
            }
        }

        function openAssignTeamModal(incidentId) {
            document.getElementById('assignIncidentId').value = incidentId;
            const modal = new bootstrap.Modal(document.getElementById('assignTeamModal'));
            modal.show();
        }

        function updateIncidentStatus(id, status) {
            if (confirm("Voulez-vous passer cet incident au statut [" + status + "] ?")) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'incidents';
                
                const actInput = document.createElement('input');
                actInput.type = 'hidden';
                actInput.name = 'action';
                actInput.value = 'updateStatus';
                form.appendChild(actInput);

                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'incidentId';
                idInput.value = id;
                form.appendChild(idInput);

                const statusInput = document.createElement('input');
                statusInput.type = 'hidden';
                statusInput.name = 'status';
                statusInput.value = status;
                form.appendChild(statusInput);

                document.body.appendChild(form);
                form.submit();
            }
        }

        // ============================================================
        // ALARME INCIDENT - Son continu pour incidents non résolus
        // ============================================================
        let alarmCtx = null;
        let alarmOsc = null;
        let alarmGain = null;
        let alarmTimer = null;
        let alarmPlaying = false;

        function hasUnresolvedIncidents() {
            const cards = document.querySelectorAll('[data-incident-status]');
            for (let c of cards) {
                if (c.dataset.incidentStatus !== 'resolu') return true;
            }
            return false;
        }

        function startAlarm() {
            if (alarmPlaying) return;
            const deactivated = sessionStorage.getItem('alarm_desactive');
            if (deactivated === 'true') return;

            try {
                alarmCtx = new (window.AudioContext || window.webkitAudioContext)();
                alarmOsc = alarmCtx.createOscillator();
                alarmGain = alarmCtx.createGain();

                alarmOsc.type = 'sawtooth';
                alarmOsc.frequency.value = 660;
                alarmGain.gain.value = 0.3;

                alarmOsc.connect(alarmGain);
                alarmGain.connect(alarmCtx.destination);
                alarmOsc.start();

                var tick = 0;
                alarmTimer = setInterval(function() {
                    tick++;
                    var on = (tick % 4) < 2;
                    alarmGain.gain.value = on ? 0.35 : 0.0;
                    alarmOsc.frequency.value = on ? 880 : 660;
                }, 300);

                alarmPlaying = true;
                document.getElementById('alarm-banner').classList.remove('hidden');
            } catch(e) {
                console.warn('Alarme non supportée:', e);
            }
        }

        function stopAlarm() {
            if (alarmTimer) { clearInterval(alarmTimer); alarmTimer = null; }
            if (alarmOsc) { try { alarmOsc.stop(); } catch(e) {} alarmOsc = null; }
            if (alarmCtx) { try { alarmCtx.close(); } catch(e) {} alarmCtx = null; }
            alarmGain = null;
            alarmPlaying = false;
            document.getElementById('alarm-banner').classList.add('hidden');
        }

        function desactiverAlarme() {
            stopAlarm();
            sessionStorage.setItem('alarm_desactive', 'true');
            document.getElementById('btn-reactiv-alarme').classList.remove('hidden');
        }

        function reactiverAlarme() {
            sessionStorage.removeItem('alarm_desactive');
            document.getElementById('btn-reactiv-alarme').classList.add('hidden');
            checkAlarm();
        }

        function checkAlarm() {
            if (hasUnresolvedIncidents()) {
                startAlarm();
                document.getElementById('btn-reactiv-alarme').classList.add('hidden');
            } else {
                stopAlarm();
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            var deactivated = sessionStorage.getItem('alarm_desactive');
            if (deactivated === 'true' && hasUnresolvedIncidents()) {
                document.getElementById('btn-reactiv-alarme').classList.remove('hidden');
            }
            checkAlarm();
        });
    </script>
</body>
</html>
