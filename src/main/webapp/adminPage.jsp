<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String adminUser = (String) session.getAttribute("adminUser");
  if (adminUser == null) {
    response.sendRedirect(request.getContextPath() + "/adminLogin.jsp?error=Please+login");
    return;
  }
%>
<!DOCTYPE html>
<html>
<head>
  <title>Admin Panel</title>
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
    :root {
      --bg-url: url('https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop');
    }
    html, body {
      height: 100%;
      margin: 0;
      font-family: 'Roboto', sans-serif;
      color: white;
      text-shadow: 1px 1px 4px rgba(0,0,0,0.7);
      background-color: #0b0b0b;
    }
    body {
      position: relative;
      display: flex;
      justify-content: center;
      align-items: center;
      text-align: center;
      min-height: 100%;
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
      box-shadow: inset 0 0 0 100vmax rgba(0,0,0,0.35);
      z-index: -1;
      transform: translateZ(0);
      backface-visibility: hidden;
      will-change: transform;
    }
    .panel-box {
      position: relative;
      z-index: 1;
      background: rgba(0,0,0,0.65);
      padding: 40px 36px;
      border-radius: 18px;
      -webkit-backdrop-filter: blur(8px);
      backdrop-filter: blur(8px);
      box-shadow: 0 8px 32px rgba(0,0,0,0.6);
      width: min(900px, 92vw);
    }
    .btn {
      font-weight: bold;
      padding: 12px 24px;
      border-radius: 40px;
      transition: all 0.25s ease;
      min-width: 220px;
    }
    .btn-success:hover   { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,255,100,0.45); }
    .btn-primary:hover   { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(0,100,255,0.45); }
    .btn-warning:hover   { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(255,200,0,0.5); }
    .btn-danger:hover    { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(255,0,0,0.5); }
    .btn-secondary:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(200,200,200,0.45); }
    hr { border-top: 2px solid rgba(255,255,255,0.6); }
  </style>
</head>
<body>

<div class="panel-box text-center">
  <h1 class="mb-1">🎬 Welcome, <%= adminUser %></h1>
  <p class="mb-3 text-light">Use the actions below to manage movies, offers, bookings, and payments.</p>
  <hr class="mb-4">

  <!-- Button grid -->
  <div class="d-flex flex-wrap justify-content-center">
    <!-- Add Movie -->
    <a href="<%= request.getContextPath() %>/addMovie.jsp"
       class="btn btn-success m-2">Add Movie</a>

    <!-- Add Offer -->
    <a href="<%= request.getContextPath() %>/addOffer.jsp"
       class="btn btn-warning m-2">Add Offer</a>

    <!-- View Bookings -->
    <a href="<%= request.getContextPath() %>/AdminBookingsServlet"
       class="btn btn-primary m-2">View Bookings</a>

    <!-- View Payment Details -->
    <a href="<%= request.getContextPath() %>/admin/payments"
       class="btn btn-info m-2">View Payment Details</a>

    <!-- ✅ View Feedbacks -->
    <a href="<%= request.getContextPath() %>/AdminFeedbacksServlet"
       class="btn btn-secondary m-2">View Feedbacks</a>

    <!-- Update Admin Password -->
    <a href="<%= request.getContextPath() %>/changeAdminPassword.jsp"
       class="btn btn-secondary m-2">Update Admin Password</a>

    <!-- Logout -->
    <a href="<%= request.getContextPath() %>/LogoutServlet"
       class="btn btn-danger m-2">Logout</a>
  </div>
</div>

</body>
</html>
