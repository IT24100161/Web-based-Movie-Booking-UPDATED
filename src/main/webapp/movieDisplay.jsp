<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.naming.InitialContext, javax.sql.DataSource" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Now Showing - Movie Schedule</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- CSS / Fonts -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <!-- Speed up background fetch -->
    <link rel="preconnect" href="https://images.unsplash.com" crossorigin>
    <link rel="preload" as="image"
          href="https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop"/>

    <style>
        :root {
            --bg-url: url('https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop');
        }

        html, body { height: 100%; margin: 0; font-family: 'Roboto', Arial, sans-serif; }

        body {
            position: relative; color: #fff; background-color: #0b0b0b;
            min-height: 100%; overflow-x: hidden; padding-top: 96px;
        }
        body::before {
            content: ""; position: fixed; inset: 0; z-index: 0;
            background-image: var(--bg-url); background-size: cover;
            background-position: 55% -80px; background-repeat: no-repeat;
            box-shadow: inset 0 0 0 100vmax rgba(0,0,0,0.35);
        }

        .nav-btns { position: fixed; top: 20px; left: 20px; display: flex; gap: 10px; z-index: 2; }
        .right-btn { position: fixed; top: 20px; right: 20px; z-index: 2; }

        .wrap { position: relative; z-index: 1; width: min(1100px, 92vw); margin: 0 auto; }

        .header { text-align: center; margin-bottom: 18px; }
        .header h1 { font-size: 40px; font-weight: 800; text-shadow: 0 3px 10px rgba(0,0,0,.6); }

        .search-bar {
            background: rgba(0,0,0,0.55); border-radius: 14px; padding: 12px 16px;
            backdrop-filter: blur(8px);
            box-shadow: 0 8px 24px rgba(0,0,0,.45); margin: 0 auto 16px; width: min(700px, 100%);
        }
        .search-bar input {
            width: 100%; border: none; border-radius: 10px; padding: 12px 14px;
            background: rgba(255,255,255,0.9); color: #000; font-weight: 600;
            outline: none;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 16px;
        }

        .card-movie {
            background: linear-gradient(135deg, rgba(255,255,255,0.95), rgba(255,255,255,0.88));
            color: #111; border-radius: 16px; padding: 18px 16px;
            min-height: 100px; display: flex; align-items: center; gap: 14px;
            box-shadow: 0 10px 26px rgba(0,0,0,.35);
            transition: transform .18s ease, box-shadow .18s ease;
            text-decoration: none;
        }
        .card-movie:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 36px rgba(0,0,0,.50);
        }

        .badge-round {
            flex: 0 0 48px; height: 48px; width: 48px; border-radius: 50%;
            display: grid; place-items: center; font-weight: 800; color: #fff;
            background: linear-gradient(135deg, #ff6f61, #ff3d2e);
            box-shadow: 0 6px 16px rgba(255, 61, 46, .45);
        }
        .title { font-size: 18px; font-weight: 800; line-height: 1.2; }

        .empty {
            text-align: center; padding: 40px; background: rgba(0,0,0,0.55);
            border-radius: 16px; backdrop-filter: blur(8px);
            box-shadow: 0 8px 24px rgba(0,0,0,.45);
        }
    </style>
</head>
<body>

<!-- Navigation buttons -->
<div class="nav-btns">
    <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-outline-light btn-sm">← Back</a>
    <a href="<%= request.getContextPath() %>/viewOffers.jsp" class="btn btn-info btn-sm">View Offers</a>
</div>
<div class="right-btn">
    <a href="<%= request.getContextPath() %>/adminLogin.jsp" class="btn btn-danger btn-sm">Admin Panel</a>
</div>

<div class="wrap">
    <div class="header">
        <h1>🎬 Now Showing</h1>
    </div>

    <!-- Search -->
    <div class="search-bar">
        <input id="searchInput" type="text" placeholder="Search movies...">
    </div>

    <%
        class MovieRow {
            int id; String title;
            MovieRow(int id, String t){ this.id=id; this.title=t; }
        }
        List<MovieRow> movies = new ArrayList<>();
        try {
            DataSource ds = (DataSource) new InitialContext().lookup("java:comp/env/jdbc/MovieDB");
            String sql = "SELECT id, title FROM movies ORDER BY id DESC";
            try (Connection conn = ds.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    movies.add(new MovieRow(rs.getInt("id"), rs.getString("title")));
                }
            }
        } catch (Exception e) {
    %>
    <div class="alert alert-danger">Error loading movies: <%= e.getMessage() %></div>
    <%
        }
    %>

    <% if (movies.isEmpty()) { %>
    <div class="empty">No movies available right now. Please check back later.</div>
    <% } else { %>
    <div id="grid" class="grid">
        <%
            for (MovieRow m : movies) {
                String safe = m.title == null ? "" : m.title;
                String initial = safe.trim().isEmpty() ? "?" : safe.substring(0,1).toUpperCase();
        %>
        <a class="card-movie" href="<%= request.getContextPath() %>/seating.jsp?movieId=<%= m.id %>">
            <div class="badge-round"><%= initial %></div>
            <div class="title"><%= safe %></div>
        </a>
        <% } %>
    </div>
    <% } %>
</div>

<script>
    (function(){
        const input = document.getElementById('searchInput');
        const cards = document.querySelectorAll('.card-movie');
        if (!input) return;
        input.addEventListener('input', function(){
            const q = this.value.trim().toLowerCase();
            cards.forEach(c => {
                const title = c.textContent.trim().toLowerCase();
                c.style.display = title.includes(q) ? '' : 'none';
            });
        });
    })();
</script>

</body>
</html>
