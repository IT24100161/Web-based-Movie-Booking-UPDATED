package movies;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServlet;
import javax.sql.DataSource;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;

@WebServlet("/BookSeatsServlet")
public class BookSeatsServlet extends HttpServlet {

    @Resource(name = "jdbc/MovieDB")
    private DataSource dataSource;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String ctx = req.getContextPath();
        String movieIdStr = req.getParameter("movieId");
        String[] seatsArr = req.getParameterValues("seats");

        String name  = req.getParameter("name");   // optional
        String email = req.getParameter("email");  // optional
        String phone = req.getParameter("phone");  // optional

        if (movieIdStr == null || seatsArr == null || seatsArr.length == 0) {
            String err = URLEncoder.encode("Please select at least one seat", StandardCharsets.UTF_8.name());
            resp.sendRedirect(ctx + "/seating.jsp?movieId=" + (movieIdStr != null ? movieIdStr : "") + "&err=" + err);
            return;
        }

        int movieId = Integer.parseInt(movieIdStr);
        List<String> seats = Arrays.asList(seatsArr);

        try {
            BookingDAO dao = new BookingDAO(dataSource);
            int bookingId = dao.createBookingWithSeats(movieId, name, email, phone, seats);

            if (bookingId < 0) {
                String err = URLEncoder.encode(
                        "One or more selected seats were just booked. Please try different seats.",
                        StandardCharsets.UTF_8.name()
                );
                resp.sendRedirect(ctx + "/seating.jsp?movieId=" + movieId + "&err=" + err);
            } else {
                String msg = URLEncoder.encode("Booking successful! ID #" + bookingId, StandardCharsets.UTF_8.name());
                // ✅ Include bookingId so the next step (Add Payment / Customer Details) doesn't require reselecting seats
                resp.sendRedirect(ctx + "/seating.jsp?movieId=" + movieId + "&msg=" + msg + "&bookingId=" + bookingId);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
