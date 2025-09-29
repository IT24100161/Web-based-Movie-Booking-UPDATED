



<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String bookingId = request.getParameter("bookingId");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Payment Saved</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet"
          href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <!-- Preload background image -->
    <link rel="preconnect" href="https://images.unsplash.com" crossorigin>
    <link rel="preload" as="image"
          href="https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop"/>

    <style>
        :root {
            --bg-url: url('https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop');
        }
        html, body {
            height: 100%;
            margin: 0;
            font-family: 'Roboto', sans-serif;
            background-color: #0b0b0b; /* fallback */
        }
        body {
            position: relative;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            overflow-x: hidden;
            z-index: 0;
        }
        body::before {
            content: "";
            position: fixed;
            inset: 0;
            background-image: var(--bg-url);
            background-size: cover;
            background-position: 55% -80px;
            background-repeat: no-repeat;
            box-shadow: inset 0 0 0 100vmax rgba(0,0,0,0.45);
            z-index: -1;
            transform: translateZ(0);
        }
        .card {
            background: rgba(255,255,255,0.9);
            border-radius: 15px;
            backdrop-filter: blur(6px);
        }
        .btn-outline-light {
            border-color: #fff;
            color: #fff;
            transition: 0.3s;
        }
        .btn-outline-light:hover {
            background: #fff;
            color: #000;
        }
    </style>
</head>
<body>
<div class="container py-5">
    <div class="col-lg-6 mx-auto text-center">
        <div class="card shadow-lg">
            <div class="card-body text-dark">
                <h3 class="text-success">✅ Payment Saved Successfully</h3>
                <p>Your payment has been recorded for booking
                    <strong>#<%= bookingId %></strong>.
                </p>
                <a href="<%= request.getContextPath() %>/adminPage.jsp" class="btn btn-primary">Go to Admin</a>
                <a href="<%= request.getContextPath() %>/movieDisplay.jsp" class="btn btn-outline-secondary ml-2">Back to Movies</a>
            </div>
        </div>

        <!-- Feedback button -->
        <div class="mt-4">
            <a href="<%= request.getContextPath() %>/feedback.jsp" class="btn btn-outline-light btn-lg">
                💬 Leave Feedback
            </a>
        </div>
    </div>
</div>
</body>
</html>

