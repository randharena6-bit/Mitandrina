package mg.mitandrina.web.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.hc.client5.http.classic.methods.*;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.io.entity.InputStreamEntity;
import org.apache.hc.core5.http.io.entity.EntityUtils;

import java.io.IOException;

/**
 * 🌪️ MITANDRINA - ApiProxyServlet
 * Proxy inverse pour router les requêtes AJAX vers la Gateway Node.js
 */
@WebServlet(name = "ApiProxyServlet", urlPatterns = {"/api/*"})
public class ApiProxyServlet extends HttpServlet {

    private static final String API_BASE_URL = System.getenv("API_BASE_URL") != null 
        ? System.getenv("API_BASE_URL") 
        : "http://localhost:3001/api";

    private final CloseableHttpClient httpClient = HttpClients.createDefault();

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String method = req.getMethod();
        String pathInfo = req.getPathInfo();
        if (pathInfo == null) {
            pathInfo = "";
        }

        // Construire l'URL cible
        String targetUrl = API_BASE_URL + pathInfo;
        String queryString = req.getQueryString();
        if (queryString != null) {
            targetUrl += "?" + queryString;
        }

        HttpUriRequestBase proxyRequest;
        switch (method.toUpperCase()) {
            case "GET":
                proxyRequest = new HttpGet(targetUrl);
                break;
            case "POST":
                proxyRequest = new HttpPost(targetUrl);
                break;
            case "PUT":
                proxyRequest = new HttpPut(targetUrl);
                break;
            case "DELETE":
                proxyRequest = new HttpDelete(targetUrl);
                break;
            case "PATCH":
                proxyRequest = new HttpPatch(targetUrl);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Méthode non supportée par le proxy");
                return;
        }

        // Copier les headers pertinents de la requête d'origine
        String contentType = req.getContentType();
        if (contentType != null) {
            proxyRequest.setHeader("Content-Type", contentType);
        }

        // Injecter le token Bearer JWT s'il est présent dans la session JSP
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("token") != null) {
            String token = (String) session.getAttribute("token");
            proxyRequest.setHeader("Authorization", "Bearer " + token);
        }

        // Copier le body pour POST/PUT/PATCH
        if ("POST".equalsIgnoreCase(method) || "PUT".equalsIgnoreCase(method) || "PATCH".equalsIgnoreCase(method)) {
            if (req.getContentLengthLong() > 0) {
                proxyRequest.setEntity(new InputStreamEntity(req.getInputStream(), req.getContentLengthLong(), null));
            }
        }

        // Exécuter l'appel
        try (CloseableHttpResponse response = httpClient.execute(proxyRequest)) {
            resp.setStatus(response.getCode());
            
            // Copier le type de contenu de la réponse
            if (response.getEntity() != null && response.getEntity().getContentType() != null) {
                resp.setContentType(response.getEntity().getContentType());
            }

            // Transférer la réponse
            if (response.getEntity() != null) {
                response.getEntity().writeTo(resp.getOutputStream());
            }
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\": \"Erreur proxy: " + e.getMessage() + "\"}");
        }
    }

    @Override
    public void destroy() {
        try {
            httpClient.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
