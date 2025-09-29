// src/main/java/movies/Booking.java
package movies;

import java.time.LocalDateTime;
import java.util.List;

public class Booking {
    private int id;
    private int movieId;
    private String movieTitle;
    private String customerName;
    private String customerEmail;
    private String customerPhone;    // NEW
    private LocalDateTime bookedAt;
    private List<String> seatLabels;

    public Booking(int id, int movieId, String movieTitle,
                   String customerName, String customerEmail, String customerPhone,
                   LocalDateTime bookedAt, List<String> seatLabels) {
        this.id = id;
        this.movieId = movieId;
        this.movieTitle = movieTitle;
        this.customerName = customerName;
        this.customerEmail = customerEmail;
        this.customerPhone = customerPhone;
        this.bookedAt = bookedAt;
        this.seatLabels = seatLabels;
    }

    public int getId() { return id; }
    public int getMovieId() { return movieId; }
    public String getMovieTitle() { return movieTitle; }
    public String getCustomerName() { return customerName; }
    public String getCustomerEmail() { return customerEmail; }
    public String getCustomerPhone() { return customerPhone; }
    public LocalDateTime getBookedAt() { return bookedAt; }
    public List<String> getSeatLabels() { return seatLabels; }
}
