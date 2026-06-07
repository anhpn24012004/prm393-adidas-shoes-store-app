namespace AdidasShoesStore.Api.DTOs.Reviews;

public class CreateReviewDto
{
    public int UserId { get; set; }
    public int ProductId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
}