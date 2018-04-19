namespace Presentation.Api.Controllers
{
    using Application.Services.FlightService;
    using Microsoft.AspNetCore.Authorization;
    using Microsoft.AspNetCore.Mvc;
    using Presentation.Api.Filters;
    using System.Threading.Tasks;


    [Authorize]
    [Route("api/[controller]")]
    public class FlightReportsController : Controller
    {
        private readonly IFlightService flightService;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="flightService"></param>
        public FlightReportsController(IFlightService flightService)
        {
            this.flightService = flightService;
        }

        /// <summary>
        /// Generates a report with all the flights created
        /// </summary>
        /// <remarks>
        /// IMPORTANT - Weight and Balance are not included in this calculations!!!!!<br/>
        /// Rough estimation for 80% payload at 36000 ft with best weather possible, no taxi considerations, no legal reserves, no climbing rates, no Airline politics, no contingency<br/>
        /// This is not an accurate calculation!<br/>
        /// Medium consumption 10000 Lbs/Hour for Boeing 737-800<br/>
        /// Units for distance: Km<br/>
        /// Units for Fuel: Lbs<br/>
        /// Units for Time: Hours<br/>
        /// </remarks>
        /// <response code="200">List of json objects with flight report information</response>
        /// <response code="404">No Flights found</response>
        /// <response code="400">Bad Request</response>
        /// <response code="500">Internal Server Error</response>
        [ValidateForm]
        [HttpGet]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Get()
        {
            var result = await this.flightService.GetFlightReports();

            if (result != null)
            {
                return Ok(result);
            }

            return NotFound();
        }

    }
}
