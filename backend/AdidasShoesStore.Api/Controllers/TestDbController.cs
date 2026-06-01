using AdidasShoesStore.Api.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TestDbController : ControllerBase
{
    private readonly AdidasShoesStoreContext _context;

    public TestDbController(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new
        {
            connected = _context.Database.CanConnect()
        });
    }
}