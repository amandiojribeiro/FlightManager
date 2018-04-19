namespace Application.Services.FlightService
{
    using Application.Dto;
    using System.Collections.Generic;
    using System.Threading.Tasks;

    public interface IFlightService
    {
        Task<FlightDto> SaveFlight(FlightDto flight);

        Task<FlightDto> GetFlight(string name);

        Task<IEnumerable<FlightDto>> GetFlights();

        Task<IEnumerable<AirportDto>> GetAirportList();

        Task<IEnumerable<FlightReportDto>> GetFlightReports();
    }
}
