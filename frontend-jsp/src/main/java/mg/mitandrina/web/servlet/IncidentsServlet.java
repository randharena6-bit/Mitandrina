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
 * 🌪️ MITANDRINA - IncidentsServlet
 * Gère le signalement, la consultation et la coordination des incidents
 */
@WebServlet(name = "IncidentsServlet", urlPatterns = {"/incidents"})
public class IncidentsServlet extends HttpServlet {

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
        String status = req.getParameter("status");

        try {
            // Récupérer les incidents
            String targetUrl = API_BASE_URL + "/incidents?limit=50";
            if (status != null && !status.trim().isEmpty()) {
                targetUrl += "&status=" + status;
            }

            HttpGet httpGet = new HttpGet(targetUrl);
            httpGet.setHeader("Authorization", "Bearer " + token);

            try (CloseableHttpResponse response = httpClient.execute(httpGet)) {
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

            // Récupérer les équipes de secours pour l'assignation
            HttpGet teamsGet = new HttpGet(API_BASE_URL + "/admin/teams"); // Mock ou appel gateway
            teamsGet.setHeader("Authorization", "Bearer " + token);
            try (CloseableHttpResponse response = httpClient.execute(teamsGet)) {
                if (response.getCode() == 200) {
                    String body = EntityUtils.toString(response.getEntity());
                    // Peut retourner directement un tableau ou un objet avec clé 'teams'
                    Object parsed = objectMapper.readValue(body, Object.class);
                    if (parsed instanceof Map) {
                        req.setAttribute("rescueTeams", ((Map<?, ?>) parsed).get("teams"));
                    } else {
                        req.setAttribute("rescueTeams", parsed);
                    }
                } else {
                    req.setAttribute("rescueTeams", Collections.emptyList());
                }
            }

            req.getRequestDispatcher("/WEB-INF/views/incidents.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("Erreur chargement incidents", e);
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
        String incidentId = req.getParameter("incidentId");

        try {
            if ("updateStatus".equals(action)) {
                String newStatus = req.getParameter("status");
                String notes = req.getParameter("notes");

                Map<String, String> payload = new HashMap<>();
                payload.put("status", newStatus);
                if (notes != null && !notes.trim().isEmpty()) {
                    payload.put("notes", notes);
                }

                HttpPut httpPut = new HttpPut(API_BASE_URL + "/incidents/" + incidentId + "/status");
                httpPut.setHeader("Authorization", "Bearer " + token);
                httpPut.setHeader("Content-Type", "application/json");
                httpPut.setEntity(new StringEntity(objectMapper.writeValueAsString(payload)));

                try (CloseableHttpResponse response = httpClient.execute(httpPut)) {
                    if (response.getCode() == 200) {
                        resp.sendRedirect(req.getContextPath() + "/incidents");
                    } else {
                        String errBody = EntityUtils.toString(response.getEntity());
                        req.setAttribute("error", "Erreur mise à jour statut: " + errBody);
                        doGet(req, resp);
                    }
                }
            } else if ("assignTeam".equals(action)) {
                String teamId = req.getParameter("teamId");

                Map<String, String> payload = new HashMap<>();
                payload.put("teamId", teamId);

                HttpPost httpPost = new HttpPost(API_BASE_URL + "/incidents/" + incidentId + "/assign");
                httpPost.setHeader("Authorization", "Bearer " + token);
                httpPost.setHeader("Content-Type", "application/json");
                httpPost.setEntity(new StringEntity(objectMapper.writeValueAsString(payload)));

                try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
                    if (response.getCode() == 200) {
                        resp.sendRedirect(req.getContextPath() + "/incidents");
                    } else {
                        String errBody = EntityUtils.toString(response.getEntity());
                        req.setAttribute("error", "Erreur assignation équipe: " + errBody);
                        doGet(req, resp);
                    }
                }
            } else {
                // Signaler un nouvel incident
                String title = req.getParameter("title");
                String description = req.getParameter("description");
                String type = req.getParameter("type");
                double lat = Double.parseDouble(req.getParameter("lat"));
                double lng = Double.parseDouble(req.getParameter("lng"));

                Map<String, Object> payload = new HashMap<>();
                payload.put("title", title);
                payload.put("description", description);
                payload.put("type", type);
                payload.put("lat", lat);
                payload.put("lng", lng);

                HttpPost httpPost = new HttpPost(API_BASE_URL + "/incidents");
                httpPost.setHeader("Authorization", "Bearer " + token);
                httpPost.setHeader("Content-Type", "application/json");
                httpPost.setEntity(new StringEntity(objectMapper.writeValueAsString(payload)));

                try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
                    if (response.getCode() == 201) {
                        resp.sendRedirect(req.getContextPath() + "/incidents");
                    } else {
                        String errBody = EntityUtils.toString(response.getEntity());
                        req.setAttribute("error", "Erreur de signalement: " + errBody);
                        doGet(req, resp);
                    }
                }
            }
        } catch (Exception e) {
            throw new ServletException("Erreur traitement action incident", e);
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
