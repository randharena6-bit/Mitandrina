<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - MITANDRINA</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/design-system.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
</head>
<body class="dashboard-page">
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <a href="${pageContext.request.contextPath}/" class="brand">
                <span class="brand-icon">🌪️</span>
                <span class="brand-text">MITANDRINA</span>
            </a>
        </div>
        
        <nav class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/dashboard" class="nav-item active">
                <span class="nav-icon">📊</span>
                <span class="nav-label">Tableau de bord</span>
            </a>
            <a href="${pageContext.request.contextPath}/map" class="nav-item">
                <span class="nav-icon">🗺️</span>
                <span class="nav-label">Carte des risques</span>
            </a>
            <a href="${pageContext.request.contextPath}/alerts" class="nav-item">
                <span class="nav-icon">🚨</span>
                <span class="nav-label">Alertes</span>
                <c:if test="${unreadAlerts > 0}">
                    <span class="badge">${unreadAlerts}</span>
                </c:if>
            </a>
            <a href="${pageContext.request.contextPath}/incidents" class="nav-item">
                <span class="nav-icon">📍</span>
                <span class="nav-label">Incidents</span>
            </a>
            <a href="${pageContext.request.contextPath}/evacuation" class="nav-item">
                <span class="nav-icon">🚗</span>
                <span class="nav-label">Évacuation</span>
            </a>
            
            <c:if test="${sessionScope.user.role == 'administrateur' || sessionScope.user.role == 'secouriste'}">
                <div class="nav-section">Administration</div>
                <a href="${pageContext.request.contextPath}/admin/users" class="nav-item">
                    <span class="nav-icon">👥</span>
                    <span class="nav-label">Utilisateurs</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/teams" class="nav-item">
                    <span class="nav-icon">🚑</span>
                    <span class="nav-label">Équipes</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/simulations" class="nav-item">
                    <span class="nav-icon">🔮</span>
                    <span class="nav-label">Simulations</span>
                </a>
            </c:if>
        </nav>
        
        <div class="sidebar-footer">
            <a href="${pageContext.request.contextPath}/profile" class="user-card">
                <div class="user-avatar">
                    ${sessionScope.user.firstName.charAt(0)}${sessionScope.user.lastName.charAt(0)}
                </div>
                <div class="user-info">
                    <span class="user-name">${sessionScope.user.firstName} ${sessionScope.user.lastName}</span>
                    <span class="user-role">${sessionScope.user.role}</span>
                </div>
            </a>
            <a href="${pageContext.request.contextPath}/auth/logout" class="btn btn-outline btn-sm">
                Déconnexion
            </a>
        </div>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content">
        <!-- Top Bar -->
        <header class="top-bar">
            <h1 class="page-title">Tableau de bord</h1>
            
            <div class="top-actions">
                <button class="btn-icon" id="notifications-btn" title="Notifications">
                    🔔
                    <c:if test="${unreadNotifications > 0}">
                        <span class="indicator">${unreadNotifications}</span>
                    </c:if>
                </button>
                
                <div class="connection-status online" id="connection-status">
                    <span class="status-dot"></span>
                    Connecté
                </div>
            </div>
        </header>
        
        <!-- Dashboard Content -->
        <div class="dashboard-content">
            <!-- Alert Banner -->
            <c:if test="${not empty activeAlert}">
                <div class="dashboard-alert alert-${activeAlert.level}">
                    <div class="alert-icon-large">🚨</div>
                    <div class="alert-content">
                        <h3>${activeAlert.title}</h3>
                        <p>${activeAlert.message}</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/evacuation?alert=${activeAlert.id}" 
                       class="btn btn-${activeAlert.level}">
                        Voir l'évacuation →
                    </a>
                </div>
            </c:if>
            
            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card glass">
                    <div class="stat-header">
                        <span class="stat-icon icon-danger">🚨</span>
                        <span class="stat-trend ${alertsTrend > 0 ? 'up' : 'down'}">
                            ${alertsTrend > 0 ? '↑' : '↓'} ${Math.abs(alertsTrend)}%
                        </span>
                    </div>
                    <div class="stat-value">${activeAlertsCount}</div>
                    <div class="stat-label">Alertes actives</div>
                </div>
                
                <div class="stat-card glass">
                    <div class="stat-header">
                        <span class="stat-icon icon-warning">⚠️</span>
                        <span class="stat-trend ${incidentsTrend > 0 ? 'up' : 'down'}">
                            ${incidentsTrend > 0 ? '↑' : '↓'} ${Math.abs(incidentsTrend)}%
                        </span>
                    </div>
                    <div class="stat-value">${todayIncidentsCount}</div>
                    <div class="stat-label">Incidents aujourd'hui</div>
                </div>
                
                <div class="stat-card glass">
                    <div class="stat-header">
                        <span class="stat-icon icon-info">🛰️</span>
                    </div>
                    <div class="stat-value">${monitoredZonesCount}</div>
                    <div class="stat-label">Zones surveillées</div>
                </div>
                
                <div class="stat-card glass">
                    <div class="stat-header">
                        <span class="stat-icon icon-success">👥</span>
                    </div>
                    <div class="stat-value">${protectedUsersCount}</div>
                    <div class="stat-label">Utilisateurs protégés</div>
                </div>
            </div>
            
            <!-- Map & Activity Grid -->
            <div class="dashboard-grid">
                <!-- Live Map -->
                <div class="card card-large glass">
                    <div class="card-header">
                        <h3>🗺️ Carte temps réel</h3>
                        <div class="card-actions">
                            <select id="map-filter" class="select-sm">
                                <option value="all">Tous les risques</option>
                                <option value="flood">Inondations</option>
                                <option value="fire">Incendies</option>
                                <option value="cyclone">Cyclones</option>
                            </select>
                            <a href="${pageContext.request.contextPath}/map" class="btn btn-sm btn-outline">
                                Agrandir
                            </a>
                        </div>
                    </div>
                    <div id="dashboard-map" class="dashboard-map"></div>
                </div>
                
                <!-- Recent Alerts -->
                <div class="card glass">
                    <div class="card-header">
                        <h3>🚨 Alertes récentes</h3>
                        <a href="${pageContext.request.contextPath}/alerts" class="link-sm">
                            Voir tout →
                        </a>
                    </div>
                    <div class="alert-list">
                        <c:forEach items="${recentAlerts}" var="alert">
                            <div class="alert-item alert-${alert.level}">
                                <div class="alert-level-indicator"></div>
                                <div class="alert-info">
                                    <span class="alert-type-badge">${alert.type}</span>
                                    <h4>${alert.title}</h4>
                                    <span class="alert-time">
                                        <fmt:formatDate value="${alert.emittedAt}" pattern="HH:mm"/>
                                    </span>
                                </div>
                            </div>
                        </c:forEach>
                        
                        <c:if test="${empty recentAlerts}">
                            <div class="empty-state">
                                <span class="empty-icon">✅</span>
                                <p>Aucune alerte active</p>
                            </div>
                        </c:if>
                    </div>
                </div>
                
                <!-- Nearby Incidents -->
                <div class="card glass">
                    <div class="card-header">
                        <h3>📍 Signalements proches</h3>
                    </div>
                    <div class="incident-list">
                        <c:forEach items="${nearbyIncidents}" var="incident">
                            <div class="incident-item">
                                <div class="incident-icon">📍</div>
                                <div class="incident-info">
                                    <h4>${incident.title}</h4>
                                    <p>${incident.distance}km • ${incident.status}</p>
                                </div>
                                <span class="status-badge status-${incident.status}">
                                    ${incident.status}
                                </span>
                            </div>
                        </c:forEach>
                        
                        <c:if test="${empty nearbyIncidents}">
                            <div class="empty-state">
                                <span class="empty-icon">🛡️</span>
                                <p>Aucun incident signalé à proximité</p>
                            </div>
                        </c:if>
                    </div>
                </div>
                
                <!-- Weather Widget -->
                <div class="card glass">
                    <div class="card-header">
                        <h3>🌤️ Météo locale</h3>
                        <span class="location-tag">📍 ${userLocation}</span>
                    </div>
                    <div class="weather-widget">
                        <div class="weather-main">
                            <span class="weather-icon">${weatherIcon}</span>
                            <span class="weather-temp">${weatherTemp}°C</span>
                        </div>
                        <div class="weather-details">
                            <div class="weather-item">
                                <span>💧 Humidité</span>
                                <strong>${weatherHumidity}%</strong>
                            </div>
                            <div class="weather-item">
                                <span>💨 Vent</span>
                                <strong>${weatherWind} km/h</strong>
                            </div>
                            <div class="weather-item">
                                <span>🌧️ Précipitations</span>
                                <strong>${weatherRain}mm</strong>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
    
    <!-- WebSocket Status Toast -->
    <div id="ws-toast" class="toast hidden">
        <span class="toast-icon">⚡</span>
        <span class="toast-message">Connexion temps réel établie</span>
    </div>
    
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
    <script>
        // Initialize dashboard map
        const map = L.map('dashboard-map').setView([parseFloat('${userLat}') || -18.9078, parseFloat('${userLng}') || 47.5208], 10);
        
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors'
        }).addTo(map);
        
        // WebSocket connection
        const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
        const ws = new WebSocket(wsProtocol + '//' + window.location.host + '/ws');
        
        ws.onopen = () => {
            document.getElementById('ws-toast').classList.remove('hidden');
            setTimeout(() => {
                document.getElementById('ws-toast').classList.add('hidden');
            }, 3000);
        };
        
        ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            if (data.type === 'alert') {
                location.reload(); // Refresh to show new alert
            }
        };
    </script>
</body>
</html>
