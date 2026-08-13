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
 * 🌪️ MITANDRINA - AdminServlet
 * Gère les fonctionnalités d'administration : Utilisateurs, Équipes et Simulations
 */
@WebServlet(name = "AdminServlet", urlPatterns = {"/admin/*"})
public class AdminServlet extends HttpServlet {

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
        String pathInfo = req.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        try {
            if (pathInfo.equals("/users")) {
                // Charger la liste des utilisateurs
                HttpGet httpGet = new HttpGet(API_BASE_URL + "/admin/users");
                httpGet.setHeader("Authorization", "Bearer " + token);
                
                try (CloseableHttpResponse response = httpClient.execute(httpGet)) {
                    if (response.getCode() == 200) {
                        String body = EntityUtils.toString(response.getEntity());
                        Map<String, Object> result = objectMapper.readValue(body, Map.class);
                        req.setAttribute("usersList", result.get("users"));
                    } else {
                        req.setAttribute("usersList", Collections.emptyList());
                    }
                }
                req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
                
            } else if (pathInfo.equals("/teams")) {
                // Charger la liste des équipes de secours
                HttpGet httpGet = new HttpGet(API_BASE_URL + "/admin/teams");
                httpGet.setHeader("Authorization", "Bearer " + token);
                
                try (CloseableHttpResponse response = httpClient.execute(httpGet)) {
                    if (response.getCode() == 200) {
                        String body = EntityUtils.toString(response.getEntity());
                        Map<String, Object> result = objectMapper.readValue(body, Map.class);
                        req.setAttribute("teamsList", result.get("teams"));
                    } else {
                        req.setAttribute("teamsList", Collections.emptyList());
                    }
                }
                req.getRequestDispatcher("/WEB-INF/views/admin/teams.jsp").forward(req, resp);
                
            } else if (pathInfo.equals("/simulations")) {
                // Charger la liste des simulations
                HttpGet httpGet = new HttpGet(API_BASE_URL + "/admin/simulations");
                httpGet.setHeader("Authorization", "Bearer " + token);
                
                try (CloseableHttpResponse response = httpClient.execute(httpGet)) {
                    if (response.getCode() == 200) {
                        String body = EntityUtils.toString(response.getEntity());
                        Map<String, Object> result = objectMapper.readValue(body, Map.class);
                        req.setAttribute("simulationsList", result.get("simulations"));
                    } else {
                        req.setAttribute("simulationsList", Collections.emptyList());
                    }
                }
                req.getRequestDispatcher("/WEB-INF/views/admin/simulations.jsp").forward(req, resp);
            } else {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            throw new ServletException("Erreur chargement page admin", e);
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
        String pathInfo = req.getPathInfo();

        try {
            if (pathInfo != null && pathInfo.equals("/users/role")) {
                String userId = req.getParameter("userId");
                String role = req.getParameter("role");

                Map<String, String> payload = new HashMap<>();
                payload.put("role", role);

                HttpPut httpPut = new HttpPut(API_BASE_URL + "/admin/users/" + userId + "/role");
                httpPut.setHeader("Authorization", "Bearer " + token);
                httpPut.setHeader("Content-Type", "application/json");
                httpPut.setEntity(new StringEntity(objectMapper.writeValueAsString(payload)));

                try (CloseableHttpResponse response = httpClient.execute(httpPut)) {
                    if (response.getCode() == 200) {
                        resp.sendRedirect(req.getContextPath() + "/admin/users");
                    } else {
                        resp.setStatus(response.getCode());
                        resp.getWriter().write(EntityUtils.toString(response.getEntity()));
                    }
                }
            } else if (pathInfo != null && pathInfo.equals("/teams/create")) {
                String name = req.getParameter("name");
                String type = req.getParameter("type");
                int teamSize = Integer.parseInt(req.getParameter("teamSize"));
                String leaderName = req.getParameter("leaderName");
                String phone = req.getParameter("phone");

                Map<String, Object> payload = new HashMap<>();
                payload.put("name", name);
                payload.put("type", type);
                payload.put("teamSize", teamSize);
                payload.put("leaderName", leaderName);
                payload.put("phone", phone);

                HttpPost httpPost = new HttpPost(API_BASE_URL + "/admin/teams");
                httpPost.setHeader("Authorization", "Bearer " + token);
                httpPost.setHeader("Content-Type", "application/json");
                httpPost.setEntity(new StringEntity(objectMapper.writeValueAsString(payload)));

                try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
                    if (response.getCode() == 201) {
                        resp.sendRedirect(req.getContextPath() + "/admin/teams");
                    } else {
                        resp.setStatus(response.getCode());
                        resp.getWriter().write(EntityUtils.toString(response.getEntity()));
                    }
                }
            } else if (pathInfo != null && pathInfo.equals("/simulations/create")) {
                String name = req.getParameter("name");
                String scenarioType = req.getParameter("scenarioType");
                int intensityLevel = Integer.parseInt(req.getParameter("intensity"));
                double lat = Double.parseDouble(req.getParameter("lat"));
                double lng = Double.parseDouble(req.getParameter("lng"));
                double radiusKm = Double.parseDouble(req.getParameter("radius"));

                Map<String, Object> payload = new HashMap<>();
                payload.put("name", name);
                payload.put("scenarioType", scenarioType);
                payload.put("intensityLevel", intensityLevel);
                payload.put("lat", lat);
                payload.put("lng", lng);
                payload.put("radiusKm", radiusKm);

                HttpPost httpPost = new HttpPost(API_BASE_URL + "/admin/simulations");
                httpPost.setHeader("Authorization", "Bearer " + token);
                httpPost.setHeader("Content-Type", "application/json");
                httpPost.setEntity(new StringEntity(objectMapper.writeValueAsString(payload)));

                try (CloseableHttpResponse response = httpClient.execute(httpPost)) {
                    if (response.getCode() == 201) {
                        resp.sendRedirect(req.getContextPath() + "/admin/simulations");
                    } else {
                        resp.setStatus(response.getCode());
                        resp.getWriter().write(EntityUtils.toString(response.getEntity()));
                    }
                }
            } else {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            throw new ServletException("Erreur de modification admin", e);
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
