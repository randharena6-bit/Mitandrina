package mg.mitandrina.web.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * 🌪️ MITANDRINA - AuthFilter
 * Filtre d'authentification pour protéger les routes
 */
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Récupérer la session
        HttpSession session = httpRequest.getSession(false);
        
        // Vérifier si l'utilisateur est connecté
        boolean isLoggedIn = session != null && session.getAttribute("user") != null;
        
        // URL demandée
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        
        // Si pas connecté et pas sur une page publique, rediriger vers login
        if (!isLoggedIn && !isPublicPath(requestURI, contextPath)) {
            httpResponse.sendRedirect(contextPath + "/auth/login");
            return;
        }
        
        // Si connecté et sur login/register, rediriger vers dashboard
        if (isLoggedIn && isAuthPath(requestURI, contextPath)) {
            httpResponse.sendRedirect(contextPath + "/dashboard");
            return;
        }
        
        // Continuer la chaîne
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Cleanup
    }
    
    private boolean isPublicPath(String requestURI, String contextPath) {
        // Pages publiques qui ne nécessitent pas d'authentification
        String path = requestURI.replace(contextPath, "");
        return path.equals("/") || 
               path.equals("/index.jsp") ||
               path.startsWith("/auth/") ||
               path.startsWith("/assets/") ||
               path.startsWith("/public/") ||
               path.startsWith("/api/") ||
               path.startsWith("/health");
    }
    
    private boolean isAuthPath(String requestURI, String contextPath) {
        // Pages d'authentification où les users connectés ne devraient pas aller
        String path = requestURI.replace(contextPath, "");
        return path.startsWith("/auth/login") ||
               path.startsWith("/auth/register");
    }
}
