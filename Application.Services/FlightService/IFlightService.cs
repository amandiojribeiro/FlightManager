namespace Application.Services.FlightService
{
    using Application.DTO;
    using System.Collections.Generic;

    public interface IFlightService
    {
        FlightDto SaveFlight(FlightDto flight);

        FlightDto GetFlight(string name);

        IEnumerable<FlightDto> GetFlights();

        IEnumerable<AirportDto> GetAirportList();

        IEnumerable<FlightReportDto> GetFlightReports();
    }
}
