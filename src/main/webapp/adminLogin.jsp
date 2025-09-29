<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  // If already logged in, go to admin page
  if (session.getAttribute("adminUser") != null) {
    response.sendRedirect(request.getContextPath() + "/adminPage.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html>
<head>
  <title>Admin Login</title>
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
      /* Use the same URL as preload so the browser reuses one cached bitmap */
      --bg-url: url('https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop');
    }

    html, body {
      height: 100%;
      margin: 0;
      font-family: 'Roboto', sans-serif;
      color: white;
      text-shadow: 1px 1px 4px rgba(0,0,0,0.7);
      background-color: #0b0b0b; /* safe fallback */
    }

    /* ✅ Background on a fixed pseudo-element: fast, no blink */
    body {
      position: relative;      /* required for ::before stacking */
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 20px;
      overflow-x: hidden;
      z-index: 0;              /* create stacking context */
    }
    body::before {
      content: "";
      position: fixed;         /* stays put on scroll and during repaints */
      inset: 0;                /* top/right/bottom/left: 0 */
      background-image: var(--bg-url);
      background-size: cover;
      background-position: 55% -80px; /* same composition you liked */
      background-repeat: no-repeat;
      /* soft overlay for readability */
      box-shadow: inset 0 0 0 100vmax rgba(0,0,0,0.35);
      z-index: -1;             /* behind content */
      transform: translateZ(0);
      backface-visibility: hidden;
      will-change: transform;
    }

    .login-box {
      position: relative;      /* above background */
      z-index: 1;
      width: 100%;
      max-width: 420px;
      background: rgba(0,0,0,0.65);
      border-radius: 15px;
      padding: 30px;
      -webkit-backdrop-filter: blur(8px);
      backdrop-filter: blur(8px);
      box-shadow: 0 8px 30px rgba(0,0,0,0.6);
      color: white;
    }
    .form-control {
      background-color: rgba(255,255,255,0.85);
      border: none;
      color: #000;
      font-weight: bold;
    }
    .form-control:focus {
      box-shadow: 0 0 6px rgba(255, 111, 97, 0.8);
    }
    .btn-primary {
      background: linear-gradient(135deg, #ff6f61, #ff3d2e);
      border: none;
      font-weight: bold;
      transition: all 0.3s ease;
    }
    .btn-primary:hover {
      background: linear-gradient(135deg, #ff3d2e, #ff6f61);
      transform: scale(1.05);
      box-shadow: 0 4px 14px rgba(0,0,0,0.5);
    }
    a.small {
      color: #ffbfae;
      text-shadow: none;
    }
    a.small:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>

<div class="login-box">
  <h2 class="text-center mb-4">Admin Login</h2>

  <!-- Error message from query param -->
  <%
    String error = request.getParameter("error");
    if (error != null && !error.isEmpty()) {
  %>
  <div class="alert alert-danger" role="alert"><%= error %></div>
  <%
    }
  %>

  <!-- Login form -->
  <form action="<%= request.getContextPath() %>/AdminLoginServlet" method="post" class="mt-3">
    <div class="form-group">
      <label for="username">Username</label>
      <input id="username" name="username" class="form-control" required>
    </div>
    <div class="form-group">
      <label for="password">Password</label>
      <input id="password" name="password" type="password" class="form-control" required>
    </div>
    <button class="btn btn-primary btn-block">Login</button>
  </form>

  <div class="text-center mt-3">
    <a href="<%= request.getContextPath() %>/movieDisplay.jsp" class="small">← Back to Movies</a>
  </div>
</div>

</body>
</html>
