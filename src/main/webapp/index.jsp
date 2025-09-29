<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Welcome to Movie World</title>

    <!-- Bootstrap -->
    <link rel="stylesheet"
          href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=Roboto&display=swap"
          rel="stylesheet">

    <!-- Speed up external image fetch -->
    <link rel="preconnect" href="https://images.unsplash.com" crossorigin>
    <!-- Preload a single, optimized variant so the browser caches it -->
    <link rel="preload" as="image"
          href="https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop"/>

    <style>
        :root {
            /* Use the same URL as the preload (one cached bitmap = faster) */
            --bg-url: url('https://images.unsplash.com/photo-1747144293265-fc806b5dbc29?w=1600&q=60&auto=format&fit=crop');
        }

        html, body {
            height: 100%;
            margin: 0;
            font-family: 'Roboto', sans-serif;
        }

        /* Fixed, GPU-pinned background layer to avoid any blink */
        .bg {
            position: fixed;
            inset: 0;
            z-index: -2;
            background-image: var(--bg-url);
            background-size: cover;
            background-position: 55% -80px; /* slightly right + up */
            background-repeat: no-repeat;

            /* keep it smooth on repaints */
            transform: translateZ(0);
            backface-visibility: hidden;
            will-change: transform;
        }
        /* soft overlay for readability */
        .bg::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(rgba(0,0,0,0.35), rgba(0,0,0,0.35));
        }

        body {
            /* fallback while first paint happens */
            background-color: #0b0b0b;

            display: flex;
            justify-content: center;
            align-items: center;
            text-align: center;
        }
        .content-wrapper {
            padding: 40px 60px;
            border-radius: 18px;
            background: rgba(0, 0, 0, 0.55);
            -webkit-backdrop-filter: blur(10px);
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.6);
            color: white;
            text-shadow: 2px 2px 6px rgba(0, 0, 0, 0.8);
            animation: fadeIn 1.2s ease;
        }
        .title {
            font-family: 'Playfair Display', serif;
            font-size: 64px;
            font-weight: bold;
            margin-bottom: 15px;
            animation: slideDown 1.2s ease;
        }
        .subtitle {
            font-size: 22px;
            margin-bottom: 30px;
            color: #f0f0f0;
            animation: fadeIn 1.6s ease;
        }
        .btn-custom {
            font-size: 20px;
            padding: 14px 36px;
            border-radius: 40px;
            border: none;
            color: white;
            background: linear-gradient(135deg, #ff6f61, #ff3d2e);
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        }
        .btn-custom:hover {
            background: linear-gradient(135deg, #ff3d2e, #ff6f61);
            transform: scale(1.05);
            box-shadow: 0 6px 18px rgba(0,0,0,0.5);
        }

        /* Animations */
        @keyframes fadeIn { from { opacity: 0; transform: scale(0.98);} to { opacity: 1; transform: scale(1);} }
        @keyframes slideDown { from { transform: translateY(-20px); opacity: 0;} to { transform: translateY(0); opacity: 1;} }

        /* Optional: if you want parallax on large screens only */
        @media (min-width: 1200px) {
            .bg { background-attachment: fixed; }
        }
    </style>
</head>
<body>

<!-- Fixed background layer (fast + no blink) -->
<div class="bg" aria-hidden="true"></div>

<div class="content-wrapper">
    <div class="title">🎬 Welcome to Movie World 🎥</div>
    <div class="subtitle">Explore the magic of cinema. Discover, manage, and enjoy movies like never before!</div>
    <a href="<%= request.getContextPath() %>/movieDisplay.jsp" class="btn btn-custom">Continue</a>
</div>

</body>
</html>
