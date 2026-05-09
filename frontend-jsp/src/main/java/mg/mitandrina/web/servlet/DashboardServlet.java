package mg.mitandrina.web.servlet;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.hc.client5.http.classic.methods.HttpGet;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.io.entity.EntityUtils;

import org.apache.hc.core5.http.ParseException;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * 🌪️ MITANDRINA - DashboardServlet
 * Page tableau de bord utilisateur
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    private static final String API_BASE_URL = System.getenv("API_BASE_URL") != null 
        ? System.getenv("API_BASE_URL") 
        : "http://localhost:3001/api/v1";
    
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final CloseableHttpClient httpClient = HttpClients.createDefault();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("token") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        
        String token = (String) session.getAttribute("token");
        @SuppressWarnings("unchecked")
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");
        
        try {
            // Récupérer les alertes actives
            List<Map<String, Object>> alerts = fetchAlerts(token);
            req.setAttribute("recentAlerts", alerts != null ? alerts.subList(0, Math.min(5, alerts.size())) : Collections.emptyList());
            req.setAttribute("activeAlertsCount", alerts != null ? alerts.size() : 0);
            req.setAttribute("unreadAlerts", countUnreadAlerts(token));
            
            // Récupérer les incidents proches
            List<Map<String, Object>> incidents = fetchNearbyIncidents(token, user);
            req.setAttribute("nearbyIncidents", incidents != null ? incidents : Collections.emptyList());
            req.setAttribute("todayIncidentsCount", incidents != null ? incidents.size() : 0);
            
            // Stats mock pour démo
            req.setAttribute("monitoredZonesCount", 47);
            req.setAttribute("protectedUsersCount", 12543);
            req.setAttribute("unreadNotifications", 3);
            
            // User location
            req.setAttribute("userLat", user.getOrDefault("locationLat", -18.9078));
            req.setAttribute("userLng", user.getOrDefault("locationLng", 47.5208));
            req.setAttribute("userLocation", "Antananarivo");
            
            // Weather mock
            req.setAttribute("weatherTemp", 24);
            req.setAttribute("weatherHumidity", 65);
            req.setAttribute("weatherWind", 12);
            req.setAttribute("weatherRain", 2.5);
            req.setAttribute("weatherIcon", "⛅");
            
            req.getRequestDispatcher("/WEB-INF/views/dashboard/index.jsp").forward(req, resp);
            
        } catch (Exception e) {
            throw new ServletException("Erreur chargement dashboard", e);
        }
    }

    private List<Map<String, Object>> fetchAlerts(String token) throws IOException, ParseException {
        HttpGet httpGet = new HttpGet(API_BASE_URL + "/alerts?active=true&limit=10");
        httpGet.setHeader("Authorization", "Bearer " + token);
        
        try (CloseableHttpResponse response = httpClient.execute(httpGet)) {
            if (response.getCode() == 200) {
                String body = EntityUtils.toString(response.getEntity());
                Map<String, Object> result = objectMapper.readValue(body, Map.class);
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> alerts = (List<Map<String, Object>>) result.get("alerts");
                return alerts;
            }
        }
        return Collections.emptyList();
    }

    private int countUnreadAlerts(String token) throws IOException {
        // Appel API pour compter les alertes non lues
        return 2; // Mock
    }

    private List<Map<String, Object>> fetchNearbyIncidents(String token, Map<String, Object> user) throws IOException, ParseException {
        Double lat = (Double) user.getOrDefault("locationLat", -18.9078);
        Double lng = (Double) user.getOrDefault("locationLng", 47.5208);
        
        HttpGet httpGet = new HttpGet(API_BASE_URL + "/incidents?lat=" + lat + "&lng=" + lng + "&radius=50&limit=5");
        httpGet.setHeader("Authorization", "Bearer " + token);
        
        try (CloseableHttpResponse response = httpClient.execute(httpGet)) {
            if (response.getCode() == 200) {
                String body = EntityUtils.toString(response.getEntity());
                Map<String, Object> result = objectMapper.readValue(body, Map.class);
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> incidents = (List<Map<String, Object>>) result.get("incidents");
                return incidents;
            }
        }
        return Collections.emptyList();
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
