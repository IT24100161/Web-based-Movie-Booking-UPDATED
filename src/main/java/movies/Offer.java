package movies;

import java.time.LocalDateTime;

public class Offer {
    private int id;
    private String title;
    private LocalDateTime createdAt;

    public Offer() {}

    public Offer(int id, String title, LocalDateTime createdAt) {
        this.id = id;
        this.title = title;
        this.createdAt = createdAt;
    }

    public Offer(String title) {
        this.title = title;
    }

    public int getId() { return id; }
    public String getTitle() { return title; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    public void setId(int id) { this.id = id; }
    public void setTitle(String title) { this.title = title; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() { return title; } // handy for JSPs
}
