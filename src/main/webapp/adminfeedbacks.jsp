<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, movies.Feedback" %>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Feedbacks</title>
    <meta charset="UTF-8">
    <link rel="stylesheet"
          href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <!-- Speed up background fetch -->
    <link rel="preconnect" href="https://images.unsplash.com" crossorigin>
    <link rel="preload" as="image"
          href="https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop"/>

    <style>
        :root {
            /* Same image as admin login */
            --bg-url: url('https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop');
        }

        html, body {
            height: 100%;
            margin: 0;
            font-family: 'Roboto', sans-serif;
            color: white;
            text-shadow: 1px 1px 4px rgba(0,0,0,0.7);
            background-color: #0b0b0b; /* fallback */
        }

        body {
            position: relative;
            z-index: 0;
            padding: 20px;
        }
        body::before {
            content: "";
            position: fixed;
            inset: 0;
            background-image: var(--bg-url);
            background-size: cover;
            background-position: 55% -80px;
            background-repeat: no-repeat;
            box-shadow: inset 0 0 0 100vmax rgba(0,0,0,0.35);
            z-index: -1;
        }

        .panel-box {
            background: rgba(0,0,0,0.65);
            padding: 30px;
            border-radius: 18px;
            backdrop-filter: blur(8px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.6);
            width: min(1000px, 95vw);
            margin: 40px auto;
        }
        table {
            color: white;
        }
        .thead-light th {
            color: #000;
        }
    </style>
</head>
<body>

<div class="panel-box">
    <h2 class="mb-4">📋 Customer Feedbacks</h2>

    <%
        String msg = request.getParameter("msg");
        if (msg != null && !msg.trim().isEmpty()) {
    %>
    <div class="alert alert-info"><%= msg %></div>
    <%
        }
        @SuppressWarnings("unchecked")
        List<Feedback> feedbacks = (List<Feedback>) request.getAttribute("feedbacks");
    %>

    <% if (feedbacks == null || feedbacks.isEmpty()) { %>
    <div class="alert alert-info">No feedbacks submitted yet.</div>
    <% } else { %>
    <div class="table-responsive">
        <table class="table table-bordered table-dark table-hover">
            <thead class="thead-light">
            <tr>
                <th>ID</th>
                <th>Created</th>
                <th>Name</th>
                <th>Email</th>
                <th>Description</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <% for (Feedback f : feedbacks) { %>
            <tr>
                <td><%= f.getId() %></td>
                <td><%= f.getCreatedAt() %></td>
                <td><%= f.getName() == null ? "" : f.getName() %></td>
                <td><%= f.getEmail() == null ? "" : f.getEmail() %></td>
                <td style="white-space: pre-wrap;"><%= f.getDescription() %></td>
                <td>
                    <form method="post" action="<%= request.getContextPath() %>/DeleteFeedbackServlet"
                          onsubmit="return confirm('Delete this feedback?');">
                        <input type="hidden" name="id" value="<%= f.getId() %>">
                        <button type="submit" class="btn btn-sm btn-danger">Delete</button>
                    </form>
                </td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>
    <% } %>

    <a href="<%= request.getContextPath() %>/adminPage.jsp"
       class="btn btn-secondary mt-3">← Back to Dashboard</a>
</div>

</body>
</html>
