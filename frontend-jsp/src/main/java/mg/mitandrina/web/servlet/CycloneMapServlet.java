package mg.mitandrina.web.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.hc.client5.http.classic.methods.HttpGet;
import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.config.RequestConfig;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.io.entity.StringEntity;
import org.apache.hc.core5.http.ContentType;
import org.apache.hc.core5.util.Timeout;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Map;

@WebServlet(name = "CycloneMapServlet", urlPatterns = {"/cyclone-map"})
public class CycloneMapServlet extends HttpServlet {

    private static final String GATEWAY_URL = System.getenv("API_BASE_URL") != null
        ? System.getenv("API_BASE_URL")
        : "http://localhost:3001/api";

    private static final String AI_SERVICE_URL = System.getenv("AI_SERVICE_URL") != null
        ? System.getenv("AI_SERVICE_URL")
        : "http://localhost:8000";

    private final CloseableHttpClient httpClient = HttpClients.custom()
        .setDefaultRequestConfig(RequestConfig.custom()
            .setConnectionRequestTimeout(Timeout.ofSeconds(5))
            .setConnectTimeout(Timeout.ofSeconds(8))
            .setResponseTimeout(Timeout.ofSeconds(10))
            .build())
        .build();

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

        double userLat = user.getOrDefault("locationLat", -18.9078) instanceof Number
            ? ((Number) user.get("locationLat")).doubleValue()
            : -18.9078;
        double userLng = user.getOrDefault("locationLng", 47.5208) instanceof Number
            ? ((Number) user.get("locationLng")).doubleValue()
            : 47.5208;

        req.setAttribute("userLat", userLat);
        req.setAttribute("userLng", userLng);

        String alertsJson = fetchFromGateway("/v1/alerts?type=cyclone&active=true&limit=50", token);
        req.setAttribute("cycloneAlertsJson",
            (alertsJson != null && !alertsJson.isEmpty()) ? alertsJson : "{\"alerts\":[]}");

        String incidentsJson = fetchFromGateway("/v1/incidents?type=cyclone&limit=50", token);
        req.setAttribute("cycloneIncidentsJson",
            (incidentsJson != null && !incidentsJson.isEmpty()) ? incidentsJson : "{\"incidents\":[]}");

        String sheltersJson = fetchFromGateway("/v1/shelters?available=true&limit=50", token);
        req.setAttribute("sheltersJson",
            (sheltersJson != null && !sheltersJson.isEmpty()) ? sheltersJson : "{\"shelters\":[]}");

        // Gemini AI analysis: NOT fetched synchronously to avoid blocking
        // Page loads instantly with fallback, JS fetches AI analysis asynchronously
        // API proxy pour simulations (appel AJAX depuis le JSP)
        String action = req.getParameter("action");
        if ("simulations".equals(action)) {
            String simJson = fetchFromGateway("/v1/admin/simulations", token);
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write(
                (simJson != null && !simJson.isEmpty()) ? simJson : "{\"simulations\":[]}");
            return;
        }

        // OpenRouter analysis and zone-advice require POST with body
        if ("openrouter".equals(action) || "zone-advice".equals(action)) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write("{\"success\":false,\"error\":\"Utilisez POST pour cette action\"}");
            return;
        }

        req.setAttribute("aiAnalysisJson", "{\"resume\":\"Analyse en cours...\"}");

        req.getRequestDispatcher("/WEB-INF/views/cyclone-map.jsp").forward(req, resp);
    }

    private String fetchFromGateway(String path, String token) {
        try {
            HttpGet request = new HttpGet(GATEWAY_URL + path);
            request.setHeader("Authorization", "Bearer " + token);
            request.setHeader("Accept", "application/json");
            return httpClient.execute(request, response -> {
                if (response.getEntity() != null) {
                    return EntityUtils.toString(response.getEntity());
                }
                return null;
            });
        } catch (Exception e) {
            return null;
        }
    }

    private String fetchAIAnalysis(String alertsJson, String incidentsJson, String sheltersJson,
                                    double userLat, double userLng) {
        try {
            // Build the payload for the AI advisor endpoint
            StringBuilder cyclones = new StringBuilder("[");
            if (alertsJson != null && !alertsJson.isEmpty()) {
                cyclones.append(buildCyclonePoints(alertsJson));
            }
            cyclones.append("]");

            StringBuilder incidents = new StringBuilder("[");
            if (incidentsJson != null && !incidentsJson.isEmpty()) {
                incidents.append(buildIncidentPoints(incidentsJson));
            }
            incidents.append("]");

            StringBuilder shelters = new StringBuilder("[");
            if (sheltersJson != null && !sheltersJson.isEmpty()) {
                shelters.append(buildShelterPoints(sheltersJson));
            }
            shelters.append("]");

            String payload = String.format(
                "{\"cyclones\":%s,\"incidents\":%s,\"shelters\":%s,\"user_lat\":%f,\"user_lng\":%f}",
                cyclones.toString(), incidents.toString(), shelters.toString(), userLat, userLng
            );

            HttpPost request = new HttpPost(AI_SERVICE_URL + "/api/v1/ai-advisor/analyze-cyclones");
            request.setHeader("Content-Type", "application/json");
            request.setEntity(new StringEntity(payload, ContentType.APPLICATION_JSON));

            return httpClient.execute(request, response -> {
                if (response.getEntity() != null) {
                    return EntityUtils.toString(response.getEntity());
                }
                return null;
            });
        } catch (Exception e) {
            return null;
        }
    }

    private String buildCyclonePoints(String alertsJson) {
        try {
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            com.fasterxml.jackson.databind.JsonNode root = mapper.readTree(alertsJson);
            com.fasterxml.jackson.databind.JsonNode alerts = root.get("alerts");
            if (alerts == null || !alerts.isArray() || alerts.size() == 0) return "";

            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < alerts.size(); i++) {
                com.fasterxml.jackson.databind.JsonNode a = alerts.get(i);
                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"lat\":").append(a.has("center_lat") ? a.get("center_lat") : a.has("lat") ? a.get("lat") : "-18.9078");
                sb.append(",\"lng\":").append(a.has("center_lng") ? a.get("center_lng") : a.has("lng") ? a.get("lng") : "47.5208");
                sb.append(",\"title\":\"").append(escapeJson(a.has("title") ? a.get("title").asText() : "Système cyclonique")).append("\"");
                sb.append(",\"level\":\"").append(a.has("level") ? a.get("level").asText() : "vigilance").append("\"");
                if (a.has("features_input") && a.get("features_input").has("wind_speed")) {
                    sb.append(",\"wind_speed\":").append(a.get("features_input").get("wind_speed"));
                }
                if (a.has("features_input") && a.get("features_input").has("pressure")) {
                    sb.append(",\"pressure\":").append(a.get("features_input").get("pressure"));
                }
                sb.append("}");
            }
            return sb.toString();
        } catch (Exception e) {
            return "";
        }
    }

    private String buildIncidentPoints(String incidentsJson) {
        try {
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            com.fasterxml.jackson.databind.JsonNode root = mapper.readTree(incidentsJson);
            com.fasterxml.jackson.databind.JsonNode incidents = root.get("incidents");
            if (incidents == null || !incidents.isArray() || incidents.size() == 0) return "";

            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < incidents.size(); i++) {
                com.fasterxml.jackson.databind.JsonNode inc = incidents.get(i);
                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"lat\":").append(inc.has("location_lat") ? inc.get("location_lat") : inc.has("lat") ? inc.get("lat") : "-18.9078");
                sb.append(",\"lng\":").append(inc.has("location_lng") ? inc.get("location_lng") : inc.has("lng") ? inc.get("lng") : "47.5208");
                sb.append(",\"title\":\"").append(escapeJson(inc.has("title") ? inc.get("title").asText() : "Incident")).append("\"");
                sb.append(",\"description\":\"").append(escapeJson(inc.has("description") ? inc.get("description").asText() : "")).append("\"");
                sb.append(",\"status\":\"").append(inc.has("status") ? inc.get("status").asText() : "signalé").append("\"");
                sb.append("}");
            }
            return sb.toString();
        } catch (Exception e) {
            return "";
        }
    }

    private String buildShelterPoints(String sheltersJson) {
        try {
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            com.fasterxml.jackson.databind.JsonNode root = mapper.readTree(sheltersJson);
            com.fasterxml.jackson.databind.JsonNode shelters = root.get("shelters");
            if (shelters == null || !shelters.isArray() || shelters.size() == 0) return "";

            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < shelters.size(); i++) {
                com.fasterxml.jackson.databind.JsonNode s = shelters.get(i);
                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"lat\":").append(s.has("location_lat") ? s.get("location_lat") : s.has("lat") ? s.get("lat") : "-18.9078");
                sb.append(",\"lng\":").append(s.has("location_lng") ? s.get("location_lng") : s.has("lng") ? s.get("lng") : "47.5208");
                sb.append(",\"name\":\"").append(escapeJson(s.has("name") ? s.get("name").asText() : "Abri")).append("\"");
                sb.append(",\"capacity\":").append(s.has("capacity") ? s.get("capacity") : "0");
                sb.append(",\"current_occupancy\":").append(s.has("current_occupancy") ? s.get("current_occupancy") : "0");
                sb.append(",\"has_medical\":").append(s.has("has_medical_facilities") ? s.get("has_medical_facilities") : "false");
                sb.append(",\"has_food\":").append(s.has("has_food") ? s.get("has_food") : "false");
                sb.append(",\"has_water\":").append(s.has("has_water") ? s.get("has_water") : "false");
                sb.append("}");
            }
            return sb.toString();
        } catch (Exception e) {
            return "";
        }
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("token") == null) {
            resp.setStatus(401);
            resp.setContentType("application/json");
            resp.getWriter().write("{\"error\":\"Non authentifié\"}");
            return;
        }

        StringBuilder body = new StringBuilder();
        String line;
        while ((line = req.getReader().readLine()) != null) {
            body.append(line);
        }

        String action = req.getParameter("action");
        String aiEndpoint;

        if ("openrouter".equals(action)) {
            aiEndpoint = AI_SERVICE_URL + "/api/v1/ai-advisor/analyze-cyclones/openrouter";
        } else if ("zone-advice".equals(action)) {
            aiEndpoint = AI_SERVICE_URL + "/api/v1/ai-advisor/analyze-zone";
        } else {
            aiEndpoint = AI_SERVICE_URL + "/api/v1/ai-advisor/analyze-cyclones/deep";
        }

        try {
            HttpPost request = new HttpPost(aiEndpoint);
            request.setHeader("Content-Type", "application/json");
            request.setEntity(new StringEntity(body.toString(), ContentType.APPLICATION_JSON));

            String result = httpClient.execute(request, response -> {
                if (response.getEntity() != null) {
                    return EntityUtils.toString(response.getEntity());
                }
                return "{\"success\":false,\"error\":\"Réponse vide\"}";
            });

            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write(result != null ? result : "{\"success\":false,\"error\":\"Erreur serveur\"}");

        } catch (Exception e) {
            resp.setStatus(500);
            resp.setContentType("application/json");
            resp.getWriter().write("{\"success\":false,\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
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
