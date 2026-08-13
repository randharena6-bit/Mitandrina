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
 * 🌪️ MITANDRINA - MapServlet
 * Gère la page de la carte temps réel
 */
@WebServlet(name = "MapServlet", urlPatterns = {"/map"})
public class MapServlet extends HttpServlet {

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

        // Transmettre les coordonnées de l'utilisateur pour centrer la carte
        req.setAttribute("userLat", user.getOrDefault("locationLat", -18.9078));
        req.setAttribute("userLng", user.getOrDefault("locationLng", 47.5208));

        req.getRequestDispatcher("/WEB-INF/views/map.jsp").forward(req, resp);
    }
}
