<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.naming.InitialContext, javax.sql.DataSource" %>
<%@ page import="java.sql.*" %>
<%
    // Flash messages from query param OR request attribute (works with redirect or forward)
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
    if (msg == null && request.getAttribute("msg") != null) msg = String.valueOf(request.getAttribute("msg"));
    if (err == null && request.getAttribute("err") != null) err = String.valueOf(request.getAttribute("err"));
%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Movies (Admin)</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap -->
    <link rel="stylesheet"
          href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <!-- Speed up external image fetch -->
    <link rel="preconnect" href="https://images.unsplash.com" crossorigin>
    <!-- Preload a single cached variant (avoid multiple sizes) -->
    <link rel="preload" as="image"
          href="https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?ixlib=rb-4.1.0&auto=format&fit=crop&w=1920&q=85"/>

    <style>
        :root {
            /* One, fixed URL so the browser caches a single bitmap */
            --bg-url: url('https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?ixlib=rb-4.1.0&auto=format&fit=crop&w=1920&q=85');
        }

        html, body {
            height: 100%;
            margin: 0;
            font-family: 'Roboto', sans-serif;
        }

        /* Fixed background layer that persists smoothly between renders */
        .bg {
            position: fixed;
            inset: 0;                   /* top:0; right:0; bottom:0; left:0 */
            z-index: -2;
            background-image: var(--bg-url);
            background-size: cover;
            background-position: 55% -80px;  /* slightly up + right as you liked */
            background-repeat: no-repeat;

            /* Make it a GPU layer to prevent blink during reflow/paint */
            transform: translateZ(0);
            backface-visibility: hidden;
            will-change: transform;
        }
        /* Soft dark overlay for readability (separate layer so image stays crisp) */
        .bg::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(rgba(0,0,0,0.35), rgba(0,0,0,0.35));
        }

        /* Page content */
        body {
            color: #fff;
            text-shadow: 1px 1px 4px rgba(0,0,0,0.7);
            background-color: #0b0b0b; /* fallback while first paint happens */
        }

        .glass-box {
            background: rgba(0,0,0,0.65);
            border-radius: 15px;
            padding: 25px;
            -webkit-backdrop-filter: blur(8px);
            backdrop-filter: blur(8px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.6);
        }
        .card {
            background: rgba(255,255,255,0.9);
            border-radius: 12px;
            color: #000;
        }
        .table {
            background: rgba(255,255,255,0.9);
            color: #000;
        }
        .thead-dark th {
            background-color: #343a40 !important;
            color: #fff;
        }
    </style>
</head>
<body>

<!-- 🔒 Fixed background layer (prevents blink) -->
<div class="bg" aria-hidden="true"></div>

<div class="container py-4">
    <div class="glass-box mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2 class="mb-0">Add Movie</h2>
            <a href="<%= request.getContextPath() %>/adminPage.jsp"
               class="btn btn-outline-light btn-sm">← Back to Admin Panel</a>
        </div>

        <!-- Flash messages -->
        <% if (msg != null && !msg.isEmpty()) { %>
        <div class="alert alert-success"><%= msg %></div>
        <% } %>
        <% if (err != null && !err.isEmpty()) { %>
        <div class="alert alert-danger"><%= err %></div>
        <% } %>

        <!-- Add Movie Form -->
        <div class="card shadow-sm mb-4">
            <div class="card-body">
                <form action="<%= request.getContextPath() %>/AddMovieServlet" method="post">
                    <div class="form-group">
                        <label for="title">Movie Title</label>
                        <input type="text" id="title" name="title" class="form-control"
                               placeholder="Enter movie title" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Add Movie</button>
                </form>
            </div>
        </div>

        <!-- Movies Table -->
        <h4 class="mb-3">Movies in Database</h4>
        <%
            try {
                DataSource ds = (DataSource) new InitialContext().lookup("java:comp/env/jdbc/MovieDB");
                String sql = "SELECT id, title FROM movies ORDER BY id DESC";
                try (Connection conn = ds.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery()) {
        %>
        <div class="table-responsive">
            <table class="table table-striped table-bordered">
                <thead class="thead-dark">
                <tr>
                    <th style="width:90px;">ID</th>
                    <th>Title</th>
                    <th style="width:120px;">Action</th>
                </tr>
                </thead>
                <tbody>
                <%
                    boolean hasRows = false;
                    while (rs.next()) { hasRows = true; %>
                <tr>
                    <td><%= rs.getInt("id") %></td>
                    <td><%= rs.getString("title") %></td>
                    <td>
                        <a href="<%= request.getContextPath() %>/DeleteMovieServlet?id=<%= rs.getInt("id") %>"
                           class="btn btn-danger btn-sm"
                           onclick="return confirm('Are you sure you want to delete this movie?');">
                            Delete
                        </a>
                    </td>
                </tr>
                <% } if (!hasRows) { %>
                <tr>
                    <td colspan="3" class="text-center text-muted">No movies added yet.</td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <%
            }
        } catch (Exception e) {
        %>
        <div class="alert alert-warning">Could not load movie list: <%= e.getMessage() %></div>
        <% } %>
    </div>
</div>

</body>
</html>

