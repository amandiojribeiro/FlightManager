namespace Presentation.Api.Controllers
{
    using System.Threading.Tasks;
    using Microsoft.AspNetCore.Mvc;
    using Application.Services.FlightService;


    [Route("api/[controller]")]
    public class AirportController : Controller
    {
        private readonly IFlightService flightService;

        public AirportController(IFlightService flightService)
        {
            this.flightService = flightService;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var result = await this.flightService.GetAirportList();
            if (result != null)
            {
                return Ok(result);
            }

            return NotFound();
        }
    }
}
