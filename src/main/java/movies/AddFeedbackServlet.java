// AddFeedbackServlet.java
// Replace your.package.here with your real package
package movies;

import jakarta.annotation.Resource;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/AddFeedbackServlet")
public class AddFeedbackServlet extends HttpServlet {

    @Resource(name = "jdbc/MovieDB")
    private DataSource dataSource;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");

        String name = trim(req.getParameter("name"));
        String email = trim(req.getParameter("email"));
        String description = trim(req.getParameter("description"));

        if (description == null || description.isBlank()) {
            send(resp, req, "feedback.jsp", "Description is required.");
            return;
        }
        if (description.length() > 4000) description = description.substring(0, 4000);

        try {
            // DAO handles JNDI fallback if injection is null
            new FeedbackDAO(dataSource).create(limit(name,100), limit(email,150), description);
            send(resp, req, "feedback.jsp", "Thank you, your feedback was submitted!");
        } catch (Exception e) {
            // TEMP: bubble up the exact error so we can see what's wrong
            String err = e.getClass().getSimpleName() + ": " + safe(e.getMessage());
            send(resp, req, "feedback.jsp", "Error saving feedback → " + err);
        }
    }

    private String trim(String s){ return s == null ? null : s.trim(); }
    private String limit(String s, int max){ if(s==null) return null; return s.length() > max ? s.substring(0,max) : s; }
    private String safe(String s){ if (s == null) return ""; return s.replace('\n',' ').replace('\r',' '); }
    private void send(HttpServletResponse resp, HttpServletRequest req, String page, String msg) throws IOException {
        String ctx = req.getContextPath();
        String encoded = URLEncoder.encode(msg, StandardCharsets.UTF_8);
        resp.sendRedirect(ctx + "/" + page + "?msg=" + encoded);
    }
}
