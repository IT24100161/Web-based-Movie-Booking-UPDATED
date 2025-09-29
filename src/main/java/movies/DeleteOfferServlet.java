package movies;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import javax.sql.DataSource;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/DeleteOfferServlet")
public class DeleteOfferServlet extends HttpServlet {

    @Resource(name = "jdbc/MovieDB")
    private DataSource dataSource;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idStr = request.getParameter("id");
        String ctx = request.getContextPath();

        if (idStr == null) {
            response.sendRedirect(ctx + "/addOffer.jsp?err=" +
                    URLEncoder.encode("Missing offer id", "UTF-8"));
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            OfferDAO dao = new OfferDAO(dataSource);
            dao.deleteOffer(id);
            response.sendRedirect(ctx + "/addOffer.jsp?msg=" +
                    URLEncoder.encode("Offer deleted", "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(ctx + "/addOffer.jsp?err=" +
                    URLEncoder.encode("Error: " + e.getMessage(), "UTF-8"));
        }
    }
}