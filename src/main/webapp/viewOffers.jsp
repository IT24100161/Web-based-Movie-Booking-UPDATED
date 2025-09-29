<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.naming.InitialContext, javax.sql.DataSource" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Current Offers</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <!-- Speed up background fetch -->
    <link rel="preconnect" href="https://images.unsplash.com" crossorigin>
    <link rel="preload" as="image"
          href="https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop"/>

    <style>
        :root{
            /* Same URL as preload so the browser reuses the cached bitmap */
            --bg-url: url('https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop');
        }

        html, body {
            height: 100%;
            margin: 0;
            font-family: 'Roboto', sans-serif;
            color: #fff;
            text-shadow: 1px 1px 4px rgba(0,0,0,0.7);
            background-color: #0b0b0b; /* safe fallback while first paint happens */
        }

        /* ✅ Fast, no-blink background on a fixed pseudo-element */
        body{
            position: relative; /* required for ::before stacking */
            min-height: 100%;
            overflow-x: hidden;
            z-index: 0;         /* create stacking context */
        }
        body::before{
            content: "";
            position: fixed;    /* stays put on scroll */
            inset: 0;           /* top/right/bottom/left: 0 */
            background-image: var(--bg-url);
            background-size: cover;
            background-position: 55% -80px; /* same composition as other pages */
            background-repeat: no-repeat;
            /* overlay for readability */
            box-shadow: inset 0 0 0 100vmax rgba(0,0,0,0.35);
            z-index: -1;        /* behind content */
            transform: translateZ(0);
            backface-visibility: hidden;
            will-change: transform;
        }

        /* Content box */
        .glass-box {
            position: relative; /* above background */
            z-index: 1;
            background: rgba(0,0,0,0.65);
            border-radius: 15px;
            padding: 25px;
            -webkit-backdrop-filter: blur(8px);
            backdrop-filter: blur(8px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.6);
            margin-top: 24px;
            margin-bottom: 24px;
        }

        .list-group-item {
            background-color: rgba(255,255,255,0.95);
            color: #000;
            font-weight: 600;
            border: none;
        }
        .btn-outline-light.btn-sm {
            border-color: rgba(255,255,255,0.6);
            color: #fff;
        }
        .btn-outline-light.btn-sm:hover {
            background: rgba(255,255,255,0.15);
        }
    </style>
</head>
<body>

<div class="container glass-box">
    <div class="d-flex justify-content-between align-items-center">
        <h2>🎁 Current Offers</h2>
        <a href="<%= request.getContextPath() %>/movieDisplay.jsp" class="btn btn-outline-light btn-sm">← Back to Movies</a>
    </div>
    <hr class="border-light">

    <ul class="list-group">
        <%
            try {
                DataSource ds = (DataSource) new InitialContext().lookup("java:comp/env/jdbc/MovieDB");
                String sql = "SELECT title, created_at FROM offers ORDER BY id DESC";
                try (Connection conn = ds.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql);
                     ResultSet rs = ps.executeQuery()) {

                    boolean any = false;
                    while (rs.next()) { any = true; %>
        <li class="list-group-item d-flex justify-content-between align-items-center">
            <span><%= rs.getString("title") %></span>
            <small class="text-muted"><%= rs.getTimestamp("created_at") %></small>
        </li>
        <% }
            if (!any) { %>
        <li class="list-group-item text-muted">No offers available right now. Please check back later.</li>
        <% }
        }
        } catch (Exception e) { %>
        <div class="alert alert-danger mt-3">Error loading offers: <%= e.getMessage() %></div>
        <%
            }
        %>
    </ul>
</div>

</body>
</html>
