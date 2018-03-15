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
    [RoutePrefix("airports")]
    public class AirportController : ApiController
    {
        private readonly IFlightService flightService;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="flightService"></param>
        public AirportController(IFlightService flightService)
        {
            this.flightService = flightService;
        }

        /// <summary>
        /// Get's the list of all Airports
        /// </summary>
        /// <response code="200">Json with airport list</response>
        /// <response code="404">No Airports found</response>
        /// <response code="400">Bad Request</response>
        /// <response code="500">Internal Server Error</response>
        [HttpGet, Route(), ResponseType(typeof(List<AirportDto>))]
        public HttpResponseMessage GetAirportList()
        {
            var result = this.flightService.GetAirportList();
            if (result != null)
            {
                return Request.CreateResponse(System.Net.HttpStatusCode.OK, result);
            }

            return Request.CreateResponse(System.Net.HttpStatusCode.NotFound);
        }
    }
}
