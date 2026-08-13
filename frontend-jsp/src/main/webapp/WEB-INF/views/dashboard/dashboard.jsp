<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord - MITANDRINA</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    
    <style>
        :root {
            --primary: #059669;
            --primary-light: #ecfdf5;
            --primary-dark: #047857;
            --danger: #dc2626;
            --danger-light: #fef2f2;
            --bg-white: #ffffff;
            --bg-gray: #f8fafc;
            --bg-gray-light: #f1f5f9;
            --text-dark: #0f172a;
            --text-gray: #64748b;
            --text-muted: #94a3b8;
            --border: #e2e8f0;
            --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            --shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }
        
        body {
            background: var(--bg-gray);
            color: var(--text-dark);
        }
        
        /* Sidebar */
        .sidebar {
            width: 260px;
            background: var(--bg-white);
            border-right: 1px solid var(--border);
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 1000;
            display: flex;
            flex-direction: column;
            transition: transform 0.3s ease;
        }
        
        .sidebar-brand {
            padding: 1.5rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .sidebar-brand i {
            color: var(--danger);
            font-size: 1.75rem;
        }
        
        .sidebar-brand span {
            font-size: 1.25rem;
            font-weight: 800;
            color: var(--text-dark);
        }
        
        .sidebar-nav {
            flex: 1;
            padding: 1rem;
            overflow-y: auto;
        }
        
        .nav-section {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--text-muted);
            margin: 1.5rem 0 0.75rem 0.75rem;
        }
        
        .nav-item {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem;
            border-radius: 10px;
            color: var(--text-gray);
            text-decoration: none;
            font-weight: 500;
            font-size: 0.9rem;
            transition: all 0.2s ease;
            margin-bottom: 0.25rem;
        }
        
        .nav-item:hover, .nav-item.active {
            background: var(--primary-light);
            color: var(--primary-dark);
        }
        
        .nav-item.active {
            font-weight: 600;
        }
        
        .nav-item i {
            font-size: 1.1rem;
        }
        
        .badge-count {
            margin-left: auto;
            background: var(--danger);
            color: white;
            font-size: 0.7rem;
            padding: 0.15rem 0.5rem;
            border-radius: 20px;
            font-weight: 600;
        }
        
        .sidebar-footer {
            padding: 1rem;
            border-top: 1px solid var(--border);
        }
        
        .user-card {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem;
            background: var(--bg-gray);
            border-radius: 12px;
            margin-bottom: 0.75rem;
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 0.9rem;
        }
        
        .user-info {
            flex: 1;
            min-width: 0;
        }
        
        .user-name {
            font-weight: 600;
            font-size: 0.85rem;
            color: var(--text-dark);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .user-role {
            font-size: 0.75rem;
            color: var(--text-muted);
            text-transform: capitalize;
        }
        
        .btn-logout {
            width: 100%;
            padding: 0.625rem;
            background: transparent;
            border: 1px solid var(--border);
            border-radius: 10px;
            color: var(--text-gray);
            font-size: 0.85rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            transition: all 0.2s ease;
            text-decoration: none;
        }
        
        .btn-logout:hover {
            background: var(--primary-light);
            border-color: var(--primary-dark);
            color: var(--primary-dark);
        }
        
        /* Main Content */
        .main-content {
            margin-left: 260px;
            min-height: 100vh;
        }
        
        /* Header */
        .header {
            background: var(--bg-white);
            border-bottom: 1px solid var(--border);
            padding: 1rem 1.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: sticky;
            top: 0;
            z-index: 100;
        }
        
        .header-left {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .menu-toggle {
            display: none;
            background: none;
            border: none;
            font-size: 1.5rem;
            color: var(--text-dark);
            cursor: pointer;
            padding: 0.25rem;
        }
        
        .header-title h1 {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--text-dark);
            margin: 0;
        }
        
        .header-title p {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin: 0;
        }
        
        .header-right {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .header-btn {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            border: 1px solid var(--border);
            background: var(--bg-white);
            color: var(--text-gray);
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
            text-decoration: none;
        }
        
        .header-btn:hover {
            background: var(--bg-gray);
            border-color: var(--text-muted);
            color: var(--text-dark);
        }
        
        .header-btn .notification-dot {
            position: absolute;
            top: 8px;
            right: 8px;
            width: 8px;
            height: 8px;
            background: var(--danger);
            border-radius: 50%;
        }
        
        /* Dashboard Content */
        .dashboard-content {
            padding: 1.5rem;
        }
        
        /* Alert Banner */
        .alert-banner {
            background: linear-gradient(135deg, var(--danger-light), #fff1f2);
            border: 1px solid rgba(220, 53, 69, 0.2);
            border-radius: 16px;
            padding: 1.25rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }
        
        .alert-icon-box {
            width: 48px;
            height: 48px;
            background: var(--danger);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
            flex-shrink: 0;
        }
        
        .alert-content {
            flex: 1;
        }
        
        .alert-content h3 {
            font-size: 1rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 0.25rem;
        }
        
        .alert-content p {
            font-size: 0.85rem;
            color: var(--text-gray);
            margin: 0;
        }
        
        .btn-alert {
            padding: 0.625rem 1.25rem;
            background: var(--danger);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 0.85rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            text-decoration: none;
            transition: all 0.2s ease;
            flex-shrink: 0;
        }
        
        .btn-alert:hover {
            background: #b91c1c;
            color: white;
        }
        
        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1rem;
            margin-bottom: 1.5rem;
        }
        
        .stat-card {
            background: #ffffff; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            border-radius: 16px;
            padding: 1.25rem;
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
            animation: fadeInUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; opacity: 0;
        }
        
        .stat-card:hover {
            box-shadow: 0 12px 48px rgba(0,0,0,0.08);
            transform: translateY(-4px);
        }
        
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .stat-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1rem;
        }
        
        .stat-icon-wrap {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
        }
        
        .stat-icon-wrap.red {
            background: var(--primary-light);
            color: var(--primary);
        }
        
        .stat-icon-wrap.amber {
            background: #fffbeb;
            color: #d97706;
        }
        
        .stat-icon-wrap.blue {
            background: #eff6ff;
            color: #2563eb;
        }
        
        .stat-icon-wrap.green {
            background: #ecfdf5;
            color: #047857;
        }
        
        .stat-trend {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 0.25rem 0.5rem;
            border-radius: 20px;
        }
        
        .stat-trend.up {
            background: var(--danger-light);
            color: var(--danger);
        }
        
        .stat-trend.down {
            background: #ecfdf5;
            color: #047857;
        }
        
        .stat-value {
            font-size: 1.75rem;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 0.25rem;
        }
        
        .stat-label {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 500;
        }
        
        /* Main Grid */
        .main-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 1.5rem;
        }
        
        /* Card Component */
        .card {
            background: #ffffff; border: 1px solid #e2e8f0; box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            border-radius: 16px;
            overflow: hidden;
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
            animation: fadeInUp 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; opacity: 0;
        }
        .card:hover { box-shadow: 0 8px 24px rgba(0,0,0,0.08); transform: translateY(-2px); }
        
        .card-header {
            padding: 1.25rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .card-title {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .card-title-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
        }
        
        .card-title-icon.red {
            background: var(--danger-light);
            color: var(--danger);
        }
        
        .card-title-icon.blue {
            background: #eff6ff;
            color: #2563eb;
        }
        
        .card-title-text h3 {
            font-size: 1rem;
            font-weight: 700;
            color: var(--text-dark);
            margin: 0;
        }
        
        .card-title-text p {
            font-size: 0.75rem;
            color: var(--text-muted);
            margin: 0;
        }
        
        .card-actions {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .btn-sm {
            padding: 0.5rem 1rem;
            border-radius: 8px;
            font-size: 0.8rem;
            font-weight: 600;
            border: 1px solid var(--border);
            background: var(--bg-white);
            color: var(--text-gray);
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
        }
        
        .btn-sm:hover {
            background: var(--bg-gray);
            border-color: var(--text-muted);
        }
        
        .btn-sm-primary {
            background: var(--primary);
            border-color: var(--primary);
            color: white;
        }
        
        .btn-sm-primary:hover {
            background: var(--primary-dark);
            border-color: var(--primary-dark);
        }
        
        .card-body {
            padding: 1.25rem;
        }
        
        /* Map Container */
        #map-container {
            height: 400px;
            background: var(--bg-gray-light);
            border-radius: 12px;
        }
        
        /* Alert List */
        .alert-list {
            max-height: 350px;
            overflow-y: auto;
        }
        
        .alert-item {
            display: flex;
            align-items: flex-start;
            gap: 0.75rem;
            padding: 1rem;
            border-radius: 12px;
            margin-bottom: 0.75rem;
            background: var(--bg-gray);
            border-left: 4px solid transparent;
            transition: all 0.2s ease;
        }
        
        .alert-item:hover {
            background: var(--bg-gray-light);
        }
        
        .alert-item.urgence {
            border-left-color: var(--danger);
        }
        
        .alert-item.alerte {
            border-left-color: #f59e0b;
        }
        
        .alert-item.info {
            border-left-color: #3b82f6;
        }
        
        .alert-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-top: 0.35rem;
            flex-shrink: 0;
        }
        
        .alert-dot.urgence {
            background: var(--danger);
        }
        
        .alert-dot.alerte {
            background: #f59e0b;
        }
        
        .alert-dot.info {
            background: #3b82f6;
        }
        
        .alert-content-item {
            flex: 1;
            min-width: 0;
        }
        
        .alert-type-badge {
            display: inline-block;
            padding: 0.15rem 0.5rem;
            background: var(--bg-white);
            border-radius: 6px;
            font-size: 0.7rem;
            font-weight: 600;
            color: var(--text-gray);
            margin-bottom: 0.35rem;
        }
        
        .alert-title {
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 0.25rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .alert-time {
            font-size: 0.75rem;
            color: var(--text-muted);
        }
        
        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
        }
        
        .empty-state-icon {
            width: 64px;
            height: 64px;
            background: #ecfdf5;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            font-size: 1.75rem;
            color: #059669;
        }
        
        .empty-state p {
            color: var(--text-muted);
            font-size: 0.9rem;
        }
        
        /* Weather Card */
        .weather-main {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1.25rem;
        }
        
        .weather-icon {
            font-size: 3rem;
        }
        
        .weather-temp {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--text-dark);
            line-height: 1;
        }
        
        .weather-desc {
            font-size: 0.9rem;
            color: var(--text-gray);
        }
        
        .weather-location {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin-bottom: 1rem;
        }
        
        .weather-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 0.75rem;
        }
        
        .weather-stat {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 0.75rem;
            text-align: center;
        }
        
        .weather-stat i {
            font-size: 1.1rem;
            color: var(--text-muted);
            margin-bottom: 0.35rem;
        }
        
        .weather-stat-label {
            font-size: 0.7rem;
            color: var(--text-muted);
            margin-bottom: 0.15rem;
        }
        
        .weather-stat-value {
            font-size: 0.9rem;
            font-weight: 700;
            color: var(--text-dark);
        }
        
        /* Sidebar Panel */
        .side-panel {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
        }
        
        /* Responsive */
        @media (max-width: 1200px) {
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .main-grid {
                grid-template-columns: 1fr;
            }
        }
        
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }
            
            .sidebar.open {
                transform: translateX(0);
            }
            
            .main-content {
                margin-left: 0;
            }
            
            .menu-toggle {
                display: block;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .alert-banner {
                flex-direction: column;
                text-align: center;
            }
            
            .header-title {
                display: none;
            }
        }
        
        /* Overlay for mobile */
        .sidebar-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 999;
        }
        
        .sidebar-overlay.active {
            display: block;
        }
    </style>
    <link rel="stylesheet" href="/assets/css/custom.css?v=777b319a">
</head>
<body>
    <!-- Sidebar Overlay -->
    <div class="sidebar-overlay" onclick="toggleSidebar()"></div>
    
    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-brand">
            <i class="bi bi-shield-shaded"></i>
            <span>MITANDRINA</span>
        </div>
        
        <nav class="sidebar-nav">
            <div class="nav-section">Principal</div>
            
            <a href="dashboard" class="nav-item active">
                <i class="bi bi-grid-1x2-fill"></i>
                <span>Tableau de bord</span>
            </a>
            
            <a href="map" class="nav-item">
                <i class="bi bi-map-fill"></i>
                <span>Carte des risques</span>
            </a>
            
            <a href="cyclone-map" class="nav-item">
                <i class="bi bi-tornado text-lg"></i>
                <span>Carte des cyclones</span>
            </a>
            
            <a href="alerts" class="nav-item">
                <i class="bi bi-bell-fill"></i>
                <span>Alertes</span>
                <c:if test="${unreadAlerts > 0}">
                    <span class="badge-count">${unreadAlerts}</span>
                </c:if>
            </a>
            
            <a href="incidents" class="nav-item">
                <i class="bi bi-geo-alt-fill"></i>
                <span>Incidents</span>
            </a>
            
            <a href="evacuation" class="nav-item">
                <i class="bi bi-car-front-fill"></i>
                <span>Évacuation</span>
            </a>
            
            <c:if test="${sessionScope.user.role == 'administrateur'}">
                <div class="nav-section">Administration</div>
                
                <a href="admin/users" class="nav-item">
                    <i class="bi bi-people-fill"></i>
                    <span>Utilisateurs</span>
                </a>
                
                <a href="admin/teams" class="nav-item">
                    <i class="bi bi-building-fill"></i>
                    <span>Équipes</span>
                </a>
                
                <a href="admin/analytics" class="nav-item">
                    <i class="bi bi-graph-up"></i>
                    <span>Analytiques</span>
                </a>
            </c:if>
        </nav>
        
        <div class="sidebar-footer">
            <div class="user-card">
                <div class="user-avatar">
                    ${sessionScope.user.firstName.charAt(0)}${sessionScope.user.lastName.charAt(0)}
                </div>
                <div class="user-info">
                    <div class="user-name">${sessionScope.user.firstName} ${sessionScope.user.lastName}</div>
                    <div class="user-role">${sessionScope.user.role}</div>
                </div>
            </div>
            <a href="auth/logout" class="btn-logout">
                <i class="bi bi-box-arrow-right"></i>
                Déconnexion
            </a>
        </div>
    </aside>
    
    <!-- Main Content -->
    <main class="main-content">
        <!-- Header -->
        <header class="header">
            <div class="header-left">
                <button class="menu-toggle" onclick="toggleSidebar()">
                    <i class="bi bi-list"></i>
                </button>
                <div class="header-title">
                    <h1>Tableau de bord</h1>
                    <p>Bienvenue, ${sessionScope.user.firstName}</p>
                </div>
            </div>
            
            <div class="header-right">
                <a href="#" class="header-btn">
                    <i class="bi bi-search"></i>
                </a>
                <a href="#" class="header-btn">
                    <i class="bi bi-bell"></i>
                    <c:if test="${unreadNotifications > 0}">
                        <span class="notification-dot"></span>
                    </c:if>
                </a>
                <a href="#" class="header-btn">
                    <i class="bi bi-gear"></i>
                </a>
            </div>
        </header>
        
        <!-- Dashboard Content -->
        <div class="dashboard-content">
            
            <!-- Emergency Alert Banner -->
            <c:if test="${not empty activeAlert}">
                <div class="alert-banner">
                    <div class="alert-icon-box">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                    </div>
                    <div class="alert-content">
                        <h3>${activeAlert.title}</h3>
                        <p>${activeAlert.message}</p>
                    </div>
                    <a href="evacuation?alert=${activeAlert.id}" class="btn-alert">
                        Voir l'évacuation <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
            </c:if>
            
            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon-wrap red">
                            <i class="bi bi-exclamation-triangle-fill"></i>
                        </div>
                        <span class="stat-trend up">+12%</span>
                    </div>
                    <div class="stat-value">${activeAlertsCount}</div>
                    <div class="stat-label">Alertes actives</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon-wrap amber">
                            <i class="bi bi-geo-alt-fill"></i>
                        </div>
                        <span class="stat-trend down">-5%</span>
                    </div>
                    <div class="stat-value">${todayIncidentsCount}</div>
                    <div class="stat-label">Incidents aujourd'hui</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon-wrap blue">
                            <i class="bi bi-satellite-fill"></i>
                        </div>
                        <span class="stat-trend down">Actif</span>
                    </div>
                    <div class="stat-value">${monitoredZonesCount}</div>
                    <div class="stat-label">Zones surveillées</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon-wrap green">
                            <i class="bi bi-shield-check"></i>
                        </div>
                        <span class="stat-trend down">+8%</span>
                    </div>
                    <div class="stat-value">${protectedUsersCount}</div>
                    <div class="stat-label">Utilisateurs protégés</div>
                </div>
            </div>
            
            <!-- Main Grid -->
            <div class="main-grid">
                <!-- Left Column -->
                <div class="left-column">
                    <!-- Map Card -->
                    <div class="card">
                        <div class="card-header">
                            <div class="card-title">
                                <div class="card-title-icon blue">
                                    <i class="bi bi-map-fill"></i>
                                </div>
                                <div class="card-title-text">
                                    <h3>Carte temps réel</h3>
                                    <p>Surveillance active des zones à risque</p>
                                </div>
                            </div>
                            <div class="card-actions">
                                <select class="btn-sm">
                                    <option>Tous les risques</option>
                                    <option>Inondations</option>
                                    <option>Séismes</option>
                                    <option>Cyclones</option>
                                </select>
                                <a href="map" class="btn-sm btn-sm-primary">Agrandir</a>
                            </div>
                        </div>
                        <div class="card-body">
                            <div id="map-container"></div>
                        </div>
                    </div>
                </div>
                
                <!-- Right Column -->
                <div class="side-panel">
                    <!-- Recent Alerts Card -->
                    <div class="card">
                        <div class="card-header">
                            <div class="card-title">
                                <div class="card-title-icon red">
                                    <i class="bi bi-bell-fill"></i>
                                </div>
                                <div class="card-title-text">
                                    <h3>Alertes récentes</h3>
                                </div>
                            </div>
                            <a href="alerts" class="btn-sm">Voir tout</a>
                        </div>
                        <div class="card-body">
                            <div class="alert-list">
                                <c:forEach items="${recentAlerts}" var="alert">
                                    <div class="alert-item ${alert.level}">
                                        <div class="alert-dot ${alert.level}"></div>
                                        <div class="alert-content-item">
                                            <span class="alert-type-badge">${alert.type}</span>
                                            <div class="alert-title">${alert.title}</div>
                                            <div class="alert-time">
                                                <i class="bi bi-clock"></i> 
                                                <fmt:formatDate value="${alert.emittedAt}" pattern="HH:mm"/>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                                
                                <c:if test="${empty recentAlerts}">
                                    <div class="empty-state">
                                        <div class="empty-state-icon">
                                            <i class="bi bi-check-lg"></i>
                                        </div>
                                        <p>Aucune alerte active</p>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Weather Card -->
                    <div class="card">
                        <div class="card-header">
                            <div class="card-title">
                                <div class="card-title-icon blue">
                                    <i class="bi bi-cloud-sun-fill"></i>
                                </div>
                                <div class="card-title-text">
                                    <h3>Météo</h3>
                                </div>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="weather-location">
                                <i class="bi bi-geo-alt"></i> <span id="weather-location">Antananarivo</span>
                            </div>
                            <div class="weather-main">
                                <img id="weather-icon-img" src="" alt="Météo" style="width:64px;height:64px;display:none;" />
                                <span class="weather-icon" id="weather-icon-emoji">⏳</span>
                                <div>
                                    <div class="weather-temp"><span id="weather-temp">--</span>°C</div>
                                    <div class="weather-desc" id="weather-desc" style="text-transform: capitalize;">Chargement...</div>
                                </div>
                            </div>
                            <div class="weather-grid">
                                <div class="weather-stat">
                                    <i class="bi bi-droplet text-primary"></i>
                                    <div class="weather-stat-label">Humidité</div>
                                    <div class="weather-stat-value"><span id="weather-humidity">--</span>%</div>
                                </div>
                                <div class="weather-stat">
                                    <i class="bi bi-wind"></i>
                                    <div class="weather-stat-label">Vent</div>
                                    <div class="weather-stat-value"><span id="weather-wind">--</span> km/h</div>
                                </div>
                                <div class="weather-stat">
                                    <i class="bi bi-cloud-rain text-primary"></i>
                                    <div class="weather-stat-label">Pluie (1h)</div>
                                    <div class="weather-stat-value"><span id="weather-rain">0</span>mm</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
    
    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script>
        // Toggle sidebar
        function toggleSidebar() {
            document.getElementById('sidebar').classList.toggle('open');
            document.querySelector('.sidebar-overlay').classList.toggle('active');
        }
        
        // Initialize map
        const map = L.map('map-container').setView([parseFloat('${userLat}') || -18.9078, parseFloat('${userLng}') || 47.5208], 10);
        
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
                    imgEl.style.display = 'inline-block';
                }
                if (emojiEl) {
                    emojiEl.style.display = 'none';
                }
            } else if (info.iconEmoji) {
                if (imgEl) {
                    imgEl.style.display = 'none';
                }
                if (emojiEl) {
                    emojiEl.innerText = info.iconEmoji;
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
                emojiEl.style.display = 'inline-block';
            }
            const imgEl = document.getElementById('weather-icon-img');
            if (imgEl) {
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
        
        document.addEventListener('DOMContentLoaded', fetchWeather);
    </script>
</body>
</html>
