package mg.mitandrina.web.servlet;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.io.entity.StringEntity;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * 🌪️ MITANDRINA - AuthServlet
 * Gestion de l'authentification (proxy vers Node.js API)
 */
@WebServlet(name = "AuthServlet", urlPatterns = {"/auth/*"})
public class AuthServlet extends HttpServlet {

    private static final String API_BASE_URL = System.getenv("API_BASE_URL") != null 
        ? System.getenv("API_BASE_URL") 
        : "http://localhost:3001/api/v1";
    
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final CloseableHttpClient httpClient = HttpClients.createDefault();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String path = req.getPathInfo();
        
        if (path == null || path.equals("/") || path.equals("/login")) {
            // Page de login
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        } else if (path.equals("/register")) {
            // Page d'inscription
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        } else if (path.equals("/logout")) {
            // Déconnexion
            doLogout(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String path = req.getPathInfo();
        
        if (path == null || path.equals("/") || path.equals("/login")) {
            doLogin(req, resp);
        } else if (path.equals("/register")) {
            doRegister(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void doLogin(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException, ServletException {
        
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        
        try {
            // Préparer la requête vers l'API Node.js
            Map<String, String> credentials = new HashMap<>();
            credentials.put("email", email);
            credentials.put("password", password);
            
            HttpPost httpPost = new HttpPost(API_BASE_URL + "/auth/login");
            httpPost.setHeader("Content-Type", "application/json");
            httpPost.setEntity(new StringEntity(objectMapper.writeValueAsString(credentials)));
            
            try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
                int statusCode = response.getCode();
                String responseBody = EntityUtils.toString(response.getEntity());
                
                if (statusCode == 200) {
                    // Parse la réponse
                    Map<String, Object> apiResponse = objectMapper.readValue(responseBody, Map.class);
                    
                    @SuppressWarnings("unchecked")
                    Map<String, Object> user = (Map<String, Object>) apiResponse.get("user");
                    String token = (String) apiResponse.get("token");
                    
                    // Créer la session
                    HttpSession session = req.getSession(true);
                    session.setAttribute("user", user);
                    session.setAttribute("token", token);
                    session.setMaxInactiveInterval(7 * 24 * 60 * 60); // 7 jours
                    
                    // Rediriger vers le dashboard
                    resp.sendRedirect(req.getContextPath() + "/dashboard");
                    
                } else {
                    // Erreur de connexion
                    Map<String, Object> errorResponse = objectMapper.readValue(responseBody, Map.class);
                    req.setAttribute("error", errorResponse.getOrDefault("error", "Identifiants invalides"));
                    req.setAttribute("email", email);
                    req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
                }
            }
            
        } catch (Exception e) {
            req.setAttribute("error", "Erreur de connexion: " + e.getMessage());
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        }
    }

    private void doRegister(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException, ServletException {
        
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String phoneNumber = req.getParameter("phoneNumber");
        String firstName = req.getParameter("firstName");
        String lastName = req.getParameter("lastName");
        
        try {
            Map<String, String> userData = new HashMap<>();
            userData.put("email", email);
            userData.put("password", password);
            userData.put("phoneNumber", phoneNumber);
            userData.put("firstName", firstName);
            userData.put("lastName", lastName);
            
            HttpPost httpPost = new HttpPost(API_BASE_URL + "/auth/register");
            httpPost.setHeader("Content-Type", "application/json");
            httpPost.setEntity(new StringEntity(objectMapper.writeValueAsString(userData)));
            
            try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
                int statusCode = response.getCode();
                String responseBody = EntityUtils.toString(response.getEntity());
                
                if (statusCode == 201) {
                    // Inscription réussie, connecter automatiquement
                    Map<String, Object> apiResponse = objectMapper.readValue(responseBody, Map.class);
                    
                    @SuppressWarnings("unchecked")
                    Map<String, Object> user = (Map<String, Object>) apiResponse.get("user");
                    String token = (String) apiResponse.get("token");
                    
                    HttpSession session = req.getSession(true);
                    session.setAttribute("user", user);
                    session.setAttribute("token", token);
                    
                    resp.sendRedirect(req.getContextPath() + "/dashboard");
                    
                } else {
                    Map<String, Object> errorResponse = objectMapper.readValue(responseBody, Map.class);
                    req.setAttribute("error", errorResponse.getOrDefault("error", "Erreur d'inscription"));
                    req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
                }
            }
            
        } catch (Exception e) {
            req.setAttribute("error", "Erreur d'inscription: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        }
    }

    private void doLogout(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        
        resp.sendRedirect(req.getContextPath() + "/");
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
