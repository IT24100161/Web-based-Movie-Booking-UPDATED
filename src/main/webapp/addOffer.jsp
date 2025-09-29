<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.naming.InitialContext, javax.sql.DataSource" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add Offers (Admin)</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap -->
    <link rel="stylesheet"
          href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <!-- Speed up background fetch -->
    <link rel="preconnect" href="https://images.unsplash.com" crossorigin>
    <link rel="preload" as="image"
          href="https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop"/>

    <style>
        :root{
            /* Same URL as preload so the browser reuses a single cached bitmap */
            --bg-url: url('https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop');
        }

        html, body {
            height: 100%;
            margin: 0;
            font-family: 'Roboto', sans-serif;
            color: white;
            text-shadow: 1px 1px 4px rgba(0,0,0,0.7);
            background-color: #0b0b0b;  /* safe fallback during first paint */
        }

        /* ✅ Fast, no-blink background on a fixed pseudo-element */
        body {
            position: relative;   /* required for ::before stacking */
            min-height: 100%;
            overflow-x: hidden;
            z-index: 0;           /* create stacking context */
        }
        body::before{
            content:"";
            position: fixed;
            inset: 0;             /* top/right/bottom/left: 0 */
            background-image: var(--bg-url);
            background-size: cover;
            background-position: 55% -80px; /* slightly up + right */
            background-repeat: no-repeat;
            /* subtle overlay for readability */
            box-shadow: inset 0 0 0 100vmax rgba(0,0,0,0.35);
            z-index: -1;          /* behind content */
            transform: translateZ(0);
            backface-visibility: hidden;
            will-change: transform;
        }

        .container { padding-top: 24px; padding-bottom: 24px; }

        .glass-box {
            position: relative;   /* stay above background */
            z-index: 1;
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
        .thead-dark th { background-color: #343a40 !important; color: #fff; }
        .btn-outline-light.btn-sm { border-color: rgba(255,255,255,0.6); color:#fff; }
        .btn-outline-light.btn-sm:hover { background: rgba(255,255,255,0.15); }
    </style>
</head>
<body>

<div class="container">
    <div class="glass-box mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2 class="mb-0">Add Offer</h2>
            <a href="<%= request.getContextPath() %>/adminPage.jsp"
               class="btn btn-outline-light btn-sm">← Back to Admin Panel</a>
        </div>

        <!-- Flash messages (?msg / ?err) -->
        <%
            String msg = request.getParameter("msg");
            String err = request.getParameter("err");
            if (msg != null && !msg.isEmpty()) {
        %>
        <div class="alert alert-success"><%= msg %></div>
        <%
            }
            if (err != null && !err.isEmpty()) {
        %>
        <div class="alert alert-danger"><%= err %></div>
        <%
            }
        %>

        <!-- Add Offer Form -->
        <div class="card shadow-sm mb-4">
            <div class="card-body">
                <form action="<%= request.getContextPath() %>/AddOfferServlet" method="post">
                    <div class="form-group">
                        <label for="title">Offer Title</label>
                        <input type="text" id="title" name="title" class="form-control"
                               placeholder="e.g., 20% off popcorn" required>
                    </div>
                    <button type="submit" class="btn btn-primary">Add Offer</button>
                </form>
            </div>
        </div>

        <!-- Offers Table -->
        <h4 class="mb-3 text-white">Offers in Database</h4>

        <%
            try {
                DataSource ds = (DataSource) new InitialContext().lookup("java:comp/env/jdbc/MovieDB");
                String sql = "SELECT id, title, created_at FROM offers ORDER BY id DESC";
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
                    <th style="width:210px;">Created</th>
                    <th style="width:120px;">Action</th>
                </tr>
                </thead>
                <tbody>
                <%
                    boolean hasRows = false;
                    while (rs.next()) {
                        hasRows = true;
                %>
                <tr>
                    <td><%= rs.getInt("id") %></td>
                    <td><%= rs.getString("title") %></td>
                    <td><%= rs.getTimestamp("created_at") %></td>
                    <td>
                        <a href="<%= request.getContextPath() %>/DeleteOfferServlet?id=<%= rs.getInt("id") %>"
                           class="btn btn-danger btn-sm"
                           onclick="return confirm('Are you sure you want to delete this offer?');">Delete</a>
                    </td>
                </tr>
                <%
                    }
                    if (!hasRows) {
                %>
                <tr>
                    <td colspan="4" class="text-center text-muted">No offers added yet.</td>
                </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
        <%
            }
        } catch (Exception e) {
        %>
        <div class="alert alert-warning">Could not load offer list: <%= e.getMessage() %></div>
        <%
            }
        %>
    </div>
</div>

</body>
</html>
