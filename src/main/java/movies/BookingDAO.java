package movies;

import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

/**
 * BookingDAO — handles booking CRUD and queries.
 *
 * Tables expected:
 *   movies(id, title)
 *   bookings(id, movie_id, customer_name, customer_email, customer_phone, booked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)
 *   booking_seats(id, booking_id, movie_id, seat_label, UNIQUE KEY uniq_movie_seat_once (movie_id, seat_label))
 *   movie_seats(id, movie_id, seat_label, booked TINYINT(1), UNIQUE KEY uniq_movie_seat (movie_id, seat_label))
 */
public class BookingDAO {

    private final DataSource ds;

    public BookingDAO(DataSource ds) {
        this.ds = ds;
    }

    /**
     * Create a booking and reserve seats atomically.
     * @return booking_id on success, or -1 if any chosen seat was already booked.
     */
    public int createBookingWithSeats(int movieId, String name, String email, String phone, List<String> seatLabels) throws Exception {
        if (seatLabels == null || seatLabels.isEmpty()) return -1;

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = ds.getConnection();
            con.setAutoCommit(false);

            // 1) Insert booking header (stores name/email/phone)
            ps = con.prepareStatement(
                    "INSERT INTO bookings(movie_id, customer_name, customer_email, customer_phone) VALUES (?,?,?,?)",
                    Statement.RETURN_GENERATED_KEYS
            );
            ps.setInt(1, movieId);
            ps.setString(2, name);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            int bookingId = -1;
            if (rs.next()) bookingId = rs.getInt(1);
            rs.close(); rs = null;
            ps.close(); ps = null;

            // 2) Insert seats for this booking (unique(movie_id, seat_label) prevents dup seat across bookings)
            ps = con.prepareStatement("INSERT INTO booking_seats(booking_id, movie_id, seat_label) VALUES (?,?,?)");
            for (String s : seatLabels) {
                ps.setInt(1, bookingId);
                ps.setInt(2, movieId);
                ps.setString(3, s);
                ps.addBatch();
            }
            ps.executeBatch();
            ps.close(); ps = null;

            // 3) Flip movie_seats.booked to 1 for each selected seat, but only if currently 0
            int flipped = 0;
            try (PreparedStatement upd = con.prepareStatement(
                    "UPDATE movie_seats SET booked=1 WHERE movie_id=? AND seat_label=? AND booked=0")) {
                for (String s : seatLabels) {
                    upd.setInt(1, movieId);
                    upd.setString(2, s);
                    flipped += upd.executeUpdate();
                }
            }

            if (flipped != seatLabels.size()) {
                // Some seat was taken concurrently; rollback and signal failure
                con.rollback();
                return -1;
            }

            con.commit();
            return bookingId;

        } catch (SQLIntegrityConstraintViolationException dup) {
            if (con != null) con.rollback();
            return -1; // unique constraint on (movie_id, seat_label) hit
        } catch (Exception e) {
            if (con != null) con.rollback();
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignored) {}
            if (ps != null) try { ps.close(); } catch (Exception ignored) {}
            if (con != null) try { con.setAutoCommit(true); con.close(); } catch (Exception ignored) {}
        }
    }

    /** Admin view: list all bookings with movie title and seats (most recent first). */
    public List<Booking> listAllWithSeats() throws Exception {
        List<Booking> out = new ArrayList<>();
        Map<Integer, Booking> map = new LinkedHashMap<>();

        // 1) headers
        final String q1 =
                "SELECT b.id, b.movie_id, m.title AS movie_title, " +
                        "       b.customer_name, b.customer_email, b.customer_phone, b.booked_at " +
                        "FROM bookings b " +
                        "JOIN movies m ON m.id = b.movie_id " +
                        "ORDER BY b.booked_at DESC";

        try (Connection con = ds.getConnection();
             PreparedStatement ps = con.prepareStatement(q1);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int id = rs.getInt("id");
                int movieId = rs.getInt("movie_id");
                String title = rs.getString("movie_title");
                String name = rs.getString("customer_name");
                String email = rs.getString("customer_email");
                String phone = rs.getString("customer_phone");
                Timestamp ts = rs.getTimestamp("booked_at");
                LocalDateTime at = ts != null ? ts.toLocalDateTime() : null;

                map.put(id, new Booking(id, movieId, title, name, email, phone, at, new ArrayList<>()));
            }
        }

        if (map.isEmpty()) return out;

        // 2) seats for those bookings
        String placeholders = String.join(",", Collections.nCopies(map.size(), "?"));
        final String q2 =
                "SELECT booking_id, seat_label FROM booking_seats " +
                        "WHERE booking_id IN (" + placeholders + ") " +
                        "ORDER BY seat_label";

        try (Connection con = ds.getConnection();
             PreparedStatement ps = con.prepareStatement(q2)) {
            int i = 1;
            for (Integer id : map.keySet()) ps.setInt(i++, id);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int bid = rs.getInt("booking_id");
                    String seat = rs.getString("seat_label");
                    Booking b = map.get(bid);
                    if (b != null) b.getSeatLabels().add(seat);
                }
            }
        }

        out.addAll(map.values());
        return out;
    }

    /** Convenience: list bookings for a single movie id (grouped with seats). */
    public List<Booking> listByMovie(int movieId) throws Exception {
        List<Booking> out = new ArrayList<>();
        Map<Integer, Booking> map = new LinkedHashMap<>();

        final String q1 =
                "SELECT b.id, b.movie_id, m.title AS movie_title, " +
                        "       b.customer_name, b.customer_email, b.customer_phone, b.booked_at " +
                        "FROM bookings b " +
                        "JOIN movies m ON m.id = b.movie_id " +
                        "WHERE b.movie_id=? " +
                        "ORDER BY b.booked_at DESC";

        try (Connection con = ds.getConnection();
             PreparedStatement ps = con.prepareStatement(q1)) {
            ps.setInt(1, movieId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int id = rs.getInt("id");
                    String title = rs.getString("movie_title");
                    String name = rs.getString("customer_name");
                    String email = rs.getString("customer_email");
                    String phone = rs.getString("customer_phone");
                    Timestamp ts = rs.getTimestamp("booked_at");
                    LocalDateTime at = ts != null ? ts.toLocalDateTime() : null;

                    map.put(id, new Booking(id, movieId, title, name, email, phone, at, new ArrayList<>()));
                }
            }
        }

        if (map.isEmpty()) return out;

        String placeholders = String.join(",", Collections.nCopies(map.size(), "?"));
        final String q2 =
                "SELECT booking_id, seat_label FROM booking_seats " +
                        "WHERE booking_id IN (" + placeholders + ") " +
                        "ORDER BY seat_label";

        try (Connection con = ds.getConnection();
             PreparedStatement ps = con.prepareStatement(q2)) {
            int i = 1;
            for (Integer id : map.keySet()) ps.setInt(i++, id);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int bid = rs.getInt("booking_id");
                    String seat = rs.getString("seat_label");
                    Booking b = map.get(bid);
                    if (b != null) b.getSeatLabels().add(seat);
                }
            }
        }

        out.addAll(map.values());
        return out;
    }

    /** Helper: return all seat labels for a booking. */
    public List<String> getSeatsForBooking(int bookingId) throws Exception {
        List<String> seats = new ArrayList<>();
        final String q = "SELECT seat_label FROM booking_seats WHERE booking_id=? ORDER BY seat_label";
        try (Connection con = ds.getConnection();
             PreparedStatement ps = con.prepareStatement(q)) {
            ps.setInt(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) seats.add(rs.getString("seat_label"));
            }
        }
        return seats;
    }

    /**
     * Delete a booking and free its seats (sets movie_seats.booked=0) atomically.
     * @return true on success, false if booking header was not deleted.
     */
    public boolean deleteBookingAndFreeSeats(int bookingId) throws Exception {
        Connection con = null;
        try {
            con = ds.getConnection();
            con.setAutoCommit(false);

            // 1) Free seats
            try (PreparedStatement unbook = con.prepareStatement(
                    "UPDATE movie_seats ms " +
                            "JOIN booking_seats bs ON bs.movie_id = ms.movie_id AND bs.seat_label = ms.seat_label " +
                            "SET ms.booked = 0 " +
                            "WHERE bs.booking_id = ?")) {
                unbook.setInt(1, bookingId);
                unbook.executeUpdate();
            }

            // 2) Delete row(s) from booking_seats
            try (PreparedStatement delSeats = con.prepareStatement(
                    "DELETE FROM booking_seats WHERE booking_id = ?")) {
                delSeats.setInt(1, bookingId);
                delSeats.executeUpdate();
            }

            // 3) Delete booking header
            int affected;
            try (PreparedStatement delBooking = con.prepareStatement(
                    "DELETE FROM bookings WHERE id = ?")) {
                delBooking.setInt(1, bookingId);
                affected = delBooking.executeUpdate();
            }

            if (affected != 1) {
                con.rollback();
                return false;
            }

            con.commit();
            return true;

        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (Exception ignored) {}
            throw e;
        } finally {
            if (con != null) try { con.setAutoCommit(true); con.close(); } catch (Exception ignored) {}
        }
    }

    /**
     * Search bookings by movie title, customer name/email/phone, booking id, or seat label.
     * Returns bookings with their movie title and seats.
     */
    public List<Booking> searchBookings(String rawQuery) throws Exception {
        String q = rawQuery == null ? "" : rawQuery.trim();
        if (q.isEmpty()) return new ArrayList<>();

        String like = "%" + q + "%";
        Map<Integer, Booking> map = new LinkedHashMap<>();

        // 1) Headers that match query
        final String sql =
                "SELECT DISTINCT b.id, b.movie_id, m.title AS movie_title, " +
                        "       b.customer_name, b.customer_email, b.customer_phone, b.booked_at " +
                        "FROM bookings b " +
                        "JOIN movies m ON m.id = b.movie_id " +
                        "LEFT JOIN booking_seats bs ON bs.booking_id = b.id " +
                        "WHERE m.title LIKE ? " +
                        "   OR b.customer_name LIKE ? " +
                        "   OR b.customer_email LIKE ? " +
                        "   OR b.customer_phone LIKE ? " +
                        "   OR CAST(b.id AS CHAR) LIKE ? " +
                        "   OR bs.seat_label LIKE ? " +
                        "ORDER BY b.booked_at DESC";

        try (Connection con = ds.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setString(4, like);
            ps.setString(5, like);
            ps.setString(6, like);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int id = rs.getInt("id");
                    int movieId = rs.getInt("movie_id");
                    String title = rs.getString("movie_title");
                    String name = rs.getString("customer_name");
                    String email = rs.getString("customer_email");
                    String phone = rs.getString("customer_phone");
                    Timestamp ts = rs.getTimestamp("booked_at");
                    LocalDateTime at = ts != null ? ts.toLocalDateTime() : null;

                    map.put(id, new Booking(id, movieId, title, name, email, phone, at, new ArrayList<>()));
                }
            }
        }

        if (map.isEmpty()) return new ArrayList<>();

        // 2) Seats for the matched bookings
        String placeholders = String.join(",", Collections.nCopies(map.size(), "?"));
        final String seatSql =
                "SELECT booking_id, seat_label FROM booking_seats " +
                        "WHERE booking_id IN (" + placeholders + ") " +
                        "ORDER BY seat_label";

        try (Connection con = ds.getConnection();
             PreparedStatement ps = con.prepareStatement(seatSql)) {
            int i = 1;
            for (Integer id : map.keySet()) ps.setInt(i++, id);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int bid = rs.getInt("booking_id");
                    String seat = rs.getString("seat_label");
                    Booking b = map.get(bid);
                    if (b != null) b.getSeatLabels().add(seat);
                }
            }
        }

        return new ArrayList<>(map.values());
    }
}
