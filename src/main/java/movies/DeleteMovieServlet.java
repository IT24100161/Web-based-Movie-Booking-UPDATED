package movies;

import jakarta.annotation.Resource;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import javax.sql.DataSource;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/DeleteMovieServlet")
public class DeleteMovieServlet extends HttpServlet {

    @Resource(name = "jdbc/MovieDB")
    private DataSource dataSource;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String ctx = request.getContextPath();
        String idParam = request.getParameter("id");

        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(ctx + "/addMovie.jsp?err=" +
                    URLEncoder.encode("Missing movie id", "UTF-8"));
            return;
        }

        try {
            int id = Integer.parseInt(idParam);
            MovieDAO dao = new MovieDAO(dataSource);
            boolean ok = dao.deleteMovie(id);

            if (ok) {
                response.sendRedirect(ctx + "/addMovie.jsp?msg=" +
                        URLEncoder.encode("Movie deleted successfully!", "UTF-8"));
            } else {
                response.sendRedirect(ctx + "/addMovie.jsp?err=" +
                        URLEncoder.encode("Failed to delete movie (id=" + id + ")", "UTF-8"));
            }
        } catch (NumberFormatException nfe) {
            response.sendRedirect(ctx + "/addMovie.jsp?err=" +
                    URLEncoder.encode("Invalid movie id", "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(ctx + "/addMovie.jsp?err=" +
                    URLEncoder.encode("Error: " + e.getMessage(), "UTF-8"));
        }
    }
}
