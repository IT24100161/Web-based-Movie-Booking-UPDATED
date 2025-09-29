package movies;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import javax.sql.DataSource;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.*;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {

    @Resource(name = "jdbc/MovieDB") // from META-INF/context.xml
    private DataSource dataSource;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String ctx = request.getContextPath();

        if (username == null || password == null ||
                (username = username.trim()).isEmpty() ||
                (password = password.trim()).isEmpty()) {
            response.sendRedirect(ctx + "/adminLogin.jsp?error=" +
                    URLEncoder.encode("Username and password are required", "UTF-8"));
            return;
        }

        String sql = "SELECT id, username FROM admin WHERE username = ? AND password = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password); // NOTE: hash in production

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    HttpSession session = request.getSession(true);
                    session.setAttribute("adminUser", rs.getString("username"));
                    session.setAttribute("adminId", rs.getInt("id"));
                    response.sendRedirect(ctx + "/adminPage.jsp");
                } else {
                    response.sendRedirect(ctx + "/adminLogin.jsp?error=" +
                            URLEncoder.encode("Invalid username or password", "UTF-8"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(ctx + "/adminLogin.jsp?error=" +
                    URLEncoder.encode("DB error: " + e.getMessage(), "UTF-8"));
        }
    }

    // Optional: let GET simply show the login page
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/adminLogin.jsp");
    }
}
