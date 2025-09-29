package movies;

public class Movie {
    private int id;
    private String title;

    public Movie(int id, String title) {
        this.id = id;
        this.title = title;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; } // optional

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; } // optional

    @Override
    public String toString() {
        return title; // helpful for JSP loops
    }
}
