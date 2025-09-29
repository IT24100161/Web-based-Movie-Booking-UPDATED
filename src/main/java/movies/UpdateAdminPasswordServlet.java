package movies;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import javax.sql.DataSource;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.*;

@WebServlet("/UpdateAdminPasswordServlet")
public class UpdateAdminPasswordServlet extends HttpServlet {

    @Resource(name = "jdbc/MovieDB") // matches your JNDI resource
    private DataSource dataSource;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            response.sendRedirect(request.getContextPath() + "/adminLogin.jsp?error=" +
                    URLEncoder.encode("Please login", "UTF-8"));
            return;
        }

        String username = String.valueOf(session.getAttribute("adminUser"));
        request.setCharacterEncoding("UTF-8");

        String current = trim(request.getParameter("currentPassword"));
        String newer   = trim(request.getParameter("newPassword"));
        String again   = trim(request.getParameter("confirmPassword"));

        if (current.isEmpty() || newer.isEmpty() || again.isEmpty()) {
            redirectMsg(response, request, "err", "All fields are required.");
            return;
        }
        if (!newer.equals(again)) {
            redirectMsg(response, request, "err", "New password and confirmation do not match.");
            return;
        }

        // Your DB uses plaintext passwords (same as AdminLoginServlet), so we match that.
        String selectSql = "SELECT id FROM admin WHERE username = ? AND password = ?";
        String updateSql = "UPDATE admin SET password = ? WHERE id = ?";

        try (Connection conn = dataSource.getConnection()) {
            conn.setAutoCommit(false);

            Integer adminId = null;
            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setString(1, username);
                ps.setString(2, current);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) adminId = rs.getInt("id");
                }
            }

            if (adminId == null) {
                conn.rollback();
                redirectMsg(response, request, "err", "Current password is incorrect.");
                return;
            }

            try (PreparedStatement ups = conn.prepareStatement(updateSql)) {
                ups.setString(1, newer); // store plaintext (like your current design)
                ups.setInt(2, adminId);
                int rows = ups.executeUpdate();
                if (rows == 1) {
                    conn.commit();
                    redirectMsg(response, request, "msg", "Password updated successfully.");
                } else {
                    conn.rollback();
                    redirectMsg(response, request, "err", "Could not update password. Please try again.");
                }
            }
        } catch (SQLException e) {
            redirectMsg(response, request, "err", "Database error: " + e.getMessage());
        }
    }

    private static String trim(String s) {
        return (s == null) ? "" : s.trim();
    }

    private void redirectMsg(HttpServletResponse response, HttpServletRequest request,
                             String key, String value) throws IOException {
        String url = request.getContextPath() + "/changeAdminPassword.jsp?" + key + "=" +
                URLEncoder.encode(value, "UTF-8");
        response.sendRedirect(url);
    }
}
