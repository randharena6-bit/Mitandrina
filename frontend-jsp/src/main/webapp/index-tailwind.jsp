<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>

<%-- Page Configuration --%>
<c:set var="pageTitle" value="MITANDRINA - Protection par l'IA" />
<c:set var="pageDescription" value="Plateforme IA de prédiction, détection et coordination des catastrophes naturelles" />

<%-- Use Base Layout --%>
<jsp:include page="/WEB-INF/views/layout/base-tailwind.jsp">
    <jsp:attribute name="extraHead">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing-tailwind.css">
    </jsp:attribute>
    
    <jsp:attribute name="emergencyBanner">
        <c:if test="${not empty emergencyAlert}">
            <div class="fixed top-0 left-0 right-0 z-[60] animate-slide-down">
                <div class="${emergencyAlert.level == 'urgence' ? 'bg-gradient-to-r from-danger-600 to-danger-700' : 'bg-gradient-to-r from-warning-500 to-warning-600'} 
                            text-white py-3 px-4">
                    <div class="container mx-auto flex items-center justify-center gap-4 flex-wrap">
                        <span class="text-xl">🚨</span>
                        <strong class="font-semibold">${emergencyAlert.title}</strong>
                        <span class="text-white/90">${emergencyAlert.message}</span>
                        <a href="${pageContext.request.contextPath}/evacuation" 
                           class="bg-white text-danger-700 px-4 py-2 rounded-lg font-semibold text-sm hover:scale-105 transition-transform shadow-lg">
                            Voir l'itinéraire d'évacuation →
                        </a>
                    </div>
                </div>
            </div>
        </c:if>
    </jsp:attribute>
    
    <jsp:attribute name="content">
        
        <%-- Hero Section --%>
        <section class="relative min-h-screen flex items-center justify-center overflow-hidden">
            <%-- Background Effects --%>
            <div class="absolute inset-0 z-0">
                <div class="absolute inset-0 bg-gradient-to-br from-dark-900 via-dark-800 to-dark-900"></div>
                
                <%-- Animated Gradient Spheres --%>
                <div class="absolute -top-40 -right-40 w-96 h-96 bg-danger-600/30 rounded-full blur-[100px] animate-float"></div>
                <div class="absolute -bottom-20 -left-20 w-72 h-72 bg-info-500/20 rounded-full blur-[100px] animate-float animation-delay-2000"></div>
                <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-warning-500/10 rounded-full blur-[120px] animate-float animation-delay-4000"></div>
                
                <%-- Grid Pattern --%>
                <div class="absolute inset-0 opacity-20" 
                     style="background-image: linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px); background-size: 50px 50px;">
                </div>
            </div>
            
            <%-- Hero Content --%>
            <div class="container mx-auto px-4 relative z-10 text-center pt-20">
                <%-- Badge --%>
                <div class="inline-flex items-center gap-2 glass px-4 py-2 rounded-full mb-8 animate-fade-in-up">
                    <span class="relative flex h-2 w-2">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-success-500 opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-2 w-2 bg-success-500"></span>
                    </span>
                    <span class="text-sm text-gray-300">Système opérationnel • ${activeZonesCount} zones surveillées</span>
                </div>
                
                <%-- Title --%>
                <h1 class="text-5xl md:text-7xl font-extrabold mb-6 leading-tight">
                    <span class="text-white">Prédire les catastrophes.</span><br>
                    <span class="gradient-text">Protéger les vies.</span>
                </h1>
                
                <%-- Description --%>
                <p class="text-xl text-gray-400 max-w-3xl mx-auto mb-10 leading-relaxed">
                    MITANDRINA utilise l'intelligence artificielle pour prédire, détecter 
                    et coordonner les réponses aux catastrophes naturelles en temps réel.
                </p>
                
                <%-- CTA Buttons --%>
                <div class="flex flex-col sm:flex-row items-center justify-center gap-4 mb-16">
                    <a href="${pageContext.request.contextPath}/map" 
                       class="btn-emergency text-lg px-8 py-4 flex items-center gap-2 animate-pulse-slow">
                        <i class="bi bi-map-fill"></i>
                        Voir la carte des risques
                    </a>
                    <a href="#features" 
                       class="px-8 py-4 rounded-lg border border-white/20 text-white font-semibold 
                              hover:bg-white/10 transition-all duration-300 backdrop-blur-sm">
                        Découvrir la technologie
                    </a>
                </div>
                
                <%-- Stats --%>
                <div class="glass rounded-2xl p-6 max-w-3xl mx-auto inline-block">
                    <div class="grid grid-cols-3 gap-8 md:gap-16">
                        <div class="text-center">
                            <div class="text-3xl md:text-4xl font-bold text-white mb-1" id="stat-predictions">
                                ${predictionCount}
                            </div>
                            <div class="text-sm text-gray-400">Prédictions IA</div>
                        </div>
                        <div class="text-center border-x border-white/10">
                            <div class="text-3xl md:text-4xl font-bold text-white mb-1" id="stat-users">
                                ${userCount}
                            </div>
                            <div class="text-sm text-gray-400">Utilisateurs protégés</div>
                        </div>
                        <div class="text-center">
                            <div class="text-3xl md:text-4xl font-bold text-white mb-1">${avgResponseTime}s</div>
                            <div class="text-sm text-gray-400">Temps de réponse</div>
                        </div>
                    </div>
                </div>
            </div>
            
            <%-- Scroll Indicator --%>
            <div class="absolute bottom-8 left-1/2 transform -translate-x-1/2 text-center z-10">
                <span class="text-xs text-gray-500 uppercase tracking-wider">Défiler</span>
                <div class="mt-2 w-6 h-10 border-2 border-gray-500 rounded-full mx-auto relative">
                    <div class="w-1.5 h-3 bg-gray-400 rounded-full absolute top-2 left-1/2 transform -translate-x-1/2 animate-bounce"></div>
                </div>
            </div>
        </section>

        <%-- Live Map Section --%>
        <section id="map-section" class="py-20 relative">
            <div class="container mx-auto px-4">
                <%-- Section Header --%>
                <div class="text-center mb-12">
                    <span class="inline-block glass px-4 py-2 rounded-full text-sm text-gray-300 mb-4">
                        <i class="bi bi-satellite me-2"></i>Temps réel
                    </span>
                    <h2 class="text-4xl md:text-5xl font-bold text-white mb-4">Surveillance 24/7</h2>
                    <p class="text-gray-400 max-w-2xl mx-auto text-lg">
                        Données satellites NASA FIRMS, météo OpenWeather et signaux sociaux 
                        analysés en continu par nos modèles IA.
                    </p>
                </div>
                
                <%-- Map Container --%>
                <div class="glass rounded-2xl overflow-hidden">
                    <%-- Map Toolbar --%>
                    <div class="flex flex-wrap items-center justify-between p-4 border-b border-white/10 gap-4">
                        <%-- Filters --%>
                        <div class="flex flex-wrap gap-2">
                            <button class="map-filter-btn active px-4 py-2 rounded-lg text-sm font-medium 
                                         bg-danger-600 text-white transition-all" data-type="all">
                                <i class="bi bi-globe me-1"></i> Tous
                            </button>
                            <button class="map-filter-btn px-4 py-2 rounded-lg text-sm font-medium 
                                         bg-white/5 text-gray-300 hover:bg-white/10 transition-all" data-type="flood">
                                <i class="bi bi-droplet me-1"></i> Inondations
                            </button>
                            <button class="map-filter-btn px-4 py-2 rounded-lg text-sm font-medium 
                                         bg-white/5 text-gray-300 hover:bg-white/10 transition-all" data-type="fire">
                                <i class="bi bi-fire me-1"></i> Incendies
                            </button>
                            <button class="map-filter-btn px-4 py-2 rounded-lg text-sm font-medium 
                                         bg-white/5 text-gray-300 hover:bg-white/10 transition-all" data-type="cyclone">
                                <i class="bi bi-hurricane me-1"></i> Cyclones
                            </button>
                        </div>
                        
                        <%-- Legend --%>
                        <div class="flex items-center gap-4 text-sm">
                            <span class="flex items-center gap-1">
                                <span class="w-3 h-3 rounded-full bg-danger-600"></span>
                                <span class="text-gray-400">Danger</span>
                            </span>
                            <span class="flex items-center gap-1">
                                <span class="w-3 h-3 rounded-full bg-warning-500"></span>
                                <span class="text-gray-400">Alerte</span>
                            </span>
                            <span class="flex items-center gap-1">
                                <span class="w-3 h-3 rounded-full bg-info-500"></span>
                                <span class="text-gray-400">Vigilance</span>
                            </span>
                        </div>
                    </div>
                    
                    <%-- Map --%>
                    <div id="map" class="h-[500px] w-full"></div>
                </div>
            </div>
        </section>

        <%-- Features Section (Bento Grid) --%>
        <section id="features" class="py-20">
            <div class="container mx-auto px-4">
                <%-- Section Header --%>
                <div class="text-center mb-16">
                    <span class="inline-block glass px-4 py-2 rounded-full text-sm text-gray-300 mb-4">
                        <i class="bi bi-cpu me-2"></i>IA & Machine Learning
                    </span>
                    <h2 class="text-4xl md:text-5xl font-bold text-white">Technologies de pointe</h2>
                </div>
                
                <%-- Bento Grid --%>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    
                    <%-- Feature 1: Flood Prediction --%>
                    <div class="glass-card group hover:scale-[1.02] transition-transform">
                        <div class="flex items-center gap-4 mb-4">
                            <div class="w-14 h-14 rounded-xl bg-blue-500/20 flex items-center justify-center text-2xl">
                                💧
                            </div>
                            <div>
                                <h3 class="text-xl font-bold text-white">Prédiction Inondations</h3>
                            </div>
                        </div>
                        <p class="text-gray-400 mb-4">
                            Modèle XGBoost analysant précipitations, niveaux d'eau et topographie 
                            pour prédire les crues 24-72h à l'avance.
                        </p>
                        <div class="flex gap-2">
                            <span class="px-3 py-1 rounded-full bg-blue-500/20 text-blue-400 text-xs font-medium">94% précision</span>
                            <span class="px-3 py-1 rounded-full bg-blue-500/20 text-blue-400 text-xs font-medium">24-72h horizon</span>
                        </div>
                    </div>
                    
                    <%-- Feature 2: Fire Detection --%>
                    <div class="glass-card group hover:scale-[1.02] transition-transform">
                        <div class="flex items-center gap-4 mb-4">
                            <div class="w-14 h-14 rounded-xl bg-orange-500/20 flex items-center justify-center text-2xl">
                                🔥
                            </div>
                            <div>
                                <h3 class="text-xl font-bold text-white">Détection Incendies</h3>
                            </div>
                        </div>
                        <p class="text-gray-400 mb-4">
                            CNN ResNet-50 analysant images satellites NASA FIRMS pour détecter 
                            les feux de forêt en temps réel.
                        </p>
                        <div class="flex gap-2">
                            <span class="px-3 py-1 rounded-full bg-orange-500/20 text-orange-400 text-xs font-medium">CNN ResNet-50</span>
                            <span class="px-3 py-1 rounded-full bg-orange-500/20 text-orange-400 text-xs font-medium">Temps réel</span>
                        </div>
                    </div>
                    
                    <%-- Feature 3: NLP Social --%>
                    <div class="glass-card group hover:scale-[1.02] transition-transform">
                        <div class="flex items-center gap-4 mb-4">
                            <div class="w-14 h-14 rounded-xl bg-purple-500/20 flex items-center justify-center text-2xl">
                                💬
                            </div>
                            <div>
                                <h3 class="text-xl font-bold text-white">Analyse Réseaux Sociaux</h3>
                            </div>
                        </div>
                        <p class="text-gray-400 mb-4">
                            BERT multilingue analysant Twitter pour détecter les signaux 
                            d'alerte et localiser les incidents.
                        </p>
                        <div class="flex gap-2">
                            <span class="px-3 py-1 rounded-full bg-purple-500/20 text-purple-400 text-xs font-medium">BERT NLP</span>
                            <span class="px-3 py-1 rounded-full bg-purple-500/20 text-purple-400 text-xs font-medium">Multi-langue</span>
                        </div>
                    </div>
                    
                    <%-- Feature 4: Routing A* --%>
                    <div class="glass-card group hover:scale-[1.02] transition-transform">
                        <div class="flex items-center gap-4 mb-4">
                            <div class="w-14 h-14 rounded-xl bg-green-500/20 flex items-center justify-center text-2xl">
                                🗺️
                            </div>
                            <div>
                                <h3 class="text-xl font-bold text-white">Routes d'Évacuation</h3>
                            </div>
                        </div>
                        <p class="text-gray-400 mb-4">
                            Algorithme A* pondéré avec OSM pour calculer les itinéraires 
                            optimaux évitant les zones de danger.
                        </p>
                        <div class="flex gap-2">
                            <span class="px-3 py-1 rounded-full bg-green-500/20 text-green-400 text-xs font-medium">Algorithme A*</span>
                            <span class="px-3 py-1 rounded-full bg-green-500/20 text-green-400 text-xs font-medium">OpenStreetMap</span>
                        </div>
                    </div>
                    
                    <%-- Feature 5: Real-time Alerts (Wide Card) --%>
                    <div class="glass-card md:col-span-2 group hover:scale-[1.02] transition-transform">
                        <div class="grid md:grid-cols-2 gap-6">
                            <div>
                                <div class="flex items-center gap-4 mb-4">
                                    <div class="w-14 h-14 rounded-xl bg-danger-500/20 flex items-center justify-center text-2xl">
                                        ⚡
                                    </div>
                                    <div>
                                        <h3 class="text-xl font-bold text-white">Alertes Multicanal</h3>
                                    </div>
                                </div>
                                <p class="text-gray-400 mb-4">
                                    Notifications instantanées via SMS (Twilio), Push (Firebase), 
                                    Email et WebSocket selon votre localisation.
                                </p>
                                <div class="flex gap-2">
                                    <span class="px-3 py-1 rounded-full bg-danger-500/20 text-danger-400 text-xs font-medium">SMS Twilio</span>
                                    <span class="px-3 py-1 rounded-full bg-danger-500/20 text-danger-400 text-xs font-medium">Push FCM</span>
                                    <span class="px-3 py-1 rounded-full bg-danger-500/20 text-danger-400 text-xs font-medium">WebSocket</span>
                                </div>
                            </div>
                            <div class="flex items-center justify-center">
                                <%-- Phone Notification Preview --%>
                                <div class="glass p-4 rounded-2xl max-w-xs">
                                    <div class="flex items-center gap-2 mb-3 pb-2 border-b border-white/10">
                                        <span class="text-lg">🌪️</span>
                                        <span class="text-sm font-semibold text-white">MITANDRINA</span>
                                        <span class="text-xs text-gray-500 ml-auto">Maintenant</span>
                                    </div>
                                    <div>
                                        <strong class="text-danger-400 text-sm">🚨 Alerte Inondation</strong>
                                        <p class="text-xs text-gray-400 mt-1">Risque élevé dans votre zone. Itinéraire disponible.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <%-- Feature 6: Simulation --%>
                    <div class="glass-card group hover:scale-[1.02] transition-transform">
                        <div class="flex items-center gap-4 mb-4">
                            <div class="w-14 h-14 rounded-xl bg-teal-500/20 flex items-center justify-center text-2xl">
                                🔮
                            </div>
                            <div>
                                <h3 class="text-xl font-bold text-white">Simulation "What If?"</h3>
                            </div>
                        </div>
                        <p class="text-gray-400 mb-4">
                            Simulez des scénarios de catastrophe pour planifier les 
                            réponses et tester les plans d'évacuation.
                        </p>
                        <div class="flex gap-2">
                            <span class="px-3 py-1 rounded-full bg-teal-500/20 text-teal-400 text-xs font-medium">Scénarios</span>
                            <span class="px-3 py-1 rounded-full bg-teal-500/20 text-teal-400 text-xs font-medium">&lt; 30s calcul</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <%-- How It Works Section --%>
        <section id="how-it-works" class="py-20 relative">
            <div class="container mx-auto px-4">
                <%-- Section Header --%>
                <div class="text-center mb-16">
                    <span class="inline-block glass px-4 py-2 rounded-full text-sm text-gray-300 mb-4">
                        <i class="bi bi-arrow-repeat me-2"></i>Flux de données
                    </span>
                    <h2 class="text-4xl md:text-5xl font-bold text-white">De la détection à l'alerte</h2>
                </div>
                
                <%-- Flow Diagram --%>
                <div class="flex flex-wrap justify-center items-start gap-4 md:gap-8">
                    
                    <%-- Step 1 --%>
                    <div class="flex flex-col items-center text-center max-w-[200px]">
                        <div class="glass w-12 h-12 rounded-full flex items-center justify-center mb-4">
                            <span class="text-white font-bold">1</span>
                        </div>
                        <div class="text-3xl mb-3">🛰️</div>
                        <h4 class="text-lg font-semibold text-white mb-2">Collecte</h4>
                        <p class="text-gray-400 text-sm">Données satellites, météo, réseaux sociaux</p>
                    </div>
                    
                    <%-- Arrow --%>
                    <div class="hidden md:flex items-center pt-8 text-gray-600">
                        <i class="bi bi-arrow-right text-2xl"></i>
                    </div>
                    
                    <%-- Step 2 --%>
                    <div class="flex flex-col items-center text-center max-w-[200px]">
                        <div class="glass w-12 h-12 rounded-full flex items-center justify-center mb-4">
                            <span class="text-white font-bold">2</span>
                        </div>
                        <div class="text-3xl mb-3">🧠</div>
                        <h4 class="text-lg font-semibold text-white mb-2">Analyse IA</h4>
                        <p class="text-gray-400 text-sm">Modèles XGBoost, CNN, BERT analysent</p>
                    </div>
                    
                    <%-- Arrow --%>
                    <div class="hidden md:flex items-center pt-8 text-gray-600">
                        <i class="bi bi-arrow-right text-2xl"></i>
                    </div>
                    
                    <%-- Step 3 --%>
                    <div class="flex flex-col items-center text-center max-w-[200px]">
                        <div class="glass w-12 h-12 rounded-full flex items-center justify-center mb-4">
                            <span class="text-white font-bold">3</span>
                        </div>
                        <div class="text-3xl mb-3">⚠️</div>
                        <h4 class="text-lg font-semibold text-white mb-2">Détection</h4>
                        <p class="text-gray-400 text-sm">Risque identifié avec score de confiance</p>
                    </div>
                    
                    <%-- Arrow --%>
                    <div class="hidden md:flex items-center pt-8 text-gray-600">
                        <i class="bi bi-arrow-right text-2xl"></i>
                    </div>
                    
                    <%-- Step 4 --%>
                    <div class="flex flex-col items-center text-center max-w-[200px]">
                        <div class="glass w-12 h-12 rounded-full flex items-center justify-center mb-4">
                            <span class="text-white font-bold">4</span>
                        </div>
                        <div class="text-3xl mb-3">📢</div>
                        <h4 class="text-lg font-semibold text-white mb-2">Alerte</h4>
                        <p class="text-gray-400 text-sm">Notification multicanal en &lt; 5 secondes</p>
                    </div>
                    
                    <%-- Arrow --%>
                    <div class="hidden md:flex items-center pt-8 text-gray-600">
                        <i class="bi bi-arrow-right text-2xl"></i>
                    </div>
                    
                    <%-- Step 5 --%>
                    <div class="flex flex-col items-center text-center max-w-[200px]">
                        <div class="glass w-12 h-12 rounded-full flex items-center justify-center mb-4">
                            <span class="text-white font-bold">5</span>
                        </div>
                        <div class="text-3xl mb-3">🚗</div>
                        <h4 class="text-lg font-semibold text-white mb-2">Évacuation</h4>
                        <p class="text-gray-400 text-sm">Route optimale calculée par A*</p>
                    </div>
                </div>
            </div>
        </section>

    </jsp:attribute>
    
    <jsp:attribute name="extraScripts">
        <script src="${pageContext.request.contextPath}/assets/js/map.js"></script>
        <script>
            // Animate stats on load
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
            
            window.addEventListener('load', () => {
                animateValue('stat-predictions', 0, parseInt('${predictionCount}') || 1247, 2000);
                animateValue('stat-users', 0, parseInt('${userCount}') || 15432, 2000);
            });
        </script>
    </jsp:attribute>
</jsp:include>
