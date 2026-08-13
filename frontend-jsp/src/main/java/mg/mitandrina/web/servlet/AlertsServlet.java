package mg.mitandrina.web.servlet;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.hc.client5.http.classic.methods.HttpGet;
import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.classic.methods.HttpPut;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.CloseableHttpResponse;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.io.entity.StringEntity;

import java.io.IOException;
import java.util.*;

/**
 * 🌪️ MITANDRINA - AlertsServlet
 * Gère la consultation et l'émission des alertes d'urgence
 */
@WebServlet(name = "AlertsServlet", urlPatterns = {"/alerts"})
public class AlertsServlet extends HttpServlet {

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
        String activeOnly = req.getParameter("active") != null ? req.getParameter("active") : "false";

        try {
            // Récupérer la liste des alertes
            String targetUrl = API_BASE_URL + "/alerts?active=" + activeOnly + "&limit=50";
            HttpGet httpGet = new HttpGet(targetUrl);
            httpGet.setHeader("Authorization", "Bearer " + token);

            try (CloseableHttpResponse response = httpClient.execute(httpGet)) {
                if (response.getCode() == 200) {
                    String body = EntityUtils.toString(response.getEntity());
                    Map<String, Object> result = objectMapper.readValue(body, Map.class);
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> alerts = (List<Map<String, Object>>) result.get("alerts");
                    req.setAttribute("alertsList", alerts);
                } else {
                    req.setAttribute("alertsList", Collections.emptyList());
                }
            }

            // Récupérer aussi les zones pour l'émission des alertes
            HttpGet zonesGet = new HttpGet(API_BASE_URL + "/incidents?limit=50"); // En guise de zones/incidents
            zonesGet.setHeader("Authorization", "Bearer " + token);
            try (CloseableHttpResponse response = httpClient.execute(zonesGet)) {
                if (response.getCode() == 200) {
                    String body = EntityUtils.toString(response.getEntity());
                    Map<String, Object> result = objectMapper.readValue(body, Map.class);
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> incidents = (List<Map<String, Object>>) result.get("incidents");
                    req.setAttribute("incidentsList", incidents);
                } else {
                    req.setAttribute("incidentsList", Collections.emptyList());
                }
            }

            req.getRequestDispatcher("/WEB-INF/views/alerts.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Erreur chargement alertes", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("token") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String token = (String) session.getAttribute("token");
        String action = req.getParameter("action");

        try {
            if ("resolve".equals(action)) {
                String id = req.getParameter("id");
                HttpPut httpPut = new HttpPut(API_BASE_URL + "/alerts/" + id + "/resolve");
                httpPut.setHeader("Authorization", "Bearer " + token);
                
                try (CloseableHttpResponse response = httpClient.execute(httpPut)) {
                    if (response.getCode() == 200) {
                        resp.getWriter().write("{\"success\": true}");
                    } else {
                        resp.setStatus(response.getCode());
                        resp.getWriter().write(EntityUtils.toString(response.getEntity()));
                    }
                }
            } else {
                // Créer une nouvelle alerte
                String level = req.getParameter("level");
                String type = req.getParameter("type");
                String title = req.getParameter("title");
                String message = req.getParameter("message");
                String zoneId = req.getParameter("zoneId");

                Map<String, Object> payload = new HashMap<>();
                payload.put("level", level);
                payload.put("type", type);
                payload.put("title", title);
                payload.put("message", message);
                if (zoneId != null && !zoneId.trim().isEmpty()) {
                    payload.put("zoneId", zoneId);
                }
                
                // Mettre un Polygone par défaut pour affectedArea pour Joi validation
                Map<String, Object> affectedArea = new HashMap<>();
                affectedArea.put("type", "Polygon");
                List<List<List<Double>>> coords = new ArrayList<>();
                List<List<Double>> ring = new ArrayList<>();
                ring.add(Arrays.asList(47.5, -18.9));
                ring.add(Arrays.asList(47.6, -18.9));
                ring.add(Arrays.asList(47.6, -19.0));
                ring.add(Arrays.asList(47.5, -19.0));
                ring.add(Arrays.asList(47.5, -18.9));
                coords.add(ring);
                affectedArea.put("coordinates", coords);
                payload.put("affectedArea", affectedArea);

                HttpPost httpPost = new HttpPost(API_BASE_URL + "/alerts");
                httpPost.setHeader("Authorization", "Bearer " + token);
                httpPost.setHeader("Content-Type", "application/json");
                httpPost.setEntity(new StringEntity(objectMapper.writeValueAsString(payload)));

                try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
                    if (response.getCode() == 201) {
                        resp.sendRedirect(req.getContextPath() + "/alerts");
                    } else {
                        String errBody = EntityUtils.toString(response.getEntity());
                        req.setAttribute("error", "Erreur lors de l'émission: " + errBody);
                        doGet(req, resp);
                    }
                }
            }
        } catch (Exception e) {
            throw new ServletException("Erreur traitement action alerte", e);
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
