<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion - MITANDRINA</title>
    <meta name="description" content="Connectez-vous à MITANDRINA - Plateforme de protection par l'IA">
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary: #059669;
            --primary-light: #ecfdf5;
            --primary-dark: #047857;
            --danger: #dc2626;
            --danger-light: #fef2f2;
            --bg-gray: #f8fafc;
            --bg-white: #ffffff;
            --text-dark: #0f172a;
            --text-gray: #64748b;
            --text-muted: #94a3b8;
            --border: #e2e8f0;
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
            --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 50%, #ecfdf5 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }
        
        .login-container {
            width: 100%;
            max-width: 420px;
        }
        
        .login-card {
            background: rgba(255, 255, 255, 0.85); backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.4);
            border-radius: 24px;
            padding: 2.5rem;
            box-shadow: 0 12px 48px rgba(0,0,0,0.08);
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .login-card:hover { box-shadow: 0 20px 64px rgba(0,0,0,0.12); }
        
        .login-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .brand {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            font-size: 1.75rem;
            font-weight: 800;
            color: var(--text-dark);
            text-decoration: none;
            margin-bottom: 1.5rem;
        }
        
        .brand i {
            color: var(--danger);
            font-size: 2rem;
        }
        
        .login-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 0.5rem;
        }
        
        .login-subtitle {
            color: var(--text-gray);
            font-size: 0.95rem;
        }
        
        .form-group {
            margin-bottom: 1.25rem;
        }
        
        .form-label {
            display: block;
            color: var(--text-dark);
            font-weight: 600;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
        }
        
        .input-group {
            position: relative;
        }
        
        .input-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            font-size: 1.1rem;
            z-index: 10;
        }
        
        .form-control {
            width: 100%;
            padding: 0.875rem 1rem 0.875rem 2.75rem;
            background: var(--bg-gray);
            border: 2px solid transparent;
            border-radius: 12px;
            color: var(--text-dark);
            font-size: 1rem;
            transition: all 0.2s ease;
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--primary);
            background: var(--bg-white);
            box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.1);
        }
        
        .form-control::placeholder {
            color: var(--text-muted);
        }
        
        .password-toggle {
            position: absolute;
            right: 1rem;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--text-muted);
            cursor: pointer;
            padding: 0.25rem;
            transition: color 0.2s ease;
        }
        
        .password-toggle:hover {
            color: var(--text-dark);
        }
        
        .form-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            flex-wrap: wrap;
            gap: 0.5rem;
        }
        
        .form-check {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            cursor: pointer;
        }
        
        .form-check-input {
            width: 1.125rem;
            height: 1.125rem;
            border: 2px solid var(--border);
            border-radius: 6px;
            background: var(--bg-white);
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .form-check-input:checked {
            background: var(--primary);
            border-color: var(--primary);
        }
        
        .form-check-label {
            color: var(--text-gray);
            font-size: 0.9rem;
            cursor: pointer;
        }
        
        .forgot-link {
            color: var(--primary-dark);
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 600;
            transition: color 0.2s ease;
        }
        
        .forgot-link:hover {
            color: var(--primary);
            text-decoration: underline;
        }
        
        .btn-login {
            width: 100%;
            padding: 1rem;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            box-shadow: 0 4px 6px -1px rgba(5, 150, 105, 0.2);
        }
        
        .btn-login:hover {
            background: var(--primary-dark);
            transform: translateY(-1px);
            box-shadow: 0 10px 15px -3px rgba(5, 150, 105, 0.3);
        }
        
        .divider {
            display: flex;
            align-items: center;
            margin: 1.5rem 0;
            color: var(--text-muted);
            font-size: 0.85rem;
        }
        
        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--border);
        }
        
        .divider span {
            padding: 0 1rem;
        }
        
        .social-login {
            display: flex;
            gap: 0.75rem;
        }
        
        .btn-social {
            flex: 1;
            padding: 0.75rem;
            background: var(--bg-gray);
            border: 1px solid var(--border);
            border-radius: 10px;
            color: var(--text-dark);
            font-size: 1.25rem;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .btn-social:hover {
            background: var(--bg-white);
            border-color: var(--primary);
            color: var(--primary-dark);
            transform: translateY(-1px);
        }
        
        .signup-prompt {
            text-align: center;
            margin-top: 1.5rem;
            color: var(--text-gray);
            font-size: 0.95rem;
        }
        
        .signup-prompt a {
            color: var(--primary-dark);
            font-weight: 700;
            text-decoration: none;
            transition: color 0.2s ease;
        }
        
        .signup-prompt a:hover {
            color: var(--primary);
            text-decoration: underline;
        }
        
        .back-link {
            position: absolute;
            top: 2rem;
            left: 2rem;
            color: var(--text-gray);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-weight: 600;
            transition: color 0.2s ease;
        }
        
        .back-link:hover {
            color: var(--primary-dark);
        }
        
        .alert {
            border-radius: 12px;
            padding: 1rem;
            margin-bottom: 1rem;
            border: none;
        }
        
        .alert-danger {
            background: var(--danger-light);
            color: #991b1b;
            border: 1px solid rgba(220, 53, 69, 0.2);
        }
        
        @media (max-width: 576px) {
            body {
                padding: 1rem;
                background: var(--bg-white);
            }
            
            .login-card {
                padding: 1.5rem;
                box-shadow: none;
                border: none;
            }
            
            .back-link {
                position: relative;
                top: 0;
                left: 0;
                margin-bottom: 1rem;
                justify-content: center;
            }
        }
        
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .login-card {
            animation: fadeInUp 0.5s ease-out;
        }
    </style>
    <link rel="stylesheet" href="/assets/css/custom.css?v=d4eccb16">
</head>
<body>
    <a href="./" class="back-link">
        <i class="bi bi-arrow-left"></i>
        Retour à l'accueil
    </a>
    
    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <a href="./" class="brand">
                    <i class="bi bi-shield-shaded"></i>
                    MITANDRINA
                </a>
                <h1 class="login-title">Connexion</h1>
                <p class="login-subtitle">Accédez à votre espace sécurisé</p>
            </div>
            
            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i>
                    ${error}
                </div>
            </c:if>
            
            <form action="auth/login" method="POST">
                <div class="form-group">
                    <label class="form-label">Adresse email</label>
                    <div class="input-group">
                        <i class="bi bi-envelope input-icon"></i>
                        <input type="email" class="form-control" name="email" placeholder="exemple@email.com" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label class="form-label">Mot de passe</label>
                    <div class="input-group">
                        <i class="bi bi-lock input-icon"></i>
                        <input type="password" class="form-control" name="password" id="password" placeholder="••••••••" required>
                        <button type="button" class="password-toggle" onclick="togglePassword()">
                            <i class="bi bi-eye" id="toggleIcon"></i>
                        </button>
                    </div>
                </div>
                
                <div class="form-options">
                    <label class="form-check">
                        <input type="checkbox" class="form-check-input" name="remember">
                        <span class="form-check-label">Se souvenir de moi</span>
                    </label>
                    <a href="#" class="forgot-link">Mot de passe oublié?</a>
                </div>
                
                <button type="submit" class="btn-login">
                    <i class="bi bi-box-arrow-in-right"></i>
                    Se connecter
                </button>
            </form>
            
            <div class="divider">
                <span>ou continuer avec</span>
            </div>
            
            <div class="social-login">
                <button type="button" class="btn-social" title="Google">
                    <i class="bi bi-google"></i>
                </button>
                <button type="button" class="btn-social" title="Microsoft">
                    <i class="bi bi-microsoft"></i>
                </button>
                <button type="button" class="btn-social" title="GitHub">
                    <i class="bi bi-github"></i>
                </button>
            </div>
            
            <div class="signup-prompt">
                Pas encore de compte <a href="./">S'inscrire gratuitement</a>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function togglePassword() {
            const password = document.getElementById('password');
            const icon = document.getElementById('toggleIcon');
            
            if (password.type === 'password') {
                password.type = 'text';
                icon.classList.remove('bi-eye');
                icon.classList.add('bi-eye-slash');
            } else {
                password.type = 'password';
                icon.classList.remove('bi-eye-slash');
                icon.classList.add('bi-eye');
            }
        }
    </script>
</body>
</html>
