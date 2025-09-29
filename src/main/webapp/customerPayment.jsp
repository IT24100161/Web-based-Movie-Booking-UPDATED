<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.naming.InitialContext, javax.sql.DataSource" %>
<%@ page import="java.sql.*" %>
<%
  request.setCharacterEncoding("UTF-8");
  String bookingId = request.getParameter("bookingId");   // preferred path
  String movieId = request.getParameter("movieId");       // fallback
  String seatsCsv = request.getParameter("seats");        // fallback

  String resolvedSeats = "";
  String resolvedMovieTitle = "";
  String resolvedBookingId = (bookingId != null) ? bookingId : "";

  try {
    DataSource ds = (DataSource) new InitialContext().lookup("java:comp/env/jdbc/MovieDB");
    if (bookingId != null && !bookingId.isEmpty()) {
      try (Connection conn = ds.getConnection();
           PreparedStatement ps = conn.prepareStatement(
                   "SELECT b.seats, m.title FROM bookings b JOIN movies m ON b.movie_id=m.id WHERE b.id=?")) {
        ps.setLong(1, Long.parseLong(bookingId));
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) {
            resolvedSeats = rs.getString("seats");
            resolvedMovieTitle = rs.getString("title");
          }
        }
      }
    } else if (movieId != null && seatsCsv != null) {
      try (Connection conn = ds.getConnection();
           PreparedStatement ps = conn.prepareStatement("SELECT title FROM movies WHERE id=?")) {
        ps.setInt(1, Integer.parseInt(movieId));
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) resolvedMovieTitle = rs.getString("title");
        }
      }
      resolvedSeats = seatsCsv;
    }
  } catch (Exception ex) {
    // ignore; show minimal page
  }
%>
<!DOCTYPE html>
<html>
<head>
  <title>Customer & Payment Details</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

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
      background-color: #0b0b0b; /* fallback */
    }
    body {
      position: relative;
      display: flex;
      justify-content: center;
      align-items: flex-start;
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
      box-shadow: inset 0 0 0 100vmax rgba(0,0,0,0.4);
      z-index: -1;
      transform: translateZ(0);
      will-change: transform;
    }
    .card {
      background: rgba(255,255,255,0.9);
      border-radius: 15px;
      backdrop-filter: blur(6px);
    }
  </style>
</head>
<body>
<div class="container py-5">
  <div class="col-lg-7 mx-auto">
    <div class="card shadow-lg">
      <div class="card-header bg-primary text-white">
        <h4 class="mb-0">Add Payment / Customer Details</h4>
      </div>
      <div class="card-body text-dark">
        <% if (resolvedMovieTitle != null && !resolvedMovieTitle.isEmpty()) { %>
        <div class="alert alert-info">
          <strong>Movie:</strong> <%= resolvedMovieTitle %><br>
          <strong>Seats:</strong> <%= (resolvedSeats != null ? resolvedSeats : "") %>
        </div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/PaymentDetailsServlet">
          <% if (resolvedBookingId != null && !resolvedBookingId.isEmpty()) { %>
          <input type="hidden" name="bookingId" value="<%= resolvedBookingId %>">
          <% } else { %>
          <input type="hidden" name="movieId" value="<%= movieId != null ? movieId : "" %>">
          <input type="hidden" name="seats" value="<%= seatsCsv != null ? seatsCsv : "" %>">
          <% } %>

          <div class="mb-3">
            <label class="form-label">Full Name</label>
            <input type="text" name="payer_name" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Phone Number</label>
            <input type="text" name="phone" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Payment Method</label>
            <select name="method" class="form-control" required>
              <option value="" disabled selected>Select a method</option>
              <option value="Cash">Cash</option>
              <option value="Card">Card</option>
              <option value="Online">Online</option>
            </select>
          </div>

          <div class="d-flex justify-content-between">
            <a href="<%= request.getContextPath() %>/seating.jsp?movieId=<%= movieId != null ? movieId : "" %><%= (resolvedBookingId!=null && !resolvedBookingId.isEmpty()) ? ("&bookingId=" + resolvedBookingId) : "" %>" class="btn btn-outline-secondary">Back</a>
            <button type="submit" class="btn btn-success">Save Payment</button>
          </div>
        </form>
      </div>
      <div class="card-footer bg-light">
        <% if (resolvedBookingId != null && !resolvedBookingId.isEmpty()) { %>
        <small>Booking ID: <%= resolvedBookingId %></small>
        <% } %>
      </div>
    </div>
  </div>
</div>
</body>
</html>
