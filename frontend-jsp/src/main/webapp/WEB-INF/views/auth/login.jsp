<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion - MITANDRINA</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/design-system.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body class="auth-page">
    <div class="auth-container">
        <div class="auth-card glass">
            <div class="auth-header">
                <a href="${pageContext.request.contextPath}/" class="brand">
                    <span class="brand-icon">🌪️</span>
                    <span class="brand-text">MITANDRINA</span>
                </a>
                <h1>Connexion</h1>
                <p>Accédez à votre tableau de bord de sécurité</p>
            </div>
            
            <c:if test="${not empty error}">
                <div class="alert alert-error">
                    <span class="alert-icon">⚠️</span>
                    ${error}
                </div>
            </c:if>
            
            <form action="${pageContext.request.contextPath}/auth/login" method="post" class="auth-form">
                <div class="form-group">
                    <label for="email">Email</label>
                    <div class="input-wrapper">
                        <span class="input-icon">📧</span>
                        <input 
                            type="email" 
                            id="email" 
                            name="email" 
                            required 
                            placeholder="votre@email.com"
                            value="${param.email}"
                            autocomplete="email"
                        >
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="password">Mot de passe</label>
                    <div class="input-wrapper">
                        <span class="input-icon">🔒</span>
                        <input 
                            type="password" 
                            id="password" 
                            name="password" 
                            required 
                            placeholder="••••••••"
                            autocomplete="current-password"
                        >
                        <button type="button" class="toggle-password" onclick="togglePassword()">
                            👁️
                        </button>
                    </div>
                </div>
                
                <div class="form-options">
                    <label class="checkbox">
                        <input type="checkbox" name="remember" value="true">
                        <span class="checkmark"></span>
                        Se souvenir de moi
                    </label>
                    <a href="${pageContext.request.contextPath}/auth/forgot-password" class="link">
                        Mot de passe oublié?
                    </a>
                </div>
                
                <button type="submit" class="btn btn-primary btn-lg btn-full">
                    Se connecter
                </button>
            </form>
            
            <div class="auth-footer">
                <p>Pas encore de compte?</p>
                <a href="${pageContext.request.contextPath}/auth/register" class="btn btn-outline btn-full">
                    Créer un compte
                </a>
            </div>
        </div>
        
        <div class="auth-background">
            <div class="gradient-sphere sphere-1"></div>
            <div class="gradient-sphere sphere-2"></div>
            <div class="grid-pattern"></div>
        </div>
    </div>
    
    <script>
        function togglePassword() {
            const input = document.getElementById('password');
            input.type = input.type === 'password' ? 'text' : 'password';
        }
    </script>
</body>
</html>
