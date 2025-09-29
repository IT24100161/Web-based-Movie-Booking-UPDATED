<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Feedback</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <link rel="preconnect" href="https://images.unsplash.com" crossorigin>
    <link rel="preload" as="image"
          href="https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop"/>

    <style>
        :root { --bg-url: url('https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop'); }
        html, body { height: 100%; margin: 0; font-family: 'Roboto', Arial, sans-serif; }
        body { position: relative; color: #fff; background-color: #0b0b0b; min-height: 100%; overflow-x: hidden; padding-top: 96px; }
        body::before {
            content: ""; position: fixed; inset: 0; z-index: 0;
            background-image: var(--bg-url); background-size: cover;
            background-position: 55% -80px; background-repeat: no-repeat;
            box-shadow: inset 0 0 0 100vmax rgba(0,0,0,0.35);
        }
        .nav-btns { position: fixed; top: 20px; left: 20px; display: flex; gap: 10px; z-index: 2; }
        .right-btn { position: fixed; top: 20px; right: 20px; z-index: 2; }
        .wrap { position: relative; z-index: 1; width: min(720px, 92vw); margin: 0 auto; }
        .panel { background: rgba(0,0,0,0.55); border-radius: 16px; padding: 24px;
            backdrop-filter: blur(8px); box-shadow: 0 8px 24px rgba(0,0,0,.45); }
        .header { text-align: center; margin-bottom: 18px; }
        .header h1 { font-size: 36px; font-weight: 800; text-shadow: 0 3px 10px rgba(0,0,0,.6); }
        label { font-weight: 700; }
        .form-control { border-radius: 10px; }
    </style>
</head>
<body>

<div class="nav-btns">
    <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-outline-light btn-sm">← Back</a>
    <a href="<%= request.getContextPath() %>/viewOffers.jsp" class="btn btn-info btn-sm">View Offers</a>
</div>
<div class="right-btn">
    <a href="<%= request.getContextPath() %>/adminLogin.jsp" class="btn btn-danger btn-sm">Admin Panel</a>
</div>

<div class="wrap">
    <div class="header">
        <h1>💬 We value your feedback</h1>
    </div>

    <div class="panel">
        <% String msg = request.getParameter("msg"); %>
        <% if (msg != null && !msg.trim().isEmpty()) { %>
        <div class="alert alert-success"><%= msg %></div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/AddFeedbackServlet">
            <div class="form-group">
                <label for="name">Name</label>
                <input id="name" name="name" class="form-control" maxlength="100" placeholder="Your name">
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input id="email" name="email" type="email" class="form-control" maxlength="150" placeholder="name@example.com">
            </div>
            <div class="form-group">
                <label for="description">Feedback (required)</label>
                <textarea id="description" name="description" rows="6" maxlength="4000"
                          class="form-control" placeholder="Type your feedback..." required></textarea>
            </div>
            <button type="submit" class="btn btn-primary btn-block">Submit Feedback</button>
        </form>
    </div>
</div>

</body>
</html>
