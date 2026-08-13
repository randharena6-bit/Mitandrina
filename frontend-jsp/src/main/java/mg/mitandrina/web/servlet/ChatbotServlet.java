package mg.mitandrina.web.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.apache.hc.client5.http.classic.methods.HttpPost;
import org.apache.hc.client5.http.impl.classic.CloseableHttpClient;
import org.apache.hc.client5.http.impl.classic.HttpClients;
import org.apache.hc.core5.http.io.entity.EntityUtils;
import org.apache.hc.core5.http.io.entity.StringEntity;
import org.apache.hc.core5.http.ContentType;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Map;

@WebServlet(name = "ChatbotServlet", urlPatterns = {"/chatbot"})
public class ChatbotServlet extends HttpServlet {

    private static final String OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";
    private static final String API_KEY = System.getenv().getOrDefault("OPENROUTER_API_KEY", "");
    private static final String BACKEND_AI_URL = "http://localhost:8000/api/v1/ai-advisor/analyze-cyclones/openrouter";

    private static final String SYSTEM_PROMPT_BASE =
        "Tu es un assistant spécialisé dans la gestion des catastrophes naturelles à Madagascar. " +
        "Tu connais bien la géographie de Madagascar. Reponds toujours en francais.";

    private final CloseableHttpClient httpClient = HttpClients.createDefault();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("token") == null) {
            resp.setStatus(401);
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write("{\"reply\":\"Vous devez etre connecte pour utiliser le chatbot.\"}");
            return;
        }

        StringBuilder body = new StringBuilder();
        String line;
        try (BufferedReader reader = req.getReader()) {
            while ((line = reader.readLine()) != null) body.append(line);
        }

        JsonNode root = mapper.readTree(body.toString());
        String userMessage = root.has("message") ? root.get("message").asText("") : "";
        JsonNode context = root.has("context") ? root.get("context") : null;

        if (userMessage.isEmpty()) {
            writeJson(resp, "Veuillez poser une question sur les catastrophes ou la survie.");
            return;
        }

        boolean simMode = context != null && context.has("simulationMode") && context.get("simulationMode").asBoolean(false);
        boolean hasZones = context != null && context.has("zones") && context.get("zones").isArray() && context.get("zones").size() > 0;

        String reply;
        if (!simMode || !hasZones) {
            reply = "Rien à signaler. Aucun cyclone ou catastrophe n'est actuellement actif sur la carte. " +
                    "Activez le mode Simulation sur la carte pour analyser les scénarios de cyclones et obtenir des prévisions détaillées.";
        } else {
            String enrichedPrompt = buildEnrichedPrompt(context, userMessage);
            String mlAnalysis = callBackendML(context);
            reply = callOpenRouter(enrichedPrompt, mlAnalysis);
        }

        writeJson(resp, reply);
    }

    private String buildEnrichedPrompt(JsonNode context, String userMessage) {
        StringBuilder sb = new StringBuilder();
        sb.append(SYSTEM_PROMPT_BASE);
        sb.append(" Voici les donnees actuellement affichees sur la carte des risques a Madagascar:\n\n");

        JsonNode zones = context.get("zones");
        if (zones != null && zones.isArray()) {
            sb.append("--- ZONES DE DANGER ---\n");
            for (JsonNode z : zones) {
                sb.append("- Nom: ").append(z.has("name") ? z.get("name").asText("?") : "?");
                sb.append(" | Type: ").append(z.has("type") ? z.get("type").asText("?") : "?");
                sb.append(" | Niveau: ").append(z.has("level") ? z.get("level").asText("?") : "?");
                sb.append(" | Score danger: ").append(z.has("danger_score") ? z.get("danger_score").asText("?") : "?");
                sb.append(" | Position: ").append(z.has("lat") ? z.get("lat").asText() : "?").append("S, ").append(z.has("lng") ? z.get("lng").asText() : "?").append("E");
                if (z.has("desc")) sb.append(" | ").append(z.get("desc").asText());
                sb.append("\n");
            }
        }

        JsonNode shelters = context.get("shelters");
        if (shelters != null && shelters.isArray() && shelters.size() > 0) {
            sb.append("\n--- REFUGES DISPONIBLES ---\n");
            for (JsonNode s : shelters) {
                sb.append("- ").append(s.has("name") ? s.get("name").asText("?") : "?");
                sb.append(" | Capacite: ").append(s.has("capacity") ? s.get("capacity").asText() : "?");
                sb.append(" | Occupés: ").append(s.has("occupied") ? s.get("occupied").asText() : "?");
                sb.append("\n");
            }
        }

        JsonNode incidents = context.get("incidents");
        if (incidents != null && incidents.isArray() && incidents.size() > 0) {
            sb.append("\n--- INCIDENTS ---\n");
            for (JsonNode i : incidents) {
                sb.append("- ").append(i.has("title") ? i.get("title").asText("?") : "?");
                sb.append(" | Statut: ").append(i.has("status") ? i.get("status").asText("?") : "?");
                sb.append(" | Severite: ").append(i.has("severity") ? i.get("severity").asText() : "?");
                sb.append("\n");
            }
        }

        sb.append("\n--- QUESTION DE L'UTILISATEUR ---\n");
        sb.append(userMessage);
        sb.append("\n\nReponds de maniere claire et concise (max 300 mots). Utilise des listes a puces. ");
        sb.append("Base tes reponses UNIQUEMENT sur les donnees de la carte fournies ci-dessus. ");
        sb.append("Si l'utilisateur demande des previsions, analyse les trajectoires et donne des conseils d'evacuation. ");
        sb.append("Sois specifique: cite les noms des cyclones, les vitesses de vent, les zones touchees.");

        return sb.toString();
    }

    private String callBackendML(JsonNode context) {
        try {
            ObjectNode mlPayload = mapper.createObjectNode();
            ArrayNode cyclones = mlPayload.putArray("cyclones");
            JsonNode zones = context.get("zones");
            if (zones != null && zones.isArray()) {
                for (JsonNode z : zones) {
                    ObjectNode c = cyclones.addObject();
                    c.put("lat", z.has("lat") ? z.get("lat").asDouble() : 0);
                    c.put("lng", z.has("lng") ? z.get("lng").asDouble() : 0);
                    c.put("title", z.has("name") ? z.get("name").asText("Zone de danger") : "Zone de danger");
                    c.put("level", z.has("level") ? z.get("level").asText("vigilance") : "vigilance");
                    c.put("wind_speed", z.has("danger_score") ? z.get("danger_score").asDouble() * 2.5 : 0);
                }
            }
            mlPayload.put("user_lat", -18.9078);
            mlPayload.put("user_lng", 47.5208);

            HttpPost request = new HttpPost(BACKEND_AI_URL);
            request.setHeader("Content-Type", "application/json");
            request.setEntity(new StringEntity(mapper.writeValueAsString(mlPayload), ContentType.APPLICATION_JSON));

            return httpClient.execute(request, response -> {
                int code = response.getCode();
                String respBody = response.getEntity() != null
                    ? EntityUtils.toString(response.getEntity())
                    : "{}";
                JsonNode result = mapper.readTree(respBody);
                if (code == 200 && result.has("data")) {
                    JsonNode data = result.get("data");
                    StringBuilder ml = new StringBuilder();
                    if (data.has("risk_analysis")) ml.append("Analyse risque: ").append(data.get("risk_analysis").asText()).append("\n");
                    if (data.has("predictions")) ml.append("Previsions: ").append(data.get("predictions").asText()).append("\n");
                    if (data.has("recommendations")) ml.append("Recommandations: ").append(data.get("recommendations").asText()).append("\n");
                    if (data.has("evacuation_advice")) ml.append("Evacuation: ").append(data.get("evacuation_advice").asText()).append("\n");
                    if (data.has("alerts")) ml.append("Alertes: ").append(data.get("alerts").asText()).append("\n");
                    return ml.toString();
                }
                return null;
            });
        } catch (Exception e) {
            return null;
        }
    }

    private String callOpenRouter(String systemPrompt, String mlAnalysis) {
        try {
            String userContent = mlAnalysis != null && !mlAnalysis.isEmpty()
                ? "Analyse ML des donnees:\n" + mlAnalysis + "\n\nReponds a la question de l'utilisateur en te basant sur cette analyse et les donnees de la carte fournies."
                : "Reponds a la question de l'utilisateur en te basant uniquement sur les donnees de la carte fournies ci-dessus.";

            String payload = mapper.writeValueAsString(
                Map.of(
                    "model", "deepseek/deepseek-chat",
                    "messages", new Object[] {
                        Map.of("role", "system", "content", systemPrompt),
                        Map.of("role", "user", "content", userContent)
                    },
                    "max_tokens", 800,
                    "temperature", 0.7
                )
            );

            HttpPost request = new HttpPost(OPENROUTER_URL);
            request.setHeader("Content-Type", "application/json");
            request.setHeader("Authorization", "Bearer " + API_KEY);
            request.setHeader("HTTP-Referer", "https://mitandrina.app");
            request.setHeader("X-Title", "Mitandrina");
            request.setEntity(new StringEntity(payload, ContentType.APPLICATION_JSON));

            return httpClient.execute(request, response -> {
                int statusCode = response.getCode();
                String responseBody = response.getEntity() != null
                    ? EntityUtils.toString(response.getEntity())
                    : "{}";

                JsonNode root = mapper.readTree(responseBody);

                if (statusCode == 200) {
                    if (root.has("choices") && root.get("choices").isArray() && root.get("choices").size() > 0) {
                        String content = root.get("choices").get(0).get("message").get("content").asText();
                        if (content != null && !content.isEmpty()) return content;
                    }
                    return "Je n'ai pas pu generer une reponse a partir des donnees de la carte.";
                }

                if (root.has("error")) {
                    String errorMsg = root.get("error").has("message")
                        ? root.get("error").get("message").asText()
                        : root.get("error").asText();
                    if (statusCode == 402 || errorMsg.toLowerCase().contains("insufficient balance") || errorMsg.toLowerCase().contains("quota")) {
                        return "Le service IA est temporairement indisponible (solde API insuffisant). " +
                               "Voici un resume des donnees sur la carte:\n" + buildFallbackText(contextFromPrompt(systemPrompt));
                    }
                    return "Erreur API: " + errorMsg;
                }

                return "Erreur " + statusCode + " - Service temporairement indisponible. Voici les donnees brutes:\n" + buildFallbackText(contextFromPrompt(systemPrompt));
            });
        } catch (Exception e) {
            return "Erreur de connexion au service. Donnees sur la carte:\n" + buildFallbackText(contextFromPrompt(systemPrompt));
        }
    }

    private String buildFallbackText(String contextText) {
        return contextText != null && !contextText.isEmpty()
            ? contextText
            : "Aucune donnee disponible sur la carte actuellement.";
    }

    private String contextFromPrompt(String systemPrompt) {
        if (systemPrompt == null) return "";
        int idx = systemPrompt.indexOf("--- ZONES DE DANGER ---");
        if (idx < 0) return "";
        int endIdx = systemPrompt.indexOf("Reponds de maniere");
        if (endIdx < 0) return systemPrompt.substring(idx);
        return systemPrompt.substring(idx, endIdx);
    }

    private void writeJson(HttpServletResponse resp, String reply) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write("{\"reply\":\"" + escapeJson(reply) + "\"}");
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
    public void destroy() {
        try {
            httpClient.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
