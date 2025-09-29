package movies;

import jakarta.annotation.Resource;
import javax.sql.DataSource;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class FeedbackDAO {

    @Resource(name = "jdbc/MovieDB")
    private DataSource dataSource;

    public FeedbackDAO() {}

    public FeedbackDAO(DataSource ds) {
        this.dataSource = ds;
    }

    /** Utility to get a connection (works with @Resource or manual JNDI) */
    private Connection getConnection() throws Exception {
        if (dataSource != null) return dataSource.getConnection();

        try {
            InitialContext ctx = new InitialContext();
            DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/MovieDB");
            if (ds == null) throw new NamingException("jdbc/MovieDB not found");
            return ds.getConnection();
        } catch (NamingException ne) {
            throw new Exception("JNDI lookup failed for jdbc/MovieDB. Check your server config.", ne);
        }
    }

    /** Insert new feedback */
    public void create(String name, String email, String description) throws Exception {
        String sql = "INSERT INTO feedback (name, email, description, created_at) VALUES (?, ?, ?, ?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, description);
            ps.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now()));

            ps.executeUpdate();
        }
    }

    /** List all feedbacks, newest first */
    public List<Feedback> listAll() throws Exception {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT id, name, email, description, created_at FROM feedback ORDER BY created_at DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Feedback f = new Feedback();
                f.setId(rs.getInt("id"));
                f.setName(rs.getString("name"));
                f.setEmail(rs.getString("email"));
                f.setDescription(rs.getString("description"));

                Timestamp ts = rs.getTimestamp("created_at");
                f.setCreatedAt(ts == null ? null : ts.toLocalDateTime());

                list.add(f);
            }
        }
        return list;
    }

    /** Delete a feedback by ID */
    public void deleteById(int id) throws Exception {
        String sql = "DELETE FROM feedback WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }
}
