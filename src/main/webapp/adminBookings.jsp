<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, movies.Booking" %>
<%
  // Protect admin page
  String adminUser = (String) session.getAttribute("adminUser");
  if (adminUser == null) {
    response.sendRedirect("adminLogin.jsp?error=Please+login");
    return;
  }
  List<Booking> bookings = (List<Booking>) request.getAttribute("bookings");
%>
<!DOCTYPE html>
<html>
<head>
  <title>Admin - View Bookings</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Bootstrap -->
  <link rel="stylesheet"
        href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

  <style>
    html, body { height: 100%; margin: 0; font-family: 'Roboto', Arial, sans-serif; }
    body {
      /* Background image with dark overlay for readability */
      background:
              linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
              url('https://media.istockphoto.com/id/1779743996/photo/dark-movie-theatre-interior-with-screen-and-chairs.jpg?s=2048x2048&w=is&k=20&c=Gx7BFv9vuqNwJW18M6At4XNISn1_lbr9DT6WTIEoUJg=')
              center / cover no-repeat fixed;
      color: #fff;
    }
    .wrap {
      max-width: 1100px;
      margin: 40px auto;
      padding: 20px;
      background: rgba(0,0,0,0.80);
      border-radius: 16px;
      box-shadow: 0 12px 28px rgba(0,0,0,.55);
    }
    h2 {
      font-weight: 800;
      text-align: center;
      text-shadow: 0 3px 12px rgba(0,0,0,.6);
    }
    .actions-col { width: 120px; }
    .table { background: #fff; color: #111; border-radius: 12px; overflow: hidden; }
    thead th { background: #212529; color: #fff; border: none; }
    .top-bar {
      display: flex; align-items: center; justify-content: space-between;
      margin-bottom: 16px;
    }
  </style>
</head>
<body>

<div class="wrap">
  <div class="top-bar">
    <!-- ✅ Back to Admin Panel button (kept) -->
    <a href="<%= request.getContextPath() %>/adminPage.jsp"
       class="btn btn-outline-light btn-sm">← Back to Admin Panel</a>

    <h2 class="m-0">🎬 Bookings</h2>

    <!-- spacer to balance flex layout -->
    <span></span>
  </div>

  <% String err = request.getParameter("err"); String msg = request.getParameter("msg"); %>
  <% if (err != null) { %>
  <div class="alert alert-danger"><%= err %></div>
  <% } %>
  <% if (msg != null) { %>
  <div class="alert alert-success"><%= msg %></div>
  <% } %>

  <% if (bookings == null || bookings.isEmpty()) { %>
  <div class="alert alert-info">No bookings found.</div>
  <% } else { %>
  <div class="table-responsive">
    <table class="table table-striped table-hover">
      <thead>
      <tr>
        <th>ID</th>
        <th>Movie</th>
        <th>Customer</th>
        <th>Email</th>
        <th>Seats</th>
        <th>Booked At</th>
        <th class="actions-col">Actions</th>
      </tr>
      </thead>
      <tbody>
      <% for (Booking b : bookings) { %>
      <tr>
        <td><%= b.getId() %></td>
        <td><%= b.getMovieTitle() %></td>
        <td><%= b.getCustomerName() == null ? "-" : b.getCustomerName() %></td>
        <td><%= b.getCustomerEmail() == null ? "-" : b.getCustomerEmail() %></td>
        <td><%= String.join(", ", b.getSeatLabels()) %></td>
        <td><%= b.getBookedAt() == null ? "-" : b.getBookedAt() %></td>
        <td>
          <form method="post"
                action="<%= request.getContextPath() %>/DeleteBookingServlet"
                onsubmit="return confirm('Delete booking #<%= b.getId() %> and free its seats?');"
                style="margin:0;">
            <input type="hidden" name="bookingId" value="<%= b.getId() %>">
            <button type="submit" class="btn btn-sm btn-danger">Delete</button>
          </form>
        </td>
      </tr>
      <% } %>
      </tbody>
    </table>
  </div>
  <% } %>
</div>

</body>
</html>
