<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javax.naming.InitialContext, javax.sql.DataSource" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Seat Selection</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="stylesheet"
          href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <style>
        :root { --bg-url: url('https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop'); }
        html, body { height: 100%; margin: 0; font-family: 'Roboto', Arial, sans-serif; }
        body { position: relative; color: #fff; background-color: #0b0b0b; min-height: 100%; overflow-x: hidden; padding-top: 84px; }
        body::before { content: ""; position: fixed; inset: 0; z-index: 0; background-image: var(--bg-url); background-size: cover;
            background-position: 55% -80px; background-repeat: no-repeat; box-shadow: inset 0 0 0 100vmax rgba(0,0,0,0.45); }
        .wrap { position: relative; z-index: 1; width: min(1100px, 94vw); margin: 0 auto 48px; }
        .screen { width: 100%; text-align: center; margin: 6px auto 18px; background: rgba(255,255,255,0.9); color: #111; font-weight: 900;
            letter-spacing: 3px; border-radius: 10px; padding: 10px 0; box-shadow: 0 8px 20px rgba(0,0,0,.4); }
        .panel { background: rgba(0,0,0,0.6); border-radius: 14px; padding: 14px; box-shadow: 0 8px 24px rgba(0,0,0,.45); }
        .seating { overflow-x: auto; }
        .seat-grid { display: grid; grid-auto-rows: minmax(40px, auto); gap: 8px; }
        .row-label, .col-label { display: grid; place-items: center; font-weight: 800; color: #fff; opacity: .9; }
        .col-label { background: rgba(0,0,0,0.5); border-radius: 8px; padding: 6px 0; }
        .row-label { background: rgba(0,0,0,0.5); border-radius: 8px; padding: 0 10px; }
        .seat { display: inline-flex; align-items: center; justify-content: center; border-radius: 8px; padding: 10px 0; font-weight: 800;
            user-select: none; cursor: pointer; color: #fff; box-shadow: 0 4px 12px rgba(0,0,0,.35); }
        .seat input { display: none; }
        .available { background: #2e7d32; }
        .available:hover { transform: translateY(-2px); }
        .booked { background: #8d8d8d; cursor: not-allowed; }
        .selected { outline: 3px solid #fff; }
        .aisle { display: grid; place-items: center; opacity: .3; }
        .legend .box { width: 18px; height: 18px; display: inline-block; margin-right: 6px; border-radius: 4px; }
    </style>
</head>
<body>
<div class="wrap">
    <a href="<%= request.getContextPath() %>/movieDisplay.jsp" class="btn btn-outline-light btn-sm mb-3">← Back to Movies</a>

    <%
        String err = request.getParameter("err");
        String msg = request.getParameter("msg");

        String bookingIdParam = request.getParameter("bookingId"); // may be null
        String movieTitle = "";
        int movieId = 0;

        int ROWS = 8, COLS = 12, AISLE_AFTER = 6;
        Map<String, Boolean> seatBooked = new HashMap<>();

        try {
            movieId = Integer.parseInt(request.getParameter("movieId"));
            DataSource ds = (DataSource) new InitialContext().lookup("java:comp/env/jdbc/MovieDB");

            // Movie title
            try (Connection conn = ds.getConnection();
                 PreparedStatement ps = conn.prepareStatement("SELECT title FROM movies WHERE id=?")) {
                ps.setInt(1, movieId);
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) movieTitle = rs.getString("title"); }
            }

            // Ensure seats exist; then fetch states
            try (Connection conn = ds.getConnection()) {
                try (PreparedStatement check = conn.prepareStatement("SELECT COUNT(*) FROM movie_seats WHERE movie_id=?")) {
                    check.setInt(1, movieId);
                    try (ResultSet rs = check.executeQuery()) {
                        if (rs.next() && rs.getInt(1) == 0) {
                            try (PreparedStatement ins = conn.prepareStatement(
                                    "INSERT INTO movie_seats(movie_id, seat_label, booked) VALUES (?,?,0)")) {
                                for (int r = 0; r < ROWS; r++) {
                                    char rowChar = (char) ('A' + r);
                                    for (int c = 1; c <= COLS; c++) {
                                        ins.setInt(1, movieId);
                                        ins.setString(2, rowChar + String.valueOf(c));
                                        ins.addBatch();
                                    }
                                }
                                ins.executeBatch();
                            }
                        }
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT seat_label, booked FROM movie_seats WHERE movie_id=?")) {
                    ps.setInt(1, movieId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) seatBooked.put(rs.getString("seat_label"), rs.getBoolean("booked"));
                    }
                }
            }
        } catch (Exception e) {
    %>
    <div class="alert alert-danger">Error: <%= e.getMessage() %></div>
    <%
        }
    %>

    <div class="screen">SCREEN</div>

    <div class="d-flex justify-content-between align-items-center mb-2">
        <h3 class="m-0">Select Seats — <%= movieTitle %></h3>
        <div class="legend">
            <span class="box" style="background:#2e7d32;"></span> Available
            &nbsp;&nbsp;<span class="box" style="background:#8d8d8d;"></span> Booked
        </div>
    </div>

    <% if (err != null) { %><div class="alert alert-danger"><%= err %></div><% } %>
    <% if (msg != null) { %><div class="alert alert-success"><%= msg %></div><% } %>

    <!-- Quick row/column selector -->
    <div class="panel mb-3">
        <div class="form-inline">
            <label class="mr-2">Quick select:</label>
            <select id="rowPick" class="form-control mr-2">
                <% for (int r=0; r<ROWS; r++) { char ch=(char)('A'+r); %>
                <option value="<%= ch %>"><%= ch %></option>
                <% } %>
            </select>
            <input id="colPick" type="number" min="1" max="<%= COLS %>" value="1" class="form-control mr-2" style="width:100px;">
            <button id="addSeatBtn" type="button" class="btn btn-success">Add Seat</button>
            <small class="ml-3 text-light-50">Example: Row <b>A</b> & Column <b>5</b> → selects seat <b>A5</b> if available</small>
        </div>
    </div>

    <form id="confirmForm" method="post" action="<%= request.getContextPath() %>/BookSeatsServlet">
        <input type="hidden" name="movieId" value="<%= movieId %>"/>

        <div class="panel seating">
            <div class="seat-grid" style="grid-template-columns:
                    50px repeat(<%= AISLE_AFTER %>, 1fr) 24px repeat(<%= COLS - AISLE_AFTER %>, 1fr);">
                <div></div>
                <% for (int c=1; c<=AISLE_AFTER; c++) { %><div class="col-label"><%= c %></div><% } %>
                <div class="aisle">| |</div>
                <% for (int c=AISLE_AFTER+1; c<=COLS; c++) { %><div class="col-label"><%= c %></div><% } %>

                <%
                    for (int r=0; r<ROWS; r++) {
                        char rowChar = (char)('A' + r);
                %>
                <div class="row-label">Row <%= rowChar %></div>
                <% for (int c=1; c<=AISLE_AFTER; c++) {
                    String label = rowChar + String.valueOf(c);
                    boolean booked = Boolean.TRUE.equals(seatBooked.get(label)); %>
                <label class="seat <%= booked ? "booked" : "available" %>" data-seat="<%= label %>">
                    <input type="checkbox" name="seats" value="<%= label %>" <%= booked ? "disabled" : "" %> />
                    <%= label %>
                </label>
                <% } %>
                <div class="aisle"></div>
                <% for (int c=AISLE_AFTER+1; c<=COLS; c++) {
                    String label = rowChar + String.valueOf(c);
                    boolean booked = Boolean.TRUE.equals(seatBooked.get(label)); %>
                <label class="seat <%= booked ? "booked" : "available" %>" data-seat="<%= label %>">
                    <input type="checkbox" name="seats" value="<%= label %>" <%= booked ? "disabled" : "" %> />
                    <%= label %>
                </label>
                <% } %>
                <% } %>
            </div>
        </div>

        <div class="panel mt-3 d-flex align-items-center justify-content-between">
            <button class="btn btn-success" type="submit">Confirm Booking</button>
            <button id="gotoDetailsBtn" type="button" class="btn btn-outline-light">Add Payment / Customer Details</button>
        </div>
    </form>

    <!-- Hidden form (kept for compatibility) -->
    <form id="detailsForm" method="post" action="<%= request.getContextPath() %>/customerPayment.jsp" style="display:none;">
        <input type="hidden" name="movieId" value="<%= movieId %>">
        <input type="hidden" id="bookingIdHidden" name="bookingId" value="<%= bookingIdParam != null ? bookingIdParam : "" %>">
        <div id="detailsSeatsHolder"></div>
    </form>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function(){

        // Toggle selection by clicking the label
        document.querySelectorAll('.seat.available').forEach(function(seatEl){
            seatEl.addEventListener('click', function(e){
                const chk = seatEl.querySelector('input[type="checkbox"]');
                if (!chk || chk.disabled) return;
                e.preventDefault();
                chk.checked = !chk.checked;
                seatEl.classList.toggle('selected', chk.checked);
            });
        });

        // Quick selector helper
        var addBtn = document.getElementById('addSeatBtn');
        if (addBtn) addBtn.addEventListener('click', function(){
            var row = document.getElementById('rowPick').value;
            var col = parseInt(document.getElementById('colPick').value, 10);
            if (!row || isNaN(col)) return;
            var label = row + String(col);
            var seat = document.querySelector('.seat[data-seat="'+label+'"]');
            if (!seat) { alert('Seat '+label+' not found.'); return; }
            if (seat.classList.contains('booked')) { alert('Seat '+label+' is already booked.'); return; }
            var chk = seat.querySelector('input[type="checkbox"]');
            if (chk && !chk.checked) { chk.checked = true; seat.classList.add('selected'); seat.scrollIntoView({behavior:'smooth', block:'center', inline:'center'}); }
        });

        // NEW: Go to details — prefer bookingId if present
        document.getElementById('gotoDetailsBtn').addEventListener('click', function () {
            var bookingId = '<%= bookingIdParam != null ? bookingIdParam : "" %>';
            if (bookingId && bookingId.trim().length > 0) {
                // Already confirmed; go with bookingId only
                var url = '<%= request.getContextPath() %>/customerPayment.jsp?bookingId=' + encodeURIComponent(bookingId);
                window.location.href = url;
                return;
            }

            // Not confirmed yet: fall back to seats CSV + movieId (optional)
            var checked = Array.from(document.querySelectorAll('input[name="seats"]:checked'));
            if (checked.length === 0) { alert('Please select at least one seat first, or Confirm Booking.'); return; }

            var seatsCsv = checked.map(function(c){ return encodeURIComponent(c.value); }).join(',');
            var url = '<%= request.getContextPath() %>/customerPayment.jsp'
                + '?movieId=<%= movieId %>'
                + '&seats=' + seatsCsv;
            window.location.href = url;
        });

    });
</script>
</body>
</html>
