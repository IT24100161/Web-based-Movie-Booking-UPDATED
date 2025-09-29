package movies;

import jakarta.annotation.Resource;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import javax.sql.DataSource;

import java.io.IOException;
import java.net.URL;
import java.util.List;

@WebServlet("/AdminFeedbacksServlet")
public class AdminFeedbacksServlet extends HttpServlet {

    @Resource(name = "jdbc/MovieDB")
    private DataSource dataSource;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            List<Feedback> feedbacks = new FeedbackDAO(dataSource).listAll();
            req.setAttribute("feedbacks", feedbacks);

            // Try the intended location first
            String primary = "/admin/adminfeedbacks.jsp";
            String fallback = "/adminfeedbacks.jsp";

            // Check which one actually exists inside the WAR
            URL primaryUrl = getServletContext().getResource(primary);
            String jspToUse = (primaryUrl != null) ? primary : fallback;

            RequestDispatcher rd = getServletContext().getRequestDispatcher(jspToUse);
            rd.forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(500, "Error loading feedbacks: " + e.getMessage());
        }
    }
}
