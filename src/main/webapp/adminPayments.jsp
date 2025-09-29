<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, movies.PaymentDAO, movies.PaymentView" %>
<%@ page import="javax.naming.InitialContext, javax.sql.DataSource" %>
<%
  // Lookup datasource
  DataSource ds = (DataSource) new InitialContext().lookup("java:comp/env/jdbc/MovieDB");
  PaymentDAO dao = new PaymentDAO(ds);

  // Optional filters (from query params)
  String filterBookingId = request.getParameter("bookingId");
  String filterPhone     = request.getParameter("phone");
  String filterMethod    = request.getParameter("method");

  Long bookingId = null;
  if (filterBookingId != null && !filterBookingId.trim().isEmpty()) {
    try { bookingId = Long.parseLong(filterBookingId); } catch (NumberFormatException ignore) {}
  }

  List<PaymentView> payments = dao.listPayments(bookingId, filterPhone, filterMethod);
%>
<!DOCTYPE html>
<html>
<head>
  <title>Admin - Payments</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet"
        href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

  <!-- Preload background -->
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
    }
    body {
      position: relative;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      justify-content: flex-start;
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
    }
    .card, .table {
      background: rgba(0,0,0,0.75);
      color: #fff;
      border-radius: 12px;
      backdrop-filter: blur(6px);
    }
    .table td, .table th {
      vertical-align: middle;
    }
  </style>
</head>
<body>
<div class="container py-4">
  <div class="card shadow-lg p-4">
    <h2 class="mb-4 text-center">💳 Payment Records</h2>

    <!-- Alerts -->
    <% if (request.getParameter("deleted") != null) { %>
    <div class="alert alert-success">Payment deleted successfully.</div>
    <% } %>
    <% if (request.getParameter("error") != null) { %>
    <div class="alert alert-danger"><%= request.getParameter("error") %></div>
    <% } %>

    <!-- Filters -->
    <form class="form-inline mb-3" method="get">
      <input type="text" name="bookingId" class="form-control mr-2 mb-2"
             placeholder="Booking ID"
             value="<%= (filterBookingId != null ? filterBookingId : "") %>">
      <input type="text" name="phone" class="form-control mr-2 mb-2"
             placeholder="Phone"
             value="<%= (filterPhone != null ? filterPhone : "") %>">
      <select name="method" class="form-control mr-2 mb-2">
        <option value="">All Methods</option>
        <option value="Cash"   <%= "Cash".equals(filterMethod) ? "selected" : "" %>>Cash</option>
        <option value="Card"   <%= "Card".equals(filterMethod) ? "selected" : "" %>>Card</option>
        <option value="Online" <%= "Online".equals(filterMethod) ? "selected" : "" %>>Online</option>
      </select>
      <button type="submit" class="btn btn-primary mb-2">Filter</button>
    </form>

    <!-- Payments Table -->
    <div class="table-responsive">
      <table class="table table-striped table-dark table-hover">
        <thead>
        <tr>
          <th>ID</th>
          <th>Booking</th>
          <th>Movie</th>
          <th>Seats</th>
          <th>Payer</th>
          <th>Phone</th>
          <th>Method</th>
          <th>Paid At</th>
          <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        <% for (PaymentView v : payments) { %>
        <tr>
          <td><%= v.getPaymentId() %></td>
          <td>#<%= v.getBookingId() %></td>
          <td><%= v.getMovieTitle() %></td>
          <td><%= v.getSeats() != null ? v.getSeats() : "" %></td>
          <td><%= v.getPayerName() %></td>
          <td><%= v.getPhone() %></td>
          <td><%= v.getMethod() %></td>
          <td><%= v.getPaidAt() %></td>
          <td>
            <form method="post" action="<%= request.getContextPath() %>/DeletePaymentServlet"
                  onsubmit="return confirm('Delete payment #<%= v.getPaymentId() %>? This cannot be undone.');">
              <input type="hidden" name="paymentId" value="<%= v.getPaymentId() %>"/>
              <button type="submit" class="btn btn-sm btn-danger">Delete</button>
            </form>
          </td>
        </tr>
        <% } %>
        <% if (payments.isEmpty()) { %>
        <tr><td colspan="9" class="text-center">No payments found.</td></tr>
        <% } %>
        </tbody>
      </table>
    </div>

    <!-- Back to Admin Dashboard -->
    <div class="mt-3 text-center">
      <a href="<%= request.getContextPath() %>/adminPage.jsp" class="btn btn-outline-light">← Back to Dashboard</a>
    </div>
  </div>
</div>
</body>
</html>
