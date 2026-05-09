/**
 * 🌪️ MITANDRINA - Map JavaScript
 * Carte interactive avec Leaflet
 */

document.addEventListener('DOMContentLoaded', function() {
    
    const mapContainer = document.getElementById('map');
    if (!mapContainer) return;
    
    // ============================================
    // Initialize Map
    // ============================================
    const map = L.map('map', {
        center: [-18.9078, 47.5208], // Antananarivo
        zoom: 7,
        zoomControl: false,
        attributionControl: false
    });
    
    // Add zoom control to top-right
    L.control.zoom({
        position: 'topright'
    }).addTo(map);
    
    // Add attribution
    L.control.attribution({
        position: 'bottomright',
        prefix: '🌪️ MITANDRINA'
    }).addTo(map);
    
    // ============================================
    // Base Layers
    // ============================================
    const osmLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '© OpenStreetMap'
    });
    
    const satelliteLayer = L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', {
        maxZoom: 17,
        attribution: '© OpenTopoMap'
    });
    
    // Default layer
    osmLayer.addTo(map);
    
    // ============================================
    // Layer Control
    // ============================================
    const baseLayers = {
        'Carte': osmLayer,
        'Satellite': satelliteLayer
    };
    
    L.control.layers(baseLayers, null, {
        position: 'topright',
        collapsed: true
    }).addTo(map);
    
    // ============================================
    // Custom Icons
    // ============================================
    const createIcon = (emoji, color) => {
        return L.divIcon({
            className: 'custom-marker',
            html: `<div class="marker-pin" style="background: ${color}">${emoji}</div>`,
            iconSize: [40, 40],
            iconAnchor: [20, 40],
            popupAnchor: [0, -40]
        });
    };
    
    const icons = {
        flood: createIcon('💧', '#3B82F6'),
        fire: createIcon('🔥', '#EF4444'),
        cyclone: createIcon('🌀', '#8B5CF6'),
        earthquake: createIcon('🏚️', '#F59E0B'),
        shelter: createIcon('🏠', '#10B981'),
        incident: createIcon('📍', '#F97316'),
        user: createIcon('👤', '#6366F1')
    };
    
    // ============================================
    // Sample Data (Mock)
    // ============================================
    const zones = [
        {
            id: 1,
            type: 'flood',
            level: 'alerte',
            lat: -18.9078,
            lng: 47.5208,
            name: 'Risque Inondation - Antananarivo',
            description: 'Niveau d\'eau élevé. Précautions recommandées.',
            radius: 5000
        },
        {
            id: 2,
            type: 'fire',
            level: 'urgence',
            lat: -18.1442,
            lng: 49.3956,
            name: 'Incendie - Toamasina',
            description: 'Feu de forêt détecté. Évacuation en cours.',
            radius: 3000
        },
        {
            id: 3,
            type: 'cyclone',
            level: 'vigilance',
            lat: -15.7167,
            lng: 46.3167,
            name: 'Surveillance Cyclone - Mahajanga',
            description: 'Formation dépressionnaire. Surveillance renforcée.',
            radius: 8000
        }
    ];
    
    const shelters = [
        { id: 1, lat: -18.9100, lng: 47.5250, name: 'Centre d\'urgence Analakely', capacity: 500, occupied: 120 },
        { id: 2, lat: -18.1500, lng: 49.4000, name: 'Refuge Toamasina', capacity: 300, occupied: 45 }
    ];
    
    // ============================================
    // Add Zones to Map
    // ============================================
    const zoneLayer = L.layerGroup().addTo(map);
    const shelterLayer = L.layerGroup().addTo(map);
    
    function getZoneColor(level) {
        const colors = {
            'urgence': '#DC2626',
            'alerte': '#F59E0B',
            'vigilance': '#3B82F6',
            'info': '#6B7280'
        };
        return colors[level] || colors.info;
    }
    
    zones.forEach(zone => {
        const color = getZoneColor(zone.level);
        
        // Circle for danger zone
        const circle = L.circle([zone.lat, zone.lng], {
            color: color,
            fillColor: color,
            fillOpacity: 0.2,
            radius: zone.radius,
            weight: 2
        });
        
        // Marker at center
        const marker = L.marker([zone.lat, zone.lng], {
            icon: icons[zone.type]
        });
        
        // Popup
        const popupContent = `
            <div class="map-popup">
                <h4>${zone.name}</h4>
                <span class="badge badge-${zone.level}">${zone.level.toUpperCase()}</span>
                <p>${zone.description}</p>
                <a href="/evacuation?zone=${zone.id}" class="btn btn-sm btn-primary">
                    Voir évacuation
                </a>
            </div>
        `;
        
        marker.bindPopup(popupContent);
        circle.bindPopup(popupContent);
        
        zoneLayer.addLayer(circle);
        zoneLayer.addLayer(marker);
    });
    
    // ============================================
    // Add Shelters
    // ============================================
    shelters.forEach(shelter => {
        const marker = L.marker([shelter.lat, shelter.lng], {
            icon: icons.shelter
        });
        
        const popupContent = `
            <div class="map-popup">
                <h4>${shelter.name}</h4>
                <p>Capacité: ${shelter.occupied}/${shelter.capacity}</p>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${(shelter.occupied/shelter.capacity)*100}%"></div>
                </div>
                <a href="/evacuation?shelter=${shelter.id}" class="btn btn-sm btn-success">
                    Itinéraire
                </a>
            </div>
        `;
        
        marker.bindPopup(popupContent);
        shelterLayer.addLayer(marker);
    });
    
    // ============================================
    // Filter Buttons
    // ============================================
    const filterButtons = document.querySelectorAll('.filter-btn');
    
    filterButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            const type = this.dataset.type;
            
            // Toggle active state
            filterButtons.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            
            // Filter markers
            zoneLayer.clearLayers();
            
            zones.forEach(zone => {
                if (type === 'all' || zone.type === type) {
                    const color = getZoneColor(zone.level);
                    
                    const circle = L.circle([zone.lat, zone.lng], {
                        color: color,
                        fillColor: color,
                        fillOpacity: 0.2,
                        radius: zone.radius,
                        weight: 2
                    });
                    
                    const marker = L.marker([zone.lat, zone.lng], {
                        icon: icons[zone.type]
                    });
                    
                    const popupContent = `
                        <div class="map-popup">
                            <h4>${zone.name}</h4>
                            <span class="badge badge-${zone.level}">${zone.level.toUpperCase()}</span>
                            <p>${zone.description}</p>
                        </div>
                    `;
                    
                    marker.bindPopup(popupContent);
                    circle.bindPopup(popupContent);
                    
                    zoneLayer.addLayer(circle);
                    zoneLayer.addLayer(marker);
                }
            });
        });
    });
    
    // ============================================
    // Geolocation
    // ============================================
    if ("geolocation" in navigator) {
        navigator.geolocation.getCurrentPosition(position => {
            const userLat = position.coords.latitude;
            const userLng = position.coords.longitude;
            
            // Add user marker
            const userMarker = L.marker([userLat, userLng], {
                icon: icons.user,
                zIndexOffset: 1000
            }).addTo(map);
            
            userMarker.bindPopup('<strong>Votre position</strong>');
            
            // Center map on user
            map.setView([userLat, userLng], 10);
            
        }, error => {
            console.log('Geolocation error:', error);
        });
    }
    
    // ============================================
    // Zone Info Panel
    // ============================================
    const zoneInfoPanel = document.getElementById('zone-info');
    
    map.on('mousemove', function(e) {
        // Check if hovering over a zone
        // This is a simplified version
    });
    
});

// ============================================
// Map Styles
// ============================================
const mapStyles = document.createElement('style');
mapStyles.textContent = `
    .custom-marker {
        background: transparent;
        border: none;
    }
    
    .marker-pin {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.3);
        border: 2px solid white;
    }
    
    .map-popup h4 {
        margin: 0 0 8px 0;
        font-size: 14px;
        font-weight: 600;
    }
    
    .map-popup p {
        margin: 0 0 12px 0;
        font-size: 12px;
        color: #666;
    }
    
    .badge {
        display: inline-block;
        padding: 2px 8px;
        border-radius: 4px;
        font-size: 10px;
        font-weight: 600;
        text-transform: uppercase;
    }
    
    .badge-urgence { background: #DC2626; color: white; }
    .badge-alerte { background: #F59E0B; color: white; }
    .badge-vigilance { background: #3B82F6; color: white; }
    
    .progress-bar {
        height: 6px;
        background: #e5e7eb;
        border-radius: 3px;
        overflow: hidden;
        margin-bottom: 12px;
    }
    
    .progress-fill {
        height: 100%;
        background: #10B981;
        transition: width 0.3s ease;
    }
    
    .btn-sm {
        padding: 4px 12px;
        font-size: 12px;
        border-radius: 4px;
        text-decoration: none;
        display: inline-block;
    }
    
    .btn-primary { background: #DC2626; color: white; }
    .btn-success { background: #10B981; color: white; }
`;
document.head.appendChild(mapStyles);
