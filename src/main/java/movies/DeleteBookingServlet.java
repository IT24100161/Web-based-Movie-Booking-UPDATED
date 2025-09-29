// src/main/java/movies/DeleteBookingServlet.java
package movies;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import javax.sql.DataSource;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/DeleteBookingServlet")
public class DeleteBookingServlet extends HttpServlet {

    @Resource(name = "jdbc/MovieDB")
    private DataSource dataSource;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String ctx = req.getContextPath();
        String idStr = req.getParameter("bookingId");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(ctx + "/AdminBookingsServlet?err=" +
                    URLEncoder.encode("Missing booking id", "UTF-8"));
            return;
        }
        try {
            int bookingId = Integer.parseInt(idStr);
            BookingDAO dao = new BookingDAO(dataSource);
            boolean ok = dao.deleteBookingAndFreeSeats(bookingId);

            if (ok) {
                resp.sendRedirect(ctx + "/AdminBookingsServlet?msg=" +
                        URLEncoder.encode("Booking #" + bookingId + " deleted and seats freed.", "UTF-8"));
            } else {
                resp.sendRedirect(ctx + "/AdminBookingsServlet?err=" +
                        URLEncoder.encode("Failed to delete booking #" + bookingId, "UTF-8"));
            }
        } catch (NumberFormatException nfe) {
            resp.sendRedirect(ctx + "/AdminBookingsServlet?err=" +
                    URLEncoder.encode("Invalid booking id", "UTF-8"));
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
