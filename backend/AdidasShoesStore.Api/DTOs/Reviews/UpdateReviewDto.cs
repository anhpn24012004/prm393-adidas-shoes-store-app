namespace AdidasShoesStore.Api.DTOs.Reviews;

public class UpdateReviewDto
{
    public int UserId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
}
