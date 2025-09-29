// src/main/java/movies/SeatDAO.java
package movies;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SeatDAO {
    private final DataSource ds;
    public SeatDAO(DataSource ds) { this.ds = ds; }

    /** Create rows x cols seat grid if not already present for the movie. */
    public void initSeatsIfMissing(int movieId, int rows, int cols) throws Exception {
        try (Connection con = ds.getConnection()) {
            int count = 0;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM movie_seats WHERE movie_id=?")) {
                ps.setInt(1, movieId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) count = rs.getInt(1); }
            }
            if (count > 0) return;

            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO movie_seats(movie_id, seat_label, booked) VALUES(?,?,0)")) {
                for (int r = 0; r < rows; r++) {
                    char rowChar = (char)('A' + r);
                    for (int c = 1; c <= cols; c++) {
                        ps.setInt(1, movieId);
                        ps.setString(2, rowChar + String.valueOf(c));
                        ps.addBatch();
                    }
                }
                ps.executeBatch();
            }
        }
    }

    public List<Seat> getSeatsByMovie(int movieId) throws Exception {
        List<Seat> list = new ArrayList<>();
        String sql = "SELECT id, movie_id, seat_label, booked FROM movie_seats WHERE movie_id=? ORDER BY seat_label";
        try (Connection con = ds.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Seat(
                            rs.getInt("id"),
                            rs.getInt("movie_id"),
                            rs.getString("seat_label"),
                            rs.getBoolean("booked")
                    ));
                }
            }
        }
        return list;
    }

    /** Internal: mark seats booked inside an existing transaction. */
    int markSeatsBooked(Connection con, int movieId, List<String> seatLabels) throws Exception {
        int updated = 0;
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE movie_seats SET booked=1 WHERE movie_id=? AND seat_label=? AND booked=0")) {
            for (String s : seatLabels) {
                ps.setInt(1, movieId);
                ps.setString(2, s);
                updated += ps.executeUpdate();
            }
        }
        return updated;
    }
}
