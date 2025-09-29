// src/main/java/movies/Seat.java
package movies;

public class Seat {
    private final int id;
    private final int movieId;
    private final String seatLabel;
    private boolean booked;

    public Seat(int id, int movieId, String seatLabel, boolean booked) {
        this.id = id;
        this.movieId = movieId;
        this.seatLabel = seatLabel;
        this.booked = booked;
    }
    public int getId() { return id; }
    public int getMovieId() { return movieId; }
    public String getSeatLabel() { return seatLabel; }
    public boolean isBooked() { return booked; }
    public void setBooked(boolean booked) { this.booked = booked; }
}
