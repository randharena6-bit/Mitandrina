<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Urgence & Alertes - MITANDRINA</title>
    
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
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .card-modern:hover { box-shadow: 0 8px 24px rgba(0,0,0,0.08); }
        .animate-fade-in-up { animation: fadeInUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; opacity: 0; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        .btn-icon {
            width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center;
            background: white; border: 1px solid #e2e8f0; color: #64748b; transition: all 0.2s ease;
        }
        .btn-icon:hover { background: #f8fafc; border-color: #cbd5e1; color: #1e293b; }
    </style>
    <script src="https://cdn.socket.io/4.7.4/socket.io.min.js"></script>
    <link rel="stylesheet" href="/assets/css/custom.css?v=88a84a7f">
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
                
                <a href="alerts" class="nav-item active">
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
        <!-- Top Bar -->
        <header class="sticky top-0 z-30 bg-white/80 backdrop-blur-md border-b border-gray-100 h-16 flex items-center justify-between px-6">
            <div class="flex items-center gap-4">
                <button class="md:hidden btn-icon" onclick="toggleSidebar()">
                    <i class="bi bi-list text-xl"></i>
                </button>
                <div>
                    <h1 class="text-xl font-bold text-gray-900">Registre d'Urgence & Alertes</h1>
                    <p class="text-xs text-gray-500">Diffusez et coordonnez les plans de survie de la population</p>
                </div>
            </div>
            
            <c:if test="${sessionScope.user.role == 'administrateur' || sessionScope.user.role == 'secouriste'}">
                <button data-bs-toggle="modal" data-bs-target="#emitAlertModal" 
                        class="flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-danger-600 to-danger-700 text-white rounded-xl font-semibold shadow-lg shadow-danger-600/20 hover:scale-[1.02] hover:shadow-danger-600/30 transition-all text-sm">
                    <i class="bi bi-broadcast text-lg"></i>
                    Émettre une alerte
                </button>
            </c:if>
        </header>
        
        <!-- Alerts Log List -->
        <div class="p-6">
            <c:if test="${sessionScope.user.role == 'administrateur' || sessionScope.user.role == 'secouriste'}">
                <!-- Status widget for Audio / WebSocket -->
                <div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 rounded-2xl flex items-center justify-between shadow-sm animate-fade-in-up">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-xl bg-emerald-500 flex items-center justify-center text-white">
                            <i class="bi bi-volume-up-fill text-xl animate-bounce"></i>
                        </div>
                        <div>
                            <h4 class="text-sm font-bold text-emerald-950">Mode Secours Sonore Actif</h4>
                            <p class="text-xs text-emerald-700">Vous recevrez des alertes critiques en temps réel avec sirène sonore</p>
                        </div>
                    </div>
                    <button onclick="playAlarmSound()" class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-bold transition-all shadow-md">
                        🔊 Tester l'alarme
                    </button>
                </div>
            </c:if>

            <c:if test="${not empty error}">
                <div class="p-4 mb-6 rounded-xl bg-red-50 border border-red-200 text-sm font-semibold text-red-700">
                    ${error}
                </div>
            </c:if>

            <div class="card-modern overflow-hidden animate-fade-in-up">
                <div class="flex items-center justify-between p-5 border-b border-gray-100 bg-gray-50">
                    <h3 class="font-bold text-gray-900 text-sm">Toutes les alertes émises</h3>
                    <div class="flex items-center gap-3">
                        <a href="?active=true" class="text-xs font-semibold px-3 py-1.5 rounded-lg border border-gray-200 bg-white text-gray-600 hover:text-gray-900 transition-colors">Actives seulement</a>
                        <a href="alerts" class="text-xs font-semibold px-3 py-1.5 rounded-lg border border-gray-200 bg-white text-gray-600 hover:text-gray-900 transition-colors">Toutes</a>
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table mb-0 align-middle">
                        <thead class="bg-gray-50 border-b border-gray-100">
                            <tr>
                                <th class="px-6 py-4 text-xs font-bold text-gray-400 uppercase">Alerte</th>
                                <th class="px-6 py-4 text-xs font-bold text-gray-400 uppercase">Sévérité / Type</th>
                                <th class="px-6 py-4 text-xs font-bold text-gray-400 uppercase">Message</th>
                                <th class="px-6 py-4 text-xs font-bold text-gray-400 uppercase">Émis le</th>
                                <th class="px-6 py-4 text-xs font-bold text-gray-400 uppercase text-end">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                            <c:forEach items="${alertsList}" var="alert">
                                <tr>
                                    <td class="px-6 py-4">
                                        <div class="flex items-center gap-3">
                                            <div class="w-2.5 h-2.5 rounded-full ${alert.resolved_at == null ? 'bg-danger-600 animate-pulse' : 'bg-gray-300'}"></div>
                                            <div>
                                                <p class="text-sm font-semibold text-gray-900">${alert.title}</p>
                                                <p class="text-xs text-gray-400 uppercase font-medium">Zone: ${alert.zone_name != null ? alert.zone_name : 'Nationale'}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="flex items-center gap-2">
                                            <span class="px-2.5 py-1 text-xs font-bold rounded-lg uppercase
                                                         ${alert.level == 'urgence' ? 'bg-red-50 text-red-600 border border-red-100' : alert.level == 'alerte' ? 'bg-amber-50 text-amber-600 border border-amber-100' : 'bg-blue-50 text-blue-600 border border-blue-100'}">
                                                ${alert.level}
                                            </span>
                                            <span class="px-2 py-0.5 text-xs text-gray-500 bg-gray-100 rounded-md capitalize">${alert.type}</span>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <p class="text-xs text-gray-600 max-w-sm truncate">${alert.message}</p>
                                    </td>
                                    <td class="px-6 py-4 text-xs text-gray-500 font-medium">
                                        ${alert.emitted_at}
                                    </td>
                                    <td class="px-6 py-4 text-end">
                                        <c:choose>
                                            <c:when test="${alert.resolved_at == null}">
                                                <c:if test="${sessionScope.user.role == 'administrateur' || sessionScope.user.role == 'secouriste'}">
                                                    <button onclick="resolveAlert('${alert.id}')" 
                                                            class="px-3 py-1.5 text-xs font-semibold bg-green-50 text-green-700 border border-green-200 rounded-lg hover:bg-green-100 transition-colors">
                                                        Résoudre
                                                    </button>
                                                </c:if>
                                                <a href="evacuation?alert=${alert.id}" 
                                                   class="px-3 py-1.5 text-xs font-semibold bg-blue-50 text-blue-700 border border-blue-200 rounded-lg no-underline hover:bg-blue-100 transition-colors ml-2">
                                                    Évacuer
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-xs text-green-600 font-semibold flex items-center justify-end gap-1">
                                                    <i class="bi bi-check-circle-fill"></i>
                                                    Résolue
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            
                            <c:if test="${empty alertsList}">
                                <tr>
                                    <td colspan="5" class="text-center py-12 text-gray-500">
                                        <i class="bi bi-broadcast text-4xl text-gray-300 block mb-3"></i>
                                        Aucune alerte émise pour le moment
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

    <!-- Modal for Emitting Emergency Alert -->
    <div class="modal fade" id="emitAlertModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 rounded-2xl shadow-2xl">
                <form action="alerts" method="POST">
                    <div class="modal-header border-b border-gray-100 p-4">
                        <h5 class="modal-title font-bold text-gray-900 flex items-center gap-2">
                            <i class="bi bi-broadcast text-danger-600 animate-pulse"></i>
                            Émission d'Alerte d'Urgence
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4 space-y-4">
                        <!-- Niveau de sévérité -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Niveau de Danger / Sévérité</label>
                            <select name="level" class="form-select bg-gray-50 border-gray-200 rounded-xl" required>
                                <option value="urgence">🔴 URGENCE (Péril immédiat, évacuation recommandée)</option>
                                <option value="alerte">🟠 ALERTE (Danger imminent, confinement)</option>
                                <option value="vigilance">🔵 VIGILANCE (Suivi météorologique actif)</option>
                                <option value="info">🟢 INFO (Information citoyenne simple)</option>
                            </select>
                        </div>
                        
                        <!-- Type de sinistre -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Nature de la Catastrophe</label>
                            <select name="type" class="form-select bg-gray-50 border-gray-200 rounded-xl" required>
                                <option value="incendie">🔥 Feu de forêt / Incendie urbain</option>
                                <option value="inondation">💧 Inondation de plaine / Crues éclair</option>
                                <option value="cyclone">🌀 Cyclone / Tempête tropicale</option>
                                <option value="seisme">🏚️ Séisme / Tremblement de terre</option>
                                <option value="glissement_terrain">⛰️ Éboulement / Glissement de terrain</option>
                                <option value="tsunami">🌊 Tsunami / Raz de marée</option>
                            </select>
                        </div>

                        <!-- Titre -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Titre court du flash info</label>
                            <input type="text" name="title" placeholder="Ex: Risque inondation extrême plaine Betsiboka" 
                                   class="form-control bg-gray-50 border-gray-200 rounded-xl" required minlength="5">
                        </div>

                        <!-- Message -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Consignes et Instructions de sécurité</label>
                            <textarea name="message" rows="4" placeholder="Ex: L'eau monte rapidement de 10cm/h. Veuillez quitter les zones basses et rejoindre le refuge Analakely." 
                                      class="form-control bg-gray-50 border-gray-200 rounded-xl" required minlength="10"></textarea>
                        </div>

                        <!-- Association incident -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Associer à un incident actif (Optionnel)</label>
                            <select name="zoneId" class="form-select bg-gray-50 border-gray-200 rounded-xl">
                                <option value="">Aucun incident (Alerte générale)</option>
                                <c:forEach items="${incidentsList}" var="incident">
                                    <option value="${incident.zone_id}">${incident.title} (${incident.type})</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-t border-gray-100 p-4">
                        <button type="button" class="px-4 py-2 border border-gray-200 rounded-xl font-semibold text-gray-600 hover:bg-gray-50 transition-colors" data-bs-dismiss="modal">Annuler</button>
                        <button type="submit" 
                                class="px-5 py-2 bg-danger-600 hover:bg-danger-700 text-white rounded-xl font-bold shadow-lg shadow-danger-600/20 transition-all">
                            Diffuser l'Alerte
                        </button>
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

        function resolveAlert(id) {
            if (confirm('Voulez-vous marquer cette alerte d\'urgence comme résolue ?')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'alerts';
                
                const actInput = document.createElement('input');
                actInput.type = 'hidden';
                actInput.name = 'action';
                actInput.value = 'resolve';
                form.appendChild(actInput);

                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'id';
                idInput.value = id;
                form.appendChild(idInput);

                document.body.appendChild(form);
                
                // AJAX alternative for seamless experience
                fetch('alerts?action=resolve&id=' + id, {
                    method: 'POST'
                })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        location.reload();
                    } else {
                        alert('Erreur: ' + JSON.stringify(data));
                    }
                })
                .catch(err => {
                    console.log('Err resolving:', err);
                    location.reload();
                });
            }
        }

        // Web Audio API Alarm generator
        function playAlarmSound() {
            try {
                const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
                let time = audioCtx.currentTime;
                
                // 4 cycles of beep pairs to simulate a real emergency siren
                for (let i = 0; i < 4; i++) {
                    const osc = audioCtx.createOscillator();
                    const gain = audioCtx.createGain();
                    
                    osc.type = 'sine';
                    // Alert tone alternates frequency
                    const freq = (i % 2 === 0) ? 880 : 660;
                    osc.frequency.setValueAtTime(freq, time);
                    osc.frequency.exponentialRampToValueAtTime(freq / 2, time + 0.35);
                    
                    gain.gain.setValueAtTime(0.5, time);
                    gain.gain.linearRampToValueAtTime(0.01, time + 0.4);
                    
                    osc.connect(gain);
                    gain.connect(audioCtx.destination);
                    
                    osc.start(time);
                    osc.stop(time + 0.45);
                    
                    time += 0.5;
                }
            } catch (e) {
                console.error("Failed to play alarm audio using Web Audio API", e);
            }
        }

        function escapeHtml(str) {
            if (!str) return '';
            return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
        }

        function addAlertToTable(alert) {
            const tbody = document.querySelector("table tbody");
            if (!tbody) return;

            // Remove empty row if present
            const emptyRow = tbody.querySelector("td[colspan='5']");
            if (emptyRow) {
                emptyRow.parentElement.remove();
            }

            const tr = document.createElement("tr");
            tr.className = "bg-red-50/70 border-l-4 border-red-500 transition-all duration-1000";

            const levelClass = alert.level === 'urgence' ? 'bg-red-50 text-red-600 border border-red-100' : alert.level === 'alerte' ? 'bg-amber-50 text-amber-600 border border-amber-100' : 'bg-blue-50 text-blue-600 border border-blue-100';

            const dateStr = new Date(alert.emitted_at || alert.emittedAt || new Date()).toLocaleString('fr-FR');

            tr.innerHTML = 
                '<td class="px-6 py-4">' +
                '    <div class="flex items-center gap-3">' +
                '        <div class="w-2.5 h-2.5 rounded-full bg-danger-600 animate-pulse"></div>' +
                '        <div>' +
                '            <p class="text-sm font-semibold text-gray-900">' + escapeHtml(alert.title) + '</p>' +
                '            <p class="text-xs text-gray-400 uppercase font-medium">Zone: ' + escapeHtml(alert.zone_name || 'Nationale') + '</p>' +
                '        </div>' +
                '    </div>' +
                '</td>' +
                '<td class="px-6 py-4">' +
                '    <div class="flex items-center gap-2">' +
                '        <span class="px-2.5 py-1 text-xs font-bold rounded-lg uppercase ' + levelClass + '">' +
                            escapeHtml(alert.level) +
                '        </span>' +
                '        <span class="px-2 py-0.5 text-xs text-gray-500 bg-gray-100 rounded-md capitalize">' + escapeHtml(alert.type) + '</span>' +
                '    </div>' +
                '</td>' +
                '<td class="px-6 py-4">' +
                '    <p class="text-xs text-gray-600 max-w-sm font-semibold text-red-700">' + escapeHtml(alert.message) + '</p>' +
                '</td>' +
                '<td class="px-6 py-4 text-xs text-gray-500 font-medium">' +
                    dateStr +
                '</td>' +
                '<td class="px-6 py-4 text-end">' +
                '    <button onclick="resolveAlert(\'' + alert.id + '\')"' +
                '            class="px-3 py-1.5 text-xs font-semibold bg-green-50 text-green-700 border border-green-200 rounded-lg hover:bg-green-100 transition-colors">' +
                '        Résoudre' +
                '    </button>' +
                '    <a href="evacuation?alert=' + alert.id + '"' +
                '       class="px-3 py-1.5 text-xs font-semibold bg-blue-50 text-blue-700 border border-blue-200 rounded-lg no-underline hover:bg-blue-100 transition-colors ml-2">' +
                '        Évacuer' +
                '    </a>' +
                '</td>';

            tbody.insertBefore(tr, tbody.firstChild);

            setTimeout(() => {
                tr.classList.remove("bg-red-50/70");
                tr.classList.remove("border-l-4");
                tr.classList.remove("border-red-500");
            }, 6000);
        }

        function showToast(alert) {
            const container = document.getElementById("toast-container");
            if (!container) return;

            const toastEl = document.createElement("div");
            toastEl.className = "toast border-0 rounded-2xl shadow-2xl bg-white mb-3";
            toastEl.setAttribute("role", "alert");
            toastEl.setAttribute("aria-live", "assertive");
            toastEl.setAttribute("aria-atomic", "true");

            toastEl.innerHTML = 
                '<div class="toast-header border-b border-gray-100 rounded-t-2xl p-3 bg-red-600 text-white flex justify-between items-center">' +
                '    <strong class="me-auto flex items-center gap-2">' +
                '        <i class="bi bi-exclamation-triangle-fill text-yellow-300 animate-pulse text-lg"></i>' +
                '        <span class="font-bold">ALERTE SECURE IA DÉTECTÉE</span>' +
                '    </strong>' +
                '    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast" aria-label="Close"></button>' +
                '</div>' +
                '<div class="toast-body p-4 space-y-3">' +
                '    <h5 class="text-sm font-bold text-gray-900">' + escapeHtml(alert.title) + '</h5>' +
                '    <p class="text-xs text-gray-600 leading-relaxed font-semibold">' + escapeHtml(alert.message) + '</p>' +
                '    <div class="pt-2 flex justify-end gap-2">' +
                '        <button onclick="resolveAlert(\'' + alert.id + '\')" class="px-3 py-1.5 text-xs font-semibold bg-green-600 text-white rounded-lg hover:bg-green-700">Résoudre</button>' +
                '        <button type="button" class="px-3 py-1.5 text-xs font-semibold bg-gray-100 text-gray-600 rounded-lg" data-bs-dismiss="toast">Ignorer</button>' +
                '    </div>' +
                '</div>';

            container.appendChild(toastEl);
            const bsToast = new bootstrap.Toast(toastEl, { delay: 15000 });
            bsToast.show();
        }

        // Initialize Socket.io connection for rescue staff
        <c:if test="${sessionScope.user.role == 'administrateur' || sessionScope.user.role == 'secouriste'}">
            document.addEventListener("DOMContentLoaded", () => {
                const token = "${sessionScope.token}";
                if (!token) return;

                console.log("Initializing Socket.io connection...");
                const socket = io("http://localhost:3001", {
                    auth: {
                        token: token
                    }
                });

                socket.on("connect", () => {
                    console.log("WebSocket connecté au Gateway");
                });

                socket.on("alert:admin", (alert) => {
                    console.log("WebSocket alert:admin reçu:", alert);
                    playAlarmSound();
                    showToast(alert);
                    addAlertToTable(alert);
                });

                socket.on("connect_error", (err) => {
                    console.error("Socket connection error:", err.message);
                });
            });
        </c:if>
    </script>
    
    <!-- Toast Container -->
    <div id="toast-container" class="position-fixed bottom-4 end-4 p-3" style="z-index: 9999; max-width: 350px;"></div>
</body>
</html>
