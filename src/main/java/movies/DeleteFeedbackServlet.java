// src/main/java/movies/DeleteFeedbackServlet.java
package movies;

import jakarta.annotation.Resource;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import javax.sql.DataSource;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/DeleteFeedbackServlet")
public class DeleteFeedbackServlet extends HttpServlet {

    @Resource(name = "jdbc/MovieDB")
    private DataSource dataSource;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idStr = req.getParameter("id");
        String ctx = req.getContextPath();

        try {
            int id = Integer.parseInt(idStr);
            new FeedbackDAO(dataSource).deleteById(id);
            String msg = URLEncoder.encode("Feedback deleted.", StandardCharsets.UTF_8);
            resp.sendRedirect(ctx + "/AdminFeedbacksServlet?msg=" + msg);
        } catch (Exception e) {
            String msg = URLEncoder.encode("Delete failed: " + (e.getMessage() == null ? "" : e.getMessage()), StandardCharsets.UTF_8);
            resp.sendRedirect(ctx + "/AdminFeedbacksServlet?msg=" + msg);
        }
    }
}
