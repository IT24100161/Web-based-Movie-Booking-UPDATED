package movies;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OfferDAO {

    private final DataSource ds;

    public OfferDAO(DataSource dataSource) {
        this.ds = dataSource;
    }

    /** Returns true if one row was inserted */
    public boolean addOffer(String title) throws SQLException {
        final String sql = "INSERT INTO offers (title) VALUES (?)";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            return ps.executeUpdate() == 1;
        }
    }

    /** Returns all offers ordered by most recent */
    public List<Offer> getAllOffers() throws SQLException {
        final String sql = "SELECT id, title, created_at FROM offers ORDER BY created_at DESC";
        List<Offer> list = new ArrayList<>();
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Offer o = new Offer();
                o.setId(rs.getInt("id"));
                o.setTitle(rs.getString("title"));

                // Some MySQL drivers support JDBC 4.2 getObject(..., LocalDateTime.class)
                // but to be safe across versions we use Timestamp -> toLocalDateTime().
                Timestamp ts = rs.getTimestamp("created_at");
                if (ts != null) {
                    o.setCreatedAt(ts.toLocalDateTime());
                }
                list.add(o);
            }
        }
        return list;
    }

    /** Returns true if one row was deleted */
    public boolean deleteOffer(int id) throws SQLException {
        final String sql = "DELETE FROM offers WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() == 1;
        }
    }
}
