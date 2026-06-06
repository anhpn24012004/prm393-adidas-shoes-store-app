using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AdidasShoesStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TestAuthController : ControllerBase
    {
        [HttpGet("customer")]
        [Authorize]
        public IActionResult Customer()
        {
            return Ok("Login success");
        }

        [HttpGet("admin")]
        [Authorize(Roles = "Admin")]
        public IActionResult Admin()
        {
            return Ok("Admin success");
        }
    }
}
