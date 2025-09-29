package movies;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import javax.sql.DataSource;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name = "DeletePaymentServlet", urlPatterns = {"/DeletePaymentServlet"})
public class DeletePaymentServlet extends HttpServlet {
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

        String idStr = req.getParameter("paymentId");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/adminPayments.jsp?error=Missing+paymentId");
            return;
        }

        long paymentId;
        try {
            paymentId = Long.parseLong(idStr);
        } catch (NumberFormatException nfe) {
            resp.sendRedirect(req.getContextPath() + "/adminPayments.jsp?error=Invalid+paymentId");
            return;
        }

        PaymentDAO dao = new PaymentDAO(ds);
        try {
            int rows = dao.deletePaymentById(paymentId);
            if (rows == 1) {
                resp.sendRedirect(req.getContextPath() + "/adminPayments.jsp?deleted=1");
            } else {
                resp.sendRedirect(req.getContextPath() + "/adminPayments.jsp?error=Not+found");
            }
        } catch (SQLException e) {
            // Optional: log e
            resp.sendRedirect(req.getContextPath() + "/adminPayments.jsp?error=Delete+failed");
        }
    }
}
