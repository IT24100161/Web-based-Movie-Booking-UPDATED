package movies;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class MovieDAO {

    private final DataSource ds;

    public MovieDAO(DataSource ds) {
        this.ds = ds;
    }

    public boolean addMovie(String title) {
        String sql = "INSERT INTO movies (title) VALUES (?)";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace(); // consider logging properly
            return false;
        }
    }

    public boolean deleteMovie(int id) {
        String sql = "DELETE FROM movies WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() == 1; // true if one row deleted
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
