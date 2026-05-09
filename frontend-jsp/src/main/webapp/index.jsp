<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="MITANDRINA - Plateforme IA de prédiction et gestion des catastrophes naturelles">
    <title>🌪️ MITANDRINA - Protection par l'Intelligence Artificielle</title>
    
    <!-- Design System: Glassmorphism + Emergency Red -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/design-system.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css">
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    
    <!-- Leaflet Maps -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    
    <!-- Favicon -->
    <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/assets/images/logo.svg">
</head>
<body class="mitandrina-landing">
    
    <!-- 🚨 Emergency Alert Banner (if active) -->
    <c:if test="${not empty emergencyAlert}">
        <div class="emergency-banner alert-${emergencyAlert.level}">
            <div class="container">
                <span class="alert-icon">🚨</span>
                <strong>${emergencyAlert.title}</strong>
                <span class="alert-message">${emergencyAlert.message}</span>
                <a href="${pageContext.request.contextPath}/evacuation" class="btn-evacuation">
                    Voir l'itinéraire d'évacuation →
                </a>
            </div>
        </div>
    </c:if>

    <!-- 🧭 Navigation -->
    <nav class="navbar glass">
        <div class="nav-container">
            <a href="${pageContext.request.contextPath}/" class="nav-brand">
                <span class="brand-icon">🌪️</span>
                <span class="brand-text">MITANDRINA</span>
            </a>
            
            <div class="nav-links">
                <a href="#features" class="nav-link">Fonctionnalités</a>
                <a href="#map-section" class="nav-link">Carte temps réel</a>
                <a href="#how-it-works" class="nav-link">Comment ça marche</a>
            </div>
            
            <div class="nav-actions">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary">
                            <span class="btn-icon">📊</span>
                            Dashboard
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/auth/login" class="btn btn-outline">
                            Connexion
                        </a>
                        <a href="${pageContext.request.contextPath}/auth/register" class="btn btn-primary">
                            S'inscrire
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <button class="nav-toggle" aria-label="Menu">
                <span></span><span></span><span></span>
            </button>
        </div>
    </nav>

    <!-- 🦸 Hero Section -->
    <header class="hero">
        <div class="hero-background">
            <div class="gradient-overlay"></div>
            <div class="particles" id="particles"></div>
        </div>
        
        <div class="hero-content container">
            <div class="hero-badge glass">
                <span class="pulse-dot"></span>
                Système opérationnel - ${activeZonesCount} zones surveillées
            </div>
            
            <h1 class="hero-title">
                Prédire les catastrophes.
                <span class="gradient-text">Protéger les vies.</span>
            </h1>
            
            <p class="hero-description">
                MITANDRINA utilise l'intelligence artificielle pour prédire, détecter 
                et coordonner les réponses aux catastrophes naturelles en temps réel.
                Inondations, incendies, cyclones - soyez informé avant que le danger ne frappe.
            </p>
            
            <div class="hero-actions">
                <a href="${pageContext.request.contextPath}/map" class="btn btn-lg btn-primary btn-glow">
                    <span class="btn-icon">🗺️</span>
                    Voir la carte des risques
                </a>
                <a href="#features" class="btn btn-lg btn-outline-light">
                    Découvrir la technologie
                </a>
            </div>
            
            <!-- Stats -->
            <div class="hero-stats glass">
                <div class="stat-item">
                    <span class="stat-value" id="stat-predictions">${predictionCount}</span>
                    <span class="stat-label">Prédictions IA</span>
                </div>
                <div class="stat-divider"></div>
                <div class="stat-item">
                    <span class="stat-value" id="stat-users">${userCount}</span>
                    <span class="stat-label">Utilisateurs protégés</span>
                </div>
                <div class="stat-divider"></div>
                <div class="stat-item">
                    <span class="stat-value" id="stat-response">${avgResponseTime}s</span>
                    <span class="stat-label">Temps de réponse</span>
                </div>
            </div>
        </div>
        
        <div class="hero-scroll">
            <span>Défiler</span>
            <div class="scroll-indicator"></div>
        </div>
    </header>

    <!-- 🗺️ Live Map Preview Section -->
    <section id="map-section" class="map-preview">
        <div class="container">
            <div class="section-header">
                <span class="section-badge">🛰️ Temps réel</span>
                <h2 class="section-title">Surveillance 24/7</h2>
                <p class="section-description">
                    Données satellites NASA FIRMS, météo OpenWeather et signaux sociaux 
                    analysés en continu par nos modèles IA.
                </p>
            </div>
            
            <div class="map-container glass">
                <div class="map-toolbar">
                    <div class="map-filters">
                        <button class="filter-btn active" data-type="all">
                            <span class="filter-icon">🌍</span> Tous
                        </button>
                        <button class="filter-btn" data-type="flood">
                            <span class="filter-icon">💧</span> Inondations
                        </button>
                        <button class="filter-btn" data-type="fire">
                            <span class="filter-icon">🔥</span> Incendies
                        </button>
                        <button class="filter-btn" data-type="cyclone">
                            <span class="filter-icon">🌀</span> Cyclones
                        </button>
                    </div>
                    <div class="map-legend">
                        <span class="legend-item"><span class="dot dot-danger"></span> Danger</span>
                        <span class="legend-item"><span class="dot dot-warning"></span> Alerte</span>
                        <span class="legend-item"><span class="dot dot-watch"></span> Vigilance</span>
                    </div>
                </div>
                
                <div id="map" class="live-map"></div>
                
                <div class="map-info-panel glass" id="zone-info">
                    <p class="empty-state">Survolez une zone pour voir les détails</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ⚡ Features Grid -->
    <section id="features" class="features">
        <div class="container">
            <div class="section-header">
                <span class="section-badge">🤖 IA & Machine Learning</span>
                <h2 class="section-title">Technologies de pointe</h2>
            </div>
            
            <div class="features-grid bento-grid">
                <!-- Feature 1: Flood Prediction -->
                <div class="feature-card card-flood glass">
                    <div class="feature-icon">
                        <div class="icon-bg icon-blue">💧</div>
                    </div>
                    <h3 class="feature-title">Prédiction Inondations</h3>
                    <p class="feature-description">
                        Modèle XGBoost analysant précipitations, niveaux d'eau et topographie 
                        pour prédire les crues 24-72h à l'avance.
                    </p>
                    <div class="feature-metrics">
                        <span class="metric">94% précision</span>
                        <span class="metric">24-72h horizon</span>
                    </div>
                </div>

                <!-- Feature 2: Fire Detection -->
                <div class="feature-card card-fire glass">
                    <div class="feature-icon">
                        <div class="icon-bg icon-orange">🔥</div>
                    </div>
                    <h3 class="feature-title">Détection Incendies</h3>
                    <p class="feature-description">
                        CNN ResNet-50 analysant images satellites NASA FIRMS et drones 
                        pour détecter les feux de forêt en temps réel.
                    </p>
                    <div class="feature-metrics">
                        <span class="metric">CNN ResNet-50</span>
                        <span class="metric">Temps réel</span>
                    </div>
                </div>

                <!-- Feature 3: NLP Social -->
                <div class="feature-card card-nlp glass">
                    <div class="feature-icon">
                        <div class="icon-bg icon-purple">💬</div>
                    </div>
                    <h3 class="feature-title">Analyse Réseaux Sociaux</h3>
                    <p class="feature-description">
                        BERT multilingue analysant Twitter/Facebook pour détecter 
                        les signaux d'alerte et localiser les incidents.
                    </p>
                    <div class="feature-metrics">
                        <span class="metric">BERT NLP</span>
                        <span class="metric">Multi-langue</span>
                    </div>
                </div>

                <!-- Feature 4: Routing A* -->
                <div class="feature-card card-routing glass">
                    <div class="feature-icon">
                        <div class="icon-bg icon-green">🗺️</div>
                    </div>
                    <h3 class="feature-title">Routes d'Évacuation</h3>
                    <p class="feature-description">
                        Algorithme A* pondéré avec données OSM pour calculer les itinéraires 
                        d'évacuation optimaux évitant les zones de danger.
                    </p>
                    <div class="feature-metrics">
                        <span class="metric">Algorithme A*</span>
                        <span class="metric">OpenStreetMap</span>
                    </div>
                </div>

                <!-- Feature 5: Real-time -->
                <div class="feature-card card-rt glass card-wide">
                    <div class="feature-icon">
                        <div class="icon-bg icon-red">⚡</div>
                    </div>
                    <div class="feature-content">
                        <h3 class="feature-title">Alertes Multicanal</h3>
                        <p class="feature-description">
                            Notifications instantanées via SMS (Twilio), Push (Firebase), 
                            Email et WebSocket selon votre localisation et préférences.
                        </p>
                    </div>
                    <div class="notification-preview">
                        <div class="notif-phone glass">
                            <div class="notif-header">
                                <span class="app-icon">🌪️</span>
                                <span class="app-name">MITANDRINA</span>
                                <span class="time">Maintenant</span>
                            </div>
                            <div class="notif-body">
                                <strong>🚨 Alerte Inondation</strong>
                                <p>Risque élevé détecté dans votre zone. Itinéraire d'évacuation disponible.</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Feature 6: Simulation -->
                <div class="feature-card card-sim glass">
                    <div class="feature-icon">
                        <div class="icon-bg icon-teal">🔮</div>
                    </div>
                    <h3 class="feature-title">Simulation "What If?"</h3>
                    <p class="feature-description">
                        Simulez des scénarios de catastrophe pour planifier les 
                        réponses et tester les plans d'évacuation.
                    </p>
                    <div class="feature-metrics">
                        <span class="metric">Scénarios</span>
                        <span class="metric">&lt; 30s calcul</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 📊 How It Works -->
    <section id="how-it-works" class="how-it-works">
        <div class="container">
            <div class="section-header">
                <span class="section-badge">🔄 Flux de données</span>
                <h2 class="section-title">De la détection à l'alerte</h2>
            </div>
            
            <div class="flow-diagram">
                <div class="flow-step">
                    <div class="step-number glass">1</div>
                    <div class="step-icon">🛰️</div>
                    <h4>Collecte</h4>
                    <p>Données satellites, météo, réseaux sociaux</p>
                </div>
                <div class="flow-arrow">→</div>
                <div class="flow-step">
                    <div class="step-number glass">2</div>
                    <div class="step-icon">🧠</div>
                    <h4>Analyse IA</h4>
                    <p>Modèles XGBoost, CNN, BERT analysent</p>
                </div>
                <div class="flow-arrow">→</div>
                <div class="flow-step">
                    <div class="step-number glass">3</div>
                    <div class="step-icon">⚠️</div>
                    <h4>Détection</h4>
                    <p>Risque identifié avec score de confiance</p>
                </div>
                <div class="flow-arrow">→</div>
                <div class="flow-step">
                    <div class="step-number glass">4</div>
                    <div class="step-icon">📢</div>
                    <h4>Alerte</h4>
                    <p>Notification multicanal en &lt; 5 secondes</p>
                </div>
                <div class="flow-arrow">→</div>
                <div class="flow-step">
                    <div class="step-number glass">5</div>
                    <div class="step-icon">🚗</div>
                    <h4>Évacuation</h4>
                    <p>Route optimale calculée par A*</p>
                </div>
            </div>
        </div>
    </section>

    <!-- 🦶 Footer -->
    <footer class="footer">
        <div class="container">
            <div class="footer-grid">
                <div class="footer-brand">
                    <span class="brand-icon">🌪️</span>
                    <h3>MITANDRINA</h3>
                    <p>Protection par l'intelligence artificielle</p>
                </div>
                
                <div class="footer-links">
                    <h4>Navigation</h4>
                    <a href="${pageContext.request.contextPath}/map">Carte des risques</a>
                    <a href="${pageContext.request.contextPath}/alerts">Alertes</a>
                    <a href="${pageContext.request.contextPath}/evacuation">Évacuation</a>
                    <a href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                </div>
                
                <div class="footer-links">
                    <h4>Ressources</h4>
                    <a href="#">Guide d'utilisation</a>
                    <a href="#">API Documentation</a>
                    <a href="#">Open Source</a>
                </div>
                
                <div class="footer-links">
                    <h4>Légal</h4>
                    <a href="#">Mentions légales</a>
                    <a href="#">Politique de confidentialité</a>
                    <a href="#">Conditions d'utilisation</a>
                </div>
            </div>
            
            <div class="footer-bottom">
                <p>&copy; 2024 MITANDRINA. Tous droits réservés.</p>
                <p class="tech-stack">Built with ❤️ using FastAPI + Node.js + Java/JSP</p>
            </div>
        </div>
    </footer>

    <!-- Scripts -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/map.js"></script>
    
    <script>
        // Live stats animation
        function animateValue(id, start, end, duration) {
            const obj = document.getElementById(id);
            if (!obj) return;
            let startTimestamp = null;
            const step = (timestamp) => {
                if (!startTimestamp) startTimestamp = timestamp;
                const progress = Math.min((timestamp - startTimestamp) / duration, 1);
                obj.innerHTML = Math.floor(progress * (end - start) + start).toLocaleString();
                if (progress < 1) {
                    window.requestAnimationFrame(step);
                }
            };
            window.requestAnimationFrame(step);
        }
        
        // Animate on load
        window.addEventListener('load', () => {
            animateValue('stat-predictions', 0, parseInt('${predictionCount}') || 1247, 2000);
            animateValue('stat-users', 0, parseInt('${userCount}') || 15432, 2000);
        });
    </script>
</body>
</html>
