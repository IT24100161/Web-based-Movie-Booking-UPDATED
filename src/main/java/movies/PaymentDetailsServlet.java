
package movies;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import javax.sql.DataSource;
import java.io.IOException;
import java.sql.*;

@WebServlet(name = "PaymentDetailsServlet", urlPatterns = {"/PaymentDetailsServlet"})
public class PaymentDetailsServlet extends HttpServlet {
    private DataSource ds;

    @Override
    public void init() throws ServletException {
        try {
            ds = (DataSource) new InitialContext().lookup("java:comp/env/jdbc/MovieDB");
        } catch (NamingException e) {
            throw new ServletException("JNDI DataSource lookup failed", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String bookingIdStr = req.getParameter("bookingId");
        String payerName = req.getParameter("payer_name");
        String phone = req.getParameter("phone");
        String method = req.getParameter("method");

        if (payerName == null || payerName.isEmpty()
                || phone == null || phone.isEmpty()
                || method == null || method.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/customerPayment.jsp?error=Missing+fields");
            return;
        }

        if (bookingIdStr == null || bookingIdStr.isEmpty()) {
            // You decided to key payments strictly by booking_id
            resp.sendRedirect(req.getContextPath() + "/customerPayment.jsp?error=Booking+not+confirmed+yet");
            return;
        }

        long bookingId = Long.parseLong(bookingIdStr);

        try (Connection conn = ds.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO payments(booking_id, payer_name, phone, method) VALUES (?,?,?,?)")) {
                ps.setLong(1, bookingId);
                ps.setString(2, payerName);
                ps.setString(3, phone);
                ps.setString(4, method);
                ps.executeUpdate();
            }
            resp.sendRedirect(req.getContextPath() + "/paymentSuccess.jsp?bookingId=" + bookingId);
        } catch (SQLException e) {
            throw new ServletException("Failed to save payment", e);
        }
    }
}
