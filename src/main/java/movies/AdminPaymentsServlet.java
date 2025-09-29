package movies;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.servlet.RequestDispatcher;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/admin/payments")
public class AdminPaymentsServlet extends HttpServlet {

    @Resource(name = "jdbc/MovieDB")
    private DataSource dataSource;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String bookingIdParam = req.getParameter("bookingId");
        String phoneParam     = req.getParameter("phone");
        String methodParam    = req.getParameter("method");
        String debug          = req.getParameter("debug");

        Long bookingIdFilter = null;
        try {
            if (bookingIdParam != null && !bookingIdParam.trim().isEmpty()) {
                bookingIdFilter = Long.parseLong(bookingIdParam.trim());
            }
        } catch (NumberFormatException ignore) {}

        try {
            if (dataSource == null) throw new IllegalStateException("JNDI DataSource 'jdbc/MovieDB' not injected");

            PaymentDAO dao = new PaymentDAO(dataSource);
            List<PaymentView> payments = dao.listPayments(bookingIdFilter, phoneParam, methodParam);

            // Quick debug output if requested
            if ("1".equals(debug)) {
                resp.setContentType("text/plain");
                PrintWriter out = resp.getWriter();
                out.println("Debug OK");
                out.println("payments.size = " + (payments == null ? "null" : payments.size()));
                out.println("filters: bookingId=" + bookingIdFilter + ", phone=" + phoneParam + ", method=" + methodParam);
                out.flush();
                return;
            }

            req.setAttribute("payments", payments);
            req.setAttribute("bookingId", bookingIdParam);
            req.setAttribute("phone", phoneParam);
            req.setAttribute("method", methodParam);

            // Forward to JSP located at /adminPayments.jsp (webapp root)
            RequestDispatcher rd = req.getRequestDispatcher("/adminPayments.jsp");
            rd.forward(req, resp);

        } catch (Exception e) {
            // In case forwarding fails or JNDI missing, show the reason
            resp.setContentType("text/plain");
            e.printStackTrace(resp.getWriter());
        }
    }
}
