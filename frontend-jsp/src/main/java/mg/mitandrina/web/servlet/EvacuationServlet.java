package mg.mitandrina.web.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;

/**
 * 🌪️ MITANDRINA - EvacuationServlet
 * Gère le calcul et l'affichage des itinéraires d'évacuation optimaux
 */
@WebServlet(name = "EvacuationServlet", urlPatterns = {"/evacuation"})
public class EvacuationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("token") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        @SuppressWarnings("unchecked")
        Map<String, Object> user = (Map<String, Object>) session.getAttribute("user");

        // Paramètres optionnels d'alerte ou de refuge cibles
        String alertId = req.getParameter("alert");
        String shelterId = req.getParameter("shelter");

        req.setAttribute("targetAlertId", alertId);
        req.setAttribute("targetShelterId", shelterId);
        req.setAttribute("userLat", user.getOrDefault("locationLat", -18.9078));
        req.setAttribute("userLng", user.getOrDefault("locationLng", 47.5208));

        req.getRequestDispatcher("/WEB-INF/views/evacuation.jsp").forward(req, resp);
    }
}
