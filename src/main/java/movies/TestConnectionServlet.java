package movies;

import jakarta.servlet.annotation.WebServlet;
import jakarta.annotation.Resource;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.io.IOException;

@WebServlet("/testConnection")
public class TestConnectionServlet extends HttpServlet {

    @Resource(name = "jdbc/MovieDB")
    private DataSource dataSource;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/plain");
        try (Connection conn = dataSource.getConnection()) {
            response.getWriter().println("✅ Connected to DB: " + conn.getCatalog());
        } catch (SQLException e) {
            e.printStackTrace(response.getWriter());
            response.getWriter().println("❌ DB Connection failed: " + e.getMessage());
        }
    }
}
