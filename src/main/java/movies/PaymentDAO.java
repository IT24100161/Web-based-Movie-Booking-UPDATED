package movies;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO for reading / deleting payment records.
 * - listPayments(...) shows payments joined with booking + movie, with optional filters
 * - deletePaymentById(...) deletes a payment row by primary key
 *
 * Notes:
 * - The seats column uses MySQL's GROUP_CONCAT; adjust if you use a different DB.
 * - All methods use prepared statements.
 */
public class PaymentDAO {
    private final DataSource ds;

    public PaymentDAO(DataSource ds) {
        this.ds = ds;
    }

    /**
     * List payments joined with bookings & movies.
     * Optional filters by bookingId, phone (LIKE), method (=).
     *
     * Columns returned (mapped to PaymentView):
     *  - payment_id, booking_id, payer_name, phone, method, paid_at, movie_title, seats
     */
    public List<PaymentView> listPayments(Long bookingId, String phone, String method) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT p.id AS payment_id, p.booking_id, p.payer_name, p.phone, p.method, p.paid_at, " +
                        "       m.title AS movie_title, " +
                        "       (SELECT GROUP_CONCAT(bs.seat_label ORDER BY bs.seat_label SEPARATOR ',') " +
                        "          FROM booking_seats bs WHERE bs.booking_id = p.booking_id) AS seats " +
                        "FROM payments p " +
                        "JOIN bookings b ON p.booking_id = b.id " +
                        "JOIN movies   m ON b.movie_id   = m.id "
        );

        List<Object> params = new ArrayList<>();
        List<Integer> types  = new ArrayList<>();
        boolean whereAdded = false;

        if (bookingId != null) {
            sql.append(whereAdded ? " AND" : " WHERE").append(" p.booking_id = ?");
            params.add(bookingId); types.add(Types.BIGINT);
            whereAdded = true;
        }
        if (phone != null && !phone.trim().isEmpty()) {
            sql.append(whereAdded ? " AND" : " WHERE").append(" p.phone LIKE ?");
            params.add("%" + phone.trim() + "%"); types.add(Types.VARCHAR);
            whereAdded = true;
        }
        if (method != null && !method.trim().isEmpty()) {
            sql.append(whereAdded ? " AND" : " WHERE").append(" p.method = ?");
            params.add(method.trim()); types.add(Types.VARCHAR);
            whereAdded = true;
        }

        sql.append(" ORDER BY p.paid_at DESC");

        List<PaymentView> out = new ArrayList<>();
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                int t = types.get(i);
                if (t == Types.BIGINT) {
                    ps.setLong(i + 1, (Long) params.get(i));
                } else {
                    ps.setString(i + 1, (String) params.get(i));
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PaymentView v = new PaymentView();
                    v.setPaymentId(rs.getLong("payment_id"));
                    v.setBookingId(rs.getLong("booking_id"));
                    v.setPayerName(rs.getString("payer_name"));
                    v.setPhone(rs.getString("phone"));
                    v.setMethod(rs.getString("method"));
                    v.setPaidAt(rs.getTimestamp("paid_at"));
                    v.setMovieTitle(rs.getString("movie_title"));
                    v.setSeats(rs.getString("seats"));
                    out.add(v);
                }
            }
        }
        return out;
    }

    /**
     * Delete one payment by its primary key ID.
     *
     * @param paymentId ID in payments.id
     * @return number of rows deleted (0 or 1)
     */
    public int deletePaymentById(long paymentId) throws SQLException {
        final String sql = "DELETE FROM payments WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, paymentId);
            return ps.executeUpdate();
        }
    }
}
