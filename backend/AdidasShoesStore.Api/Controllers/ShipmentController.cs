using System.Security.Claims;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AdidasShoesStore.Api.Controllers
{
    [Authorize]
    [ApiController]
    public class ShipmentController : ControllerBase
    {
        private readonly IShipmentService _shipmentService;

        public ShipmentController(IShipmentService shipmentService)
        {
            _shipmentService = shipmentService;
        }

        [HttpGet("api/orders/{orderId:int}/shipment")]
        public async Task<IActionResult> GetShipment(int orderId)
        {
            if (!TryGetUserId(out var userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            var shipment = await _shipmentService.GetUserShipmentAsync(userId, orderId);

            if (shipment == null)
            {
                return NotFound(new { message = "Shipment not found" });
            }

            return Ok(shipment);
        }

        [HttpGet("api/orders/{orderId:int}/tracking")]
        public async Task<IActionResult> GetTracking(int orderId)
        {
            if (!TryGetUserId(out var userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            var tracking = await _shipmentService.GetUserTrackingAsync(userId, orderId);

            if (tracking == null)
            {
                return NotFound(new { message = "Shipment not found" });
            }

            return Ok(tracking);
        }

        private bool TryGetUserId(out int userId)
        {
            var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            return int.TryParse(value, out userId);
        }
    }
}
