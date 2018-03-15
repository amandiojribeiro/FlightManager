namespace Domain.Services
{
    using Application.DTO;
    using Domain.Model;
    using System.Collections.Generic;

    public interface IFlightDistanceCalculatorService
    {
        void CalculateDistances(List<FlightReportDto> flights, List<Airport> airportsList);
    }
}
