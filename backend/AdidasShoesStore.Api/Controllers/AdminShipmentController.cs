using AdidasShoesStore.Api.DTOs.Shipments;
using AdidasShoesStore.Api.Services.Interfaces;
using AdidasShoesStore.Api.Settings;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace AdidasShoesStore.Api.Controllers
{
    [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("api/admin/shipments")]
    public class AdminShipmentController : ControllerBase
    {
        private readonly IShipmentService _shipmentService;
        private readonly ShipmentSettings _shipmentSettings;

        public AdminShipmentController(
            IShipmentService shipmentService,
            IOptions<ShipmentSettings> shipmentOptions)
        {
            _shipmentService = shipmentService;
            _shipmentSettings = shipmentOptions.Value;
        }

        [HttpGet]
        public async Task<IActionResult> GetShipments()
        {
            var shipments = await _shipmentService.GetAdminShipmentsAsync();

            return Ok(shipments);
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetShipment(int id)
        {
            var shipment = await _shipmentService.GetAdminShipmentAsync(id);

            if (shipment == null)
            {
                return NotFound(new { message = "Shipment not found" });
            }

            return Ok(shipment);
        }

        [HttpPost]
        public async Task<IActionResult> CreateShipment(CreateShipmentDto dto)
        {
            var result = await _shipmentService.CreateShipmentAsync(dto);

            if (!result.Success)
            {
                if (result.ErrorType == "NotFound")
                {
                    return NotFound(new { message = result.Error });
                }

                return BadRequest(new { message = result.Error });
            }

            return CreatedAtAction(
                nameof(GetShipment),
                new { id = result.Data!.ShipmentId },
                result.Data
            );
        }

        [HttpPut("{id:int}/status")]
        public async Task<IActionResult> UpdateStatus(
            int id,
            UpdateShipmentStatusDto dto)
        {
            if (!_shipmentSettings.ManualOverrideEnabled)
            {
                return StatusCode(
                    StatusCodes.Status403Forbidden,
                    new { message = "Manual shipment status override is disabled" }
                );
            }

            var result = await _shipmentService.UpdateShipmentStatusAsync(id, dto);

            if (!result.Success)
            {
                if (result.ErrorType == "NotFound")
                {
                    return NotFound(new { message = result.Error });
                }

                return BadRequest(new { message = result.Error });
            }

            return Ok(result.Data);
        }

        [HttpPut("{id:int}/tracking-info")]
        public async Task<IActionResult> UpdateTrackingInfo(
            int id,
            UpdateTrackingInfoDto dto)
        {
            var result = await _shipmentService.UpdateTrackingInfoAsync(id, dto);

            if (!result.Success)
            {
                if (result.ErrorType == "NotFound")
                {
                    return NotFound(new { message = result.Error });
                }

                return BadRequest(new { message = result.Error });
            }

            return Ok(result.Data);
        }

        [HttpPost("{id:int}/sync-ghn-status")]
        public async Task<IActionResult> SyncGhnStatus(int id)
        {
            var result = await _shipmentService.SyncGhnStatusAsync(id);

            if (!result.Success)
            {
                if (result.ErrorType == "NotFound")
                {
                    return NotFound(new { message = result.Error });
                }

                return BadRequest(new { message = result.Error });
            }

            return Ok(result.Data);
        }
    }
}
