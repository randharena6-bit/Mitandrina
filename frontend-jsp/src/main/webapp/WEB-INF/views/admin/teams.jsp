<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Équipes de Secours - Administration - MITANDRINA</title>
    
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
    <link rel="stylesheet" href="/assets/css/custom.css?v=9a7f7b52">
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
                    
                    <a href="teams" class="nav-item active">
                        <i class="bi bi-building-fill text-lg"></i>
                        <span>Équipes</span>
                    </a>
                    
                    <a href="simulations" class="nav-item">
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
                    <h1 class="text-xl font-bold text-gray-900">Équipes d'Intervention & Secours</h1>
                    <p class="text-xs text-gray-500">Coordonnez les brigades mobiles de secours et d'aide</p>
                </div>
            </div>
            
            <button data-bs-toggle="modal" data-bs-target="#createTeamModal" 
                    class="flex items-center gap-2 px-4 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-xl font-semibold shadow-lg shadow-primary-600/20 hover:scale-[1.02] hover:shadow-primary-600/30 transition-all text-sm">
                <i class="bi bi-plus-circle-fill text-lg"></i>
                Créer une équipe
            </button>
        </header>
        
        <!-- Teams List -->
        <div class="p-6">
            <div class="card-modern overflow-hidden animate-fade-in-up">
                <div class="p-5 border-b border-gray-100 bg-gray-50">
                    <h3 class="font-bold text-gray-900 text-sm">Escouades d'Intervention</h3>
                </div>
                
                <div class="table-responsive">
                    <table class="table mb-0 align-middle">
                        <thead class="bg-gray-50 border-b border-gray-100">
                            <tr>
                                <th class="px-6 py-4 text-xs font-bold text-gray-400 uppercase">Brigade</th>
                                <th class="px-6 py-4 text-xs font-bold text-gray-400 uppercase">Type / Effectif</th>
                                <th class="px-6 py-4 text-xs font-bold text-gray-400 uppercase">Chef de Brigade</th>
                                <th class="px-6 py-4 text-xs font-bold text-gray-400 uppercase">Contact / Fréquence</th>
                                <th class="px-6 py-4 text-xs font-bold text-gray-400 uppercase">Statut</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                            <c:forEach items="${teamsList}" var="team">
                                <tr>
                                    <td class="px-6 py-4">
                                        <div class="flex items-center gap-3">
                                            <div class="w-10 h-10 rounded-xl bg-green-50 text-green-600 flex items-center justify-center font-bold text-lg">
                                                🚨
                                            </div>
                                            <div>
                                                <p class="text-sm font-semibold text-gray-900">${team.name}</p>
                                                <p class="text-xs text-gray-400 font-medium">GPS: ${team.current_lat}, ${team.current_lng}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4">
                                        <div class="flex items-center gap-2">
                                            <span class="px-2.5 py-1 text-xs font-bold rounded-lg uppercase bg-blue-50 text-blue-600 border border-blue-100">
                                                ${team.type}
                                            </span>
                                            <span class="px-2 py-0.5 text-xs text-gray-500 bg-gray-100 rounded-md font-semibold">${team.team_size} membres</span>
                                        </div>
                                    </td>
                                    <td class="px-6 py-4 text-sm font-semibold text-gray-900">
                                        ${team.leader_name != null ? team.leader_name : 'Non défini'}
                                    </td>
                                    <td class="px-6 py-4">
                                        <p class="text-xs text-gray-600 font-semibold"><i class="bi bi-phone mr-1"></i>${team.phone}</p>
                                        <p class="text-xs text-gray-400 font-medium"><i class="bi bi-broadcast mr-1"></i>148.50 MHz</p>
                                    </td>
                                    <td class="px-6 py-4">
                                        <span class="px-2.5 py-1 text-xs font-bold rounded-lg uppercase
                                                     ${team.current_status == 'disponible' ? 'bg-green-50 text-green-600 border border-green-100' : 'bg-amber-50 text-amber-600 border border-amber-100'}">
                                            ${team.current_status}
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                            
                            <c:if test="${empty teamsList}">
                                <tr>
                                    <td colspan="5" class="text-center py-12 text-gray-500">
                                        <i class="bi bi-building text-4xl text-gray-300 block mb-3 animate-pulse"></i>
                                        Aucune brigade de secours n'est configurée en base.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

    <!-- Modal for Creating Rescue Team -->
    <div class="modal fade" id="createTeamModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 rounded-2xl shadow-2xl">
                <form action="teams/create" method="POST">
                    <div class="modal-header border-b border-gray-100 p-4">
                        <h5 class="modal-title font-bold text-gray-900 flex items-center gap-2">
                            <i class="bi bi-building-add text-primary-500"></i>
                            Enregistrer une Équipe de Secours
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4 space-y-4">
                        <!-- Nom -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Nom de la brigade / Identifiant</label>
                            <input type="text" name="name" placeholder="Ex: Sapeurs-Pompiers Analakely Section A" 
                                   class="form-control bg-gray-50 border-gray-200 rounded-xl" required minlength="4">
                        </div>
                        
                        <!-- Type -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Type de corps d'intervention</label>
                            <select name="type" class="form-select bg-gray-50 border-gray-200 rounded-xl" required>
                                <option value="pompier">🧑‍🚒 Pompier (Incendies et sauvetages complexes)</option>
                                <option value="police">👮 Police (Sécurisation et bouclage des zones)</option>
                                <option value="medical">🩺 Médical (Médecins de catastrophe et ambulances)</option>
                                <option value="secouriste">⛺ Secouriste (Croix Rouge, abris d'urgence)</option>
                                <option value="militaire">🪖 Militaire (Évacuations lourdes et logistique)</option>
                            </select>
                        </div>

                        <!-- Effectif & Chef -->
                        <div class="grid grid-cols-2 gap-3">
                            <div>
                                <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Effectif (Membres)</label>
                                <input type="number" name="teamSize" value="5" min="1" 
                                       class="form-control bg-gray-50 border-gray-200 rounded-xl" required>
                            </div>
                            <div>
                                <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Chef de Brigade</label>
                                <input type="text" name="leaderName" placeholder="Ex: Lt. Rakoto" 
                                       class="form-control bg-gray-50 border-gray-200 rounded-xl" required>
                            </div>
                        </div>

                        <!-- Phone -->
                        <div>
                            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5">Numéro de téléphone d'urgence</label>
                            <input type="tel" name="phone" placeholder="Ex: +261 34 00 000 00" 
                                   class="form-control bg-gray-50 border-gray-200 rounded-xl" required>
                        </div>
                    </div>
                    <div class="modal-footer border-t border-gray-100 p-4">
                        <button type="button" class="px-4 py-2 border border-gray-200 rounded-xl font-semibold text-gray-600 hover:bg-gray-50" data-bs-dismiss="modal">Annuler</button>
                        <button type="submit" 
                                class="px-5 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-xl font-bold shadow-lg shadow-primary-600/20 transition-all">
                            Enregistrer
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
    </script>
</body>
</html>
