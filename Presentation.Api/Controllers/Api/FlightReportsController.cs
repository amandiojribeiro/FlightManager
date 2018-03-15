namespace Presentation.Api.Controllers
{
    using Application.DTO;
    using Application.Services.FlightService;
    using System.Collections.Generic;
    using System.Net.Http;
    using System.Web.Http;
    using System.Web.Http.Description;

    /// <summary>
    /// 
    /// </summary>
    [RoutePrefix("flightReports")]
    public class FlightReportsController : ApiController
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
        [HttpGet, Route(), ResponseType(typeof(List<FlightReportDto>))]
        public HttpResponseMessage GetFlightReports()
        {
            var result = this.flightService.GetFlightReports();
            if (result != null)
            {
                return Request.CreateResponse(System.Net.HttpStatusCode.OK, result);
            }

            return Request.CreateResponse(System.Net.HttpStatusCode.NotFound);
        }
    }
}
