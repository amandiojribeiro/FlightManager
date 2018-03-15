namespace Presentation.Api.Controllers
{
    using Application.DTO;
    using Application.Services.FlightService;
    using System.Net.Http;
    using System.Web.Http;
    using System.Web.Http.Description;

    /// <summary>
    /// 
    /// </summary>
    [RoutePrefix("flights")]
    public class FlightController : ApiController
    {
        private readonly IFlightService flightService;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="flightService"></param>
        public FlightController(IFlightService flightService)
        {
            this.flightService = flightService;
        }

        /// <summary>
        /// This method is used for creating or updating flights
        /// </summary>
        /// <param name="request">Json with the flight information </param>
        /// <response code="200">Json with Flight created or updated</response>
        /// <response code="404">No flight found</response>
        /// <response code="400">Bad Request</response>
        /// <response code="500">Internal Server Error</response>
        [HttpPost, Route(""), ResponseType(typeof(FlightDto))]
        public HttpResponseMessage AddFlight(FlightDto request)
        {
            var result = this.flightService.SaveFlight(request);
            if (result != null)
            {
                return Request.CreateResponse(System.Net.HttpStatusCode.OK, result);
            }

            return Request.CreateResponse(System.Net.HttpStatusCode.NotFound);
        }

        /// <summary>
        /// Get's a flight by name
        /// </summary>
        /// <param name="name">The name of the flight</param>
        /// <response code="200">Json with flight information</response>
        /// <response code="404">No Flight found</response>
        /// <response code="400">Bad Request</response>
        /// <response code="500">Internal Server Error</response>
        [HttpGet, Route("{name}"), ResponseType(typeof(FlightDto))]
        public HttpResponseMessage GetFlightByName(string name)
        {
            var result = this.flightService.GetFlight(name);
            if (result != null)
            {
                return Request.CreateResponse(System.Net.HttpStatusCode.OK, result);
            }

            return Request.CreateResponse(System.Net.HttpStatusCode.NotFound);
        }
    }
}
